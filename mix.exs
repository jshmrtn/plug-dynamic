defmodule PlugDynamic.MixProject do
  @moduledoc false
  use Mix.Project

  @version "1.0.0"

  def project do
    [
      app: :plug_dynamic,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  defp description do
    """
    Allows registration of every Plug with dynamic configuration.
    """
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {PlugDynamic.Application, []}
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.6"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:inch_ex, only: :docs, runtime: false},
      {:excoveralls, "~> 0.4", only: :test, runtime: false},
      {:dialyxir, "~> 1.0-rc", only: :dev, runtime: false},
      {:credo, "~> 0.5", only: :dev, runtime: false}
    ]
  end

  defp package do
    # These are the default files included in the package
    [
      name: :plug_dynamic,
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Jonatan Männchen"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jshmrtn/plug-dynamic"}
    ]
  end

  defp docs do
    [
      source_ref: "v" <> @version,
      source_url: "https://github.com/jshmrtn/crontab"
    ]
  end
end
