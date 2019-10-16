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
    query = "select se.*, cam.name, cam.exid, cam.owner_id, cam.id as camera_id, u.api_key, u.api_id from snapshot_extractors se
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
    per_page = String.to_integer(params["per_page"])
    current_page = String.to_integer(params["page"])
    {last_page, display_start, index_end} = Utils.pagination_info(total_records, per_page, current_page)

    data =
      Enum.reduce((display_start - 1)..(index_end - 1), [], fn i, acc ->
        snapshot_extractor = Enum.at(roles, i)
        se = %{
          id: snapshot_extractor[:id],
          camera: (if snapshot_extractor[:name], do: snapshot_extractor[:name], else: "Deleted"),
          camera_owner: "#{snapshot_extractor[:owner_id]}",
          created_at: (if snapshot_extractor[:created_at], do: Calendar.Strftime.strftime!(snapshot_extractor[:created_at], "%A, %d %b %Y %l:%M %p"), else: ""),
          from_date: (if snapshot_extractor[:from_date], do: Calendar.Strftime.strftime!(snapshot_extractor[:from_date], "%A, %d %b %Y %l:%M %p"), else: ""),
          to_date: (if snapshot_extractor[:to_date], do: Calendar.Strftime.strftime!(snapshot_extractor[:to_date], "%A, %d %b %Y %l:%M %p"), else: ""),
          notes: snapshot_extractor[:notes],
          status: snapshot_extractor[:status],
          interval: snapshot_extractor[:interval],
          requestor: snapshot_extractor[:requestor],
          exid: snapshot_extractor[:exid],
          api_key: snapshot_extractor[:api_key],
          api_id: snapshot_extractor[:api_id],
          jpegs_to_dropbox: snapshot_extractor[:jpegs_to_dropbox],
          inject_to_cr: snapshot_extractor[:inject_to_cr],
          create_mp4: snapshot_extractor[:create_mp4],
          schedule: Jason.encode!(snapshot_extractor[:schedule]),
          camera_id: snapshot_extractor[:camera_id]
        }
        acc ++ [se]
      end)

    json(conn, Utils.paginator(display_start, index_end, params["sort"], total_records, per_page, current_page, data, "snapshot_extractors", last_page))
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
  defp sorting("status", order) do
    "order by case
        when se.status in (2, 12, 22) then 1
        when se.status in (1, 11, 21) then 2
        else 3
      end #{order}
    "
  end
  defp sorting("requestor", order), do: "order by se.requestor #{order}"
  defp sorting("created_at", order), do: "order by se.created_at #{order}"
end