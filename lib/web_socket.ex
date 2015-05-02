defmodule WebSocket do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = []
    plug = WebSocket.Router
    opts = []
    dispatch = build_dispatch(plug, opts)

    Plug.Adapters.Cowboy.http plug, opts, [dispatch: dispatch]

    opts = [strategy: :one_for_one, name: WebSocket.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # to be extracted to a util module
  defp build_dispatch(plug, opts) do
    opts = plug.init(opts)
    [{:_, [ {"/echo", WebSocket.Cowboy.Handler, {WebSocket.EchoController, :echo}},
            {"/topic", WebSocket.Cowboy.Handler, {WebSocket.TopicController, :handle}},
            {:_, Plug.Adapters.Cowboy.Handler, {plug, opts}} ]}]
  end
end
