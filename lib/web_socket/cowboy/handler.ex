defmodule WebSocket.Cowboy.Handler do
  # for Cowboy WebSocket connections
  @behaviour :cowboy_websocket_handler
  @connection Plug.Adapters.Cowboy.Conn

  defmodule State do
    defstruct conn: nil,
              plug: nil,
              action: nil,
              use_topics: true
  end

  defmodule Message do
    defstruct event: nil, data: nil
  end

  ## Init

  def init(_transport, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_init(transport, req, opts) do
    state = @connection.conn(req, transport)
      |> build_state(opts)
    args = get_args(:init, state)
    handle_reply req, args, state
  end

  ## Handle

  def websocket_handle({:text, msg}, req, state) do
    args = get_args(msg, state)
    handle_reply req, args, state
  end

  def websocket_handle(_other, req, state) do
    {:ok, req, state}
  end

  ## Info

  def websocket_info({:timeout, _ref, msg}, req, state) do
    args = get_args(msg, state)
    handle_reply req, args, state
  end

  def websocket_info(_info, req, state) do
    {:ok, req, state, :hibernate}
  end

  ## Terminate

  def websocket_terminate(_Reason, _req, state) do
    apply(state.plug, state.action, [:terminate, state])
  end

  def terminate(_reason, _req, _state) do
    :ok
  end

  ## Helpers

  defp build_state(conn, {plug, action}) do
    conn = update_scheme(conn)
    %State{conn: conn, 
           plug: plug, 
           action: action}
  end

  defp get_args(:init, state),      do: [:init, state]
  defp get_args(:terminate, state), do: [:terminate, state]
  defp get_args(message, %State{use_topics: false} = state) do
    [message, state]
  end
  defp get_args(message, %State{use_topics: true} = state) do
    case Poison.decode(message, as: Message) do
      {:ok, mes} -> [mes.event, state, mes.data]
      _          -> [message, state]
    end
  end

  defp get_payload([event, _, _], payload) do
    payload = %Message{
      event: event,
      data: payload
    }
    case Poison.encode(payload) do
      {:ok, result} -> result
      _             -> payload
    end
  end

  defp handle_reply(req, args, state) do
    do_handle_reply req, args, apply(state.plug, state.action, args)
  end

  defp do_handle_reply(req, _args, {:ok, state}) do
    {:ok, req, state}
  end
  defp do_handle_reply(req, _args, {:reply, {opcode, payload}, state}) when payload |> is_binary do
    {:reply, {opcode, payload}, req, state, :hibernate}
  end
  defp do_handle_reply(req, args, {:reply, {opcode, payload}, state}) do
    payload = get_payload(args, payload)
    {:reply, {opcode, payload}, req, state, :hibernate}
  end

  defp update_scheme(%Plug.Conn{scheme: :http} = conn) do
    %{conn | scheme: :ws}
  end
  defp update_scheme(%Plug.Conn{scheme: :https} = conn) do
    %{conn | scheme: :wss}
  end
end