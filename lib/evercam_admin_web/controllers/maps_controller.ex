defmodule EvercamAdminWeb.MapsController do
  use EvercamAdminWeb, :controller
  import Ecto.Query

  def index(conn, params) do
    case params["map_for"] do
      "all" -> map(conn, :all)
    end
  end

  defp map(conn, :all) do
    markers =
      Camera
      |> preload(:owner)
      |> preload(:vendor_model)
      |> preload([vendor_model: :vendor])
      |> Evercam.Repo.all
      |> Enum.filter(& !is_nil(&1.location))
      |> Enum.reduce([], fn camera, acc ->
        %Geo.Point{coordinates: {lng, lat}} = camera.location
        marker = %{
          position: %{
            lat: lat,
            lng: lng
          },
          infoText: camera.exid,
          icon: %{
            url: "http://maps.google.com/mapfiles/ms/icons/orange-dot.png",
            size: %{width: 46, height: 46, f: "px", b: "px"},
            scaledSize: %{width: 23, height: 23, f: "px", b: "px"}
          }
        }
        acc ++ [marker]
      end)
    json(conn, %{markers: markers})
  end
end
