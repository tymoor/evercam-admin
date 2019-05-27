# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :evercam_admin, EvercamAdminWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "c6ZNmWz1J+1H9tthMge41N5pJciPrdqEfMe5IIzpi6+JORYSlovoej5B7MgK8z23",
  render_errors: [view: EvercamAdminWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: EvercamAdmin.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.

config :evercam_admin,
  seaweedfs_new: "http://localhost:8888",
  seaweedfs_old: "http://localhost:8888",
  seaweedfs_oldest: "http://localhost:8888",
  proxy_host: "",
  proxy_pass: ""

import_config "#{Mix.env()}.exs"
