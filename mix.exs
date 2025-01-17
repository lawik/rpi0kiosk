defmodule Kiosk.MixProject do
  use Mix.Project

  @app :kiosk
  @version "0.1.0"
  @all_targets [
    :rpi,
    :rpi0,
    :rpi2,
    :rpi3,
    :rpi3a,
    :rpi4,
    :bbb,
    :osd32mp1,
    :x86_64,
    :grisp2,
    :mangopi_mq_pro,
    :frio_rpi4
  ]

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      archives: [nerves_bootstrap: "~> 1.12"],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [{@app, release()}],
      aliases: aliases(),
      preferred_cli_target: [run: :host, test: :host]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Kiosk.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Phoenix project
      {:phoenix, "~> 1.7.11"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {:ecto_sqlite3, ">= 0.0.0"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.20.2"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.2"},

      # Nerves
      # Dependencies for all targets
      {:nerves, "~> 1.10", runtime: false},
      {:shoehorn, "~> 0.9.1"},
      {:ring_logger, "~> 0.10.0"},
      {:toolshed, "~> 0.3.0"},

      # Allow Nerves.Runtime on host to support development, testing and CI.
      # See config/host.exs for usage.
      {:nerves_runtime, "~> 0.13.0"},

      # Dependencies for all targets except :host
      {:nerves_pack, "~> 0.7.0", targets: @all_targets},

      # Dependencies for specific targets
      # NOTE: It's generally low risk and recommended to follow minor version
      # bumps to Nerves systems. Since these include Linux kernel and Erlang
      # version updates, please review their release notes in case
      # changes to your application are needed.
      # {:nerves_system_rpi, "~> 1.24", runtime: false, targets: :rpi},
      # {:nerves_system_rpi0, "~> 1.24", runtime: false, targets: :rpi0},
      # {:nerves_system_rpi2, "~> 1.24", runtime: false, targets: :rpi2},
      # {:nerves_system_rpi3, "~> 1.24", runtime: false, targets: :rpi3},
      # {:nerves_system_rpi3a, "~> 1.24", runtime: false, targets: :rpi3a},
      # {:nerves_system_rpi4, "~> 1.24", runtime: false, targets: :rpi4},
      # {:nerves_system_bbb, "~> 2.19", runtime: false, targets: :bbb},
      # {:nerves_system_osd32mp1, "~> 0.15", runtime: false, targets: :osd32mp1},
      # {:nerves_system_x86_64, "~> 1.24", runtime: false, targets: :x86_64},
      # {:nerves_system_grisp2, "~> 0.8", runtime: false, targets: :grisp2},
      # {:nerves_system_mangopi_mq_pro, "~> 0.6", runtime: false, targets: :mangopi_mq_pro},
      {:nerves_hub_link,
       github: "lawik/nerves_hub_link", branch: "extension-pubsub", override: true},
      {:nerves_hub_link_geo, github: "nervescloud/nerves_hub_link_geo"},
      {:nerves_hub_health, github: "nervescloud/nerves_hub_health"},
      {:nerves_hub_cli, "~> 2.0"},
      # {:frio_rpi4,
      #  #path: "../frio_rpi4", runtime: false, nerves: [compile: true], targets: :frio_rpi4},
      #  path: Path.expand("~/projects/nerves_systems/src/frio_rpi4"), runtime: false, nerves: [compile: true], targets: :frio_rpi4},
      {:nerves_system_rpi0, "== 1.27.1", runtime: false, targets: :rpi0},
      {:muontrap, "~> 1.5"},
      {:nerves_time, "~> 0.4.8"},
      {:nerves_key, "~> 1.2"}
    ]
  end

  def release do
    [
      overwrite: true,
      # Erlang distribution is not started automatically.
      # See https://hexdocs.pm/nerves_pack/readme.html#erlang-distribution
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod or [keep: ["Docs"]]
    ]
  end

  defp aliases do
    [
      #      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      #      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      #      "ecto.reset": ["ecto.drop", "ecto.setup"],
      #      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind kiosk", "tailwind keyboard", "esbuild kiosk"],
      "assets.deploy": [
        "tailwind kiosk --minify",
        "esbuild kiosk --minify",
        "phx.digest"
      ],
      firmware: [
        "assets.deploy",
        "firmware"
      ]
    ]
  end
end
