defmodule EvercamAdminWeb.Router do
  use EvercamAdminWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EvercamAdminWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/users/sign_in", PageController, :login
  end

  # Other scopes may use custom stacks.
  # scope "/api", EvercamAdminWeb do
  #   pipe_through :api
  # end
end
