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
    get "/construction_cameras", CamerasController, :construction_cameras
    get "/camera_shares", CameraSharesController, :index
    get "/camera_share_requests", CameraShareRequestsController, :index
    delete "/camera_share_requests", CameraShareRequestsController, :delete
    delete "/vendor_models/:exid", VendorModelsController, :delete
    get "/vendor_models", VendorModelsController, :index
    post "/vendor_models", VendorModelsController, :create
    get "/all_vendors", VendorsController, :vendors
    get "/vendors", VendorsController, :index
    post "/vendors", VendorsController, :create
    delete "/vendors/:exid", VendorsController, :delete
    get "/cloud_recordings", CloudRecordingsController, :index
    get "/admins", AdminsController, :index
    get "/archives", ArchivesController, :index
    get "/compares", ComparesController, :index
    get "/snapmails", SnapmailsController, :index
    get "/snapmail_history", SnapmailsController, :history
    patch "/admins/:email", AdminsController, :update
    delete "/admins/:email", AdminsController, :delete
    get "/maps", MapsController, :index
    get "/snapshot_extractors", SnapshotExtractorsController, :index
  end

  scope "/", EvercamAdminWeb do
    pipe_through :browser

    get "/users/sign_out", PageController, :logout
    get "/users/sign_in", PageController, :login
    post "/users/sign_in", PageController, :create
    get "/*anything", PageController, :index
  end
end
