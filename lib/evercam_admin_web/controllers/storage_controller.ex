defmodule EvercamAdminWeb.StorageController do
  use EvercamAdminWeb, :controller
  import Ecto.Query

  def index(conn, param) do
    query = "select c.*, u.api_id, u.api_key
            from cameras as c
            inner JOIN users u on c.owner_id = u.id
            where owner_id in (13959, 109148) order by c.name asc"

    cameras = Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
    cols = Enum.map cameras.columns, &(String.to_atom(&1))
    roles = Enum.map cameras.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    length = cameras.num_rows

    data =
      case length <= 0 do
        true -> []
        _ ->
          Enum.reduce(0..length - 1, [], fn i, acc ->
            camera = Enum.at(roles, i)
            c = %{
              exid: camera[:exid],
              name: camera[:name],
              camera_link: "<a href='https://dash.evercam.io/v2/cameras/#{camera[:exid]}?api_id=#{camera[:api_id]}&api_key=#{camera[:api_key]}' target='_blank'>#{camera[:name]} <i class='fa fa-external-link'></i></a>",
              api_key: camera[:api_key],
              api_id: camera[:api_id]
            }
            acc ++ [c]
          end)
      end

    json(conn, %{data: data})
  end
end