defmodule CsgoStats.Logs.Parser.Attacked do
  import NimbleParsec

  alias CsgoStats.{Events, Types}
  alias CsgoStats.Logs.Parser

  # Example: "Niles<16><BOT><TERRORIST>" [123 616 72] attacked "Elmer<18><BOT><CT>" [932 550 88] with "glock" (damage "17") (damage_armor "0") (health "83") (armor "100") (hitgroup "right leg")
  def parser() do
    ignore(string(" "))
    |> ignore(Parser.Position.parser())
    |> ignore(string(" attacked "))
    |> concat(Parser.Player.parser())
    |> ignore(string(" "))
    |> ignore(Parser.Position.parser())
    |> ignore(string(" with "))
    |> concat(Parser.Weapon.parser())
    |> ignore(string(" "))
    |> concat(stat())
    |> ignore(string(" "))
    |> concat(stat())
    |> ignore(string(" "))
    |> concat(stat())
    |> ignore(string(" "))
    |> concat(stat())
    |> ignore(string(" "))
    |> concat(hitgroup())
    |> reduce({__MODULE__, :cast, []})
  end

  # Example: (hitgroup "right leg")
  defp hitgroup() do
    ignore(string(~s/(hitgroup "/))
    |> choice([
      string("chest"),
      string("generic"),
      string("head"),
      string("left arm"),
      string("left leg"),
      string("neck"),
      string("right arm"),
      string("right leg"),
      string("stomach")
    ])
    |> ignore(string(~s/")/))
  end

  @hitgroups Enum.map(Types.hitgroups(), fn hitgroup -> to_string(hitgroup) end)

  Enum.each(Types.hitgroups(), fn
    :left_arm ->
      defp cast_hitgroup("left arm"), do: :left_arm

    :left_leg ->
      defp cast_hitgroup("left leg"), do: :left_leg

    :right_arm ->
      defp cast_hitgroup("right arm"), do: :right_arm

    :right_leg ->
      defp cast_hitgroup("right leg"), do: :right_leg

    _hitgroup ->
      defp cast_hitgroup(hitgroup) when hitgroup in @hitgroups,
        do: String.to_existing_atom(hitgroup)
  end)

  # Example: (damage_armor "32")
  defp stat() do
    ignore(
      choice([
        string(~s/(damage_armor "/),
        string(~s/(damage "/),
        string(~s/(health "/),
        string(~s/(armor "/)
      ])
    )
    |> integer(min: 1)
    |> ignore(string(~s/")/))
  end

  def cast([
        attacked,
        weapon,
        damage,
        damage_armor,
        health,
        armor,
        hitgroup
      ]) do
    hitgroup = cast_hitgroup(hitgroup)

    %Events.Attacked{
      attacked: attacked,
      weapon: weapon,
      damage: damage,
      damage_armor: damage_armor,
      health: health,
      armor: armor,
      hitgroup: hitgroup
    }
  end
end
