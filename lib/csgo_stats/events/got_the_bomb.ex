defmodule CsgoStats.Events.GotTheBomb do
  @type t() :: %__MODULE__{
          player: CsgoStats.Types.player(),
          timestamp: NaiveDateTime.t()
        }
  defstruct [:player, :timestamp]
end
