defmodule WebSocket.App do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      worker(WebSocket.Router, [], function: :run)
    ]
    opts     = [strategy: :one_for_one, 
                name: WebSocket.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
