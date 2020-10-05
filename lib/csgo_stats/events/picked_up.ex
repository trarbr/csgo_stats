defmodule CsgoStats.Events.PickedUp do
  alias CsgoStats.Types

  @type t() :: %__MODULE__{
          player: Types.player(),
          item: Types.weapon() | Types.item(),
          timestamp: NaiveDateTime.t()
        }

  defstruct [:player, :item, :timestamp]
end
