defmodule CsgoStatsWeb.MatchLive.Index do
  use Phoenix.LiveView

  def mount(_params, socket) do
    matches = CsgoStats.Matches.list_matches()

    {:ok, assign(socket, matches: matches)}
  end

  def render(assigns) do
    CsgoStatsWeb.MatchView.render("index.html", assigns)
  end
end
