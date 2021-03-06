use Mix.Config

config :immortals,
  nodes: ["alice@127.0.0.1", "bob@127.0.0.1"]

config :libcluster,
  topologies: [
    immortals: [
      strategy: Cluster.Strategy.Gossip
    ]
  ]

import_config "#{Mix.env()}.exs"
