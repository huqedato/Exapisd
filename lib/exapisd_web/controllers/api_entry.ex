defmodule ExapisdWeb.Api do
  use ExapisdWeb, :controller

  def index(conn, %{"path" => path}) do
    joinPath = Enum.reduce(path, "", fn x, acc -> acc <> "/" <> x end) |> Exapisd.Backend.path()

    case joinPath do
      {:file, file} -> sendFile(conn, file)
      {:error, type, msg} -> sendError(conn, type, msg)
      {:stream, stream} -> sendStream(conn, stream)
    end
  end

  defp sendError(conn, type, msg) do
    conn
    |> send_resp(type, Jason.encode!(%{error: msg}))
    |> halt
  end

  defp sendFile(conn, file) do
    json(conn, file)
  end

  defp sendStream(conn, stream) do
    conn =
      put_resp_header(conn, "content-type", "application/json; charset=utf-8")
      |> send_chunked(200)

    send_stream_chunks(conn, stream)
  end

  defp send_stream_chunks(conn, stream) do
   {:ok, conn} = chunk(conn, "[")

    conn =
      Enum.reduce_while(stream, conn, fn chunk, conn ->
        case Plug.Conn.chunk(conn, chunk) do
          {:ok, conn} -> {:cont, conn}
          {:error, :closed} -> {:halt, conn}
        end
      end)

    {:ok, conn} = chunk(conn, "]")
    conn
  end
end
