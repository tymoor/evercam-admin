defmodule EvercamAdminWeb.NvrsController do
  use EvercamAdminWeb, :controller

  def index(conn, params) do
    owner_id = params["owner_id"]
    append_query = if owner_id == "-1", do: "owner_id not in (109148, 13959)", else: "owner_id=#{owner_id}" 
    query = "select c.*, u.api_id, u.api_key
            from cameras as c
            inner JOIN users u on c.owner_id = u.id
            where #{append_query} order by c.name asc"

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
              api_key: camera[:api_key],
              api_id: camera[:api_id],
              external_host: camera[:config]["external_host"]
            }
            acc ++ [c]
          end)
      end

    json(conn, %{data: data})
  end
end