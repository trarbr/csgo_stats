defmodule CsgoStats.Events.LeftBuyzone do
  alias CsgoStats.Types

  @type t() :: %__MODULE__{
          player: Types.player(),
          c4: boolean(),
          defuser: boolean(),
          helmet: boolean(),
          kevlar: integer(),
          weapons: list(Types.weapon()),
          timestamp: NaiveDateTime.t()
        }

  defstruct [:player, :c4, :defuser, :helmet, :kevlar, :weapons, :timestamp]
end
