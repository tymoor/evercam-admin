defmodule EvercamAdmin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      EvercamAdminWeb.Endpoint,
      # Starts a worker by calling: EvercamAdmin.Worker.start_link(arg)
      :hackney_pool.child_spec(:snapshot_pool, [timeout: 5000, max_connections: 1000]),
      :hackney_pool.child_spec(:seaweedfs_upload_pool, [timeout: 5000, max_connections: 1000]),
      :hackney_pool.child_spec(:seaweedfs_download_pool, [timeout: 5000, max_connections: 1000]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EvercamAdmin.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    EvercamAdminWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
