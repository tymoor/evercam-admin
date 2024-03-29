defmodule EvercamAdminWeb.CameraShareRequestsController do
  use EvercamAdminWeb, :controller

  def index(conn, params) do
    [column, order] = params["sort"] |> String.split("|")

    query = "SELECT csr.*, u.firstname || ' ' || u.lastname as fullname, cam.name as camera
            FROM camera_share_requests as csr
            LEFT JOIN users as u ON csr.user_id = u.id
            LEFT JOIN cameras as cam ON csr.camera_id = cam.id
            #{condition(params)}
            #{sorting(column, order)}"

    camera_share_requests = Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
    cols = Enum.map camera_share_requests.columns, &(String.to_atom(&1))
    roles = Enum.map camera_share_requests.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    total_records = camera_share_requests.num_rows
    per_page = String.to_integer(params["per_page"])
    current_page = String.to_integer(params["page"])
    {last_page, display_start, index_end} = Utils.pagination_info(total_records, per_page, current_page)
    data =
      Enum.reduce((display_start - 1)..(index_end - 1), [], fn i, acc ->
        camera_share_request = Enum.at(roles, i)
        csr = %{
          id: camera_share_request[:id],
          sharee_email: camera_share_request[:email],
          camera: camera_share_request[:camera],
          sharer: camera_share_request[:fullname],
          message: camera_share_request[:message],
          rights: translate_rights(camera_share_request[:rights]),
          status: camera_share_request[:status],
          created_at: (if camera_share_request[:created_at], do: Calendar.Strftime.strftime!(camera_share_request[:created_at], "%A, %d %b %Y %l:%M %p"), else: "")
        }
        acc ++ [csr]
      end)

    json(conn, Utils.paginator(display_start, index_end, params["sort"], total_records, per_page, current_page, data, "camera_share_requests", last_page))
  end

  def delete(conn, %{"ids" => ids} = _params) do
    query = "delete from camera_share_requests where id in (#{ids})"
    Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
    json(conn, %{success: true})
  end

  defp translate_rights("list,snapshot"), do: "Read Only"
  defp translate_rights(_rights), do: "Full Rights"

  defp condition(params) do
    Enum.reduce(params, "where 1=1", fn param, condition = _acc ->
      {name, value} = param
      cond do
        name == "sharer" && value != "" -> condition <> " and lower(u.firstname || ' ' || u.lastname) like lower('%#{value}%')"
        name == "camera" && value != "" -> condition <> " and lower(cam.name) like lower('%#{value}%')"
        name == "sharee_email" && value != "" -> condition <> " and lower(csr.email) like lower('%#{value}%')"
        name == "status" && value != "" -> condition <> " and status=#{value}"
        true -> condition
      end
    end)
  end

  defp sorting("created_at", order), do: "ORDER BY csr.created_at #{order}"
  defp sorting("sharer", order), do: "ORDER BY lower(u.firstname || ' ' || u.lastname) #{order}"
  defp sorting("sharee_email", order), do: "ORDER BY csr.email #{order}"
  defp sorting("rights", order), do: "ORDER BY csr.rights #{order}"
  defp sorting("status", order), do: "ORDER BY csr.status #{order}"
  defp sorting("camera", order), do: "ORDER BY cam.name #{order}"
  defp sorting(_column, _order), do: "ORDER BY csr.created_at desc"
end