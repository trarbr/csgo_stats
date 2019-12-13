defmodule CsgoStats.Matches do
  alias CsgoStats.Matches.{DB, EventHandler, Supervisor}

  def list_matches() do
    DB.list()
  end

  def get_match(server_instance_token) do
    DB.get(server_instance_token)
  end

  def subscribe_all() do
    DB.subscribe_all()
  end

  def subscribe_match(server_instance_token) do
    DB.subscribe_match(server_instance_token)
  end

  def started?(server_instance_token) do
    case EventHandler.lookup(server_instance_token) do
      {:ok, _} -> true
      {:error, :not_found} -> false
    end
  end

  def start(server_instance_token) do
    Supervisor.start_child({EventHandler, server_instance_token: server_instance_token})
  end

  def update(server_instance_token, events) do
    # TODO: return error if the match starts in invalid state, e.g. if log is
    # started in the middle of a match
    case EventHandler.lookup(server_instance_token) do
      {:ok, event_handler} -> :ok = EventHandler.apply(event_handler, events)
      {:error, :not_found} -> {:error, :not_started}
    end
  end
end
