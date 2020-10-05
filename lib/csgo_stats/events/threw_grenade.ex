defmodule CsgoStats.Events.ThrewGrenade do
  alias CsgoStats.Types

  @type t() :: %__MODULE__{
          player: Types.player(),
          item: Types.grenade(),
          timestamp: NaiveDateTime.t()
        }

  defstruct [:player, :item, :timestamp]
end
