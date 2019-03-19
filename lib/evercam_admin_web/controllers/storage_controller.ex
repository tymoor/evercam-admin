defmodule EvercamAdminWeb.StorageController do
  use EvercamAdminWeb, :controller
  import Ecto.Query

  alias HTTPoison.Response, as: Resp

  def index(conn, param) do
    year = param["year"]

    months = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
    construction_cameras =
      Camera
      |> where([cam], cam.owner_id == 13959)
      |> preload(:owner)
      |> Evercam.Repo.all


    length = if param["length"], do: String.to_integer(param["length"]), else: Enum.count(construction_cameras)

    hearders = ["Accept": "application/json"]

    data = 
      Enum.reduce(0..length - 1, [], fn i, acc ->
        camera = Enum.at(construction_cameras, i)

        months_data =
          Enum.map(months, fn month ->
            available =
              create_request_url(camera, year, month)
              |> get_month_request(hearders)
            %{
              translate_month(month) => available
            }
          end)

        storage = %{
          camera_name: camera.name,
          camera_exid: camera.exid,
          months_data: months_data
        }

        acc ++ [storage]
      end)

    json(conn, %{data: data})
  end

  defp get_month_request(url, hearders) do
    with {:ok, %Resp{status_code: 200, body: body}} <- HTTPoison.get(url, hearders) do
      Jason.decode!(body)["days"] |> directories?
    else
      _ ->
        false
    end
  end

  defp directories?([]), do: false
  defp directories?(_dirs), do: true

  defp create_request_url(camera, year, month) do
    "https://media.evercam.io/v2/cameras/#{camera.exid}/recordings/snapshots/#{year}/#{month}/days?api_id=#{camera.owner.api_id}&api_key=#{camera.owner.api_key}"
  end

  defp translate_month("01"), do: "Jan"
  defp translate_month("02"), do: "Feb"
  defp translate_month("03"), do: "Mar"
  defp translate_month("04"), do: "Apr"
  defp translate_month("05"), do: "May"
  defp translate_month("06"), do: "June"
  defp translate_month("07"), do: "Jul"
  defp translate_month("08"), do: "Aug"
  defp translate_month("09"), do: "Sep"
  defp translate_month("10"), do: "Oct"
  defp translate_month("11"), do: "Nov"
  defp translate_month("12"), do: "Dec"
end