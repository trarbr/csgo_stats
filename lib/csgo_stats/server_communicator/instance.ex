defmodule CsgoStats.ServerCommunicator.Instance do
  defstruct [:ip_addresses, :ip_address, :ip_index, :port]

  def new(address) do
    case String.split(address, ":", parts: 2) do
      [ip, port] ->
        new(ip, port)

      _ ->
        # TODO: Better errors
        {:format_error, address}
    end
  end

  def new(address, port) when is_binary(port) do
    new(address, String.to_integer(port))
  end

  def new(address, port) do
    {:ok, ips} = resolveAddress(address)

    %__MODULE__{
      ip_addresses: ips,
      ip_address: List.first(ips),
      ip_index: 0,
      port: port
    }
  end

  def key(%__MODULE__{ip_address: ip_address, port: port} = instance) do
    ip_address
    |> :inet_parse.ntoa()
    |> to_string()
    |> Kernel.<>(":")
    |> Kernel.<>(to_string(port))
  end

  defp resolveAddress(address) when is_binary(address) do
    address |> to_charlist() |> resolveAddress()
  end

  defp resolveAddress(address) do
    with {:error, :einval} <- :inet.parse_address(address),
         {:ok, {:hostent, _, _, _, _, ips}} <- :inet_res.gethostbyname(address),
         false <- Enum.empty?(ips) do
      {:ok, ips}
    else
      {:ok, ip} -> {:ok, [ip]}
      # TODO: Better errors
      true -> {:error, "Cannot resolve address"}
      error -> error
    end
  end
end
