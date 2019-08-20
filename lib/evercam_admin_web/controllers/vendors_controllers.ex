defmodule EvercamAdminWeb.VendorsController do
  use EvercamAdminWeb, :controller
  import Ecto.Query

  def create(conn, params) do
    with :ok <- known_macs(params["known_macs"]) do
      vendor = Vendor.by_exid(params["exid"]) || %Vendor{}
      Vendor.changeset(vendor, %{
        exid: params["exid"],
        name: params["name"],
        known_macs: (if params["known_macs"] in ["", nil], do: [], else: String.split(params["known_macs"], ","))
      })
      |> Evercam.Repo.insert_or_update
      |> case do
        {:ok, _vendor} -> json(conn, %{success: true})
        {:error, _changeset} -> conn |> put_status(400) |> json(%{success: false, message: "Something went wrong."})
      end
    else
      :not_ok -> conn |> put_status(400) |> json(%{success: false, message: "Mac Addresses are not correct."})
    end
  end

  def delete(conn, %{"exid" => vendor_exid} = _params) do
    Vendor
    |> where(exid: ^vendor_exid)
    |> Evercam.Repo.one
    |> Evercam.Repo.delete

    json(conn, %{success: true})
  end

  def index(conn, params) do
    [column, order] = params["sort"] |> String.split("|")
    search = if params["search"] in ["", nil], do: "", else: params["search"]
    query = from v in Vendor,
              where: like(fragment("lower(?)", v.name), ^("%#{search}%"))
    vendors = query |> add_sorting(column, order) |> Evercam.Repo.all()

    total_records = vendors |> Enum.count
    per_page = String.to_integer(params["per_page"])
    current_page = String.to_integer(params["page"])
    {last_page, display_start, index_end} = Utils.pagination_info(total_records, per_page, current_page)

    data =
      case total_records <= 0 do
        true -> []
        _ ->
          Enum.reduce((display_start - 1)..(index_end - 1), [], fn i, acc ->
            vendor = Enum.at(vendors, i)
            v = %{
              exid: vendor.exid,
              name: vendor.name,
              known_macs: vendor.known_macs,
            }
            acc ++ [v]
          end)
      end

    json(conn, Utils.paginator(display_start, index_end, params["sort"], total_records, per_page, current_page, data, "vendors", last_page))
  end

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

  defp sort_order("asc"), do: :asc
  defp sort_order("desc"), do: :desc

  defp add_sorting(query, "exid", order) do
    from [v] in query,
      order_by: [{^sort_order(order), v.exid}]
  end
  defp add_sorting(query, "name", order) do
    from [v] in query,
      order_by: [{^sort_order(order), v.name}]
  end

  defp known_macs(known_macs) when known_macs in [nil, ""], do: :ok
  defp known_macs(known_macs) do
    mac_addresses = String.split(known_macs, ",")

    Enum.reduce(mac_addresses, 0, fn mac_address, wrong_count = _acc ->
      case mac_address =~ ~r/^([0-9A-Fa-f]{2}[:-]){2}([0-9A-Fa-f]{2})$/ do
        true -> wrong_count + 0
        false -> wrong_count + 1
      end
    end) |> case do
      0 -> :ok
      _ -> :not_ok
    end
  end
end