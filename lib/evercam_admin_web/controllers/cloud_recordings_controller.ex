defmodule EvercamAdminWeb.CloudRecordingsController do
  use EvercamAdminWeb, :controller

  def index(conn, params) do
    [column, order] = params["sort"] |> String.split("|")

    query = "select c.name, c.exid, c.id cam_id, c.is_online, c.is_public, u.username,u.firstname, u.lastname, u.id user_id, u.api_id, u.api_key, u.payment_method ,cr.*,
      (select count(c1.id) from cameras c1 inner join cloud_recordings cr1 on c1.id=cr1.camera_id where owner_id=u.id and cr1.storage_duration=cr.storage_duration) total_cameras
      from cloud_recordings cr
      inner join cameras c on cr.camera_id=c.id
      inner join users u on c.owner_id=u.id #{condition(params)} #{sorting(column, order)}"
    cloud_recordings = Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
    cols = Enum.map cloud_recordings.columns, &(String.to_atom(&1))
    roles = Enum.map cloud_recordings.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    total_records = cloud_recordings.num_rows
    per_page = String.to_integer(params["per_page"])
    current_page = String.to_integer(params["page"])
    {last_page, display_start, index_end} = Utils.pagination_info(total_records, per_page, current_page)

    data =
      Enum.reduce((display_start - 1)..(index_end - 1), [], fn i, acc ->
        cloud_recording = Enum.at(roles, i)
        cr = %{
          camera_name: cloud_recording[:name],
          status: cloud_recording[:status],
          storage_duration: cloud_recording[:storage_duration],
          interval: cloud_recording[:frequency],
          schedule: get_hours(cloud_recording[:schedule]),
          online: cloud_recording[:is_online],
          public: cloud_recording[:is_public],
          api_key: cloud_recording[:api_key],
          api_id: cloud_recording[:api_id],
          exid: cloud_recording[:exid],
          schedule_for_edit: cloud_recording[:schedule],
          payment_method: cloud_recording[:payment_method],
          camera_link: "<a href='https://dash.evercam.io/v2/cameras/#{cloud_recording[:exid]}?api_id=#{cloud_recording[:api_id]}&api_key=#{cloud_recording[:api_key]}' target='_blank'>#{cloud_recording[:firstname]} #{cloud_recording[:lastname]} <i class='fa fa-external-link'></i></a>"
        }
        acc ++ [cr]
      end)

    json(conn, Utils.paginator(display_start, index_end, params["sort"], total_records, per_page, current_page, data, "cloud_recordings", last_page))
  end

  defp get_hours(nil), do: ""
  defp get_hours(schedule) do
    Enum.reduce(schedule, 0, fn day, total_hours = _acc ->
      {_name, hours} = day
      calculated_hours =
        Enum.reduce(hours, 0, fn hour, calc_hours = _acc ->
          [from_time, to_time] = String.split(hour, "-")
          with {:ok, from} <- parse_date_erl(from_time),
               {:ok, to} <- parse_date_erl(to_time)
          do (Time.diff(to, from) / 3600 |> Float.round) + calc_hours end
        end)
      total_hours + calculated_hours
    end)
  end

  defp parse_date_erl(time) do
    [start, ending] = String.split(time, ":")
    Time.from_erl({String.to_integer(start), String.to_integer(ending), 0})
  end

  defp condition(params) do
    Enum.reduce(params, "where 1=1", fn param, condition = _acc ->
      {name, value} = param
      cond do
        name == "camera_name" && value != "" -> condition <> " and lower(c.name) like lower('%#{value}%')"
        name == "owner" && value != "" -> condition <> " and lower(u.firstname || ' ' || u.lastname) like lower('%#{value}%')"
        name == "status" && value != "" -> condition <> " and lower(status) like lower('%#{value}%')"
        name == "storage_duration" && value != "" -> condition <> " and CAST(storage_duration AS TEXT) like '#{value}%'"
        name == "interval" && value != "" -> condition <> " and CAST(frequency AS TEXT) like '#{value}%'"
        true -> condition
      end
    end)
  end

  defp sorting("name", order), do: "order by name #{order}"
  defp sorting("firstname", order), do: "order by u.firstname #{order}"
  defp sorting("status", order), do: "order by status #{order}"
  defp sorting("storage_duration", order), do: "order by storage_duration #{order}"
  defp sorting("interval", order), do: "order by frequency #{order}"
  defp sorting("online", order), do: "order by c.is_online #{order}"
  defp sorting("public", order), do: "order by c.is_public #{order}"
  defp sorting("licences", order), do: "order by licences #{order}"
  defp sorting("payment_method", order), do: "order by u.payment_method #{order}"
  defp sorting(_column, _order), do: "order by u.username"
end
