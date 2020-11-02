defmodule CsgoStats.Events.Assisted do
  alias CsgoStats.Types

  @type t() :: %__MODULE__{
          assistant: Types.player(),
          killed: Types.player(),
          timestamp: NaiveDateTime.t()
        }

  defstruct [:assistant, :killed, :timestamp]
end
