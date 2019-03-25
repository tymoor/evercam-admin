defmodule EvercamAdminWeb.IntercomController do
  use EvercamAdminWeb, :controller
  require Logger

  @intercom_url System.get_env["INTERCOM_URL"]
  @intercom_token System.get_env["INTERCOM_ACCESS_TOKEN"]

  def create(conn, params) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- create_company(params) do
      company = Jason.decode!(body)
      spawn fn ->
        add_users(company)
      end
      json(conn, %{success: true})
    else
      _->
        json(conn |> put_status(400), %{success: false})
    end
  end

  def index(conn, _params) do
    with {:ok, companies} <- Intercom.get_companies() do
      length = Enum.count(companies)
      data =
        case length <= 0 do
          true -> []
          _ ->
            Enum.reduce(0..length - 1, [], fn i, acc ->
              company = Enum.at(companies, i)
              comp = %{
                company_id: company["company_id"],
                name: company["name"],
                session_count: company["session_count"],
                user_count: company["user_count"],
                created_at: company["created_at"]
              }
              acc ++ [comp]
            end)
        end
      json(conn, %{data: data})
    else
      _ ->
        json(conn, %{data: []})
    end
  end

  defp add_users(company) do
    users = Ecto.Adapters.SQL.query!(Evercam.Repo, "select * from users where email like '%@#{company["company_id"]}'", [])
    cols = Enum.map users.columns, &(String.to_atom(&1))
    roles = Enum.map users.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    Enum.each(roles, fn(db_user) ->
      with :not_found <- find_user(db_user[:email]) do
        Logger.info "User not found."
      else
        user ->
          new_user = %{
            id: user["id"],
            companies: [%{
              company_id: company["company_id"],
              name: company["name"]
              }]
          }
          json = Jason.encode!(new_user)
          url = "#{@intercom_url}/users"
          headers = ["Authorization": "Bearer #{@intercom_token}", "Accept": "Accept:application/json", "Content-Type": "application/json"]
          HTTPoison.post(url, json, headers)
      end
    end)
  end

  defp find_user(email) do
    url = "#{@intercom_url}/users?email=#{email}"
    headers = ["Authorization": "Bearer #{@intercom_token}", "Accept": "Accept:application/json"]
    response = HTTPoison.get(url, headers) |> elem(1)
    case response.status_code do
      200 -> Jason.decode!(response.body)
      _ -> :not_found
    end
  end

  defp create_company(params) do
    company = %{
      company_id: params["company_id"],
      name:  params["company_name"],
      created_at: Calendar.DateTime.now_utc |> Calendar.DateTime.Format.unix
    }
    headers = ["Authorization": "Bearer #{@intercom_token}", "Accept": "Accept:application/json", "Content-Type": "application/json"]
    url = "#{@intercom_url}/companies"
    json = Jason.encode!(company)
    HTTPoison.post(url, json, headers)
  end
end
