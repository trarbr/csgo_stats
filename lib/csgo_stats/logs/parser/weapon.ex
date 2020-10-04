defmodule CsgoStats.Logs.Parser.Weapon do
  import NimbleParsec

  @weapons [
    string("ak47"),
    string("aug"),
    string("awp"),
    string("bizon"),
    string("c4"),
    string("cz75a"),
    string("deagle"),
    string("decoy"),
    string("elite"),
    string("famas"),
    string("g3sg1"),
    string("galilar"),
    string("glock"),
    string("hkp2000"),
    string("knife_t"),
    string("knife"),
    string("m249"),
    string("m4a1_silencer"),
    string("m4a1"),
    string("mac10"),
    string("mag7"),
    string("molotov"),
    string("mp7"),
    string("mp9"),
    string("negev"),
    string("nova"),
    string("p250"),
    string("p90"),
    string("sawedoff"),
    string("scar20"),
    string("sg556"),
    string("ssg08"),
    string("taser"),
    string("tec9"),
    string("ump45"),
    string("usp_silencer"),
    string("xm1014")
  ]

  @grenades [
    string("smokegrenade"),
    string("flashbang"),
    string("incgrenade"),
    string("hegrenade"),
    string("inferno")
  ]

  # Example: "glock"
  def parser() do
    ignore(string(~s/"/))
    |> concat(weapon_name())
    |> ignore(string(~s/"/))
  end

  def weapon_name() do
    choice(@weapons ++ @grenades)
    |> reduce({__MODULE__, :cast, []})
  end

  def grenade_name() do
    choice(@grenades)
    |> reduce({__MODULE__, :cast, []})
  end

  def cast([weapon]) do
    case weapon do
      "ak47" -> :ak47
      "aug" -> :aug
      "awp" -> :awp
      "bizon" -> :bizon
      "c4" -> :c4
      "cz75a" -> :cz75a
      "deagle" -> :deagle
      "decoy" -> :decoy
      "elite" -> :elite
      "famas" -> :famas
      "flashbang" -> :flashbang
      "g3sg1" -> :g3sg1
      "galilar" -> :galilar
      "glock" -> :glock
      "hegrenade" -> :hegrenade
      "hkp2000" -> :hkp2000
      "incgrenade" -> :incgrenade
      "inferno" -> :inferno
      "knife" -> :knife
      "knife_t" -> :knife_t
      "m249" -> :m249
      "m4a1" -> :m4a1
      "m4a1_silencer" -> :m4a1_silencer
      "mac10" -> :mac10
      "mag7" -> :mag7
      "molotov" -> :molotov
      "mp7" -> :mp7
      "mp9" -> :mp9
      "negev" -> :negev
      "nova" -> :nova
      "p250" -> :p250
      "p90" -> :p90
      "sawedoff" -> :sawedoff
      "scar20" -> :scar20
      "sg556" -> :sg556
      "smokegrenade" -> :smokegrenade
      "ssg08" -> :ssg08
      "taser" -> :taser
      "tec9" -> :tec9
      "ump45" -> :ump45
      "usp_silencer" -> :usp_silencer
      "xm1014" -> :xm1014
    end
  end
end
