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

  # Other scopes may use custom stacks.
  scope "/v1", EvercamAdminWeb do
    pipe_through :api

    get "/users", UsersController, :index
    get "/countries", UsersController, :countries
    patch "/update_multiple_users", UsersController, :update_multiple_users
    get "/cameras", CamerasController, :index
    get "/camera_shares", CameraSharesController, :index
  end

  scope "/", EvercamAdminWeb do
    pipe_through :browser

    get "/users/sign_out", PageController, :logout
    get "/users/sign_in", PageController, :login
    post "/users/sign_in", PageController, :create
    get "/*anything", PageController, :index
  end
end
