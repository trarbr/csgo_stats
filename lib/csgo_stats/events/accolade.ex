defmodule CsgoStats.Events.Accolade do
  alias CsgoStats.Types

  @type t() :: %__MODULE__{
          award: Types.award(),
          player: Types.player(),
          value: float(),
          position: integer(),
          score: float(),
          timestamp: NaiveDateTime.t()
        }

  defstruct [:award, :player, :value, :position, :score, :timestamp]
end
