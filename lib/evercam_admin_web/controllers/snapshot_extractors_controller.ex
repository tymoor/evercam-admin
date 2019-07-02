defmodule EvercamAdminWeb.SnapshotExtractorsController do
  use EvercamAdminWeb, :controller
  import Ecto.Query

  @extractor_ip "#{System.get_env["EXTRACTOR_IP"]}"
  @extractor_password "#{System.get_env["EXTRACTOR_PASSWORD"]}"

  def create(conn, params) do
    SnapshotExtractor.changeset(%SnapshotExtractor{}, %{
      camera_id: params["camera_id"],
      from_date: params["from_date"] |> NaiveDateTime.from_iso8601! |> Calendar.DateTime.from_naive("Etc/UTC") |> elem(1),
      to_date: params["to_date"] |> NaiveDateTime.from_iso8601! |> Calendar.DateTime.from_naive("Etc/UTC") |> elem(1),
      interval: params["interval"],
      schedule: Jason.decode!(params["schedule"]),
      requestor: params["requestor"],
      status: 0
    })
    |> Evercam.Repo.insert
    |> case do
      {:ok, _extraction} -> json(conn, %{success: true})
      {:error, _error} -> conn |> put_status(400) |> json(%{success: false})
    end
  end

  def index(conn, params) do
    [column, order] = params["sort"] |> String.split("|")
    search = if params["search"] in ["", nil], do: "", else: params["search"]
    query = "select se.*, cam.name, cam.exid, u.api_key, u.api_id from snapshot_extractors se
            left join cameras as cam on se.camera_id = cam.id
            left join users as u on cam.owner_id = u.id
            where lower(cam.name) like lower('%#{search}%') or lower(se.requestor) like lower('%#{search}%')
            #{sorting(column, order)}"

    snapshot_extractors = Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
    cols = Enum.map snapshot_extractors.columns, &(String.to_atom(&1))
    roles = Enum.map snapshot_extractors.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    total_records = snapshot_extractors.num_rows
    d_length = String.to_integer(params["per_page"])
    display_length = if d_length < 0, do: total_records, else: d_length
    display_start = if String.to_integer(params["page"]) <= 1, do: 0, else: (String.to_integer(params["page"]) - 1) * display_length + 1
    index_e = ((String.to_integer(params["page"]) - 1) * display_length) + display_length
    index_end = if index_e > total_records, do: total_records - 1, else: index_e
    last_page = Float.round(total_records / (display_length / 1))

    data =
      Enum.reduce(display_start..index_end, [], fn i, acc ->
        snapshot_extractor = Enum.at(roles, i)
        se = %{
          id: snapshot_extractor[:id],
          camera: (if snapshot_extractor[:name], do: snapshot_extractor[:name], else: "Deleted"),
          created_at: (if snapshot_extractor[:created_at], do: Calendar.Strftime.strftime!(snapshot_extractor[:created_at], "%A, %d %b %Y %l:%M %p"), else: ""),
          from_date: (if snapshot_extractor[:from_date], do: Calendar.Strftime.strftime!(snapshot_extractor[:from_date], "%A, %d %b %Y %l:%M %p"), else: ""),
          to_date: (if snapshot_extractor[:to_date], do: Calendar.Strftime.strftime!(snapshot_extractor[:to_date], "%A, %d %b %Y %l:%M %p"), else: ""),
          notes: snapshot_extractor[:notes],
          status: snapshot_extractor[:status],
          interval: snapshot_extractor[:interval],
          requestor: snapshot_extractor[:requestor],
          exid: snapshot_extractor[:exid],
          api_key: snapshot_extractor[:api_key],
          api_id: snapshot_extractor[:api_id]
        }
        acc ++ [se]
      end)

    records = %{
      data: (if total_records < 1, do: [], else: data),
      total: total_records,
      per_page: display_length,
      from: display_start,
      to: index_end,
      current_page: String.to_integer(params["page"]),
      last_page: last_page,
      next_page_url: (if String.to_integer(params["page"]) == last_page, do: "", else: "/v1/snapshot_extractors?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) + 1}"),
      prev_page_url: (if String.to_integer(params["page"]) < 1, do: "", else: "/v1/snapshot_extractors?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) - 1}")
    }
    json(conn, records)
  end

  def delete(conn, params) do
    extraction_id = params["extraction_id"]
    extractor =
      SnapshotExtractor
      |> where(id: ^extraction_id)
      |> Evercam.Repo.one

    extractor
    |> Evercam.Repo.delete

    start_stop_extractor(extractor.status)

    json(conn, %{success: true})
  end

  defp start_stop_extractor(0), do: :noop
  defp start_stop_extractor(2), do: :noop
  defp start_stop_extractor(_) do
    {:ok, conn} = SSHEx.connect ip: "#{@extractor_ip}", user: 'root', password: "#{@extractor_password}"
    {:ok, _, 0} = SSHEx.run conn, 'stop extractor'
    {:ok, _, 0} = SSHEx.run conn, 'start extractor'
  end

  defp sorting("id", order), do: "order by se.id #{order}"
  defp sorting("camera", order), do: "order by cam.name #{order}"
  defp sorting("from_date", order), do: "order by se.from_date #{order}"
  defp sorting("to_date", order), do: "order by se.to_date #{order}"
  defp sorting("interval", order), do: "order by se.interval #{order}"
  defp sorting("status", order), do: "order by se.status #{order}"
  defp sorting("nature", order), do: "order by se.status #{order}"
  defp sorting("requestor", order), do: "order by se.requestor #{order}"
  defp sorting("created_at", order), do: "order by se.created_at #{order}"
end