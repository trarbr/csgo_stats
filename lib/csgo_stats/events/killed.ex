defmodule CsgoStats.Events.Killed do
  alias CsgoStats.Types

  @type t() :: %__MODULE__{
          killer: Types.player(),
          killed: Types.player(),
          weapon: Types.weapon(),
          headshot: boolean(),
          penetrated: boolean(),
          timestamp: NaiveDateTime.t()
        }

  defstruct [:killer, :killed, :weapon, :headshot, :penetrated, :timestamp]
end
