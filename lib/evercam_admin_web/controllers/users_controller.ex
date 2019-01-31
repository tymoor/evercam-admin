defmodule EvercamAdminWeb.UsersController do
  use EvercamAdminWeb, :controller

  def index(conn, params) do
    case_value = "(CASE WHEN (required_licence - (CASE WHEN valid_licence >=0 THEN valid_licence ELSE 0 END)) >= 0 THEN (required_licence - (CASE WHEN valid_licence >=0 THEN valid_licence ELSE 0 END)) ELSE 0 end)"
    [column, order] = params["sort"] |> String.split("|")

    first_sort = ["payment_method", "username", "name", "email", "api_id", "api_key", "cameras_owned", "camera_shares", "snapmail_count", "country", "created_at", "last_login_at", "required_licence", "referral_url"]
    second_sort = ["total_cameras", "valid_licence", "required_licence", "def"]
    sorting1 =
      Enum.any?(first_sort, fn(x) -> x == column end)
      |> decide_sorting(column, order)

    sorting2 =
      Enum.any?(second_sort, fn(x) -> x == column end)
      |> decide_sorting(column, order)

    condition1 = decide_condition1(params)
    condition2 = decide_condition2(params)
    query = "select *, #{case_value} def, (cameras_owned + camera_shares) total_cameras from (
                 select *, (select count(cr.id) from cloud_recordings cr left join cameras c on c.owner_id=u.id where c.id=cr.camera_id and cr.status <>'off' and cr.storage_duration <> 1) required_licence,
                 (select SUM(l.total_cameras) from licences l left join users uu on l.user_id=uu.id where uu.id=u.id and cancel_licence=false) valid_licence,
                 (select count(*) from cameras cc left join users uuu on cc.owner_id=uuu.id where uuu.id=u.id) cameras_owned,
                 (select count(*) from camera_shares cs left join users uuuu on cs.user_id=uuuu.id where uuuu.id = u.id) camera_shares,
                 (select count(*) from snapmails sm left join users suser on sm.user_id=suser.id where suser.id = u.id) snapmail_count,
                 (select name from countries ct left join users uuuuu on ct.id=uuuuu.country_id where uuuuu.id=u.id) country,
                 (select count(cs1.id) from camera_shares cs1 where cs1.user_id=u.id and cs1.camera_id = 279) share_id
                 from users u #{condition1} #{sorting1}
                ) t #{condition2} #{sorting2}"
    users = Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
    cols = Enum.map users.columns, &(String.to_atom(&1))
    roles = Enum.map users.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    total_records = users.num_rows
    d_length = String.to_integer(params["per_page"])
    display_length = if d_length < 0, do: total_records, else: d_length
    display_start = if String.to_integer(params["page"]) <= 1, do: 0, else: (String.to_integer(params["page"]) - 1) * display_length + 1
    index_e = ((String.to_integer(params["page"]) - 1) * display_length) + display_length
    index_end = if index_e > total_records, do: total_records - 1, else: index_e
    last_page = Float.round(total_records / (display_length / 1))

    data =
      Enum.reduce(display_start..index_end, [], fn i, acc ->
        user = Enum.at(roles, i)
        u = %{
          username: user[:username],
          name: user[:fullname],
          name_link: "<a href='https://dash.evercam.io/v1/cameras?api_id=#{user[:api_id]}&api_key=#{user[:api_key]}' target='_blank'>#{user[:firstname]} #{user[:lastname]} <i class='fa fa-external-link'></i></a>",
          email: user[:email],
          api_id: user[:api_id],
          api_key: user[:api_key],
          cameras_owned: user[:cameras_owned],
          camera_shares: user[:camera_shares],
          total_cameras: user[:total_cameras],
          country: user[:country],
          required_licence: user[:required_licence],
          valid_licence: user[:valid_licence],
          def: user[:def],
          payment_method: user[:payment_method],
          id: user[:id],
          referral_url: user[:referral_url],
          snapmail_count: user[:snapmail_count],
          created_at: (if user[:created_at], do: Calendar.Strftime.strftime!(user[:created_at], "%A, %d %b %Y %l:%M %p"), else: ""),
          confirmed_at: (if user[:confirmed_at], do: Calendar.Strftime.strftime!(user[:confirmed_at], "%A, %d %b %Y %l:%M %p"), else: ""),
          last_login_at: (if user[:last_login_at], do: Calendar.Strftime.strftime!(user[:last_login_at], "%A, %d %b %Y %l:%M %p"), else: "")
        }
        acc ++ [u]
      end)

    records = %{
      data: (if total_records < 1, do: [], else: data),
      total: total_records,
      per_page: display_length,
      from: display_start,
      to: index_end,
      current_page: String.to_integer(params["page"]),
      last_page: last_page,
      next_page_url: (if String.to_integer(params["page"]) == last_page, do: "", else: "/v1/users?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) + 1}"),
      prev_page_url: (if String.to_integer(params["page"]) < 1, do: "", else: "/v1/users?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) - 1}")
    }
    json(conn, records)
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
    cond do
      params["total_cameras"] != "" && params["total_cameras"] != nil -> "where (cameras_owned + camera_shares) = #{params["total_cameras"]}"
      params["cameras_owned"] != "" && params["camera_shares"] != "" && params["cameras_owned"] != nil && params["camera_shares"] != nil && params["include_erc"] != "" && params["include_erc"] == "true" ->
        "where cameras_owned < #{params["cameras_owned"]} and camera_shares < #{params["camera_shares"]} and share_id > 0"
      params["cameras_owned"] != "" && params["camera_shares"] != "" && params["include_erc"] != "" && params["cameras_owned"] != nil && params["camera_shares"] != nil && params["include_erc"] != nil && params["include_erc"] == "false" ->
        "where cameras_owned < #{params["cameras_owned"]} and camera_shares < #{params["camera_shares"]} and share_id = 0"
      params["camera_shares"] != "" && params["include_erc"] != "" && params["camera_shares"] != nil && params["include_erc"] != nil && params["include_erc"] == "false" ->
        "where camera_shares < #{params["camera_shares"]} and share_id = 0"
      params["camera_shares"] != "" && params["include_erc"] != "" && params["camera_shares"] != nil && params["include_erc"] != nil && params["include_erc"] == "true" ->
        "where camera_shares < #{params["camera_shares"]} and share_id > 0"
      params["cameras_owned"] != "" && params["include_erc"] != "" && params["cameras_owned"] != nil && params["include_erc"] != nil && params["include_erc"] == "false" ->
        "where cameras_owned < #{params["cameras_owned"]} and share_id = 0"
      params["cameras_owned"] != "" && params["include_erc"] != "" && params["cameras_owned"] != nil && params["include_erc"] != nil && params["include_erc"] == "true" ->
        "where cameras_owned < #{params["cameras_owned"]} and share_id > 0"
      params["cameras_owned"] != "" && params["camera_shares"] != "" && params["cameras_owned"] != nil && params["camera_shares"] != nil ->
        "where cameras_owned < #{params["cameras_owned"]} and camera_shares < #{params["camera_shares"]}"
      params["camera_shares"] != "" && params["camera_shares"] != nil ->
        "where camera_shares < #{params["camera_shares"]}"
      params["cameras_owned"] != "" && params["cameras_owned"] != nil ->
        "where cameras_owned < #{params["cameras_owned"]}"
      params["licREQ1"] != "" && params["licREQ2"] != "" && params["licREQ1"] != nil && params["licREQ2"] != nil ->
        "where required_licence > #{params["licREQ1"]} and required_licence < #{params["licREQ2"]}"
      params["licVALID1"] != "" && params["licVALID2"] != "" && params["licVALID1"] != nil && params["licVALID2"] != nil ->
        "where valid_licence > #{params["licVALID1"]} and valid_licence < #{params["licVALID2"]}"
      params["licDEF1"] != "" && params["licDEF2"] != "" && params["licDEF1"] != nil && params["licDEF2"] != nil ->
        "where (required_licence - (CASE WHEN valid_licence >=0 THEN valid_licence ELSE 0 END)) > #{params["licDEF1"]} and (required_licence - (CASE WHEN valid_licence >=0 THEN valid_licence ELSE 0 END)) < #{params["licDEF2"]}"
      params["licDEF1"] != "" && params["licDEF1"] != nil ->
        "where (required_licence - (CASE WHEN valid_licence >=0 THEN valid_licence ELSE 0 END)) > #{params["licDEF1"]}"
      params["licDEF2"] != "" && params["licDEF2"] != nil ->
        "where (required_licence - (CASE WHEN valid_licence >=0 THEN valid_licence ELSE 0 END)) < #{params["licDEF2"]}"
      params["licVALID1"] != "" && params["licVALID1"] != nil ->
        "where valid_licence > #{params["licVALID1"]}"
      params["licVALID2"] != "" && params["licVALID2"] != nil ->
        "where valid_licence < #{params["licVALID2"]}"
      params["licREQ1"] != "" && params["licREQ1"] != nil ->
        "where required_licence > #{params["licREQ1"]}"
      params["licREQ2"] != "" && params["licREQ2"] != nil ->
        "where required_licence < #{params["licREQ2"]}"
      params["include_erc"] != "" && params["include_erc"] == "false" ->
        "where share_id = 0"
      params["include_erc"] != "" && params["include_erc"] == "true" ->
        "where share_id > 0"
      params["include_erc"] != "" && params["include_erc"] == "whatever" ->
        ""
      true -> ""
    end
  end

  defp not_empty_params(name, param, conn) do
    case param do
      nil -> json(conn, %{error: "params '#{name}' is required.", success: false})
      _ -> :ok
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