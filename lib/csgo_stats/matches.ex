defmodule CsgoStats.Matches do
  alias CsgoStats.Matches.{Match, Registry, Supervisor}

  def apply(server_instance_token, events) do
    case Registry.lookup(server_instance_token) do
      {:ok, match} ->
        Match.apply(match, events)

      {:error, :not_found} ->
        Supervisor.start_child(
          {Match, server_instance_token: server_instance_token, events: events}
        )
    end
  end
end
