defmodule Exapisd.Backend do
  # import Exapisd.Repo
  import Exapisd.WithFile
  import Exapisd.WithStream

  @root Application.get_env(:exapisd, :repo)
  @t Application.get_env(:exapisd, :switch_threshold) #in MB

  def path(url) do
    fullpath = Path.expand(@root <> url)
    if File.dir?(fullpath) do
      {:ok, files} = File.ls(fullpath)
      files(files, fullpath)
    else
      {:error, 404, "Path not found"}
    end
  end

  defp files(files, fullpath) do
    Enum.filter(files, fn f ->
      Path.extname(f) != "" &&
        Enum.member?([".csv", ".json", ".sqlite", ".db", ".sqlite3"], Path.extname(f))
    end)
    |> Enum.take(1)
    |> switchBySize(fullpath <> "/")
  end

  defp switchBySize([f], fullpath) do
    file = (fullpath <> f) |> Path.expand(__DIR__)

    case File.stat(file) do
      {:ok, %{size: size}} -> identify(file, size)
      {:error, reason} -> {:error, 500, reason}
    end
  end

  defp switchBySize([], _fullpath) do
    {:error, 404, "no file in the path"}
  end

  defp identify(file, size) when size < @t do
    case Path.extname(file) do
      ".json" -> js(file)
      ".csv" -> csv(file)
      ".db" -> sqlite(file)
      ".sqlite" -> sqlite(file)
      ".sqlite3" -> sqlite(file)
      _ -> {:error, 404, "No suitable file"}
    end
  end

  defp identify(file, size) when size >= @t do
    case Path.extname(file) do
      ".json" -> json_stream(file)
      ".csv" -> csv_stream(file)
      ".db" -> sqlite_stream(file)
      ".sqlite" -> sqlite_stream(file)
      ".sqlite3" -> sqlite_stream(file)
      _ -> {:error, 404, "No suitable file"}
    end
  end
end
