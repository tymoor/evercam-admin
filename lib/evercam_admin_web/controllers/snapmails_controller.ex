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
    per_page = String.to_integer(params["per_page"])
    current_page = String.to_integer(params["page"])
    {last_page, display_start, index_end} = Utils.pagination_info(total_records, per_page, current_page)

    data =
      Enum.reduce((display_start - 1)..(index_end - 1), [], fn i, acc ->
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

    json(conn, Utils.paginator(display_start, index_end, params["sort"], total_records, per_page, current_page, data, "snapmails", last_page))
  end

  def history(conn, params) do
    from = params["fromDate"]
    to = params["toDate"]
    query = "SELECT * FROM snapmail_logs WHERE (DATE(inserted_at) >= '#{from}' and DATE(inserted_at) <= '#{to}') ORDER BY inserted_at desc"
    snapmail_logs = Ecto.Adapters.SQL.query!(Evercam.SnapshotRepo, query, [])
    cols = Enum.map snapmail_logs.columns, &(String.to_atom(&1))
    roles = Enum.map snapmail_logs.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    length = snapmail_logs.num_rows
    data =
      case length <= 0 do
        true -> []
        _ ->
          Enum.reduce(0..length - 1, [], fn i, acc ->
            snapmail_log = Enum.at(roles, i)
            smh = %{
              inserted_at: (if snapmail_log[:inserted_at], do: Calendar.Strftime.strftime!(snapmail_log[:inserted_at], "%A, %d %b %Y %l:%M %p"), else: ""),
              recipients: snapmail_log[:recipients],
              camera_ids: all_camera_ids(snapmail_log[:body]),
              camera_ids_failed: camera_ids_failed(snapmail_log[:body]),
              subject: snapmail_log[:subject],
              id: "#{snapmail_log[:id]}"
            }
            acc ++ [smh]
          end)
      end
    json(conn, %{data: data})
  end

  defp all_camera_ids(body) do
    Floki.attribute(body, ".last-snapmail-snapshot", "id") ++ Floki.attribute(body, ".failed-camera", "id")
    |> case do
      [] -> ""
      cameras ->
        Enum.reduce(cameras, "", fn camera, acc ->
          acc <> camera <> " "
        end)
    end
  end

  defp camera_ids_failed(body) do
    Floki.attribute(body, ".failed-camera", "id")
    |> case do
      [] -> ""
      cameras ->
        Enum.reduce(cameras, "", fn camera, acc ->
          acc <> camera <> " "
        end)
    end
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