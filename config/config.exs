# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

config :emlt_web,
  generators: [context_app: :emlt]

# Configures the endpoint
config :emlt_web, EmltWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "PONlQ61y64b+iORasXN6HhPrrVXrKGUUzU5Ai1diUmprugUQ0szWZtpviEhOlfsU",
  render_errors: [view: EmltWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: EmltWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :emlt,
  nn_layers: [
    %{
      size: {17, 17},
      size_nc: 28,
      nc_weights: -5..5,
      z_index: 2,
      targets: nil,
      role: "hidden",
      rate: 0.1
    },
    %{
      size: {1, 10},
      size_nc: 17,
      nc_weights: -5..5,
      z_index: 3,
      targets: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      role: "out",
      rate: 0.1
    }
  ]
