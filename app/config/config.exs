# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :grafik,
  ecto_repos: [Grafik.Repo]

# Configures the endpoint
config :grafik, GrafikWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "fCpplzyk+d3aOE40uHnM1FW4WY80Xp1MqrdFZb28WTThb11QFaWjL+Vq7aQlUE8Y",
  render_errors: [view: GrafikWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Grafik.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :grafik, :backups_data_access_path, "https://fcstore.finalclass.net/grafik-backups"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

