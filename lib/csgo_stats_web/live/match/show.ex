defmodule CsgoStatsWeb.MatchLive.Show do
  use Phoenix.LiveView

  alias CsgoStats.Matches.Match

  def mount(_params, %{"server_instance_token" => server_instance_token}, socket) do
    match =
      CsgoStats.Matches.get_match(server_instance_token) ||
        Match.new(server_instance_token)

    CsgoStats.Matches.subscribe_match(server_instance_token)
    match = %{match | players: sort_players(match.players)}

    if connected?(socket) do
      :timer.send_interval(1000, self(), :tick)
    end

    {:ok, assign(socket, match: match, time_left: timer(match, 0))}
  end

  def render(assigns) do
    CsgoStatsWeb.MatchView.render("show.html", assigns)
  end

  def handle_info(:tick, socket) do
    {:noreply, assign(socket, time_left: timer(socket.assigns.match, socket.assigns.time_left))}
  end

  def handle_info({:match_updated, match}, socket) do
    match = %{match | players: sort_players(match.players)}

    {:noreply,
     assign(socket, match: match, time_left: timer(socket.assigns.match, socket.assigns.time_left))}
  end

  defp timer(%Match{bomb_timeout: nil, round_timeout: nil, freeze_timeout: nil}, _), do: 0

  defp timer(%Match{bomb_timeout: nil, round_timeout: nil} = match, _) do
    NaiveDateTime.diff(match.freeze_timeout, NaiveDateTime.utc_now())
  end

  defp timer(%Match{bomb_timeout: nil} = match, _) do
    NaiveDateTime.diff(match.round_timeout, NaiveDateTime.utc_now())
  end

  defp timer(%Match{phase: :round_over}, time_left), do: time_left

  defp timer(%Match{} = match, _) do
    NaiveDateTime.diff(match.bomb_timeout, NaiveDateTime.utc_now())
  end

  defp sort_players(players) do
    Enum.sort(players, fn {_, a}, {_, b} ->
      a.kills + a.assists / 100 - a.deaths / 1000 >= b.kills + b.assists / 100 - b.deaths / 1000
    end)
  end
end
