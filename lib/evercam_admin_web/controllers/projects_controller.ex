defmodule EvercamAdminWeb.ProjectsController do
  use EvercamAdminWeb, :controller
  import Ecto.Query

  def index(conn, params) do
    [column, order] = params["sort"] |> String.split("|")
    search = if params["search"] in ["", nil], do: "", else: params["search"]

    query = "select p.*,u.firstname || ' ' || u.lastname as fullname, u.api_id, u.api_key, (select count(id) from cameras where project_id=p.id) cameras
            from projects p inner join users u on u.id=p.user_id
            where 1=1 or lower(p.exid) like lower('%#{search}%') or lower(p.name) like lower('%#{search}%')
            #{sorting(column, order)}"

    projects = Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
    cols = Enum.map projects.columns, &(String.to_atom(&1))
    rows = Enum.map projects.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    total_records = projects.num_rows
    per_page = String.to_integer(params["per_page"])
    current_page = String.to_integer(params["page"])
    {last_page, display_start, index_end} = Utils.pagination_info(total_records, per_page, current_page)


    data =
      Enum.reduce((display_start - 1)..(index_end - 1), [], fn i, acc ->
        project = Enum.at(rows, i)
        c = %{
          id: project[:id],
          name: project[:name],
          owner: "<a href='https://dash.evercam.io/v2/cameras?api_id=#{project[:api_id]}&api_key=#{project[:api_key]}' target='_blank'>#{project[:fullname]} <i class='fa fa-external-link'></i></a>",
          exid: project[:exid],
          cameras: project[:cameras],
          inserted_at: Calendar.Strftime.strftime!(project[:inserted_at], "%A, %d %b %Y %l:%M %p")
          # api_id: project[:api_id],
          # api_key: project[:api_key],
        }
        acc ++ [c]
      end)

    json(conn, Utils.paginator(display_start, index_end, params["sort"], total_records, per_page, current_page, data, "projects", last_page))
  end

  def create(conn, params) do
    changeset = Project.changeset(%Project{}, %{user_id: params["owner_id"], name: params["project_name"]})
    case Evercam.Repo.insert(changeset) do
      {:ok, _project} -> json(conn, %{success: true})
      {:error, _changeset} -> json(conn, %{success: false})
    end
  end

  def update(conn, params) do
    project = Project.by_exid(params["project_exid"])
    Project.changeset(project, %{name: params["project_name"]}) |> Evercam.Repo.update
    json(conn, %{success: true})
  end

  def delete(conn, params) do
    project = Project.by_exid(params["project_exid"])
    
    query = "update cameras set project_id=null where project_id=#{project.id}"
    Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
    
    Project.delete_by_exid(params["project_exid"])
    json(conn, %{success: true})
  end

  def get_owner(conn, params) do
    search = if params["search"] in ["", nil], do: "", else: params["search"]
    users =
      User
      |> where([u], like(u.email, ^"%#{String.downcase(search)}%"))
      |> Evercam.Repo.all
      |> Enum.reduce([], fn user, acc ->
        acc ++ [%{id: user.id, email: user.email}]
      end)
    json(conn, users)
  end

  def search_project(conn, params) do
    search = if params["search"] in ["", nil], do: "", else: params["search"]
    projects_list =
      Project
      |> where([p], like(fragment("lower(?)", p.name), ^"%#{String.downcase(search)}%"))
      |> Evercam.Repo.all
      |> Enum.reduce([], fn project, acc ->
        acc ++ [%{id: project.id, name: project.name}]
      end)
    
    projects =
      case Enum.count(projects_list) do
        0 -> [%{id: 0, name: params["search"]}]
        _ -> projects_list
      end
    json(conn, projects)
  end

  defp sorting("name", order), do: "order by p.name #{order}"
  defp sorting("exid", order), do: "order by p.exid #{order}"
  defp sorting("fullname", order), do: "order by fullname #{order}"
  defp sorting("cameras", order), do: "order by cameras #{order}"
  defp sorting("inserted_at", order), do: "order by inserted_at #{order}"
end