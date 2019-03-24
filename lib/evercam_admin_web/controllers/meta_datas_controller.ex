defmodule EvercamAdminWeb.MetaDatasController do
  use EvercamAdminWeb, :controller
  import SweetXml
  import Ecto.Query
  require Logger

  def index(conn, params) do
    [column, order] = params["sort"] |> String.split("|")
    search = if params["search"] in ["", nil], do: "", else: params["search"]

    query = "select md.*, cam.name as camera_name, cam.exid as camera_exid, u.api_key, u.api_id
            from meta_datas as md
            left join cameras as cam on md.camera_id = cam.id
            left join users as u on cam.owner_id = u.id
            where lower(cam.exid) like lower('%#{search}%') or lower(cam.name) like lower('%#{search}%') 
            #{sorting(column, order)}"

    meta_datas = Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
    cols = Enum.map meta_datas.columns, &(String.to_atom(&1))
    roles = Enum.map meta_datas.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    total_records = meta_datas.num_rows
    d_length = String.to_integer(params["per_page"])
    display_length = if d_length < 0, do: total_records, else: d_length
    display_start = if String.to_integer(params["page"]) <= 1, do: 0, else: (String.to_integer(params["page"]) - 1) * display_length + 1
    index_e = ((String.to_integer(params["page"]) - 1) * display_length) + display_length
    index_end = if index_e > total_records, do: total_records - 1, else: index_e
    last_page = Float.round(total_records / (display_length / 1))

    data =
      Enum.reduce(display_start..index_end, [], fn i, acc ->
        meta_data = Enum.at(roles, i)
        md = %{
          camera_exid: meta_data[:camera_exid],
          camera_link: ( if meta_data[:camera_name], do: "<a href='https://dash.evercam.io/v2/cameras/#{meta_data[:camera_exid]}?api_id=#{meta_data[:api_id]}&api_key=#{meta_data[:api_key]}' target='_blank'>#{meta_data[:camera_name]} <i class='fa fa-external-link'></i></a>", else: "Deleted"),
          inserted_at: (if meta_data[:inserted_at], do: Calendar.Strftime.strftime!(meta_data[:inserted_at], "%A, %d %b %Y %l:%M %p"), else: ""),
          action: meta_data[:action],
          resolution: get_resolution(meta_data[:extra]),
          token: Util.deep_get(meta_data[:extra], ["token"], ""),
          requester: Util.deep_get(meta_data[:extra], ["requester"], ""),
          rtsp_url: Util.deep_get(meta_data[:extra], ["rtsp_url"], ""),
          frame_rate: Util.deep_get(meta_data[:extra], ["frame_rate"], ""),
          bit_rate: Util.deep_get(meta_data[:extra], ["bit_rate"], ""),
          codec: Util.deep_get(meta_data[:extra], ["codec"], ""),
          ip: Util.deep_get(meta_data[:extra], ["ip"], "")
        }
        acc ++ [md]
      end)

    records = %{
      data: (if total_records < 1, do: [], else: data),
      total: total_records,
      per_page: display_length,
      from: display_start,
      to: index_end,
      current_page: String.to_integer(params["page"]),
      last_page: last_page,
      next_page_url: (if String.to_integer(params["page"]) == last_page, do: "", else: "/v1/meta_datas?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) + 1}"),
      prev_page_url: (if String.to_integer(params["page"]) < 1, do: "", else: "/v1/meta_datas?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) - 1}")
    }
    json(conn, records)
  end

  def sync_stat_metadata(conn, _params) do
    referer_url =
      case List.keyfind(conn.req_headers, "referer", 0) do
        {"referer", referer} -> referer
        nil -> ""
      end

    case String.match?(referer_url, ~r/meta_data/) do
      true ->
        {:ok, %HTTPoison.Response{body: body}} = HTTPoison.get("https://media.evercam.io/stats/")
        tokens =
          body
          |> xpath(~x"//stream"l)
          |> get_token_from_streams

        tokens |> get_exids_from_tokens |> delete_streams
        tokens |> kill_rtmp_stream
        json(conn, %{status: true})
      _ -> json(conn, %{status: false})
    end
  end

  defp get_token_from_streams([]), do: []
  defp get_token_from_streams(streams) do
    Enum.map(streams, fn (stream_node) ->
      stream_node |> xpath(~x"./name/text()")
    end)
  end

  defp get_exids_from_tokens([] = _tokens), do: ""
  defp get_exids_from_tokens([token] = _tokens), do: "'#{Base.decode64!(token) |> String.split("|") |> List.first}'"
  defp get_exids_from_tokens(tokens) do
    Enum.reduce(tokens, "'fake'", fn token, acc ->
      exid = Base.decode64!("#{token}") |> String.split("|") |> List.first
      "#{acc}" <> ", '#{exid}'"
    end)
  end

  defp delete_streams(""), do: :noop
  defp delete_streams(exids) do
    query = "delete from meta_datas where camera_id not in (select id from cameras where exid in (#{exids}))"
    Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
  end

  defp kill_rtmp_stream(tokens)  do
    exids = MetaData |> preload(:camera) |> Evercam.Repo.all |> Enum.map(fn(meta_data) -> meta_data.camera.exid end)
    Enum.each(tokens, fn(token) ->
      exid = Base.decode64!("#{token}") |> String.split("|") |> List.first
      case Enum.member?(exids, exid) do
        true -> :noop
        false ->
          HTTPoison.get("https://media.evercam.io/control/drop/publisher?app=live&name=#{token}")
          Logger.info "Unused Stream: #{exid} has been deleted with token: #{token}"
      end
    end)
  end

  defp get_resolution(extra) do
    width = Util.deep_get(extra, ["width"], "")
    height = Util.deep_get(extra, ["height"], "")
    resolution = "#{width}x#{height}"
    if resolution == "x", do: "", else: resolution
  end

  defp sorting("camera_name", order), do: "order by cam.name #{order}"
  defp sorting("camera_exid", order), do: "order by cam.exid #{order}"
  defp sorting("inserted_at", order), do: "order by md.inserted_at #{order}"
  defp sorting("action", order), do: "order by md.action #{order}"
end