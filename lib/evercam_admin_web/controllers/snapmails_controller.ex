defmodule EvercamAdminWeb.SnapmailsController do
  use EvercamAdminWeb, :controller

  def index(conn, params) do
    [column, order] = params["sort"] |> String.split("|")

    query = "SELECT sm.*, u.firstname || ' ' || u.lastname as fullname, string_agg(cam.name, ',') as cam_names
            FROM snapmails as sm
            INNER JOIN users as u ON sm.user_id = u.id
            LEFT JOIN snapmail_cameras as sc ON sm.id = sc.snapmail_id
            LEFT JOIN cameras as cam ON sc.camera_id = cam.id
            #{condition(params)}
            GROUP BY sm.id, u.id
            #{sorting(column, order)}"

    snapmails = Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
    cols = Enum.map snapmails.columns, &(String.to_atom(&1))
    roles = Enum.map snapmails.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    total_records = snapmails.num_rows
    d_length = String.to_integer(params["per_page"])
    display_length = if d_length < 0, do: total_records, else: d_length
    display_start = if String.to_integer(params["page"]) <= 1, do: 0, else: (String.to_integer(params["page"]) - 1) * display_length + 1
    index_e = ((String.to_integer(params["page"]) - 1) * display_length) + display_length
    index_end = if index_e > total_records, do: total_records - 1, else: index_e
    last_page = Float.round(total_records / (display_length / 1))

    data =
      Enum.reduce(display_start..index_end, [], fn i, acc ->
        snapmail = Enum.at(roles, i)
        sm = %{
          fullname: snapmail[:fullname],
          cameras: snapmail[:cam_names],
          recipients: snapmail[:recipients],
          notify_days: snapmail[:notify_days],
          notify_time: snapmail[:notify_time],
          timezone: snapmail[:timezone],
          is_paused: snapmail[:is_paused],
          inserted_at: (if snapmail[:inserted_at], do: Calendar.Strftime.strftime!(snapmail[:inserted_at], "%A, %d %b %Y %l:%M %p"), else: "")
        }
        acc ++ [sm]
      end)

    records = %{
      data: (if total_records < 1, do: [], else: data),
      total: total_records,
      per_page: display_length,
      from: display_start,
      to: index_end,
      current_page: String.to_integer(params["page"]),
      last_page: last_page,
      next_page_url: (if String.to_integer(params["page"]) == last_page, do: "", else: "/v1/snapmails?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) + 1}"),
      prev_page_url: (if String.to_integer(params["page"]) < 1, do: "", else: "/v1/snapmails?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) - 1}")
    }
    json(conn, records)
  end

  def history(conn, params) do
    snapmail_logs = SnapmailLogs |> Evercam.Repo.all
    length = Enum.count(snapmail_logs)
    data =
      case length <= 0 do
        true -> []
        _ ->
          Enum.reduce(0..length - 1, [], fn i, acc ->
            snapmail_log = Enum.at(snapmail_logs, i)
            smh = %{
              inserted_at: (if snapmail_log.inserted_at, do: Calendar.Strftime.strftime!(snapmail_log.inserted_at, "%A, %d %b %Y %l:%M %p"), else: ""),
              recipients: snapmail_log.recipients,
              camera_ids: "all",
              camera_ids_failed: "failed",
              subject: snapmail_log.subject
            }
            acc ++ [smh]
          end)
      end
    json(conn, %{data: data})
  end

  defp condition(params) do
    Enum.reduce(params, "where 1=1", fn param, condition = _acc ->
      {name, value} = param
      cond do
        name == "fullname" && value != "" -> condition <> " and lower(u.firstname || ' ' || u.lastname) like lower('%#{value}%')"
        name == "cameras" && value != "" -> condition <> " and lower(cam.name) like lower('%#{value}%')"
        name == "recipients" && value != "" -> condition <> " and lower(sm.recipients) like lower('%#{value}%')"
        name == "notify_time" && value != "" -> condition <> " and lower(sm.notify_time) like lower('%#{value}%')"
        name == "timezone" && value != "" -> condition <> " and lower(sm.timezone) like lower('%#{value}%')"
        true -> condition
      end
    end)
  end

  defp sorting("inserted_at", order), do: "ORDER BY sm.inserted_at #{order}"
  defp sorting("fullname", order), do: "ORDER BY lower(u.firstname || ' ' || u.lastname) #{order}"
  defp sorting("recipients", order), do: "ORDER BY sm.recipients #{order}"
  defp sorting("notify_time", order), do: "ORDER BY sm.notify_time #{order}"
  defp sorting("timezone", order), do: "ORDER BY sm.timezone #{order}"
  defp sorting("is_paused", order), do: "ORDER BY sm.is_paused #{order}"
  defp sorting(_column, _order), do: "ORDER BY sm.inserted_at desc"
end