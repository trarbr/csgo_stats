defmodule CsgoStats.Events.PlayerSwitchedTeam do
  alias CsgoStats.Types

  @type t() :: %__MODULE__{
          player: Types.player(),
          from: Types.team(),
          to: Types.team(),
          timestamp: NaiveDateTime.t()
        }

  defstruct [:player, :from, :to, :timestamp]
end
