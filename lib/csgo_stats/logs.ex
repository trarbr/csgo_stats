defmodule CsgoStats.Logs do
  require Logger

  alias CsgoStats.Matches
  alias CsgoStats.Logs.{Entry, Parser}

  def process(data, metadata) do
    with {:ok, entry} <- Entry.new(data, metadata),
         true <- CsgoStats.Matches.started?(entry.server_instance_token) do
      :ok = log(entry.server_instance_token, data)
      events = do_parse(entry)
      :ok = Matches.update(entry.server_instance_token, events)
    else
      false ->
        CsgoStats.Matches.start(metadata.server_instance_token)
        Logger.info("unknown_match||#{metadata.server_instance_token}")
        :restart_log

      {:error, :invalid_metadata} = error ->
        Logger.warn([
          "invalid_metadata||",
          Jason.encode!(metadata),
          "||",
          String.replace(data, "\n", "|>")
        ])

        error
    end
  end

  defp do_parse(entry) do
    case Parser.parse(entry.lines) do
      {:ok, events} ->
        events

      {:error, _, unparsed} ->
        Logger.error(["event_error||", entry.lines, "||", unparsed])
        []
    end
  end

  def init() do
    File.mkdir_p!(log_dir())
  end

  defp log_dir() do
    Application.get_env(:csgo_stats, :log_dir, "/tmp/csgo_stats_logs/")
  end

  defp log(server_instance_token, data) do
    log_dir()
    |> Path.join(server_instance_token)
    |> File.write(data, [:append])
  end
end
