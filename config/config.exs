import Config

config :logger, level: :info

config :d3fl_simulator, :data_directory_path, "./data"

config :nx,
  default_backend: EXLA.Backend,
  default_defn_options: [compiler: EXLA]

config :exla,
  xla_target: "cuda120"
