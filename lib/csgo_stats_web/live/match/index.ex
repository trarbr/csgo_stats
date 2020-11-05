defmodule CsgoStatsWeb.MatchLive.Index do
  use CsgoStatsWeb, :live_view

  def mount(_params, _assigns, socket) do
    matches = CsgoStats.Matches.list_matches()
    CsgoStats.Matches.subscribe_all()

    {:ok, assign(socket, matches: matches)}
  end

  def handle_info(:matches_updated, socket) do
    matches = CsgoStats.Matches.list_matches()
    {:noreply, assign(socket, matches: matches)}
  end
end
