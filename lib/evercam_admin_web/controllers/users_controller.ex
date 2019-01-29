defmodule EvercamAdminWeb.UsersController do
  use EvercamAdminWeb, :controller
  require IEx

  def index(conn, params) do
    IEx.pry
    case_value = "(CASE WHEN (required_licence - (CASE WHEN valid_licence >=0 THEN valid_licence ELSE 0 END)) >= 0 THEN (required_licence - (CASE WHEN valid_licence >=0 THEN valid_licence ELSE 0 END)) ELSE 0 end)"
    [column, order] = params["sort"] |> String.split("|")

    first_sort = ["payment_method", "username", "name", "email", "api_id", "api_key", "cameras_owned", "camera_shares", "snapmail_count", "country", "created_at", "last_login_at", "required_licence", "referral_url"]
    second_sort = ["total_cameras", "valid_licence", "required_licence", "def"]
  end

  def countries(conn, _params) do
    countries =
      Country
      |> Evercam.Repo.all
      |> Enum.map(fn(country) ->
        %{
          id: country.id,
          name: country.name
        }
      end)
    json(conn, %{countries: countries})
  end

  def update_multiple_users(conn, params) do
    with :ok <- not_empty_params("ids", params["ids"], conn),
         :ok <- not_empty_params("payment_type", params["payment_type"], conn),
         :ok <- not_empty_params("country", params["country"], conn)
    do
      query = "update users set updated_at=now(),payment_method=#{params["payment_type"]},country_id=#{params["country"]} where id in (#{params["ids"]})"
      Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
      json(conn, %{success: true})
    end
  end

  defp not_empty_params(name, param, conn) do
    case not_nil(param) do
      true -> :ok
      false -> json(conn, %{error: "params '#{name}' is required.", success: false})
    end
  end

  defp not_nil(nil), do: false
  defp not_nil(_), do: true

  defp sorting("payment_method", order), do: "order by payment_method #{order}"
  defp sorting("username", order), do: "order by u.username #{order}"
  defp sorting("name", order), do: "order by u.firstname #{order}"
  defp sorting("email", order), do: "order by u.email #{order}"
  defp sorting("api_id", order), do: "order by u.api_id #{order}"
  defp sorting("api_key", order), do: "order by u.api_key #{order}"
  defp sorting("cameras_owned", order), do: "order by cameras_owned #{order}"
  defp sorting("camera_shares", order), do: "order by camera_shares #{order}"
  defp sorting("total_cameras", order), do: "order by total_cameras #{order}"
  defp sorting("snapmail_count", order), do: "order by snapmail_count #{order}"
  defp sorting("country", order), do: "order by country #{order}"
  defp sorting("created_at", order), do: "order by created_at #{order}"
  defp sorting("last_login_at", order), do: "order by last_login_at #{order}"
  defp sorting("required_licence", order), do: "order by required_licence #{order}"
  defp sorting("valid_licence", order), do: "order by valid_licence #{order}"
  defp sorting("def", order), do: "order by def #{order}"
  defp sorting("referral_url", order), do: "order by referral_url #{order}"
  defp sorting("id", order), do: "order by u.id #{order}"
  defp sorting(_column, order), do: "order by u.id #{order}"
end