defmodule EvercamAdminWeb.CamerasController do
  use EvercamAdminWeb, :controller
  import Ecto.Query

  def index(conn, params) do

    with nil <- params["shared-with"] do

      [column, order] = params["sort"] |> String.split("|")

      {is_recording, camera_exid, camera_name, camera_owner, camera_ip, model, vendor, username, password} =
        Enum.reduce(params, {"", "", "", "", "", "", "", "", ""}, fn param, {is_recording, camera_exid, camera_name, camera_owner, camera_ip, model, vendor, username, password} = _acc ->
          {name, value} = param
          cond do
            name == "is_recording" && value != "" ->
              {" and lower(is_recording) like lower('%#{value}%')", camera_exid, camera_owner, camera_name, camera_ip, model, vendor, username, password}
            name == "camera_exid" && value != "" ->
              {is_recording, " and lower(c.exid) like lower('%#{value}%')", camera_owner, camera_name, camera_ip, model, vendor, username, password}
            name == "camera_name" && value != "" ->
              {is_recording, camera_exid, camera_owner, " and lower(c.name) like lower('%#{value}%')", camera_ip, model, vendor, username, password}
            name == "camera_owner" && value != "" ->
              {is_recording, camera_exid, camera_name, " and lower(fullname) like lower('%#{value}%')", camera_ip, model, vendor, username, password}
            name == "camera_ip" && value != "" ->
              {is_recording, camera_exid, camera_name, camera_owner, " and lower(c.config->>'external_host') like lower('%#{value}%')", model, vendor, username, password}
            name == "model" && value != "" ->
              {is_recording, camera_exid, camera_name, camera_owner, camera_ip, " and lower(vendor_model_name) like lower('%#{value}%')", vendor, username, password}
            name == "vendor" && value != "" ->
              {is_recording, camera_exid, camera_name, camera_owner, camera_ip, model, " and lower(vendor_name) like lower('%#{value}%')", username, password}
            name == "username" && value != "" ->
              {is_recording, camera_exid, camera_name, camera_owner, camera_ip, model, vendor, " and lower(c.config->'auth'->'basic'->>'username') like lower('%#{value}%')", password}
            name == "password" && value != "" ->
              {is_recording, camera_exid, camera_name, camera_owner, camera_ip, model, vendor, username, " and lower(c.config->'auth'->'basic'->>'password') like lower('%#{value}%')"}
            true ->
              {is_recording, camera_exid, camera_name, camera_owner, camera_ip, model, vendor, username, password}
          end
        end)
      query = "select * from (
                  select c.*,p.name as project_name,u.firstname || ' ' || u.lastname as fullname, u.email as owner_email, u.payment_method, u as user, u.id as user_id, u.api_id, u.api_key,
                  v.name as vendor_name,vm.name as vendor_model_name, cr.status as is_recording, cr.storage_duration as cloud_recording_storage_duration,
                  (select count(id) as total from camera_shares cs where c.id=cs.camera_id) as total_share from cameras c
                  inner JOIN users u on c.owner_id = u.id
                  left JOIN projects p on c.project_id = p.id
                  left JOIN vendor_models vm on c.model_id = vm.id
                  left JOIN vendors v on vm.vendor_id = v.id
                  left JOIN cloud_recordings cr on c.id = cr.camera_id
                  ) c where 1=1
                  #{camera_exid}#{is_recording}#{camera_name}#{camera_owner}#{camera_ip}#{model}#{vendor}#{username}#{password}
                  #{sorting(column, order)}"
      cameras = Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
      cols = Enum.map cameras.columns, &(String.to_atom(&1))
      roles = Enum.map cameras.rows, fn(row) ->
        Enum.zip(cols, row)
      end

      total_records = cameras.num_rows
      per_page = String.to_integer(params["per_page"])
      current_page = String.to_integer(params["page"])
      {last_page, display_start, index_end} = Utils.pagination_info(total_records, per_page, current_page)

      data =
        Enum.reduce((display_start - 1)..(index_end - 1), [], fn i, acc ->
          camera = Enum.at(roles, i)
          c = %{
            project_id: camera[:project_id],
            exid: camera[:exid],
            fullname: camera[:fullname],
            project_name: camera[:project_name],
            name: camera[:name],
            total_share: camera[:total_share],
            mac_address: cast_mac(camera[:mac_address]),
            vendor_model_name: camera[:vendor_model_name],
            vendor_name: camera[:vendor_name],
            timezone: camera[:timezone],
            is_public: camera[:is_public],
            is_online: camera[:is_online],
            api_key: camera[:api_key],
            api_id: camera[:api_id],
            is_recording: camera[:is_recording],
            owner_email: camera[:owner_email],
            cloud_recording_storage_duration: camera[:cloud_recording_storage_duration],
            payment_method: camera[:payment_method],
            external_host: camera[:config]["external_host"],
            external_http_port: camera[:config]["external_http_port"],
            external_rtsp_port: camera[:config]["external_rtsp_port"],
            username: camera[:config]["auth"]["basic"]["username"],
            password: camera[:config]["auth"]["basic"]["password"],
            camera_link: "<a href='https://dash.evercam.io/v2/cameras/#{camera[:exid]}?api_id=#{camera[:api_id]}&api_key=#{camera[:api_key]}' target='_blank'>#{camera[:fullname]} <i class='fa fa-external-link'></i></a>",
            created_at: (if camera[:created_at], do: Calendar.Strftime.strftime!(camera[:created_at], "%A, %d %b %Y %l:%M %p"), else: ""),
            last_polled_at: (if camera[:last_polled_at], do: Calendar.Strftime.strftime!(camera[:last_polled_at], "%A, %d %b %Y %l:%M %p"), else: ""),
            last_online_at: (if camera[:last_online_at], do: Calendar.Strftime.strftime!(camera[:last_online_at], "%A, %d %b %Y %l:%M %p"), else: "")
          }
          acc ++ [c]
        end)

      json(conn, Utils.paginator(display_start, index_end, params["sort"], total_records, per_page, current_page, data, "cameras", last_page))
    else
      _ ->
      query = "select distinct c.id,c.exid,c.name,c.is_online,c.is_public,c.created_at,c.last_online_at,
        cr.frequency,cr.storage_duration,u.api_id,u.api_key,
        (select count(id) as total from camera_shares cs where c.id=cs.camera_id) as total_share,
        (select count(*) from snapmail_cameras sc where sc.camera_id = c.id) snapmail_count
        from cameras c inner join camera_shares cs on c.id=cs.camera_id
        inner join users u on u.id=c.owner_id
        left join cloud_recordings cr on c.id=cr.camera_id
        where cs.user_id in (select id from users where email like '%#{params["shared-with"]}')
        or c.owner_id in (select id from users where email like '%#{params["shared-with"]}')"
      cameras = Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
      cols = Enum.map cameras.columns, &(String.to_atom(&1))
      roles = Enum.map cameras.rows, fn(row) ->
        Enum.zip(cols, row)
      end
      all_cameras = Enum.map(roles, &Map.new/1)
      json(conn, %{data: all_cameras})
    end
  end

  def extraction_cameras(conn, params) do
    search = if params["search"] in ["", nil], do: "", else: params["search"]
    account = if params["account"] == "-1", do: [13959, 109148], else: [String.to_integer(params["account"])]
    owned_cameras =
      Camera
      |> where([cam], cam.owner_id in ^account)
      |> where([cam], like(fragment("lower(?)", cam.name), ^("%#{String.downcase(search)}%")))
      |> preload(:owner)
      |> Evercam.Repo.all

    shared_cameras =
      Camera
      |> join(:left, [u], cs in CameraShare)
      |> where([cam, cs], cs.user_id in ^account)
      |> where([cam, cs], cam.id == cs.camera_id)
      |> where([cam], like(fragment("lower(?)", cam.name), ^("%#{String.downcase(search)}%")))
      |> preload(:owner)
      |> Evercam.Repo.all

    extraction_cameras =
      owned_cameras ++ shared_cameras      
      |> Enum.reduce([], fn camera, acc ->
        external_host = Util.deep_get(camera.config, ["external_host"], "")
        http_port = Util.deep_get(camera.config, ["external_http_port"], "")
        username = Util.deep_get(camera.config, ["auth", "basic", "password"], "")
        password = Util.deep_get(camera.config, ["auth", "basic", "password"], "")
        cam = %{
          name: camera.name,
          thumbnail: "https://media.evercam.io/v2/cameras/#{camera.exid}/thumbnail?api_id=#{camera.owner.api_id}&api_key=#{camera.owner.api_key}",
          exid: camera.exid,
          api_key: camera.owner.api_key,
          api_id: camera.owner.api_id,
          camera_id: camera.id,
          onvif_url: "url=http://#{external_host}:#{http_port}&auth=#{username}:#{password}&api_id=#{camera.owner.api_id}&api_key=#{camera.owner.api_key}"
        }
        acc ++ [cam]
      end)
    json(conn, extraction_cameras)
  end

  def onvif_cameras(conn, _params) do
    onvif_cameras =
      Camera
      |> where([cam], cam.owner_id == 13959)
      |> preload(:owner)
      |> order_by(asc: :name)
      |> Evercam.Repo.all
      |> Enum.map(fn(camera) ->
        external_host = Util.deep_get(camera.config, ["external_host"], "")
        http_port = Util.deep_get(camera.config, ["external_http_port"], "")
        username = Util.deep_get(camera.config, ["auth", "basic", "username"], "")
        password = Util.deep_get(camera.config, ["auth", "basic", "password"], "")
        %{
          name: camera.name,
          onvif_url: "url=http://#{external_host}:#{http_port}&auth=#{username}:#{password}&api_id=#{camera.owner.api_id}&api_key=#{camera.owner.api_key}"
        }
      end)
    json(conn, %{onvif_cameras: onvif_cameras})
  end

  def duplicate_cameras(conn, params) do
    host_port_jpg = if params["host_port_jpg"], do: true, else: false
    with false <- host_port_jpg do
      query = "select count(nullif(c.is_online = false, true)) as online, c.config->>'external_http_port' as
              external_http_port, c.config->>'external_host' as external_host, LOWER(config->'snapshots'->>'jpg')   as jpg, count(*) as
              count, count(nullif(cr.status like 'off','on')) as is_recording from cameras c left join cloud_recordings cr on c.id=cr.camera_id
              group by c.config->>'external_http_port', c.config->>'external_host', LOWER(c.config->'snapshots'->>'jpg') HAVING (
              COUNT(*)>1)"

      cameras = Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
      length = cameras.num_rows
      cols = Enum.map cameras.columns, &(String.to_atom(&1))
      roles = Enum.map cameras.rows, fn(row) ->
        Enum.zip(cols, row)
      end

      data =
        case length <= 0 do
          true -> []
          _ ->
            Enum.reduce(0..length - 1, [], fn i, acc ->
              camera = Enum.at(roles, i)
              cam = %{
                external_host: camera[:external_host],
                external_http_port: camera[:external_http_port],
                jpg: camera[:jpg],
                online: camera[:online],
                count: camera[:count],
                is_recording: camera[:is_recording]
              }
              acc ++ [cam]
            end)
        end
      json(conn, %{data: data})
    else
      true ->
        host = if params["host"] == "" || params["host"] == nil, do: "", else: String.downcase(params["host"])
        port = if params["port"] == "" || params["port"] == nil, do: "", else: String.downcase(params["port"])
        jpg = if params["jpg"] == "" || params["jpg"] == nil, do: "", else: String.downcase(params["jpg"])
        cameras = filter_camera(port, host, jpg)

        data =
          case Enum.count(cameras) <= 0 do
            true -> []
            false ->
              Enum.map(cameras, fn camera ->
                %{
                  camera_name: camera.name,
                  exid: camera.exid,
                  id: camera.id,
                  is_online: camera.is_online,
                  api_id: camera.owner.api_id,
                  api_key: camera.owner.api_key,
                  email: camera.owner.email,
                  owner_id: camera.owner.id,
                  camera_link: "<a href='https://dash.evercam.io/v2/cameras/#{camera.exid}?api_id=#{camera.owner.api_id}&api_key=#{camera.owner.api_key}' target='_blank'>#{camera.owner.firstname} #{camera.owner.lastname} <i class='fa fa-external-link'></i></a>",
                  is_public: camera.is_public,
                  cr_status: (if camera.cloud_recordings, do: camera.cloud_recordings.status, else: ""),
                  share_count: Enum.count(camera.shares),
                  created_at: (if camera.created_at, do: Calendar.Strftime.strftime!(camera.created_at, "%A, %d %b %Y %l:%M %p"), else: "")
                }
              end)
          end
        json(conn, data)
    end
  end

  def project_cameras(conn, params) do
    project_cameras =
      Camera
      |> where(project_id: ^params["project_id"])
      |> preload(:owner)
      |> order_by(asc: :name)
      |> Evercam.Repo.all
      |> Enum.reduce([], fn camera, acc ->
        c = %{
          project_id: camera.project_id,
          id: camera.id,
          exid: camera.exid,
          name: camera.name,
          timezone: camera.timezone,
          is_public: camera.is_public,
          is_online: camera.is_online,
          owner_email: camera.owner.email,
          external_host: Util.deep_get(camera.config, ["external_host"], ""),
          external_http_port: Util.deep_get(camera.config, ["external_http_port"], ""),
          username: Util.deep_get(camera.config, ["auth", "basic", "username"], ""),
          password: Util.deep_get(camera.config, ["auth", "basic", "password"], ""),
          camera_link: "<a href='https://dash.evercam.io/v2/cameras/#{camera.exid}?api_id=#{camera.owner.api_id}&api_key=#{camera.owner.api_key}' target='_blank'>#{User.get_fullname(camera.owner)} <i class='fa fa-external-link'></i></a>",
          created_at: Calendar.Strftime.strftime!(camera.created_at, "%A, %d %b %Y %l:%M %p")
        }
        acc ++ [c]
      end)

    records = %{
      data: project_cameras,
      total: Enum.count(project_cameras),
      per_page: String.to_integer(params["per_page"]),
      from: 0,
      to: Enum.count(project_cameras),
      current_page: String.to_integer(params["page"]),
      last_page: 0.0,
      next_page_url: "",
      prev_page_url: ""
    }

    json(conn, records)
  end

  def delete_camera_from_project(conn, params) do
    camera_id = params["camera_id"]
    Camera
    |> where(id: ^camera_id)
    |> Evercam.Repo.update_all(set: [project_id: nil])
    json(conn, %{success: true})
  end

  def add_to_project(conn, params) do
    exids = params["camera_exids"] |> String.split(",")
    project_id =
      case params["project_id"] do
        0 ->
          {:ok, project} = Project.changeset(%Project{}, %{user_id: params["owner_id"], name: params["project_name"]}) |> Evercam.Repo.insert
          project.id
        pid -> pid
      end
    
    Camera
    |> where([c], c.exid in ^exids)
    |> Evercam.Repo.update_all(set: [project_id: project_id])
    invalidate_urls = params["invalidate_urls"] |> String.split(",") |> Enum.dedup
    spawn fn -> invalidate_cache(invalidate_urls) end
    json(conn, %{success: true})
  end

  defp invalidate_cache([head | tail]) do
    HTTPoison.delete("https://api.evercam.io/v2/cameras#{head}")
    invalidate_cache(tail)
  end
  defp invalidate_cache([]), do: :noop

  defp filter_camera(port, host, jpg) do
    Camera
    |> parse_through_fragment(port, host, jpg)
    |> preload(:owner)
    |> preload(:cloud_recordings)
    |> preload(:shares)
    |> Evercam.Repo.all
  end

  defp parse_through_fragment(query, "", "", "") do
    query
    |> where([_cam], fragment(
      """
      ((config->> 'external_http_port')::text = '') AND
      ((config->> 'external_host')::text = '') AND
      ((config->'snapshots'->>'jpg')::text = '')
      """
    ))
  end
  defp parse_through_fragment(query, port, host, "") do
    query
    |> where([_cam], fragment(
      """
      (lower(config->> 'external_http_port') LIKE ?) AND
      (lower(config->> 'external_host') LIKE ?) AND
      ((config->'snapshots'->>'jpg')::text = '')
      """,
      ^"%#{port}%",
      ^"%#{host}%"
    ))
  end
  defp parse_through_fragment(query, port, "", "") do
    query
    |> where([_cam], fragment(
      """
      (lower(config->> 'external_http_port') LIKE ?) AND
      ((config->> 'external_host')::text = '') AND
      ((config->'snapshots'->>'jpg')::text = '')
      """,
      ^"%#{port}%"
    ))
  end
  defp parse_through_fragment(query, "", host, "") do
    query
    |> where([_cam], fragment(
      """
      ((config->> 'external_http_port')::text = '') AND
      (lower(config->> 'external_host') LIKE ?) AND
      ((config->'snapshots'->>'jpg')::text = '')
      """,
      ^"%#{host}%"
    ))
  end
  defp parse_through_fragment(query, "", "", jpg) do
    query
    |> where([_cam], fragment(
      """
      ((config->> 'external_http_port')::text = '') AND
      ((config->> 'external_host')::text = '') AND
      (lower(config->'snapshots'->>'jpg') LIKE ?)
      """,
      ^"%#{jpg}%"
    ))
  end
  defp parse_through_fragment(query, port, "", jpg) do
    query
    |> where([_cam], fragment(
      """
      (lower(config->> 'external_http_port') LIKE ?) AND
      ((config->> 'external_host')::text = '') AND
      (lower(config->'snapshots'->>'jpg') LIKE ?)
      """,
      ^"%#{port}%",
      ^"%#{jpg}%"
    ))
  end
  defp parse_through_fragment(query, "", host, jpg) do
    query
    |> where([_cam], fragment(
      """
      ((config->> 'external_http_port')::text LIKE '') AND
      (lower(config->> 'external_host') LIKE ?) AND
      (lower(config->'snapshots'->>'jpg') LIKE ?)
      """,
      ^"%#{host}%",
      ^"%#{jpg}%"
    ))
  end
  defp parse_through_fragment(query, port, host, "") do
    query
    |> where([_cam], fragment(
      """
      (lower(config->> 'external_http_port') LIKE ?) AND
      (lower(config->> 'external_host') LIKE ?) AND
      ((config->'snapshots'->>'jpg')::text = '')
      """,
      ^"%#{port}%",
      ^"%#{host}%"
    ))
  end
  defp parse_through_fragment(query, port, host, jpg) do
    query
    |> where([_cam], fragment(
      """
      (lower(config->> 'external_http_port') LIKE ?) AND
      (lower(config->> 'external_host') LIKE ?) AND
      (lower(config->'snapshots'->>'jpg') LIKE ?)
      """,
      ^"%#{port}%",
      ^"%#{host}%",
      ^"%#{jpg}%"
    ))
  end

  defp cast_mac(nil), do: ""
  defp cast_mac(""), do: ""
  defp cast_mac(%Postgrex.MACADDR{address: {a, b, c, d, e, f}}) do
    [a, b, c, d, e, f]
    |> Enum.map(&Integer.to_string(&1, 16))
    |> Enum.map(&String.pad_leading(&1, 2, "0"))
    |> Enum.join(":")
  end

  defp sorting("last_online_at", order), do: "order by c.last_online_at #{order}"
  defp sorting("project_name", order), do: "order by project_name #{order}"
  defp sorting("exid", order), do: "order by c.exid #{order}"
  defp sorting("fullname", order), do: "order by fullname #{order}"
  defp sorting("owner_email", order), do: "order by owner_email #{order}"
  defp sorting("payment_method", order), do: "order by payment_method #{order}"
  defp sorting("name", order), do: "order by c.name #{order}"
  defp sorting("total_share", order), do: "order by total_share #{order}"
  defp sorting("external_host", order), do: "order by c.config->> 'external_host' #{order}"
  defp sorting("external_http_port", order), do: "order by c.config->> 'external_http_port' #{order}"
  defp sorting("external_rtsp_port", order), do: "order by c.config->> 'external_rtsp_port' #{order}"
  defp sorting("username", order), do: "order by c.config-> 'auth'-> 'basic'->> 'username' #{order}"
  defp sorting("password", order), do: "order by c.config-> 'auth'-> 'basic'->> 'password' #{order}"
  defp sorting("mac_address", order), do: "order by c.mac_address #{order}"
  defp sorting("vendor_model_name", order), do: "order by vendor_model_name #{order}"
  defp sorting("vendor_name", order), do: "order by vendor_name #{order}"
  defp sorting("timezone", order), do: "order by c.timezone #{order}"
  defp sorting("is_public", order), do: "order by c.is_public #{order}"
  defp sorting("is_online", order), do: "order by c.is_online #{order}"
  defp sorting("cloud_recording_storage_duration", order), do: "order by cloud_recording_storage_duration #{order}"
  defp sorting("is_recording", order), do: "order by is_recording #{order}"
  defp sorting("last_polled_at", order), do: "order by c.last_polled_at #{order}"
  defp sorting("created_at", order), do: "order by c.created_at #{order}"
  defp sorting(_column, _order), do: "order by c.created_at desc"
end