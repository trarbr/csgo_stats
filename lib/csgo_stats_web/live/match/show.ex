defmodule CsgoStatsWeb.MatchLive.Show do
  use Phoenix.LiveView

  alias CsgoStats.Matches.{EventHandler, Match}

  def mount(_params, %{"server_instance_token" => server_instance_token}, socket) do
    match =
      CsgoStats.Matches.get_match(server_instance_token) ||
        Match.new(server_instance_token)

    CsgoStats.Matches.subscribe_match(server_instance_token)
    match = %{match | players: sort_players(match.players)}

    {:ok, assign(socket, match: match)}
  end

  def render(assigns) do
    CsgoStatsWeb.MatchView.render("show.html", assigns)
  end

  def handle_event("set-event", %{"event-selector" => event}, socket) do
    event_index = String.to_integer(event)
    EventHandler.replay_from_event(socket.assigns.match.server_instance_token, event_index)

    {:noreply, socket}
  end

  def handle_info({:match_updated, match}, socket) do
    match = %{match | players: sort_players(match.players)}

    {:noreply, assign(socket, match: match)}
  end

  defp sort_players(players) do
    Enum.sort(players, fn {_, a}, {_, b} ->
      a.kills + a.assists / 100 - a.deaths / 1000 >= b.kills + b.assists / 100 - b.deaths / 1000
    end)
  end
end
