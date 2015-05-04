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
    [{:plug, "~> 0.12.0"},
     {:cowboy, "~> 1.0.0"},
     {:poison, "~> 1.4.0"},
     {:earmark, "~> 0.1.12", only: :docs},
     {:ex_doc, "~> 0.6.2", only: :docs},
     {:excoveralls, "~> 0.3", only: :test},
     {:dialyze, "~> 0.1.3", only: :test}]
  end

  defp description do
    """
    Modular web framework
    """
  end

  defp package do
    %{contributors: ["Shane Logsdon"],
      files: ["lib", "priv", "mix.exs", "README.md", "LICENSE"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/slogsdon/plug-web-socket"}}
  end
end
