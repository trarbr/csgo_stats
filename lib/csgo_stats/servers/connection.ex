defmodule CsgoStats.Servers.Connection do
  @moduledoc """
  A client for communicating with a game server using RCON
  """

  alias CsgoStats.Rcon

  @behaviour :gen_statem

  @connect_backoff_timeout 5000
  @auth_error_backoff_timeout 5000
  @auth_unauthorized_backoff_timeout 60_000
  @exec_timeout 5000

  @derive {Inspect, except: [:password]}
  defstruct [:host, :port, :password, :controlling_process, :socket, :last_packet_id]

  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :controlling_process, self())
    :gen_statem.start_link(__MODULE__, opts, [])
  end

  def execute(conn, command, timeout \\ @exec_timeout) do
    :gen_statem.call(conn, {:execute, command}, timeout)
  end

  @impl true
  def callback_mode(), do: :state_functions

  @impl true
  def init(opts) do
    data = %__MODULE__{
      host: Keyword.get(opts, :host, {127, 0, 0, 1}),
      port: Keyword.get(opts, :port, 27015),
      controlling_process: Keyword.fetch!(opts, :controlling_process),
      password: Keyword.fetch!(opts, :password)
    }

    actions = [{:next_event, :internal, :connect}]
    {:ok, :disconnected, data, actions}
  end

  def disconnected(:internal, :connect, data) do
    do_connect(data)
  end

  def disconnected(:state_timeout, :backoff, data) do
    do_connect(data)
  end

  def connected(:internal, :authenticate, data) do
    do_authenticate(data)
  end

  def connected(:state_timeout, :backoff, data) do
    do_authenticate(data)
  end

  def connected({:call, _from}, {:execute, _command}, _data) do
    :postpone
  end

  def authenticated({:call, from}, {:execute, command}, data) do
    case Rcon.exec(data.socket, data.last_packet_id, command) do
      {:ok, last_packet_id, response} ->
        actions = [{:reply, from, {:ok, response}}]
        {:keep_state, %{data | last_packet_id: last_packet_id}, actions}

      {:error, error} ->
        actions = [{:state_timeout, @connect_backoff_timeout, :backoff}]
        {:next_state, :disconnected, data, actions}
    end
  end

  defp do_connect(data) do
    case Rcon.connect(data.host, data.port) do
      {:ok, socket} ->
        actions = [{:next_event, :internal, :authenticate}]
        {:next_state, :connected, %{data | socket: socket, last_packet_id: 0}, actions}

      {:error, error} ->
        actions = [{:state_timeout, @connect_backoff_timeout, :backoff}]
        {:keep_state_and_data, actions}
    end
  end

  defp do_authenticate(data) do
    case Rcon.auth(data.socket, data.last_packet_id, data.password) do
      {:ok, last_packet_id} ->
        notify_handler(data, :connected)
        {:next_state, :authenticated, %{data | last_packet_id: last_packet_id}}

      {:error, :unauthorized} ->
        notify_handler(data, {:authentication_error, :unauthorized})
        actions = [{:state_timeout, @auth_unauthorized_backoff_timeout, :backoff}]
        {:keep_state, data, actions}

      {:error, :closed} ->
        notify_handler(data, {:authentication_error, :unauthorized})
        actions = [{:state_timeout, @auth_unauthorized_backoff_timeout, :backoff}]
        {:keep_state, data, actions}

      {:error, error} ->
        notify_handler(data, {:authentication_error, error})
        actions = [{:state_timeout, @auth_error_backoff_timeout, :backoff}]
        {:next_state, :disconnected, data, actions}
    end
  end

  defp notify_handler(data, message) do
    send(data.controlling_process, {__MODULE__, message})
  end

  # url should be a string like "http://192.168.1.102:4000/api/logs"
  def forward_logs(conn, url) do
    url = String.replace(url, "://", "$")

    commands = [
      "log on",
      "mp_logdetail 3",
      "mp_logmoney 1",
      "mp_logdetail_items 1",
      "logaddress_add_http \"#{url}\""
    ]

    Enum.map(commands, fn command -> execute(conn, command) end)
  end
end
