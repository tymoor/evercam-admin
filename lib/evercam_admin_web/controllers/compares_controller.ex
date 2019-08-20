defmodule EvercamAdminWeb.ComparesController do
  use EvercamAdminWeb, :controller

  def index(conn, params) do
    [column, order] = params["sort"] |> String.split("|")
    search = if params["search"] in ["", nil], do: "", else: params["search"]

    query = "select comp.*, u.firstname || ' ' || u.lastname as fullname, u.api_id, u.api_key, cam.exid as cam_exid, cam.name as camera_name
            from compares as comp
            left join users as u on comp.requested_by = u.id
            left join cameras as cam on comp.camera_id = cam.id
            where lower(u.firstname || ' ' || u.lastname ) like lower('%#{search}%') or lower(cam.name) like lower('%#{search}%') or lower(comp.name) like lower('%#{search}%')
            #{sorting(column, order)}"

    compares = Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
    cols = Enum.map compares.columns, &(String.to_atom(&1))
    roles = Enum.map compares.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    total_records = compares.num_rows
    per_page = String.to_integer(params["per_page"])
    current_page = String.to_integer(params["page"])
    {last_page, display_start, index_end} = Utils.pagination_info(total_records, per_page, current_page)

    data =
      Enum.reduce((display_start - 1)..(index_end - 1), [], fn i, acc ->
        compare = Enum.at(roles, i)
        comp = %{
          id: compare[:id],
          exid: compare[:exid],
          name_link: ( if compare[:fullname], do: "<a href='https://dash.evercam.io/v2/cameras?api_id=#{compare[:api_id]}&api_key=#{compare[:api_key]}' target='_blank'>#{compare[:fullname]} <i class='fa fa-external-link'></i></a>", else: "Deleted"),
          camera_link: ( if compare[:camera_name], do: "<a href='https://dash.evercam.io/v2/cameras/#{compare[:cam_exid]}?api_id=#{compare[:api_id]}&api_key=#{compare[:api_key]}' target='_blank'>#{compare[:camera_name]} <i class='fa fa-external-link'></i></a>", else: "Deleted"),
          inserted_at: (if compare[:inserted_at], do: Calendar.Strftime.strftime!(compare[:inserted_at], "%A, %d %b %Y %l:%M %p"), else: ""),
          name: compare[:name],
          status: compare[:status],
          embed_code: compare[:embed_code],
          download: "<a href='https://media.evercam.io/v2/cameras/#{compare[:cam_exid]}/compares/#{compare[:exid]}.gif' download='https://media.evercam.io/v2/cameras/#{compare[:cam_exid]}/compares/#{compare[:exid]}.gif'><i class='fa fa-download'></i> GIF</a> | <a href='https://media.evercam.io/v2/cameras/#{compare[:cam_exid]}/compares/#{compare[:exid]}.mp4' download='https://media.evercam.io/v2/cameras/#{compare[:cam_exid]}/compares/#{compare[:exid]}.mp4'><i class='fa fa-download'></i> MP4</a>"
        }
        acc ++ [comp]
      end)
    json(conn, Utils.paginator(display_start, index_end, params["sort"], total_records, per_page, current_page, data, "compares", last_page))
  end

  defp sorting("fullname", order), do: "order by u.firstname || ' ' || u.lastname #{order}"
  defp sorting("name", order), do: "order by comp.name #{order}"
  defp sorting("camera_name", order), do: "order by cam.name #{order}"
  defp sorting("status", order), do: "order by comp.status #{order}"
  defp sorting("inserted_at", order), do: "order by comp.inserted_at #{order}"
end