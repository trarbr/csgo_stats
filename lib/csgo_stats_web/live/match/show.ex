defmodule CsgoStatsWeb.MatchLive.Show do
  use Phoenix.LiveView

  def mount(params, socket) do
    match =
      CsgoStats.Matches.get_match(params.server_instance_token) ||
        CsgoStats.Matches.Match.new(params.server_instance_token)

    CsgoStats.Matches.subscribe_match(params.server_instance_token)
    match = %{ match | players: sort_players(match.players) }

    {:ok, assign(socket, match: match)}
  end

  def render(assigns) do
    CsgoStatsWeb.MatchView.render("show.html", assigns)
  end

  def handle_info({:match_updated, match}, socket) do
    match = %{ match | players: sort_players(match.players) }
    {:noreply, assign(socket, match: match)}
  end

  defp sort_players(players) do
    Enum.sort(players, fn ({_, a}, {_, b}) ->
      (a.kills + a.assists / 100 - a.deaths / 1000) >= (b.kills + b.assists / 100 - b.deaths / 1000)
    end)
  end
end
