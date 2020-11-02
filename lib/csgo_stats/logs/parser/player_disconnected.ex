defmodule CsgoStats.Logs.Parser.PlayerDisconnected do
  import NimbleParsec

  alias CsgoStats.{Events, Types}

  # Example: "tbroedsgaard<12><STEAM_1:1:42376214><Unassigned>" disconnected (reason "Disconnect")
  def parser() do
    ignore(string(~s/ disconnected (reason "/))
    |> choice([
      string("Disconnect"),
      string("Kicked by Console"),
      string("Server shutting down")
    ])
    |> ignore(string(~s/")/))
    |> reduce({__MODULE__, :cast, []})
  end

  Enum.each(Types.disconnect_reasons(), fn
    :disconnect -> defp cast_reason("Disconnect"), do: :disconnect
    :kicked_by_console -> defp cast_reason("Kicked by Console"), do: :kicked_by_console
    :server_shutting_down -> defp cast_reason("Server shutting down"), do: :server_shutting_down
  end)

  def cast([reason]) do
    reason = cast_reason(reason)
    %Events.PlayerDisconnected{reason: reason}
  end
end
