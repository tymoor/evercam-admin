defmodule EvercamAdminWeb.PageController do
  use EvercamAdminWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
