defmodule EvercamAdminWeb.NvrsController do
  use EvercamAdminWeb, :controller
  import Ecto.Query

  def index(conn, params) do
    construction_type = params["construction_type"]
    [column, order] = params["sort"] |> String.split("|")

    {camera_exid, camera_name} =
      Enum.reduce(params, {"", ""}, fn param, {camera_exid, camera_name} = _acc ->
        {name, value} = param
        cond do
          name == "camera_exid" && value != "" ->
            {" and lower(c.exid) like lower('%#{value}%')", camera_name}
          name == "camera_name" && value != "" ->
            {camera_exid, " and lower(c.name) like lower('%#{value}%')"}
          true ->
            {camera_exid, camera_name}
        end
      end)
    query = "select c.*, u.api_id, u.api_key
            from cameras as c
            inner JOIN users u on c.owner_id = u.id
            where owner_id=13959 and 1=1
            #{camera_exid}#{camera_name}
            #{sorting(column, order)}"

    cameras = Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
    cols = Enum.map cameras.columns, &(String.to_atom(&1))
    roles = Enum.map cameras.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    total_records = cameras.num_rows
    d_length = String.to_integer(params["per_page"])
    display_length = if d_length < 0, do: total_records, else: d_length
    display_start = if String.to_integer(params["page"]) <= 1, do: 0, else: (String.to_integer(params["page"]) - 1) * display_length + 1
    index_e = ((String.to_integer(params["page"]) - 1) * display_length) + display_length
    index_end = if index_e > total_records, do: total_records - 1, else: index_e
    last_page = Float.round(total_records / (display_length / 1))

    data =
      Enum.reduce(display_start..index_end, [], fn i, acc ->
        camera = Enum.at(roles, i)
        data = get_nvr_info(construction_type, camera[:exid], camera[:api_key], camera[:api_id])
        c = %{
          exid: camera[:exid],
          name: camera[:name]
        }
        object = Map.merge(data, c)
        acc ++ [object]
      end)

    records = %{
      data: (if total_records < 1, do: [], else: data),
      total: total_records,
      per_page: display_length,
      from: display_start,
      to: index_end,
      current_page: String.to_integer(params["page"]),
      last_page: last_page,
      next_page_url: (if String.to_integer(params["page"]) == last_page, do: "", else: "/v1/cameras?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) + 1}"),
      prev_page_url: (if String.to_integer(params["page"]) < 1, do: "", else: "/v1/cameras?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) - 1}")
    }
    json(conn, records)
  end

  defp sorting("exid", order), do: "order by c.exid #{order}"
  defp sorting("name", order), do: "order by c.name #{order}"
  defp sorting(_column, _order), do: "order by c.created_at desc"

  defp get_nvr_info(construction_type, camera_exid, api_key, api_id) do
    with {:ok, %HTTPoison.Response{body: body}} <- HTTPoison.get("https://media.evercam.io/v2/cameras/#{camera_exid}/nvr/stream/#{construction_type}?api_id=#{api_id}&api_key=#{api_key}") do
      data = Jason.decode!(body)
      %{
        model: data["device_info"]["model"],
        device_name: data["device_info"]["device_name"],
        mac_address: data["device_info"]["mac_address"],
        firmware_version: data["device_info"]["firmware_version"],
        resolution: data["stream_info"]["resolution"],
        bitrate_type: data["stream_info"]["bitrate_type"],
        video_quality: data["stream_info"]["video_quality"],
        frame_rate: data["stream_info"]["frame_rate"],
        bitrate: data["stream_info"]["bitrate"],
        video_encoding: data["stream_info"]["video_encoding"],
        hdd_info: data["stream_info"],
        online: true
      }
    else
      _ ->
        %{online: false}
    end
  end
end