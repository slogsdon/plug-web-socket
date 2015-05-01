defmodule WsHandler do
  # for Cowboy WebSocket connections
  @behaviour :cowboy_websocket_handler
  @connection Plug.Adapters.Cowboy.Conn

  defmodule State do
    defstruct conn: nil,
              plug: nil,
              action: nil
  end

  ## Init

  def init(_transport, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_init(transport, req, opts) do\
    state = @connection.conn(req, transport)
      |> build_state(opts)
      |> IO.inspect
    handle_reply req, apply(state.plug, state.action, [:init, state])
  end

  ## Handle

  def websocket_handle({:text, msg}, req, state) do
    handle_reply req, apply(state.plug, state.action, [msg, state])
  end

  def websocket_handle(_other, req, state) do
    {:ok, req, state}
  end

  ## Info

  def websocket_info({:timeout, _ref, msg}, req, state) do
    handle_reply req, apply(state.plug, state.action, [msg, state])
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

  defp handle_reply(req, {:ok, state}) do
    {:ok, req, state}
  end
  defp handle_reply(req, {:reply, {opcode, payload}, state}) do
    {:reply, {opcode, payload}, req, state, :hibernate}
  end

  defp update_scheme(%Plug.Conn{scheme: :http} = conn) do
    %{conn | scheme: :ws}
  end
  defp update_scheme(%Plug.Conn{scheme: :https} = conn) do
    %{conn | scheme: :wss}
  end
end