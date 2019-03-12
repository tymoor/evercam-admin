defmodule EvercamAdminWeb.CameraSharesController do
  use EvercamAdminWeb, :controller
  import Ecto.Query
  require Logger

  def create(conn, params) do
    super_camera = params["super_camera"]
    cameras_to_delete_after_share = params["sharee_cameras"] |> Enum.filter(fn(camera) -> camera["id"] != super_camera["id"] end)
    require IEx; IEx.pry()
    Enum.each(cameras_to_delete_after_share, fn camera ->
      camera_id = camera["id"]
      snapmails_for_merge_camera = SnapmailCamera |> where(camera_id: ^camera_id) |> Evercam.Repo.all

      Enum.each(snapmails_for_merge_camera, fn snapmail ->
        try do
          query = "update snapmail_cameras set updated_at=now(), camera_id = #{super_camera["id"]} where id = #{snapmail.id}"
          Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
        rescue
          _ -> Logger.info "Something went wrong"
        end
      end)

      going_to_merge_camera_share = CameraShare |> where(camera_id: ^camera_id) |> Evercam.Repo.all
      Enum.each(going_to_merge_camera_share, fn share ->
        try do
          query = "update camera_shares set updated_at=now(), camera_id=#{super_camera["id"]}, sharer_id=#{super_camera["owner_id"]} where id = #{share.id}"
          Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
        rescue
          _ -> Logger.info "Something went wrong"
        end
      end)
    end)

    super_owner = super_camera["email"]
    emails_to_share = Enum.map(cameras_to_delete_after_share, fn camera -> camera["email"] end) |> Enum.filter(fn(email) -> email != super_owner end)

    case Enum.count(emails_to_share) do
      0 -> :noop
      _ ->
        api = "#{Application.get_env(:evercam_admin, :evercam_server)}/v2/cameras/#{super_camera["exid"]}/shares?api_id=#{super_camera["api_id"]}&api_key=#{super_camera["api_key"]}"
        params = %{
          email: emails_to_share,
          rights: "Snapshot,View,Edit,List"
        }
        headers = ["Accept": "Accept:application/json", "Content-Type": "application/json"]
        json = Jason.encode!(params)
        HTTPoison.post(api, json, headers)
    end

    json(conn, %{success: true})
  end

  def index(conn, params) do
    {camera_exid, sharer_fullname, sharee_fullname, sorting} =
      Enum.reduce(params, {"", "", "", ""}, fn param, {camera_exid, sharer_fullname, sharee_fullname, sorting} = _acc ->
        {name, value} = param
        cond do
          name == "camera_exid" && value != "" ->
            {" and lower(exid) like lower('%#{value}%')", sharer_fullname, sharee_fullname, sorting}
          name == "sharer_fullname" && value != "" ->
            {camera_exid, " and lower(sharer.firstname || ' ' || sharer.lastname) like lower('%#{value}%')", sharee_fullname, sorting}
          name == "sharee_fullname" && value != "" ->
            {camera_exid, sharer_fullname, " and lower(sharee.firstname || ' ' || sharee.lastname) like lower('%#{value}%')", sorting}
            name == "sort" ->
              [column, order] =  String.split(value, "|")
            {camera_exid, sharer_fullname, sharee_fullname, sorting(column, order)}  
          true ->
            {camera_exid, sharer_fullname, sharee_fullname, sorting}
        end
      end)

    query = "SELECT sharer.id sharer_id, sharer.firstname || ' ' || sharer.lastname sharer_fullname,
            sharer.api_id sharer_api_id, sharer.api_key sharer_api_key,
            sharee.id sharee_id, sharee.firstname || ' ' || sharee.lastname sharee_fullname,
            sharee.api_id sharee_api_id, sharee.api_key sharee_api_key,
            c.id camera_id, c.exid, c.name, cs.id, cs.kind, cs.message, cs.created_at FROM camera_shares cs
            left JOIN users sharee on cs.user_id = sharee.id
            left JOIN users sharer on cs.sharer_id = sharer.id
            left JOIN cameras c on cs.camera_id = c.id where 1=1#{camera_exid}#{sharer_fullname}#{sharee_fullname} #{sorting}"
    camera_shares = Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
    cols = Enum.map camera_shares.columns, &(String.to_atom(&1))
    roles = Enum.map camera_shares.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    total_records = camera_shares.num_rows
    d_length = String.to_integer(params["per_page"])
    display_length = if d_length < 0, do: total_records, else: d_length
    display_start = if String.to_integer(params["page"]) <= 1, do: 0, else: (String.to_integer(params["page"]) - 1) * display_length + 1
    index_e = ((String.to_integer(params["page"]) - 1) * display_length) + display_length
    index_end = if index_e > total_records, do: total_records - 1, else: index_e
    last_page = Float.round(total_records / (display_length / 1))

    data =
      Enum.reduce(display_start..index_end, [], fn i, acc ->
        camera_share = Enum.at(roles, i)
        c = %{
          camera_sharee_link: (if camera_share[:sharee_fullname] == nil, do: "Deleted", else: "<a href='https://dash.evercam.io/v1/cameras/#{camera_share[:exid]}?api_id=#{camera_share[:sharee_api_id]}&api_key=#{camera_share[:sharee_api_key]}' target='_blank'>#{camera_share[:sharee_fullname]} <i class='fa fa-external-link'></i></a>"),
          camera_sharer_link: (if camera_share[:sharer_fullname] == nil, do: "Deleted", else: "<a href='https://dash.evercam.io/v1/cameras/#{camera_share[:exid]}?api_id=#{camera_share[:sharer_api_id]}&api_key=#{camera_share[:sharee_api_key]}' target='_blank'>#{camera_share[:sharer_fullname]} <i class='fa fa-external-link'></i></a>"),
          created_at: (if camera_share[:created_at], do: Calendar.Strftime.strftime!(camera_share[:created_at], "%A, %d %b %Y %l:%M %p"), else: ""),
          name: camera_share[:name],
          exid: (if camera_share[:exid] == nil, do: "Deleted", else: camera_share[:exid]),
          sharer_fullname: camera_share[:sharer_fullname],
          sharee_fullname: camera_share[:sharee_fullname],
          kind: camera_share[:kind]
        }
        acc ++ [c]
      end)

    records = %{
      data: (if total_records < 1, do: [], else: data),
      total: total_records,
      per_page: display_length,
      from: display_start,
      to: index_end,
      current_page: String.to_integer(params["page"]),
      last_page: last_page,
      next_page_url: (if String.to_integer(params["page"]) == last_page, do: "", else: "/v1/camera_shares?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) + 1}"),
      prev_page_url: (if String.to_integer(params["page"]) < 1, do: "", else: "/v1/camera_shares?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) - 1}")
    }
    json(conn, records)
  end

  defp sorting("exid", order), do: "order by exid #{order}"
  defp sorting("sharer_fullname", order), do: "order by sharer_fullname #{order}"
  defp sorting("sharee_fullname", order), do: "order by sharee_fullname #{order}"
  defp sorting("kind", order), do: "order by kind #{order}"
  defp sorting("created_at", order), do: "order by created_at #{order}"
  defp sorting(_column, _order), do: "order by created_at desc"
end
