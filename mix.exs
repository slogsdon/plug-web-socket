defmodule WebSocket.Mixfile do
  use Mix.Project

  def project do
    [app: :web_socket,
     version: "0.0.1",
     elixir: "~> 1.0",
     name: "WebSocket",
     source_url: "https://github.com/slogsdon/plug-web-socket",
     homepage_url: "https://github.com/slogsdon/plug-web-socket",
     deps: deps,
     package: package,
     description: description,
     docs: [readme: "README.md", main: "README"],
     test_coverage: [tool: ExCoveralls]]
  end

  def application do
    [applications: [:logger, :plug, :cowboy, :poison]]
  end

  defp deps do
    [{:plug, "~> 0.14.0"},
     {:cowboy, "~> 1.0.2"},
     {:poison, "~> 1.4.0"},
     {:earmark, "~> 0.1.17", only: :docs},
     {:ex_doc, "~> 0.7.3", only: :docs},
     {:excoveralls, "~> 0.3.11", only: :test},
     {:dialyze, "~> 0.2.0", only: :test}]
  end

  defp description do
    """
    A quick start for using WebSockets in Plug applications.
    """
  end

  defp package do
    %{contributors: ["Shane Logsdon"],
      files: ["lib", "priv", "mix.exs", "README.md", "LICENSE"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/slogsdon/plug-web-socket"}}
  end
end
