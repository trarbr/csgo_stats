defmodule CsgoStats.Logs.Entry do
  @metadata_keys [:server_address, :server_instance_token, :steam_id, :timestamp]

  defstruct [:server_address, :server_instance_token, :steam_id, :timestamp, :lines]

  def new(data, metadata) do
    case Enum.all?(@metadata_keys, fn key -> Map.has_key?(metadata, key) end) do
      true ->
        entry = struct(__MODULE__, metadata)
        {:ok, %{entry | lines: data}}

      false ->
        {:error, :invalid_metadata}
    end
  end
end
