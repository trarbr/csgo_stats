defmodule CsgoStats.Events.TeamWon do
  alias CsgoStats.Types

  @type t() :: %__MODULE__{
          team: :ct | :terrorist,
          win_condition: Types.win_condition(),
          ct_score: integer(),
          terrorist_score: integer(),
          timestamp: NaiveDateTime.t()
        }
  defstruct [:team, :win_condition, :ct_score, :terrorist_score, :timestamp]
end
