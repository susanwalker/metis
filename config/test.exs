import Config

config :metis, MetisWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "6rwZ3/oVONZVNbrv4IKMu9Uop7hBKjt9VEOenmgkAVnXHq1ngTG67qTT0U9AMUoI",
  server: false

config :logger, level: :warn

config :phoenix, :plug_init_mode, :runtime
