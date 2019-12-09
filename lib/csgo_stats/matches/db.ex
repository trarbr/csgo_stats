defmodule CsgoStats.Matches.DB do
  @db :matches_db

  def init() do
    :ets.new(@db, [:named_table, :set, :public])
  end

  def subscribe_match(server_instance_token) do
    Registry.register(__MODULE__, server_instance_token, [])
  end

  def upsert(match) do
    :ets.insert(@db, {match.server_instance_token, match})

    Registry.dispatch(__MODULE__, match.server_instance_token, fn entries ->
      for {pid, _} <- entries, do: send(pid, {:match_updated, match})
    end)
  end

  def list() do
    :ets.tab2list(@db)
    |> Enum.map(fn {_server_instance_token, match} -> match end)
  end

  def get(server_instance_token) do
    case :ets.lookup(@db, server_instance_token) do
      [{_server_instance_token, match}] -> match
      _ -> nil
    end
  end
end
