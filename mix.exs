defmodule WebSocket.Mixfile do
  use Mix.Project

  def project do
    [app: :web_socket,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  def application do
    [applications: [:logger],
     mod: {WebSocket, []}]
  end

  defp deps do
    [{:plug, "~> 0.12.0"},
     {:cowboy, "~> 1.0.0"},
     {:poison, "~> 1.4.0"}]
  end
end
