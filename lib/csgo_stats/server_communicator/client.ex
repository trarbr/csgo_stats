defmodule CsgoStats.ServerCommunicator.Client do
  alias CsgoStats.ServerCommunicator.Instance

  @moduledoc """
  A client for communicating with a game server using RCON
  """
  alias CsgoBot.Rcon.Packet

  @behaviour :gen_statem

  @connect_timeout 5000
  @connect_backoff_timeout 5000
  @auth_backoff_timeout 5000

  # TODO: derive protocol to avoid logging password
  defstruct [:instance, :password, :socket, :next_packet_id]

  def execute(conn, command) do
    :gen_statem.call(conn, {:execute, command})
  end

  def start_link(opts) do
    :gen_statem.start_link(__MODULE__, opts, [])
  end

  @impl true
  def callback_mode(), do: [:handle_event_function]

  @impl true
  def init(opts) do
    data = %__MODULE__{
      instance: Keyword.get(opts, :instance),
      password: Keyword.get(opts, :password, "1234")
    }

    actions = [{:next_event, :internal, :connect}]
    {:ok, :disconnected, data, actions}
  end

  @impl true
  def handle_event(:internal, :connect, :disconnected, data) do
    do_connect(data)
  end

  def handle_event(:state_timeout, :backoff, :disconnected, data) do
    do_connect(data)
  end

  def handle_event(:internal, :authenticate, :connected, data) do
    do_authenticate(data)
  end

  def handle_event(:state_timeout, :backoff, :connected, data) do
    do_authenticate(data)
  end

  def handle_event(:internal, :forward_logs, :authenticated, data) do
    id = data.next_packet_id
    logaddress = "127.0.0.1:48932"
    command = "log on; mp_logdetail 3; logaddress_del #{logaddress}; logaddress_add #{logaddress}"
    packet = serverdata_execcommand(id, command)
    :ok = send_packet(data.socket, packet)
    data = %{data | next_packet_id: id + 1}

    with {:ok, packet} = recv_packet(data.socket),
         true <- response?(packet, id) do
      {:keep_state, data}
    else
      false -> :bugger_me
    end
  end

  # def handle_event({:call, from}, {:execute, command}, :authenticated, data) do
  #   id = data.next_packet_id
  #   packet = serverdata_execcommand(id, command)
  #   :ok = send_packet(data.socket, packet)
  #   data = %{data | next_packet_id: id + 1}

  #   # TODO: handle long responses
  #   with {:ok, packet} = recv_packet(data.socket),
  #        true <- response?(packet, id) do
  #     response_size = byte_size(packet) - 4 - 4 - 2
  #     <<_::64, response::bytes-size(response_size), 0, 0>> = packet
  #     actions = [{:reply, from, response}]
  #     {:keep_state, data, actions}
  #   else
  #     false -> :bugger_me
  #   end
  # end

  defp response?(<<id::32-signed-integer-little, _rest::bytes>>, expected_id) do
    id == expected_id
  end

  defp authenticated?(packet, expected_id) do
    response?(packet, expected_id)
  end

  defp serverdata_execcommand(id, command) do
    <<
      id::32-signed-integer-little,
      2::32-signed-integer-little,
      command::bytes,
      0,
      0
    >>
  end

  defp serverdata_auth(id, password) do
    <<
      id::32-signed-integer-little,
      3::32-signed-integer-little,
      password::bytes,
      0,
      0
    >>
  end

  defp send_packet(socket, packet) do
    :gen_tcp.send(socket, [byte_size(packet), packet])
  end

  defp recv_packet(socket) do
    {:ok, <<length::32-signed-integer-little>>} = :gen_tcp.recv(socket, 4)
    :gen_tcp.recv(socket, length)
  end

  defp do_authenticate(data) do
    id = data.next_packet_id
    packet = serverdata_auth(id, data.password)
    :ok = send_packet(data.socket, packet)
    data = %{data | next_packet_id: id + 1}

    with {:ok, packet} = recv_packet(data.socket),
         true <- response?(packet, id),
         {:ok, packet} = recv_packet(data.socket),
         true <- authenticated?(packet, id) do
      actions = [{:next_event, :internal, :forward_logs}]
      {:next_state, :authenticated, data, actions}
    else
      false ->
        actions = [{:state_timeout, @auth_backoff_timeout, :backoff}]
        {:keep_state, data, actions}
    end
  end

  defp do_connect(data) do
    case :gen_tcp.connect(
           data.instance.ip_address,
           data.instance.port,
           [:binary, {:active, false}, {:packet, 0}],
           @connect_timeout
         ) do
      {:ok, socket} ->
        actions = [{:next_event, :internal, :authenticate}]
        {:next_state, :connected, %{socket: socket}, actions}

      {:error, _} ->
        actions = [{:state_timeout, @connect_backoff_timeout, :backoff}]
        {:keep_state_and_data, actions}
    end
  end
end
