defmodule EvercamAdminWeb.VendorModelsController do
  use EvercamAdminWeb, :controller
  import Ecto.Query

  def create(conn, params) do
    vendor_model = VendorModel.by_exid(params["model_exid"]) || %VendorModel{}
    VendorModel.changeset(vendor_model, %{
      exid: params["model_exid"],
      vendor_id: params["vendor"],
      channel: params["channel"],
      name: params["name"],
      jpg_url: params["jpg_url"],
      mjpg_url: params["mjpg_ur"],
      mpeg4_url: params["mpeg4_url"],
      mobile_url: params["mobile_url"],
      h264_url: params["h264_url"],
      lowres_url: params["lowres_url"],
      audio_url: params["audio_url"],
      username: params["username"],
      password: params["password"],
      resolution: params["resolution"],
      poe: params["poe"],
      wifi: params["wifi"],
      onvif: params["onvif"],
      pisa: params["pisa"],
      audio_io: params["audio_io"],
      ptz: params["ptz"],
      infrared: params["infrared"],
      varifocal: params["varifocal"],
      sd_card: params["sd_card"],
      upnp: params["upnp"]
    })
    |> Evercam.Repo.insert_or_update
    |> case do
      {:ok, _vendor_model} -> json(conn, %{success: true})
      {:error, _changeset} -> conn |> put_status(400) |> json(%{success: false})
    end
  end

  def index(conn, params) do
    [column, order] = params["sort"] |> String.split("|")
    search = if params["search"] in ["", nil], do: "", else: params["search"]

    query = "SELECT vm.*, v.name as vendor_name, v.exid as vendor_exid, v.id as vendor_id, count(cameras.id) as count
             FROM vendor_models as vm
             INNER JOIN vendors as v ON vm.vendor_id = v.id
             INNER JOIN cameras ON vm.id = cameras.model_id
             WHERE lower(vm.name) like lower('%#{search}%') OR lower(v.name) like lower('%#{search}%')
             GROUP BY vm.id, v.id
             #{add_sorting(column, order)}"

    models = Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
    cols = Enum.map models.columns, &(String.to_atom(&1))
    roles = Enum.map models.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    total_records = models.num_rows
    per_page = String.to_integer(params["per_page"])
    current_page = String.to_integer(params["page"])
    {last_page, display_start, index_end} = Utils.pagination_info(total_records, per_page, current_page)

    data =
      case total_records <= 0 do
        true -> []
        _ ->
          Enum.reduce((display_start - 1)..(index_end - 1), [], fn i, acc ->
            model = Enum.at(roles, i)
            vm = %{
              vendor_exid: model[:vendor_exid],
              exid: model[:exid],
              vendor_id: model[:vendor_id],
              vendor_name: model[:vendor_name],
              name: model[:name],
              channel: model[:channe],
              jpg_url: model[:jpg_url],
              h264_url: model[:h264_url],
              mjpg_url: model[:mjpg_url],

              mpeg4_url: model[:mpeg4_ur],
              mobile_url: model[:mobile_url],
              lowres_url: model[:lowres_url],

              username: model[:username],
              password: model[:password],
              audio_url: model[:audio_url],
              poe: model[:poe],
              wifi: model[:wifi],
              onvif: model[:onvif],
              psia: model[:psia],
              ptz: model[:ptz],
              infrared: model[:infrared],
              varifocal: model[:varifocal],
              sd_card: model[:sd_card],
              upnp: model[:upnp],
              audio_io: model[:audio_io],
              shape: model[:shape],
              resolution: model[:resolution],
              camera_count: model[:count]
            }
            acc ++ [vm]
          end)
      end

    json(conn, Utils.paginator(display_start, index_end, params["sort"], total_records, per_page, current_page, data, "vendor_models", last_page))
  end

  def delete(conn, %{"exid" => model_exid} = _params) do
    VendorModel
    |> where(exid: ^model_exid)
    |> Evercam.Repo.one
    |> Evercam.Repo.delete

    json(conn, %{success: true})
  end

  defp add_sorting("exid", order), do: "ORDER BY exid #{order}"
  defp add_sorting("vname", order), do: "ORDER BY vendor_name #{order}"
  defp add_sorting("vmname", order), do: "ORDER BY name #{order}"
  defp add_sorting("jpg_url", order), do: "ORDER BY jpg_url #{order}"
  defp add_sorting("h264_url", order), do: "ORDER BY h264_url #{order}"
  defp add_sorting("mjpg_url", order), do: "ORDER BY mjpg_url #{order}"
  defp add_sorting("mpeg4_url", order), do: "ORDER BY mpeg4_url #{order}"
  defp add_sorting("mobile_url", order), do: "ORDER BY mobile_url #{order}"
  defp add_sorting("lowres_url", order), do: "ORDER BY lowres_url #{order}"
  defp add_sorting("username", order), do: "ORDER BY username #{order}"
  defp add_sorting("password", order), do: "ORDER BY password #{order}"
  defp add_sorting("audio_url", order), do: "ORDER BY audio_url #{order}"
  defp add_sorting("poe", order), do: "ORDER BY poe #{order}"
  defp add_sorting("wifi", order), do: "ORDER BY wifi #{order}"
  defp add_sorting("onvif", order), do: "ORDER BY onvif #{order}"
  defp add_sorting("psia", order), do: "ORDER BY psia #{order}"
  defp add_sorting("ptz", order), do: "ORDER BY ptz #{order}"
  defp add_sorting("infrared", order), do: "ORDER BY infrared #{order}"
  defp add_sorting("varifocal", order), do: "ORDER BY varifocal #{order}"
  defp add_sorting("sd_card", order), do: "ORDER BY sd_card #{order}"
  defp add_sorting("upnp", order), do: "ORDER BY upnp #{order}"
  defp add_sorting("audio_io", order), do: "ORDER BY audio_io #{order}"
  defp add_sorting("shape", order), do: "ORDER BY shape #{order}"
  defp add_sorting("resolution", order), do: "ORDER BY resolution #{order}"
  defp add_sorting("camera_count", order), do: "ORDER BY count #{order}"
end
