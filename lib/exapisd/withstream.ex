defmodule Exapisd.WithStream do
  alias NimbleCSV.RFC4180, as: CSV

  def csv_stream(file) do
    headers = headers(file)
    # headers |> IO.inspect(label: ~S[headers])

    file
    |> File.stream!()
    |> CSV.parse_stream(skip_headers: true)
    |> Stream.map(fn x -> Enum.zip(headers, x) |> Map.new() |> Jason.encode_to_iodata!() end)
    |> Stream.intersperse(",")
    |> Stream.chunk_every(2)
    |> return_stream()
  end

  defp headers(file) do
    file
    |> File.stream!()
    |> Stream.take(1)
    |> CSV.parse_stream(skip_headers: false)
    |> Enum.at(0)
  end

  def json_stream(file) do
    file
    |> File.stream!()
    |> Jaxon.Stream.from_enumerable()
    |> Jaxon.Stream.query([:root, :all])
    |> Stream.map(fn x -> x |> Jason.encode_to_iodata!() end)
    |> Stream.intersperse(",")
    |> Stream.chunk_every(2)
    |> return_stream()
  end

  def sqlite_stream(file) do
    {:ok, conn} = Exqlite.Sqlite3.open(file)

    {:ok, statement} =
      Exqlite.Sqlite3.prepare(conn, "SELECT name FROM sqlite_master WHERE type='table'")

    {:ok, columns} = Exqlite.Sqlite3.fetch_all(conn, statement)
    stream = []

    Stream.concat(stream, eachTable(stream, conn, columns))
    |> return_stream()
  end

  defp eachTable(stream, conn, [h | t]) do
    stream
    |> Stream.concat(["{\""])
    |> Stream.concat([h, "\":["])
    |> Stream.concat(
      query(h, conn)
      |> Stream.intersperse(",")
      |> Stream.chunk_every(2)
    )
    |> Stream.concat(["]}"])
    |> Stream.concat([","])
    |> eachTable(conn, t)
  end

  defp eachTable(stream, _, []) do
    stream
    |> Stream.drop(-1)

    # |> Stream.concat([""])
  end

  defp query(table, conn) do
    q = "SELECT * FROM " <> to_string(table)
    {:ok, statement} = Exqlite.Sqlite3.prepare(conn, q)
    {:ok, columns} = Exqlite.Sqlite3.columns(conn, statement)
    {:ok, rows} = Exqlite.Sqlite3.fetch_all(conn, statement, 10000)

    Stream.map(rows, fn r ->
      Enum.zip(columns, r) |> Enum.into(Map.new()) |> Jason.encode_to_iodata!()
    end)
  end

  defp return_stream(file) do
    {:stream, file}
  end
end
