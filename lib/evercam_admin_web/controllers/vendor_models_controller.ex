defmodule EvercamAdminWeb.VendorModelsController do
  use EvercamAdminWeb, :controller
  import Ecto.Query

  def index(conn, params) do
    [column, order] = params["sort"] |> String.split("|")
    search = if params["search"] in ["", nil], do: "", else: params["search"]
    query = from vm in VendorModel,
              join: v in Vendor, on: vm.vendor_id == v.id,
              where: like(fragment("lower(?)", vm.name), ^("%#{search}%")),
              or_where: like(fragment("lower(?)", v.name), ^("%#{search}%"))
    models = query |> add_sorting(column, order) |> preload(:vendor) |> Evercam.Repo.all()

    total_records = models |> Enum.count
    d_length = String.to_integer(params["per_page"])
    display_length = if d_length < 0, do: total_records, else: d_length
    display_start = if String.to_integer(params["page"]) <= 1, do: 0, else: (String.to_integer(params["page"]) - 1) * display_length + 1
    index_e = ((String.to_integer(params["page"]) - 1) * display_length) + display_length
    index_end = if index_e > total_records, do: total_records - 1, else: index_e
    last_page = Float.round(total_records / (display_length / 1))

    data =
      case total_records <= 0 do
        true -> []
        _ ->
          Enum.reduce(display_start..index_end, [], fn i, acc ->
            model = Enum.at(models, i)
            vm = %{
              vendor_exid: model.vendor.exid,
              exid: model.exid,
              vendor_name: model.vendor.name,
              name: model.name,
              channel: model.channel,
              jpg_url: model.jpg_url,
              h264_url: model.h264_url,
              mjpg_url: model.mjpg_url,

              mpeg4_url: model.mpeg4_url,
              mobile_url: model.mobile_url,
              lowres_url: model.lowres_url,

              username: model.username,
              password: model.password,
              audio_url: model.audio_url,
              poe: model.poe,
              wifi: model.wifi,
              onvif: model.onvif,
              psia: model.psia,
              ptz: model.ptz,
              infrared: model.infrared,
              varifocal: model.varifocal,
              sd_card: model.sd_card,
              upnp: model.upnp,
              audio_io: model.audio_io,
              shape: model.shape,
              resolution: model.resolution,
              camera_count: Camera |> where(model_id: ^model.id) |> Evercam.Repo.all() |> Enum.count(),
            }
            acc ++ [vm]
          end)
      end

    records = %{
      data: (if total_records < 1, do: [], else: data),
      total: total_records,
      per_page: display_length,
      from: display_start,
      to: index_end,
      current_page: String.to_integer(params["page"]),
      last_page: last_page,
      next_page_url: (if String.to_integer(params["page"]) == last_page, do: "", else: "/v1/vendor_models?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) + 1}"),
      prev_page_url: (if String.to_integer(params["page"]) < 1, do: "", else: "/v1/vendor_models?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) - 1}")
    }
    json(conn, records)
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
