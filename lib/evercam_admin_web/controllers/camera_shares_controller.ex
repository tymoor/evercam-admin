defmodule EvercamAdminWeb.CameraSharesController do
  use EvercamAdminWeb, :controller

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
            c.id camera_id, c.exid, cs.id, cs.kind, cs.message, cs.created_at FROM camera_shares cs
            left JOIN users sharee on cs.user_id = sharee.id
            left JOIN users sharer on cs.sharer_id = sharer.id
            left JOIN cameras c on cs.camera_id = c.id where 1=1 #{camera_exid}#{sharer_fullname}#{sharee_fullname} #{sorting}"
    camera_shares = Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
    cols = Enum.map camera_shares.columns, &(String.to_atom(&1))
    roles = Enum.map camera_shares.rows, fn(row) ->
      Enum.zip(cols, row)
    end
  end

  defp sorting("exid", order), do: "order by exid #{order}"
  defp sorting("sharer_fullname", order), do: "order by sharer_fullname #{order}"
  defp sorting("sharee_fullname", order), do: "order by sharee_fullname #{order}"
  defp sorting("kind", order), do: "order by kind #{order}"
  defp sorting("created_at", order), do: "order by created_at #{order}"
  defp sorting(_column, _order), do: "order by created_at desc"
end
