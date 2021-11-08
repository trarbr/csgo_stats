defmodule CsgoStats.Rcon do
  @moduledoc """
  A simple gen_tcp based implementation of a Source RCON client

  - [Source RCON Protocol](https://developer.valvesoftware.com/wiki/Source_RCON_Protocol)

  By calling `connect/2`, you can obtain an open TCP socket,
  which can then be used with `auth/3` or `exec/3`.
  """

  @connect_timeout 5000
  @receive_timeout 5000

  @spec connect(:inet.socket_address() | :inet.hostname(), non_neg_integer()) ::
          {:ok, :gen_tcp.socket()} | {:error, any()}
  @spec auth(:gen_tcp.socket(), non_neg_integer(), String.t()) ::
          {:ok, non_neg_integer()} | {:error, any()}
  @spec exec(:gen_tcp.socket(), non_neg_integer(), String.t()) ::
          {:ok, non_neg_integer(), binary()} | {:error, any()}

  @doc """
  Open a connection to the nominated server. Use raw mode, so the amount of data
  to be read can be controlled precisely.
  """
  def connect(host, port) do
    socket_options = [active: false, packet: :raw, mode: :binary]
    :gen_tcp.connect(host, port, socket_options, @connect_timeout)
  end

  @doc """
  Authenticate with a given RCON password.
  """
  def auth(socket, from_sequence, password) do
    auth_sequence = from_sequence + 1
    auth_packet = build_packet(auth_sequence, :auth, password)

    with :ok <- send_packet(socket, auth_packet),
         {:ok, {^auth_sequence, :exec_response, ""}} <- receive_packet(socket),
         {:ok, {^auth_sequence, :auth_response, ""}} <- receive_packet(socket) do
      {:ok, auth_sequence}
    else
      {:ok, {-1, :auth_response, ""}} -> {:error, :unauthorized}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Run a RCON command remotely and wait for resopnse. This will send 2 packets,
  so Source RCON commands that have large repsonses can be handled properly. See
  the Source Developer page for details.
  """
  def exec(socket, from_sequence, command) do
    exec_sequence = from_sequence + 1
    over_sequence = exec_sequence + 1
    exec_packet = build_packet(exec_sequence, :exec, command)
    over_packet = build_packet(over_sequence, :over)

    with :ok <- send_packet(socket, exec_packet),
         :ok <- send_packet(socket, over_packet),
         {:ok, response} <- drain_packets(socket, over_sequence) do
      {:ok, over_sequence, response}
    end
  end

  defp drain_packets(socket, over_sequence, response \\ <<>>) do
    case receive_packet(socket) do
      {:ok, {^over_sequence, :exec_response, _}} ->
        {:ok, response}

      {:ok, {_, :exec_response, partial_response}} ->
        drain_packets(socket, over_sequence, response <> partial_response)

      {:error, _error} = error ->
        error
    end
  end

  defp outgoing_packet_type_for(:auth), do: 3
  defp outgoing_packet_type_for(:exec), do: 2
  # to allow multiple-packet responses
  defp outgoing_packet_type_for(:over), do: -1
  defp incoming_packet_type_for(2), do: :auth_response
  defp incoming_packet_type_for(0), do: :exec_response

  defp build_packet(sequence, type, body \\ "") do
    request_length = byte_size(body) + 10
    encoded_type = outgoing_packet_type_for(type)

    request_head = <<
      request_length::little-integer-signed-size(32),
      sequence::little-integer-signed-size(32),
      encoded_type::little-integer-signed-size(32)
    >>

    request_tail = <<0, 0>>
    [request_head, body, request_tail]
  end

  defp send_packet(socket, packet) do
    :gen_tcp.send(socket, packet)
  end

  defp receive_packet(socket, timeout \\ @receive_timeout) do
    with {:ok, <<length::little-integer-signed-32>>} <- :gen_tcp.recv(socket, 4, timeout),
         {:ok, response_body} <- :gen_tcp.recv(socket, length, timeout),
         {:ok, response} <- parse_response(length - 10, response_body) do
      {:ok, response}
    else
      {:error, :closed} = error -> error
      _ -> {:error, :invalid_response}
    end
  end

  defp parse_response(body_size, data) do
    <<
      response_sequence::little-integer-signed-size(32),
      response_type::little-integer-signed-size(32),
      response_body::binary-size(body_size),
      0,
      0
    >> = data

    decoded_type = incoming_packet_type_for(response_type)
    {:ok, {response_sequence, decoded_type, response_body}}
  end
end
