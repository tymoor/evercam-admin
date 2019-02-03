defmodule EvercamAdminWeb.VendorModelsController do
  use EvercamAdminWeb, :controller
  import Ecto.Query

  def index(conn, params) do
    [column, order] = params["sort"] |> String.split("|")
    search = if params["search"] in ["", nil], do: "", else: params["search"]
    query = from vm in VendorModel,
              join: v in Vendor, on: vm.vendor_id == v.id,
              where: like(fragment("lower(?)", vm.name), ^("%#{search}%")),
              where: like(fragment("lower(?)", v.name), ^("%#{search}%"))
    models = query |> add_sorting(column, order) |> preload(:vendor) |> Evercam.Repo.all()
  end

  defp sort_order("asc"), do: :asc
  defp sort_order("desc"), do: :desc

  defp add_sorting(query, "exid", order) do
    from [vm, _v] in query,
      order_by: [{^sort_order(order), vm.exid}]
  end
  defp add_sorting(query, "vname", order) do
    from [_vm, v] in query,
      order_by: [{^sort_order(order), v.name}]
  end
  defp add_sorting(query, "vmname", order) do
    from [vm, _v] in query,
      order_by: [{^sort_order(order), vm.name}]
  end
  defp add_sorting(query, "jpg_url", order) do
    from [vm, _v] in query,
      order_by: [{^sort_order(order), vm.jpg_url}]
  end
  defp add_sorting(query, "h264_url", order) do
    from [vm, _v] in query,
      order_by: [{^sort_order(order), vm.h264_url}]
  end
  defp add_sorting(query, "mjpg_url", order) do
    from [vm, _v] in query,
      order_by: [{^sort_order(order), vm.mjpg_url}]
  end
  defp add_sorting(query, "mpeg4_url", order) do
    from [vm, _v] in query,
      order_by: [{^sort_order(order), vm.mpeg4_url}]
  end
  defp add_sorting(query, "mobile_url", order) do
    from [vm, _v] in query,
      order_by: [{^sort_order(order), vm.mobile_url}]
  end
  defp add_sorting(query, "lowres_url", order) do
    from [vm, _v] in query,
      order_by: [{^sort_order(order), vm.lowres_url}]
  end
  defp add_sorting(query, "username", order) do
    from [vm, _v] in query,
      order_by: [{^sort_order(order), vm.username}]
  end
  defp add_sorting(query, "password", order) do
    from [vm, _v] in query,
      order_by: [{^sort_order(order), vm.password}]
  end
  defp add_sorting(query, "audio_url", order) do
    from [vm, _v] in query,
      order_by: [{^sort_order(order), vm.audio_url}]
  end
  defp add_sorting(query, "poe", order) do
    from [vm, _v] in query,
      order_by: [{^sort_order(order), vm.poe}]
  end
  defp add_sorting(query, "wifi", order) do
    from [vm, _v] in query,
      order_by: [{^sort_order(order), vm.wifi}]
  end
  defp add_sorting(query, "onvif", order) do
    from [vm, _v] in query,
      order_by: [{^sort_order(order), vm.onvif}]
  end
  defp add_sorting(query, "psia", order) do
    from [vm, _v] in query,
      order_by: [{^sort_order(order), vm.psia}]
  end
  defp add_sorting(query, "ptz", order) do
    from [vm, _v] in query,
      order_by: [{^sort_order(order), vm.ptz}]
  end
  defp add_sorting(query, "infrared", order) do
    from [vm, _v] in query,
      order_by: [{^sort_order(order), vm.infrared}]
  end
  defp add_sorting(query, "varifocal", order) do
    from [vm, _v] in query,
      order_by: [{^sort_order(order), vm.varifocal}]
  end
  defp add_sorting(query, "sd_card", order) do
    from [vm, _v] in query,
      order_by: [{^sort_order(order), vm.sd_card}]
  end
  defp add_sorting(query, "upnp", order) do
    from [vm, _v] in query,
      order_by: [{^sort_order(order), vm.upnp}]
  end
  defp add_sorting(query, "audio_io", order) do
    from [vm, _v] in query,
      order_by: [{^sort_order(order), vm.audio_io}]
  end
  defp add_sorting(query, "shape", order) do
    from [vm, _v] in query,
      order_by: [{^sort_order(order), vm.shape}]
  end
  defp add_sorting(query, "resolution", order) do
    from [vm, _v] in query,
      order_by: [{^sort_order(order), vm.resolution}]
  end
end
