defmodule CsgoStats.Events.Attacked do
  defstruct [
    :attacker,
    :attacked,
    :weapon,
    :damage,
    :damage_armor,
    :health,
    :armor,
    :hitgroup
  ]
end
