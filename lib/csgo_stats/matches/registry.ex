defmodule CsgoStats.Matches.Registry do
  def register(server_instance_token) do
    Registry.register(__MODULE__, server_instance_token, nil)
  end

  def lookup(server_instance_token) do
    case Registry.lookup(__MODULE__, server_instance_token) do
      [{match, _value}] -> {:ok, match}
      [] -> {:error, :not_found}
    end
  end
end
