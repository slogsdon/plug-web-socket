defmodule WebSocket.Router do
  use Plug.Router
  use WebSocket.Macro

  socket "/topic", WebSocket.TopicController, :handle
  socket "/echo",  WebSocket.EchoController,  :echo

  # def run(opts) do
  #   plug = __MODULE__
  #   opts = plug.init(opts)
  #   dispatch = build_dispatch(plug, ws_routes, opts)
  #   Plug.Adapters.Cowboy.http plug, opts, [dispatch: dispatch]
  # end

  plug Plug.Static, at: "/", from: :web_socket

  plug :match
  plug :dispatch

  get "/" do
    data = "priv/static/menu.html"
      |> Path.expand
      |> File.read!
    conn |> send_resp(200, data)
  end

  match _ do
    conn |> send_resp(404, "Not Found")
  end
end
