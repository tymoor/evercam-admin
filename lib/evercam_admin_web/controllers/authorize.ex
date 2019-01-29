defmodule EvercamAdmin.Authorize do
  import Plug.Conn
  import Phoenix.Controller

  def user_check(conn, _opts) do
    get_session(conn, :user_id)
    |> bypass_request(conn)
  end

  def bypass_request(nil, conn), do: auth_error conn, "You need to log in to view this page", "/users/sign_in"
  def bypass_request(_, conn), do: conn

  def auth_error(conn, message, path) do
    conn
    |> put_flash(:danger, message)
    |> redirect(to: path)
    |> halt
  end
end