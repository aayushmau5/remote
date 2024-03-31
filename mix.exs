defmodule Remote.MixProject do
  use Mix.Project

  def project do
    [
      app: :remote,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript_config(),
      default_task: "escript.build",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:prompt, github: "aayushmau5/prompt", branch: "default-answer-text"}
    ]
  end

  defp escript_config() do
    [main_module: Remote.CLI]
  end
end
