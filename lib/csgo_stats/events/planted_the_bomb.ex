defmodule CsgoStats.Events.PlantedTheBomb do
  @type t() :: %__MODULE__{
          player: CsgoStats.Types.player(),
          timestamp: NaiveDateTime.t()
        }
  defstruct [:player, :timestamp]
end
