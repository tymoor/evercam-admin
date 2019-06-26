defmodule EvercamAdminWeb.PageController do
  use EvercamAdminWeb, :controller
  import Plug.Conn
  import EvercamAdmin.Authorize

  plug :user_check when action in [:index]

  def index(conn, _) do
    render(conn, "index.html", current_user: current_user_for_vue(conn), api_url: Application.get_env(:evercam_admin, :evercam_server))
  end

  def login(conn, _) do
    render(conn, "login.html")
  end

  def logout(conn, _) do
    conn
    |> clear_session
    |> put_flash(:info, "You have logged out.")
    |> redirect(to: "/users/sign_in")
  end

  def create(conn, params) do
    user = User.by_username_or_email(params["user"]["email"])
    with true <- user?(user),
         true <- is_admin_user(user.is_admin, user.email),
         true <- password(params["user"]["password"], user)
    do
      conn
      |> put_session(:user_id, user.id)
      |> put_flash(:info, "You have logged In")
      |> redirect(to: "/")
    else
      {:wrong, username_or_password} ->
        conn
        |> put_flash(:danger, "#{username_or_password} is wrong.")
        |> redirect(to: "/users/sign_in")
      {:forbidden, message} ->
        conn
        |> put_flash(:danger, message)
        |> redirect(to: "/users/sign_in")
    end
  end

  defp user?(nil), do: {:wrong, "Email"}
  defp user?(_), do: true

  defp password(password, user) do
    if Comeonin.Bcrypt.checkpw(password, user.password) do
      true
    else
      {:wrong, "Password"}
    end
  end

  defp is_admin_user(true, _), do: true
  defp is_admin_user(_, email), do: {:forbidden, "#{email} is not an admin."}

  defp current_user_for_vue(conn) do
    user = Evercam.Repo.get!(User, get_session(conn, :user_id))
    %{
      username: user.username,
      password: user.password,
      email: user.email,
      user_id: user.id,
      firstname: user.firstname,
      lastname: user.lastname
    } |> Jason.encode!
  end
end
