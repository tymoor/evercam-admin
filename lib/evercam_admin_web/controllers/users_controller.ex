defmodule EvercamAdminWeb.UsersController do
  use EvercamAdminWeb, :controller

  def index(conn, params) do
    [column, order] = params["sort"] |> String.split("|")

    first_sort = ["payment_method", "username", "fullname", "email", "api_id", "api_key", "cameras_owned", "camera_shares", "snapmail_count", "country", "company_name", "created_at", "last_login_at", "referral_url"]
    second_sort = ["total_cameras"]
    sorting1 =
      Enum.any?(first_sort, fn(x) -> x == column end)
      |> decide_sorting(column, order)

    sorting2 =
      Enum.any?(second_sort, fn(x) -> x == column end)
      |> decide_sorting(column, order)

    condition1 = decide_condition1(params)
    condition2 = decide_condition2(params)
    query = "select *, (cameras_owned + camera_shares) total_cameras from (
                 select *, (select count(cr.id) from cloud_recordings cr left join cameras c on c.owner_id=u.id where c.id=cr.camera_id and cr.status <>'off' and cr.storage_duration <> 1),
                 (select count(*) from cameras cc left join users uuu on cc.owner_id=uuu.id where uuu.id=u.id) cameras_owned,
                 (select count(*) from camera_shares cs left join users uuuu on cs.user_id=uuuu.id where uuuu.id = u.id) camera_shares,
                 (select count(*) from snapmails sm left join users suser on sm.user_id=suser.id where suser.id = u.id) snapmail_count,
                 (select name from countries ct left join users uuuuu on ct.id=uuuuu.country_id where uuuuu.id=u.id) country,
                 (select name from companies cp left join users uuuuuu on cp.id=uuuuuu.company_id where uuuuuu.id=u.id) company_name,
                 (select count(cs1.id) from camera_shares cs1 where cs1.user_id=u.id and cs1.camera_id = 279) share_id
                 from users u #{condition1} #{sorting1}
                ) t #{condition2} #{sorting2}"
    users = Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
    cols = Enum.map users.columns, &(String.to_atom(&1))
    roles = Enum.map users.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    total_records = users.num_rows
    per_page = String.to_integer(params["per_page"])
    current_page = String.to_integer(params["page"])
    {last_page, display_start, index_end} = Utils.pagination_info(total_records, per_page, current_page)

    data =
      Enum.reduce((display_start - 1)..(index_end - 1), [], fn i, acc ->
        user = Enum.at(roles, i)
        u = %{
          username: user[:username],
          name: user[:fullname],
          name_link: "<a href='https://dash.evercam.io/v2/cameras?api_id=#{user[:api_id]}&api_key=#{user[:api_key]}' target='_blank'>#{user[:firstname]} #{user[:lastname]} <i class='fa fa-external-link'></i></a> | <a href='https://dash2.evercam.io/v2/cameras?api_id=#{user[:api_id]}&api_key=#{user[:api_key]}' target='_blank' style='color: orange'><i class='fa fa-external-link'></i></a>",
          email: user[:email],
          api_id: user[:api_id],
          api_key: user[:api_key],
          cameras_owned: user[:cameras_owned],
          camera_shares: user[:camera_shares],
          total_cameras: user[:total_cameras],
          country: user[:country],
          company_name: user[:company_name],
          payment_method: user[:payment_method],
          id: user[:id],
          referral_url: user[:referral_url],
          snapmail_count: user[:snapmail_count],
          created_at: (if user[:created_at], do: Calendar.Strftime.strftime!(user[:created_at], "%A, %d %b %Y %l:%M %p"), else: ""),
          confirmed_at: (if user[:confirmed_at], do: Calendar.Strftime.strftime!(user[:confirmed_at], "%A, %d %b %Y %l:%M %p"), else: ""),
          last_login_at: (if user[:last_login_at], do: Calendar.Strftime.strftime!(user[:last_login_at], "%A, %d %b %Y %l:%M %p"), else: ""),
          social: "#{get_url("linkedin", user[:linkedin_url])}#{get_url("twitter", user[:twitter_url])}",
        }
        acc ++ [u]
      end)

    json(conn, Utils.paginator(display_start, index_end, params["sort"], total_records, per_page, current_page, data, "users", last_page))
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

  def without_company_intercom_users(conn, _params) do
    with {:ok, users} <- IntercomUsers.get_users() do
      filtered_users = users_with_no_companies(users)
      length = Enum.count(filtered_users)
      data =
        case length <= 0 do
          true -> []
          _ ->
            Enum.reduce(0..length - 1, [], fn i, acc ->
              user = Enum.at(filtered_users, i)
              u = %{
                id: user["id"],
                email: user["email"],
                username: user["user_id"],
                created_at: user["created_at"],
                name: user["name"],
                domain: (if user["email"], do: String.split(user["email"], "@") |> List.last, else: ""),
                status: (if user["custom_attributes"]["status"], do: user["custom_attributes"]["status"], else: "")
              }
              acc ++ [u]
            end)
        end
      json(conn, %{data: data})
    else
      _ ->
        json(conn, %{data: []})
    end
  end

  defp get_url(_icon, url) when url in ["", nil], do: ""
  defp get_url(icon, url), do: "<a href='#{url}' target='_blank'><i class='#{icon} icon'></i></a>"

  defp users_with_no_companies(users) do
    Enum.filter(users, fn user ->
      %{"companies" => %{"companies" => companies}} = user
      length(companies) == 0
    end)
  end

  defp decide_sorting(true , column, order), do: sorting(column, order)
  defp decide_sorting(false , _column, _order), do: ""

  defp decide_condition1(params) do
    Enum.reduce(params, "where 1=1", fn param, condition = _acc ->
      {name, value} = param
      cond do
        name == "username" && value != "" -> condition <> " and lower(u.username) like lower('%#{value}%')"
        name == "email" && value != "" -> condition <> " and lower(u.email) like lower('%#{value}%')"
        name == "fullname" && value != "" -> condition <> " and lower(u.firstname || ' ' || u.lastname) like lower('%#{value}%')"
        name == "payment_method" && value != "" -> condition <> " and u.payment_method=#{String.to_integer(value)}"
        name == "created_at_date" && value != "" -> condition <> " and u.created_at < date_trunc('month', CURRENT_DATE) - INTERVAL '#{String.to_integer(value) / 12.0} year'"
        name == "last_login_at_date" && value != "" -> condition <> " and u.last_login_at < date_trunc('month', CURRENT_DATE) - INTERVAL '#{String.to_integer(value) / 12.0} year'"
        name == "last_login_at_boolean" && value == "true" -> condition <> " and u.last_login_at is not null"
        name == "last_login_at_boolean" && value == "false" -> condition <> " and u.last_login_at is null"
        name == "last_login_at_boolean" && value == "whatever" -> condition <> ""
        true -> condition
      end
    end)
  end

  defp decide_condition2(params) do
    Enum.reduce(params, "where 1=1", fn param, condition = _acc ->
      {name, value} = param
      cond do
        name == "company_name" && value != "" -> condition <> " and lower(company_name) like lower('%#{value}%')"
        name == "country" && value != "" -> condition <> " and lower(country) like lower('%#{value}%')"
        name == "snapmail_count" && value != "" -> condition <> " and snapmail_count = #{params["snapmail_count"]}"
        name == "total_cameras" && value != "" -> condition <> " and (cameras_owned + camera_shares) = #{params["total_cameras"]}"
        name == "cameras_owned" && value != "" -> condition <> " and cameras_owned = #{params["cameras_owned"]}"
        name == "camera_shares" && value != "" -> condition <> " and camera_shares = #{params["camera_shares"]} and share_id = 0"
        true -> condition
      end
    end)
  end

  defp not_empty_params(name, param, conn) do
    case param do
      nil -> json(conn, %{error: "params '#{name}' is required.", success: false})
      _ -> :ok
    end
  end

  defp sorting("payment_method", order), do: "order by payment_method #{order}"
  defp sorting("username", order), do: "order by u.username #{order}"
  defp sorting("fullname", order), do: "order by u.firstname #{order}"
  defp sorting("email", order), do: "order by u.email #{order}"
  defp sorting("api_id", order), do: "order by u.api_id #{order}"
  defp sorting("api_key", order), do: "order by u.api_key #{order}"
  defp sorting("cameras_owned", order), do: "order by cameras_owned #{order}"
  defp sorting("camera_shares", order), do: "order by camera_shares #{order}"
  defp sorting("total_cameras", order), do: "order by total_cameras #{order}"
  defp sorting("snapmail_count", order), do: "order by snapmail_count #{order}"
  defp sorting("country", order), do: "order by country #{order}"
  defp sorting("company_name", order), do: "order by company_name #{order}"
  defp sorting("created_at", order), do: "order by created_at #{order}"
  defp sorting("last_login_at", order), do: "order by last_login_at #{order}"
  defp sorting("required_licence", order), do: "order by required_licence #{order}"
  defp sorting("valid_licence", order), do: "order by valid_licence #{order}"
  defp sorting("def", order), do: "order by def #{order}"
  defp sorting("referral_url", order), do: "order by referral_url #{order}"
  defp sorting("id", order), do: "order by u.id #{order}"
  defp sorting(_column, order), do: "order by u.id #{order}"
end