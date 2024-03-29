defmodule EvercamAdminWeb.IntercomController do
  use EvercamAdminWeb, :controller
  require Logger
  import Ecto.Query

  @intercom_url "https://api.intercom.io"
  @intercom_token "#{System.get_env["INTERCOM_ACCESS_TOKEN"]}"

  def create(conn, params) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- create_company(params) do
      company = Jason.decode!(body)
      existing_company = Company.by_exid(params["company_exid"]) || %Company{}
      {:ok, db_company} = Company.changeset(existing_company, %{linkedin_url: params["linkedIn_URL"], name: params["company_name"], exid: params["company_exid"]}) |> Evercam.Repo.insert_or_update
      update_users_companies(params["add_users"], company, db_company.id)
      json(conn, %{success: true})
    else
      _->
        json(conn |> put_status(400), %{success: false})
    end
  end

  def index(conn, params) do
    [column, order] = params["sort"] |> String.split("|")
    search = if params["search"] in ["", nil], do: "", else: params["search"]

    query = "select *
            from companies
            where lower(exid) like lower('%#{search}%') or lower(name) like lower('%#{search}%') or lower(linkedin_url) like lower('%#{search}%')
            #{sorting(column, order)}"

    companies = Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
    cols = Enum.map companies.columns, &(String.to_atom(&1))
    roles = Enum.map companies.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    total_records = companies.num_rows
    per_page = String.to_integer(params["per_page"])
    current_page = String.to_integer(params["page"])
    {last_page, display_start, index_end} = Utils.pagination_info(total_records, per_page, current_page)

    data =
      Enum.reduce((display_start - 1)..(index_end - 1), [], fn i, acc ->
        company = Enum.at(roles, i)
        c = %{
          id: company[:id],
          exid: company[:exid],
          inserted_at: (if company[:inserted_at], do: Calendar.Strftime.strftime!(company[:inserted_at], "%A, %d %b %Y %l:%M %p"), else: ""),
          name: company[:name],
          social: linkedin_url(company[:linkedin_url]),
          size: company[:size],
          session_count: company[:session_count],
          linkedin_url: company[:linkedin_url]
        }
        acc ++ [c]
      end)

    json(conn, Utils.paginator(display_start, index_end, params["sort"], total_records, per_page, current_page, data, "companies", last_page))
  end

  def existing_companies(conn, params) do
    search = if params["search"] in ["", nil], do: "", else: params["search"]
    companies =
      Company
      |> where([comp], like(fragment("lower(?)", comp.name), ^("%#{String.downcase(search)}%")))
      |> Evercam.Repo.all
      |> Enum.reduce([], fn company, acc ->
        comp = %{
          name: company.name
        }
        acc ++ [comp]
      end)
    json(conn, companies)
  end

  def delete(conn, params) do
    company_id = params["company_exid"]
    company = Company.by_exid(company_id)
    User
    |> where(company_id: ^company.id)
    |> Evercam.Repo.all
    |> Enum.each(fn user ->
      User.update_changeset(user, %{company_id: nil}) |> Evercam.Repo.update!
    end)
    company |> Evercam.Repo.delete!

    spawn fn ->
      company_users = get_company_users(company_id)
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
            intercom_user = response.body |> Jason.decode!
            Logger.info "Adding company for email: #{email}, intercom_id: #{intercom_user["id"]}, company_id: #{company_id}"
            intercom_new_user = %{
              id: intercom_user["id"],
              companies: [%{company_id: company_id}]
            }
            |> Jason.encode!
            HTTPoison.post(@intercom_url <> "/users", intercom_new_user, headers)
          _ -> ""
        end
      end)
    end

    json(conn, %{success: true})
  end

  defp linkedin_url(value) when value in ["", nil], do: ""
  defp linkedin_url(value) do
    "<a href='#{value}' target='_blank'><i class='linkedin icon'></i></a>"
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
    url = "#{@intercom_url}/companies?company_id#{id}&type=user"
    headers = ["Authorization": "Bearer #{@intercom_token}", "Accept": "Accept:application/json"]
    response = HTTPoison.get(url, headers) |> elem(1)
    case response.status_code do
      200 -> Jason.decode!(response.body)["users"]
      _ -> []
    end
  end

  defp update_users_companies(value, company, id) when value in ["true", true] do
    spawn fn ->
      add_users(company, id)
    end
  end
  defp update_users_companies(_value, _company, _id), do: :noop

  defp add_users(company, id) do
    users = Ecto.Adapters.SQL.query!(Evercam.Repo, "select * from users where email like '%@#{company["company_id"]}'", [])
    cols = Enum.map users.columns, &(String.to_atom(&1))
    roles = Enum.map users.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    Enum.each(roles, fn(db_user) ->

      User.update_changeset(struct(User, db_user), %{company_id: id}) |> Evercam.Repo.update!

      with :not_found <- find_user(db_user[:email]) do
        Logger.info "User not found."
      else
        user ->
          new_user = %{
            id: user["id"],
            companies: [%{
              company_id: company["company_exid"],
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
      company_id: params["company_exid"],
      name:  params["company_name"],
      created_at: Calendar.DateTime.now_utc |> Calendar.DateTime.Format.unix
    }
    headers = ["Authorization": "Bearer #{@intercom_token}", "Accept": "Accept:application/json", "Content-Type": "application/json"]
    url = "#{@intercom_url}/companies"
    json = Jason.encode!(company)
    HTTPoison.post(url, json, headers)
  end

  defp sorting("exid", order), do: "order by exid #{order}"
  defp sorting("name", order), do: "order by name #{order}"
  defp sorting("inserted_at", order), do: "order by inserted_at #{order}"
  defp sorting("size", order), do: "order by size #{order}"
  defp sorting("session_count", order), do: "order by session_count #{order}"
  defp sorting("linkedin_url", order), do: "order by linkedin_url #{order}"
end
