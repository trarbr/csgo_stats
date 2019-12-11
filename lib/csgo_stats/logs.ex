defmodule CsgoStats.Logs do
  require Logger

  alias CsgoStats.Matches
  alias CsgoStats.Logs.{Entry, Parser}

  def process(data, metadata) do
    with {:ok, entry} <- Entry.new(data, metadata),
         true <- CsgoStats.Matches.started?(metadata.server_instance_token) do
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
    Enum.reduce(entry.lines, [], fn line, acc ->
      event_text = String.slice(line, 28..-1)

      case Parser.parse(event_text) do
        {:ok, %event_type{} = event} ->
          Logger.debug([
            "event_parsed||",
            Atom.to_string(event_type),
            "||",
            event |> Map.from_struct() |> Jason.encode!()
          ])

          [event | acc]

        {:ok, %event_type{} = event, leftovers} ->
          Logger.warn([
            "event_leftover||",
            Atom.to_string(event_type),
            "||",
            event |> Map.from_struct() |> Jason.encode!(),
            "||",
            leftovers
          ])

          [event | acc]

        {:error, _, unparsed} ->
          Logger.error(["event_error||", event_text, "||", unparsed])
          acc
      end
    end)
  end
end
