defmodule CsgoStats.Events.RoundEnd do
  @type t() :: %__MODULE__{timestamp: NaiveDateTime.t()}
  defstruct [:timestamp]
end
