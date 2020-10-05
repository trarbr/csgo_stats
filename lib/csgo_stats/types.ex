defmodule CsgoStats.Types do
  @game_modes [:casual, :competitive]
  @type game_mode() :: unquote(@game_modes |> Enum.reverse() |> Enum.reduce(&{:|, [], [&1, &2]}))
  def game_modes(), do: @game_modes

  @teams [:ct, :terrorist, :unassigned, :spectator]
  @type team() :: unquote(@teams |> Enum.reverse() |> Enum.reduce(&{:|, [], [&1, &2]}))
  def teams(), do: @teams

  @game_maps [
    :de_cache,
    :de_vertigo,
    :de_dust2,
    :de_inferno,
    :de_mirage,
    :de_nuke,
    :de_overpass,
    :de_train
  ]
  @type game_map() :: unquote(@game_maps |> Enum.reverse() |> Enum.reduce(&{:|, [], [&1, &2]}))
  def game_maps(), do: @game_maps

  @win_conditions [
    :terrorists_win,
    :cts_win,
    :target_bombed,
    :bomb_defused,
    :target_saved
  ]
  @type win_condition() ::
          unquote(@win_conditions |> Enum.reverse() |> Enum.reduce(&{:|, [], [&1, &2]}))
  def win_conditions(), do: @win_conditions

  @type player() :: map()

  @pistols [
    :cz75a,
    :deagle,
    :elite,
    :glock,
    :hkp2000,
    :p250,
    :tec9,
    :usp_silencer
  ]

  @guns [
    :ak47,
    :aug,
    :awp,
    :bizon,
    :famas,
    :g3sg1,
    :galilar,
    :m249,
    :m4a1_silencer,
    :m4a1,
    :mac10,
    :mag7,
    :mp7,
    :mp9,
    :negev,
    :nova,
    :p90,
    :sawedoff,
    :scar20,
    :sg556,
    :ssg08,
    :ump45,
    :xm1014
  ]

  @grenades [
    :decoy,
    :flashbang,
    :hegrenade,
    :incgrenade,
    :inferno,
    :molotov,
    :smokegrenade
  ]
  @type grenade() :: unquote(@grenades |> Enum.reverse() |> Enum.reduce(&{:|, [], [&1, &2]}))
  def grenades(), do: @grenades

  @weapons [:knife_t, :knife, :taser] ++ @pistols ++ @guns ++ @grenades
  @type weapon() :: unquote(@weapons |> Enum.reverse() |> Enum.reduce(&{:|, [], [&1, &2]}))
  def weapons(), do: @weapons

  @items [:c4, :defuser, :vest, :vesthelm]
  @type item() :: unquote(@items |> Enum.reverse() |> Enum.reduce(&{:|, [], [&1, &2]}))
  def items(), do: @items

  @awards [:"3k", :hsp, :firstkills, :cashspent, :deaths, :mvps, :assists]
  @type award() :: unquote(@awards |> Enum.reverse() |> Enum.reduce(&{:|, [], [&1, &2]}))
  def awards() do
    @awards
  end

  @hitgroups [
    :chest,
    :generic,
    :head,
    :left_arm,
    :left_leg,
    :neck,
    :right_arm,
    :right_leg,
    :stomach
  ]
  @type hitgroup() :: unquote(@hitgroups |> Enum.reverse() |> Enum.reduce(&{:|, [], [&1, &2]}))
  def hitgroups(), do: @hitgroups

  @killables [:chicken, :func_breakable]
  @type killable() :: unquote(@killables |> Enum.reverse() |> Enum.reduce(&{:|, [], [&1, &2]}))
  def killables(), do: @killables

  @disconnect_reasons [:disconnect, :kicked_by_console, :server_shutting_down]
  @type disconnect_reason() ::
          unquote(@disconnect_reasons |> Enum.reverse() |> Enum.reduce(&{:|, [], [&1, &2]}))
  def disconnect_reasons(), do: @disconnect_reasons
end
