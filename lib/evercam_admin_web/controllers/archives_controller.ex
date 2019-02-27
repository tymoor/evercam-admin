defmodule EvercamAdminWeb.ArchivesController do
  use EvercamAdminWeb, :controller

  def index(conn, params) do
    [column, order] = params["sort"] |> String.split("|")
    search = if params["search"] in ["", nil], do: "", else: params["search"]

    query = "select arc.*, u.firstname || u.lastname as fullname, u.api_id, u.api_key, cam.exid as cam_exid,
            EXTRACT(epoch FROM ((arc.to_date)-(arc.from_date))) as duration
            from archives as arc
            left join users as u on arc.requested_by = u.id
            left join cameras as cam on arc.camera_id = cam.id
            where lower(u.firstname || u.lastname ) like lower('%#{search}%') or lower(cam.exid) like lower('%#{search}%') or lower(arc.title) like lower('%#{search}%')
            #{sorting(column, order)}"

    archives = Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
    cols = Enum.map archives.columns, &(String.to_atom(&1))
    roles = Enum.map archives.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    total_records = archives.num_rows
    d_length = String.to_integer(params["per_page"])
    display_length = if d_length < 0, do: total_records, else: d_length
    display_start = if String.to_integer(params["page"]) <= 1, do: 0, else: (String.to_integer(params["page"]) - 1) * display_length + 1
    index_e = ((String.to_integer(params["page"]) - 1) * display_length) + display_length
    index_end = if index_e > total_records, do: total_records - 1, else: index_e
    last_page = Float.round(total_records / (display_length / 1))

    data =
      Enum.reduce(display_start..index_end, [], fn i, acc ->
        archive = Enum.at(roles, i)
        arc = %{
          id: archive[:id],
          exid: archive[:cam_exid],
          name_link: "<a href='https://dash.evercam.io/v2/cameras?api_id=#{archive[:api_id]}&api_key=#{archive[:api_key]}' target='_blank'>#{archive[:fullname]} <i class='fa fa-external-link'></i></a>",
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

    records = %{
      data: (if total_records < 1, do: [], else: data),
      total: total_records,
      per_page: display_length,
      from: display_start,
      to: index_end,
      current_page: String.to_integer(params["page"]),
      last_page: last_page,
      next_page_url: (if String.to_integer(params["page"]) == last_page, do: "", else: "/v1/archives?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) + 1}"),
      prev_page_url: (if String.to_integer(params["page"]) < 1, do: "", else: "/v1/archives?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) - 1}")
    }
    json(conn, records)
  end

  defp sorting("exid", order), do: "order by cam.exid #{order}"
  defp sorting("fullname", order), do: "order by u.firstname || u.lastname #{order}"
  defp sorting("title", order), do: "order by arc.title #{order}"
  defp sorting("from_date", order), do: "order by arc.from_date #{order}"
  defp sorting("to_date", order), do: "order by arc.to_date #{order}"
  defp sorting("status", order), do: "order by arc.status #{order}"
  defp sorting("created_at", order), do: "order by arc.created_at #{order}"
  defp sorting("public", order), do: "order by arc.public #{order}"
  defp sorting("duration", order), do: "order by duration #{order}"
end