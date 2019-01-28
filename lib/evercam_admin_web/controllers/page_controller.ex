defmodule EvercamAdminWeb.PageController do
  use EvercamAdminWeb, :controller

  def index(conn, _) do
    render(conn, "index.html")
  end

  def login(conn, _) do
    render(conn, "login.html")
  end
end
