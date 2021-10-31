defmodule CsgoStats.Matches do
  alias CsgoStats.Matches.DB

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
end
