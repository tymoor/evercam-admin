defmodule EvercamAdminWeb.IntercomController do
  use EvercamAdminWeb, :controller
  require Logger

  @intercom_url "https://api.intercom.io"
  @intercom_token "dG9rOmM3NDcyOGIyXzA2NDNfNDBkN185OWQzXzlmNzEzOWFlNDczNDoxOjA="

  def create(conn, params) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- create_company(params) do
      company = Jason.decode!(body)
      update_users_companies(params["add_users"], company)
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
                id: company["id"],
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

  def delete(conn, params) do
    hash_company_id = params["id"]
    company_id = params["company_id"]
    spawn fn ->
      company_users = get_company_users(hash_company_id)
      unlink_users_from_company(company_users, company_id)
    end
    json(conn, %{success: true})
  end

  def add_company_to_users(conn, params) do
    headers = ["Authorization": "Bearer #{@intercom_token}", "Accept": "Accept:application/json", "Content-Type": "application/json"]
    emails_list = String.split(params["emails"], ",")

    spawn fn ->
      Enum.each(emails_list, fn(email) ->
        company_domain = String.split(email, "@") |> List.last
        company_id =
          case Intercom.get_company(company_domain) do
            {:ok, company} -> company["company_id"]
            _ ->
              Logger.info "Company does not found for #{email}."
              Intercom.create_company(company_domain, String.split(company_domain, ".") |> List.first |> String.capitalize)
              company_domain
          end

        case Intercom.get_user(email) do
          {:ok, response} ->
            intercom_user = response.body |> Poison.decode!
            Logger.info "Adding company for email: #{email}, intercom_id: #{intercom_user["id"]}, company_id: #{company_id}"
            intercom_new_user = %{
              id: intercom_user["id"],
              companies: [%{company_id: company_id}]
            }
            |> Poison.encode!
            HTTPoison.post(@intercom_url <> "/users", intercom_new_user, headers)
          _ -> ""
        end
      end)
    end

    json(conn, %{success: true})
  end

  defp unlink_users_from_company(company_users, company_id) do
    Enum.each(company_users, fn user ->
      user = %{
        id: user["id"],
        companies: [
          %{
            company_id: "#{company_id}",
            remove: true
          }
        ]
      }

      headers = ["Authorization": "Bearer #{@intercom_token}", "Accept": "Accept:application/json", "Content-Type": "application/json"]
      url = "#{@intercom_url}/users"
      json = Jason.encode!(user)
      HTTPoison.post(url, json, headers)
    end)
  end

  defp get_company_users(id) do
    url = "#{@intercom_url}/companies/#{id}/users"
    headers = ["Authorization": "Bearer #{@intercom_token}", "Accept": "Accept:application/json"]
    response = HTTPoison.get(url, headers) |> elem(1)
    case response.status_code do
      200 -> Jason.decode!(response.body)["users"]
      _ -> []
    end
  end

  defp update_users_companies(value, company) when value in ["true", true] do
    spawn fn ->
      add_users(company)
    end
  end
  defp update_users_companies(_value, _company), do: :noop

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
    case Intercom.get_user(email) do
      {:ok, response} -> Jason.decode!(response.body)
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
