defmodule EvercamAdminWeb.StorageController do
  use EvercamAdminWeb, :controller

  @seaweedfs_new Application.get_env(:evercam_admin, :seaweedfs_new)

  @proxy_host Application.get_env(:evercam_admin, :proxy_host)
  @proxy_pass Application.get_env(:evercam_admin, :proxy_pass)

  def index(conn, _params) do

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get(
                              "http://#{@seaweedfs_new}:8888/evercam-admin3/storage.json",
                              ["Accept": "application/json"],
                              hackney: [pool: :seaweedfs_download_pool],
                              proxy: {@proxy_host, 80},
                              proxy_auth: {"fixie", @proxy_pass}
                            )
    do
      total_data = Jason.decode!(body)
      length = Enum.count(total_data)

      data =
        case length <= 0 do
          true -> []
          _ ->
            Enum.reduce(0..length - 1, [], fn i, acc ->
              cam_info = Enum.at(total_data, i)
              u = %{
                exid: cam_info["camera_exid"],
                camera_name: cam_info["camera_name"],
                oldest_snapshot_date: cam_info["oldest_snapshot_date"],
                latest_snapshot_date: cam_info["latest_snapshot_date"],
                years: cam_info["years"],
                total_months: total_months(cam_info["years"])
              }
              acc ++ [u]
            end)
        end
      json(conn, %{data: data})
    else
      _ ->
        json(conn, %{data: []})
    end
  end

  def refresh(conn, _params) do
    spawn(fn ->
      EvercamAdmin.Storage.start_link("refresh")
    end)
    json(conn, %{success: true})
  end

  defp total_months(years) do
    Enum.reduce(years, 0, fn year, total_months = _acc ->
      {_year, months} = year
      Enum.count(months) + total_months
    end)
  end
end