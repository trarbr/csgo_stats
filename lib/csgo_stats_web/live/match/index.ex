defmodule CsgoStatsWeb.MatchLive.Index do
  use Phoenix.LiveView

  def mount(_params, socket) do
    matches = CsgoStats.Matches.list_matches()
    CsgoStats.Matches.subscribe_all()

    {:ok, assign(socket, matches: matches)}
  end

  def render(assigns) do
    CsgoStatsWeb.MatchView.render("index.html", assigns)
  end

  def handle_info(:matches_updated, socket) do
    matches = CsgoStats.Matches.list_matches()
    {:noreply, assign(socket, matches: matches)}
  end
end
