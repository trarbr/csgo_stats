defmodule CsgoStats.Events.BeganBombDefuse do
  @type t() :: %__MODULE__{
          player: CsgoStats.Types.player(),
          kit: boolean(),
          timestamp: NaiveDateTime.t()
        }

  defstruct [:player, :kit, :timestamp]
end
