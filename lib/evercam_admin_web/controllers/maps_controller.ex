defmodule EvercamAdminWeb.MapsController do
  use EvercamAdminWeb, :controller

  def index(conn, params) do
    case params["map_for"] do
      "all" -> map(conn, :all)
    end
  end

  defp map(conn, :all) do
    Camera.all
    |> 
  end
end

      # markers: [{
      #   position: {
      #     lat: 47.376332,
      #     lng: 8.547511
      #   },
      #   infoText: 'Marker 1'
      # }, {
      #   position: {
      #     lat: 47.374592,
      #     lng: 8.548867
      #   },
      #   infoText: 'Marker 2'
      # }, {
      #   position: {
      #     lat: 47.379592,
      #     lng: 8.549867
      #   },
      #   infoText: 'Marker 3'
      # }]