use Mix.Config

config :libcluster,
  topologies: [
    immortals: [
      strategy: Cluster.Strategy.Gossip
    ]
  ]
