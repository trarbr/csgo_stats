defmodule CsgoStats.Logs.Parser.PlayerDisconnected do
  import NimbleParsec

  alias CsgoStats.Events

  # Example: "tbroedsgaard<12><STEAM_1:1:42376214><Unassigned>" disconnected (reason "Disconnect")
  def parser() do
    ignore(string(~s/ disconnected (reason "/))
    |> choice([string("Disconnect"), string("Kicked by Console")])
    |> ignore(string(~s/")/))
    |> reduce({__MODULE__, :cast, []})
  end

  def cast([reason]) do
    reason =
      case reason do
        "Disconnect" -> :disconnect
        "Kicked by Console" -> :kicked_by_console
      end

    %Events.PlayerDisconnected{reason: reason}
  end
end
