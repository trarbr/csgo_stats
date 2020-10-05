defmodule CsgoStats.Events.PlayerDisconnected do
  @type t() :: %__MODULE__{
          player: CsgoStats.Types.player(),
          reason: :disconnect | :kicked_by_console | :server_shutting_down,
          timestamp: NaiveDateTime.t()
        }

  defstruct [:player, :reason, :timestamp]
end
