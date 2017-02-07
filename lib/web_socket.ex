defmodule WebSocket do
  @moduledoc """
  An exploration into a stand-alone library for
  Plug applications to easily adopt WebSockets.

  ## Integrating with Plug

  If you're looking to try this in your own test
  application, do something like this:

  ```elixir
  defmodule MyApp.Router do
    use Plug.Router
    use WebSocket

    # WebSocket routes
    #      route     controller/handler     function & name
    socket "/topic", MyApp.TopicController, :handle
    socket "/echo",  MyApp.EchoController,  :echo

    # Rest of your router's plugs and routes
    # ...

    def run(opts \\ []) do
      dispatch = dispatch_table(opts)
      Plug.Adapters.Cowboy.http __MODULE__, opts, [dispatch: dispatch]
    end
  end
  ```

  For the time being, there is a `run/1` function
  generated for your router that starts a HTTP/WS
  listener. Not sure if this will stay or get
  reduced to helper functions that aid in the
  creation of a similar function. Most likely the
  latter will win out to help compose functionality.
  The big part that it plays is the building of a
  dispatch table to pass as an option to Cowboy that
  has an entry for each of your socket routes and a
  catch all for HTTP requests.

  ### Add the necessary bits to a module

  From the topic example:

  ```elixir
  defmodule MyApp.TopicController do
    def handle(:init, state) do
      {:ok, state}
    end
    def handle(:terminate, _state) do
      :ok
    end
    def handle("topic:" <> letter, state, data) do
      payload = %{awesome: "blah #{letter}",
                  orig: data}
      {:reply, {:text, payload}, state}
    end
  end
  ```

  Currently, the function name needs to be unique
  across all controllers/handlers as its used for
  the Events layer.

  ### Broadcast from elsewhere

  Need to send data out from elsewhere in your app?

  ```elixir
  # Build your message
  topic = "my_event"
  data  = %{foo: "awesome"}
  mes   = WebSocket.Message.build(topic, data)
  json  = Poison.encode!(mes)

  # Pick your destination (from your routes)
  name = :handle

  # Send away!
  WebSockets.broadcast!(name, json)
  ```

  This needs to be nicer, but this is still in
  progress.
  """
  @type route :: {atom | binary, Module.t, {Module.t, Keyword.t}}

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :ws_routes, accumulate: true)
    end
  end

  defmacro __before_compile__(env) do
    quote do
      unquote(dispatch_table(env))
    end
  end

  defmacro socket(route, mod, func) do
    quote do
      @ws_routes {:{}, [], [unquote(route), unquote(mod), unquote(func)]}
    end
  end

  defp dispatch_table(env) do
    plug   = env.module
    routes = Module.get_attribute(env.module, :ws_routes)
    quote do
      @spec dispatch_table(Keyword.t) :: [WebSocket.route]
      def dispatch_table(opts \\ []) do
        opts = unquote(plug).init(opts)
        build_dispatch(unquote(plug), unquote(routes), opts)
      end
    end
  end

  @spec build_dispatch(Module.t,
                       [{binary, Module.t, atom}],
                       Keyword.t) :: [{:_, [route]}]
  def build_dispatch(plug, routes \\ [], opts \\ []) do
    default = [{:_, Plug.Adapters.Cowboy.Handler, {plug, opts}}]
    routes = routes
      |> Enum.reverse
      |> Enum.reduce(default, fn {route, mod, func}, acc ->
        [{route, WebSocket.Cowboy.Handler, {mod, func}}|acc]
      end)
    [{:_, routes}]
  end
end
