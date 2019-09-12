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
    get "/without_company_intercom_users", UsersController, :without_company_intercom_users
    get "/cameras", CamerasController, :index
    options "/cameras", CamerasController, :nothing
    get "/extraction_cameras", CamerasController, :extraction_cameras
    get "/onvif_cameras", CamerasController, :onvif_cameras
    get "/duplicate_cameras", CamerasController, :duplicate_cameras
    get "/camera_shares", CameraSharesController, :index
    post "/camera_shares", CameraSharesController, :create
    delete "/camera_shares/:share_id", CameraSharesController, :delete
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
    get "/intercom_companies", IntercomController, :index
    post "/intercom_companies", IntercomController, :create
    delete "/intercom_companies", IntercomController, :delete
    post "/add_company_to_users", IntercomController, :add_company_to_users
    get "/existing_companies", IntercomController, :existing_companies
    post "/snapshot_extractors", SnapshotExtractorsController, :create
    delete "/snapshot_extractors", SnapshotExtractorsController, :delete
    get "/snapshot_extractors", SnapshotExtractorsController, :index
    get "/meta_datas", MetaDatasController, :index
    get "/sync_stat_metadata", MetaDatasController, :sync_stat_metadata
    get "/nvrs", NvrsController, :index
    get "/storage", StorageController, :index
    get "/storage_refresh", StorageController, :refresh

    get "/projects", ProjectsController, :index
    get "/projects/owner", ProjectsController, :get_owner
    patch "/projects", ProjectsController, :update
    post "/projects", ProjectsController, :create
    delete "/projects", ProjectsController, :delete
    get "/search_project", ProjectsController, :search_project
    post "/add_to_project", CamerasController, :add_to_project
    get "/project_cameras", CamerasController, :project_cameras
    delete "/camera_from_project", CamerasController, :delete_camera_from_project
  end

  scope "/", EvercamAdminWeb do
    pipe_through :browser

    get "/users/sign_out", PageController, :logout
    get "/users/sign_in", PageController, :login
    post "/users/sign_in", PageController, :create
    get "/*anything", PageController, :index
  end
end
