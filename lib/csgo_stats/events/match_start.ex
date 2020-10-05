defmodule CsgoStats.Events.MatchStart do
  @type t() :: %__MODULE__{
          game_map: CsgoStats.Types.game_map(),
          timestamp: NaiveDateTime.t()
        }

  defstruct [:game_map, :timestamp]
end
