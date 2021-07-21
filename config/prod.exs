use Mix.Config

config :libcluster,
  topologies: [
    immortals: [
      strategy: Cluster.Strategy.Kubernetes.DNS,
      config: [
        service: "immortals-service-headless",
        application_name: "immortals",
        polling_interval: 3_000
      ]
    ]
  ]
