defmodule EvercamAdminWeb.VendorsController do
  use EvercamAdminWeb, :controller

  def vendors(conn, _params) do
    vendors =
      Vendor
      |> Evercam.Repo.all
      |> Enum.map(fn(vendor) ->
        %{
          id: vendor.id,
          name: vendor.name
        }
      end)
    json(conn, %{vendors: vendors})
  end
end