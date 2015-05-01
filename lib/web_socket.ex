defmodule WebSocket do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = []
    plug = Router
    opts = []
    dispatch = build_dispatch(plug, opts)

    Plug.Adapters.Cowboy.http plug, opts, [dispatch: dispatch]

    opts = [strategy: :one_for_one, name: WebSocket.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp build_dispatch(plug, opts) do
    opts = plug.init(opts)
    [{:_, [ {"/echo", WsHandler, {WsController, :echo}},
            {:_, Plug.Adapters.Cowboy.Handler, {plug, opts}} ]}]
  end
end
