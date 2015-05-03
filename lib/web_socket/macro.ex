defmodule WebSocket.Macro do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :ws_routes, accumulate: true)
    end
  end

  defmacro __before_compile__(env) do
    routes = Module.get_attribute(env.module, :ws_routes)
    quote do
      def ws_routes, do: unquote(routes)
    end
  end

  defmacro socket(route, mod, func) do
    quote do
      @ws_routes {:{}, [], [unquote(route), unquote(mod), unquote(func)]}
    end
  end

  def build_dispatch(plug, routes \\ [], opts \\ []) do
    # opts = plug.init(opts)
    default = [ {:_, Plug.Adapters.Cowboy.Handler, {plug, opts}} ]
    routes = routes
      |> Enum.reverse
      |> Enum.reduce(default, fn {route, mod, func}, acc ->
        [{route, WebSocket.Cowboy.Handler, {mod, func}}|acc]
      end)
    [{:_, routes}]
  end
end
