defmodule TrelloElixir.Mixfile do
  use Mix.Project

  @version "1.1.1"
  @elixir_version "~> 1.2"

  def project do
    [app: :trello,
     name: "Trello",
     description: description,
     version: @version,
     elixir: @elixir_version,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def description do
    """
    Trello wrapper for elixir api
    """
  end

  def application do
    [applications: [:httpoison]]
  end

  defp deps do
    [
      {:httpoison, ">= 0.8.2"},
      {:poison, ">= 1.5.0"}
    ]
  end

  defp package do
    %{
      files: ["lib", "README*", "mix.exs", "LICENSE*"],
      maintainers: ["Mika Kalathil"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/mikaak/trello-elixir"
      }
    }
  end
end
