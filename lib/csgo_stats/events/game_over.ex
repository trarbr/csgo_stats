defmodule CsgoStats.Events.GameOver do
  alias CsgoStats.Types

  @type t() :: %__MODULE__{
          game_mode: Types.game_mode(),
          game_map: Types.game_map(),
          ct_score: integer(),
          t_score: integer(),
          duration: integer(),
          timestamp: NaiveDateTime.t()
        }

  defstruct [:game_mode, :game_map, :ct_score, :t_score, :duration, :timestamp]
end
