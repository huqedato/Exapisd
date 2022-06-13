defmodule Exapisd.WithFile do


  def js(file) do
    case file
         # |> Path.expand(__DIR__)
         |> File.read!()
         |> Jason.decode() do
      {:ok, res} -> return_file(res)
      {:error, _} -> {:error, 500, "Bad json"}
    end
  end

  def csv(file) do
    listoflist =
      file
      # |> Path.expand(__DIR__)
      |> File.read!()
      |> NimbleCSV.RFC4180.parse_string(skip_headers: false)
      |> Enum.into([])

    [h | t] = listoflist
    Enum.map(t, fn i -> Enum.zip(h, i) |> Map.new() end) |> return_file()
  end

  def sqlite(file) do
    {:ok, conn} = Exqlite.Sqlite3.open(file)

    {:ok, statement} =
      Exqlite.Sqlite3.prepare(conn, "SELECT name FROM sqlite_master WHERE type='table'")

    {:ok, columns} = Exqlite.Sqlite3.fetch_all(conn, statement)

    Enum.map(columns, fn x -> query(x, conn) end)
    |> then(fn row -> [List.flatten(columns), row] end)
    |> Enum.zip()
    |> Enum.into(Map.new())
    |> return_file()
  end

  defp query(table, conn) do
    q = "SELECT * FROM " <> to_string(table)
    {:ok, statement} = Exqlite.Sqlite3.prepare(conn, q)
    {:ok, columns} = Exqlite.Sqlite3.columns(conn, statement)
    {:ok, rows} = Exqlite.Sqlite3.fetch_all(conn, statement)
    Enum.map(rows, fn r -> Enum.zip(columns, r) |> Enum.into(Map.new()) end)
  end

  defp return_file(file) do
    {:file, file}
  end
end
