defmodule EvercamAdminWeb.AdminsController do
  use EvercamAdminWeb, :controller
  import Ecto.Query

  def index(conn, params) do
    [column, order] = params["sort"] |> String.split("|")
    search = if params["search"] in ["", nil], do: "", else: params["search"]
    query = from admin in User,
              where: admin.is_admin == true,
              where: like(fragment("lower(?)", admin.email), ^("%#{search}%"))
    admins = query |> add_sorting(column, order) |> Evercam.Repo.all()

    total_records = admins |> Enum.count
    per_page = String.to_integer(params["per_page"])
    current_page = String.to_integer(params["page"])
    {last_page, display_start, index_end} = Utils.pagination_info(total_records, per_page, current_page)

    data =
      case total_records <= 0 do
        true -> []
        _ ->
          Enum.reduce((display_start - 1)..(index_end - 1), [], fn i, acc ->
            admin = Enum.at(admins, i)
            a = %{
              fullname: admin.firstname <> " " <> admin.lastname,
              email: admin.email,
              created_at: (if admin.created_at, do: Calendar.Strftime.strftime!(admin.created_at, "%A, %d %b %Y %l:%M %p"), else: ""),
              updated_at: (if admin.updated_at, do: Calendar.Strftime.strftime!(admin.updated_at, "%A, %d %b %Y %l:%M %p"), else: ""),
              last_sign_in_at: (if admin.last_login_at, do: Calendar.Strftime.strftime!(admin.last_login_at, "%A, %d %b %Y %l:%M %p"), else: ""),
              current_sign_in_at: (if admin.current_sign_in_at, do: Calendar.Strftime.strftime!(admin.current_sign_in_at, "%A, %d %b %Y %l:%M %p"), else: ""),
              sign_in_count: admin.sign_in_count,
              last_sign_in_ip: get_ipv4(admin.last_sign_in_ip)
            }
            acc ++ [a]
          end)
      end

    json(conn, Utils.paginator(display_start, index_end, params["sort"], total_records, per_page, current_page, data, "admins", last_page))
  end

  def update(conn, %{"email" => email} = _params) do
    with %User{} = user <- User.by_username_or_email(email),
         false <- user.is_admin
    do
      User.changeset(user, %{is_admin: true}) |> Evercam.Repo.update!
      json(conn, %{success: true})
    else
      true -> conn |> put_status(400) |> json(%{success: false, message: "User is already an admin."})
      nil -> conn |> put_status(404) |> json(%{success: false, message: "User not found."})
      _ -> conn |> put_status(400) |> json(%{success: false, message: "Something went wrong."})
    end
  end

  def delete(conn, %{"email" => email} = _params) do
    with %User{} = user <- User.by_username_or_email(email),
         true <- user.is_admin
    do
      User.changeset(user, %{is_admin: false}) |> Evercam.Repo.update!
      json(conn, %{success: true})
    else
      false -> conn |> put_status(400) |> json(%{success: false, message: "User is not an admin."})
      nil -> conn |> put_status(404) |> json(%{success: false, message: "User not found."})
      _ -> conn |> put_status(400) |> json(%{success: false, message: "Something went wrong."})
    end
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
  defp add_sorting(query, "updated_at", order) do
    from [admin] in query,
      order_by: [{^sort_order(order), admin.updated_at}]
  end
  defp add_sorting(query, "last_login_at", order) do
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