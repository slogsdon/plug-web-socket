defmodule WebSocket do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :ws_routes, accumulate: true)
    end
  end

  defmacro __before_compile__(env) do
    quote do
      unquote(run(env))
    end
  end

  defmacro socket(route, mod, func) do
    quote do
      @ws_routes {:{}, [], [unquote(route), unquote(mod), unquote(func)]}
    end
  end

  defp run(env) do
    plug   = env.module
    routes = Module.get_attribute(env.module, :ws_routes)
    quote do
      def run(opts \\ []) do
        opts = unquote(plug).init(opts)
        dispatch = build_dispatch(unquote(plug), unquote(routes), opts)
        Plug.Adapters.Cowboy.http unquote(plug), opts, [dispatch: dispatch]
      end
    end
  end

  def build_dispatch(plug, routes \\ [], opts \\ []) do
    default = [ {:_, Plug.Adapters.Cowboy.Handler, {plug, opts}} ]
    routes = routes
      |> Enum.reverse
      |> Enum.reduce(default, fn {route, mod, func}, acc ->
        [{route, WebSocket.Cowboy.Handler, {mod, func}}|acc]
      end)
    [{:_, routes}]
  end
end
