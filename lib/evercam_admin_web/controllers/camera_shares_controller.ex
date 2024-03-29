defmodule EvercamAdminWeb.CameraSharesController do
  use EvercamAdminWeb, :controller
  import Ecto.Query
  require Logger

  def create(conn, params) do
    super_camera = params["super_camera"]
    cameras_to_delete_after_share = params["sharee_cameras"] |> Enum.filter(fn(camera) -> camera["id"] != super_camera["id"] end)
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


    Enum.each(cameras_to_delete_after_share, fn camera ->
      api = "#{Application.get_env(:evercam_admin, :evercam_server)}/v2/cameras/#{camera["exid"]}?api_id=#{camera["api_id"]}&api_key=#{camera["api_key"]}"
      HTTPoison.delete!(api, [], hackney: [])
    end)

    json(conn, %{success: true})
  end

  def index(conn, params) do
    {camera_exid, sharer_fullname, sharee_fullname, sharee_email, sorting} =
      Enum.reduce(params, {"", "", "", "", ""}, fn param, {camera_exid, sharer_fullname, sharee_fullname, sharee_email, sorting} = _acc ->
        {name, value} = param
        cond do
          name == "camera_exid" && value != "" ->
            {" and lower(exid) like lower('%#{value}%')", sharer_fullname, sharee_fullname, sharee_email, sorting}
          name == "sharer_fullname" && value != "" ->
            {camera_exid, " and lower(sharer.firstname || ' ' || sharer.lastname) like lower('%#{value}%')", sharee_fullname, sharee_email, sorting}
          name == "sharee_fullname" && value != "" ->
            {camera_exid, sharer_fullname, " and lower(sharee.firstname || ' ' || sharee.lastname) like lower('%#{value}%')", sharee_email, sorting}
          name == "sharee_email" && value != "" ->
            {camera_exid, sharer_fullname, sharee_fullname, " and lower(sharee.email) like lower('%#{value}%')", sorting}
          name == "sort" ->
            [column, order] =  String.split(value, "|")
            {camera_exid, sharer_fullname, sharee_fullname, sharee_email, sorting(column, order)}
          true ->
            {camera_exid, sharer_fullname, sharee_fullname, sharee_email, sorting}
        end
      end)

    query = "SELECT sharer.id sharer_id, sharer.firstname || ' ' || sharer.lastname sharer_fullname,
            sharer.api_id sharer_api_id, sharer.api_key sharer_api_key,
            sharee.id sharee_id, sharee.firstname || ' ' || sharee.lastname sharee_fullname,
            sharee.email as sharee_email,
            sharee.last_login_at as sharee_last_login,
            sharee.api_id sharee_api_id, sharee.api_key sharee_api_key,
            (select count(*) from camera_shares where user_id=sharee.id) as shared_cams_sharee,
            (select count(*) from cameras where owner_id=sharee.id) as owned_cams_sharee,
            c.id camera_id, c.exid, c.name, cs.id, cs.kind, cs.message, cs.created_at FROM camera_shares cs
            left JOIN users sharee on cs.user_id = sharee.id
            left JOIN users sharer on cs.sharer_id = sharer.id
            left JOIN cameras c on cs.camera_id = c.id where 1=1#{camera_exid}#{sharer_fullname}#{sharee_fullname}#{sharee_email} #{sorting}"
    camera_shares = Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
    cols = Enum.map camera_shares.columns, &(String.to_atom(&1))
    roles = Enum.map camera_shares.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    total_records = camera_shares.num_rows
    per_page = String.to_integer(params["per_page"])
    current_page = String.to_integer(params["page"])
    {last_page, display_start, index_end} = Utils.pagination_info(total_records, per_page, current_page)

    data =
      Enum.reduce((display_start - 1)..(index_end - 1), [], fn i, acc ->
        camera_share = Enum.at(roles, i)
        c = %{
          camera_sharee_link: (if camera_share[:sharee_fullname] == nil, do: "Deleted", else: "<a href='https://dash.evercam.io/v2/cameras/#{camera_share[:exid]}?api_id=#{camera_share[:sharee_api_id]}&api_key=#{camera_share[:sharee_api_key]}' target='_blank'>#{camera_share[:sharee_fullname]} <i class='fa fa-external-link'></i></a>"),
          camera_sharer_link: (if camera_share[:sharer_fullname] == nil, do: "Deleted", else: "<a href='https://dash.evercam.io/v2/cameras/#{camera_share[:exid]}?api_id=#{camera_share[:sharer_api_id]}&api_key=#{camera_share[:sharer_api_key]}' target='_blank'>#{camera_share[:sharer_fullname]} <i class='fa fa-external-link'></i></a>"),
          created_at: (if camera_share[:created_at], do: Calendar.Strftime.strftime!(camera_share[:created_at], "%A, %d %b %Y %l:%M %p"), else: ""),
          name: camera_share[:name],
          exid: (if camera_share[:exid] == nil, do: "Deleted", else: camera_share[:exid]),
          sharer_fullname: camera_share[:sharer_fullname],
          sharee_fullname: camera_share[:sharee_fullname],
          sharee_email: (if camera_share[:sharee_email] == nil, do: "Deleted", else: camera_share[:sharee_email]),
          shared_cams_sharee: camera_share[:shared_cams_sharee],
          owned_cams_sharee: camera_share[:owned_cams_sharee],
          sharer_api_id: camera_share[:sharer_api_id],
          sharer_api_key: camera_share[:sharer_api_key],
          kind: camera_share[:kind],
          share_id: camera_share[:id]
        }
        acc ++ [c]
      end)

    json(conn, Utils.paginator(display_start, index_end, params["sort"], total_records, per_page, current_page, data, "camera_shares", last_page))
  end

  def delete(conn, %{"share_id" => share_id} = _params) do
    CameraShare
    |> where(id: ^share_id)
    |> Evercam.Repo.one
    |> Evercam.Repo.delete

    json(conn, %{success: true})
  end

  defp sorting("exid", order), do: "order by exid #{order}"
  defp sorting("sharer_fullname", order), do: "order by sharer_fullname #{order}"
  defp sorting("sharee_fullname", order), do: "order by sharee_fullname #{order}"
  defp sorting("sharee_email", order), do: "order by sharee_email #{order}"
  defp sorting("shared_cams_sharee", order), do: "order by shared_cams_sharee #{order}"
  defp sorting("owned_cams_sharee", order), do: "order by owned_cams_sharee #{order}"
  defp sorting("kind", order), do: "order by kind #{order}"
  defp sorting("created_at", order), do: "order by created_at #{order}"
  defp sorting(_column, _order), do: "order by created_at desc"
end
