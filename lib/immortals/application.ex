defmodule Immortals.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger
  @impl true
  def start(_type, _args) do
    Logger.info("Let there be light")

    children = [
      # Starts a worker by calling: Immortals.Worker.start_link(arg)
      # {Immortals.Worker, arg}
      {Cluster.Supervisor, [topologies(), name: Immortals.LibclusterSupervisor]},
      {Horde.Registry, keys: :unique, name: GodRegistry},
      {Horde.DynamicSupervisor, name: GodSupervisor, strategy: :one_for_one}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Immortals.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp topologies do
    [
      immortals: [
        strategy: Cluster.Strategy.Gossip
      ]
    ]
  end
end
