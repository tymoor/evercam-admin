use Mix.Config

# For production, don't forget to configure the url host
# to something meaningful, Phoenix uses this information
# when generating URLs.
#
# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix phx.digest` task,
# which you should run after static files are built and
# before starting your production server.
config :evercam_admin, EvercamAdminWeb.Endpoint,
  http: [:inet6, port: System.get_env("PORT") || 4000],
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :info

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :evercam_admin, EvercamAdminWeb.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [
#         :inet6,
#         port: 443,
#         cipher_suite: :strong,
#         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
#       ]
#
# The `cipher_suite` is set to `:strong` to support only the
# latest and more secure SSL ciphers. This means old browsers
# and clients may not be supported. You can set it to
# `:compatible` for wider support.
#
# `:keyfile` and `:certfile` expect an absolute path to the key
# and cert in disk or a relative path inside priv, for example
# "priv/ssl/server.key". For all supported SSL configuration
# options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
#
# We also recommend setting `force_ssl` in your endpoint, ensuring
# no data is ever sent via http, always redirecting to https:
#
#     config :evercam_admin, EvercamAdminWeb.Endpoint,
#       force_ssl: [hsts: true]

config :evercam_admin, EvercamAdminWeb.Endpoint,
  force_ssl: [rewrite_on: [:x_forwarded_proto], hsts: true, host: nil]

# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases (distillery)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
#     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :evercam_admin, EvercamAdminWeb.Endpoint, server: true
#
# Note you can't rely on `System.get_env/1` when using releases.
# See the releases documentation accordingly.

# Finally import the config/prod.secret.exs which should be versioned
# separately.

config :evercam_models, Evercam.Repo,
  types: Evercam.PostgresTypes,
  url: System.get_env("DATABASE_URL"),
  socket_options: [keepalive: true],
  timeout: 60_000,
  pool_size: 10,
  lazy: false,
  ssl: true

config :evercam_models, Evercam.SnapshotRepo,
  url: System.get_env("SNAPSHOT_DATABASE_URL"),
  socket_options: [keepalive: false],
  timeout: 60_000,
  pool_size: 5,
  lazy: false,
  ssl: true

config :evercam_admin, EvercamAdminWeb.Endpoint,
  secret_key_base: "ThGt5FLiM+Kns1vt6XmFXJXNPV1lXz28OU3cWINOGvU2e/opC+qOyOOPuojVamPG"

config :evercam_admin,
  evercam_server: System.get_env("EVERCAM_SERVER")

config :evercam_admin,
  seaweedfs_new: System.get_env("SEAWEEDFS_NEW"),
  seaweedfs_old: System.get_env("SEAWEEDFS_OLD"),
  seaweedfs_oldest: System.get_env("SEAWEEDFS_OLDEST"),
  proxy_host: System.get_env("PROXY_HOST"),
  proxy_pass: System.get_env("PROXY_PASS")