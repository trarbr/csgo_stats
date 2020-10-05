defmodule CsgoStats.Events.MoneyChange do
  alias CsgoStats.Types

  @type t() :: %__MODULE__{
          player: Types.player(),
          previous: integer(),
          diff: integer(),
          result: integer(),
          purchase: Types.weapon() | Types.item() | nil,
          timestamp: NaiveDateTime.t()
        }

  defstruct [:player, :previous, :diff, :result, :purchase, :timestamp]
end
