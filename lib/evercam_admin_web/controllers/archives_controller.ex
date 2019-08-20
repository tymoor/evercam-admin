defmodule EvercamAdminWeb.ArchivesController do
  use EvercamAdminWeb, :controller

  def index(conn, params) do
    [column, order] = params["sort"] |> String.split("|")
    search = if params["search"] in ["", nil], do: "", else: params["search"]

    query = "select arc.*, u.firstname || ' ' || u.lastname as fullname, u.api_id, u.api_key, cam.exid as cam_exid,
            EXTRACT(epoch FROM ((arc.to_date)-(arc.from_date))) as duration
            from archives as arc
            left join users as u on arc.requested_by = u.id
            left join cameras as cam on arc.camera_id = cam.id
            where lower(u.firstname || ' ' || u.lastname ) like lower('%#{search}%') or lower(cam.exid) like lower('%#{search}%') or lower(arc.title) like lower('%#{search}%')
            #{sorting(column, order)}"

    archives = Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
    cols = Enum.map archives.columns, &(String.to_atom(&1))
    roles = Enum.map archives.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    total_records = archives.num_rows
    per_page = String.to_integer(params["per_page"])
    current_page = String.to_integer(params["page"])
    {last_page, display_start, index_end} = Utils.pagination_info(total_records, per_page, current_page)

    data =
      Enum.reduce((display_start - 1)..(index_end - 1), [], fn i, acc ->
        archive = Enum.at(roles, i)
        arc = %{
          id: archive[:id],
          exid: (if archive[:cam_exid], do: archive[:cam_exid], else: "Deleted"),
          name_link: ( if archive[:fullname], do: "<a href='https://dash.evercam.io/v2/cameras?api_id=#{archive[:api_id]}&api_key=#{archive[:api_key]}' target='_blank'>#{archive[:fullname]} <i class='fa fa-external-link'></i></a>", else: "Deleted"),
          created_at: (if archive[:created_at], do: Calendar.Strftime.strftime!(archive[:created_at], "%A, %d %b %Y %l:%M %p"), else: ""),
          from_date: (if archive[:from_date], do: Calendar.Strftime.strftime!(archive[:from_date], "%A, %d %b %Y %l:%M %p"), else: ""),
          to_date: (if archive[:to_date], do: Calendar.Strftime.strftime!(archive[:to_date], "%A, %d %b %Y %l:%M %p"), else: ""),
          title: archive[:title],
          status: archive[:status],
          duration: archive[:duration],
          public: archive[:public]
        }
        acc ++ [arc]
      end)

    json(conn, Utils.paginator(display_start, index_end, params["sort"], total_records, per_page, current_page, data, "archives", last_page))
  end

  defp sorting("exid", order), do: "order by cam.exid #{order}"
  defp sorting("fullname", order), do: "order by u.firstname || ' ' || u.lastname #{order}"
  defp sorting("title", order), do: "order by arc.title #{order}"
  defp sorting("from_date", order), do: "order by arc.from_date #{order}"
  defp sorting("to_date", order), do: "order by arc.to_date #{order}"
  defp sorting("status", order), do: "order by arc.status #{order}"
  defp sorting("created_at", order), do: "order by arc.created_at #{order}"
  defp sorting("public", order), do: "order by arc.public #{order}"
  defp sorting("duration", order), do: "order by duration #{order}"
end