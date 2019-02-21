defmodule EvercamAdminWeb.AdminsController do
  use EvercamAdminWeb, :controller
  import Ecto.Query

  def index(conn, params) do
    [column, order] = params["sort"] |> String.split("|")
    search = if params["search"] in ["", nil], do: "", else: params["search"]
    query = from admin in User,
              where: admin.is_admin == true,
              or_where: like(fragment("lower(?)", admin.firstname), ^("%#{search}%")),
              or_where: like(fragment("lower(?)", admin.lastname), ^("%#{search}%")),
              or_where: like(fragment("lower(?)", admin.email), ^("%#{search}%"))
    admins = query |> add_sorting(column, order) |> Evercam.Repo.all()

    total_records = admins |> Enum.count
    d_length = String.to_integer(params["per_page"])
    display_length = if d_length < 0, do: total_records, else: d_length
    display_start = if String.to_integer(params["page"]) <= 1, do: 0, else: (String.to_integer(params["page"]) - 1) * display_length + 1
    index_e = ((String.to_integer(params["page"]) - 1) * display_length) + display_length
    index_end = if index_e > total_records, do: total_records - 1, else: index_e
    last_page = Float.round(total_records / (display_length / 1))

    data =
      case total_records <= 0 do
        true -> []
        _ ->
          Enum.reduce(display_start..index_end, [], fn i, acc ->
            admin = Enum.at(admins, i)
            a = %{
              fullname: admin.firstname <> admin.lastname,
              email: admin.email,
              created_at: admin.created_at,
              udpated_at: admin.updated_at,
              last_sign_in_at: admin.last_login_at,
              current_sign_in_at: admin.current_sign_in_at,
              sign_in_count: admin.sign_in_count,
              last_sign_in_ip: get_ipv4(admin.last_sign_in_ip)
            }
            acc ++ [a]
          end)
      end

    records = %{
      data: (if total_records < 1, do: [], else: data),
      total: total_records,
      per_page: display_length,
      from: display_start,
      to: index_end,
      current_page: String.to_integer(params["page"]),
      last_page: last_page,
      next_page_url: (if String.to_integer(params["page"]) == last_page, do: "", else: "/v1/vendor_models?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) + 1}"),
      prev_page_url: (if String.to_integer(params["page"]) < 1, do: "", else: "/v1/vendor_models?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) - 1}")
    }
    json(conn, records)
  end

  defp get_ipv4(nil), do: ""
  defp get_ipv4(%Postgrex.INET{address: ipv4}) do
    to_string(:inet_parse.ntoa(ipv4))
  end

  defp sort_order("asc"), do: :asc
  defp sort_order("desc"), do: :desc

  defp add_sorting(query, "fullname", order) do
    from [admin] in query,
      order_by: [{^sort_order(order), admin.firstname}]
  end
  defp add_sorting(query, "email", order) do
    from [admin] in query,
      order_by: [{^sort_order(order), admin.email}]
  end
  defp add_sorting(query, "created_at", order) do
    from [admin] in query,
      order_by: [{^sort_order(order), admin.created_at}]
  end
  defp add_sorting(query, "udpated_at", order) do
    from [admin] in query,
      order_by: [{^sort_order(order), admin.udpated_at}]
  end
  defp add_sorting(query, "last_sign_in_at", order) do
    from [admin] in query,
      order_by: [{^sort_order(order), admin.last_login_at}]
  end
  defp add_sorting(query, "current_sign_in_at", order) do
    from [admin] in query,
      order_by: [{^sort_order(order), admin.current_sign_in_at}]
  end
  defp add_sorting(query, "sign_in_count", order) do
    from [admin] in query,
      order_by: [{^sort_order(order), admin.sign_in_count}]
  end
  defp add_sorting(query, "last_sign_in_ip", order) do
    from [admin] in query,
      order_by: [{^sort_order(order), admin.last_sign_in_ip}]
  end
end