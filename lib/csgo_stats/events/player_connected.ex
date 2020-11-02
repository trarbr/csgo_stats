defmodule CsgoStats.Events.PlayerConnected do
  @type t() :: %__MODULE__{
          player: CsgoStats.Types.player(),
          address: String.t() | nil,
          timestamp: NaiveDateTime.t()
        }

  defstruct [:player, :address, :timestamp]
end
