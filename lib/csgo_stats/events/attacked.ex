defmodule CsgoStats.Events.Attacked do
  alias CsgoStats.Types

  @type t() :: %__MODULE__{
          attacker: Types.player(),
          attacked: Types.player(),
          weapon: Types.weapon(),
          damage: integer(),
          damage_armor: integer(),
          health: integer(),
          armor: integer(),
          hitgroup: Types.hitgroup(),
          timestamp: NaiveDateTime.t()
        }

  defstruct [
    :attacker,
    :attacked,
    :weapon,
    :damage,
    :damage_armor,
    :health,
    :armor,
    :hitgroup,
    :timestamp
  ]
end
