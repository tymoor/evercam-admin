defmodule EvercamAdminWeb.MapsController do
  use EvercamAdminWeb, :controller
  import Ecto.Query

  def index(conn, params) do
    case params["map_for"] do
      "garda" -> map(conn, :garda)
      "construction" -> map(conn, :construction)
      _ -> map(conn, :all)
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
      |> Enum.filter(& !is_nil(&1.owner))
      |> Enum.reduce([], fn camera, acc ->
        %Geo.Point{coordinates: {lng, lat}} = camera.location
        marker = %{
          position: %{
            lat: lat,
            lng: lng
          },
          infoText: add_template(camera),
          status: status_peg(camera.status)
        }
        acc ++ [marker]
      end)
    json(conn, %{markers: markers})
  end
  defp map(conn, :garda) do
    gardashared =
      CameraShare
      |> where(user_id: 7011)
      |> preload(:camera)
      |> Evercam.Repo.all
      |> Enum.reduce([], fn share, acc ->
        acc ++ [share.camera.id]
      end)

    markers =
      Camera
      |> where([cam], cam.id in ^gardashared)
      |> preload(:owner)
      |> preload(:vendor_model)
      |> preload([vendor_model: :vendor])
      |> Evercam.Repo.all
      |> Enum.filter(& !is_nil(&1.location))
      |> Enum.filter(& !is_nil(&1.owner))
      |> Enum.reduce([], fn camera, acc ->
        %Geo.Point{coordinates: {lng, lat}} = camera.location
        marker = %{
          position: %{
            lat: lat,
            lng: lng
          },
          infoText: add_template(camera),
          status: status_peg(camera.status)
        }
        acc ++ [marker]
      end)
    json(conn, %{markers: markers})
  end
  defp map(conn, :construction) do
    camera_shared =
      CameraShare
      |> where(user_id: 13959)
      |> preload(:camera)
      |> Evercam.Repo.all
      |> Enum.reduce([], fn share, acc ->
        acc ++ [share.camera.id]
      end)

    shared_markers =
      Camera
      |> where([cam], cam.id in ^camera_shared)
      |> preload(:owner)
      |> preload(:vendor_model)
      |> preload([vendor_model: :vendor])
      |> Evercam.Repo.all
      |> Enum.filter(& !is_nil(&1.location))
      |> Enum.filter(& !is_nil(&1.owner))
      |> Enum.reduce([], fn camera, acc ->
        %Geo.Point{coordinates: {lng, lat}} = camera.location
        marker = %{
          position: %{
            lat: lat,
            lng: lng
          },
          infoText: add_template(camera),
          status: status_peg(camera.status)
        }
        acc ++ [marker]
      end)

    construction_markers =
      Camera
      |> where([cam], cam.owner_id == 13959)
      |> preload(:owner)
      |> preload(:vendor_model)
      |> preload([vendor_model: :vendor])
      |> Evercam.Repo.all
      |> Enum.filter(& !is_nil(&1.location))
      |> Enum.filter(& !is_nil(&1.owner))
      |> Enum.reduce([], fn camera, acc ->
        %Geo.Point{coordinates: {lng, lat}} = camera.location
        marker = %{
          position: %{
            lat: lat,
            lng: lng
          },
          infoText: add_template(camera),
          status: status_peg(camera.status)
        }
        acc ++ [marker]
      end)
    json(conn, %{markers: shared_markers ++ construction_markers})
  end

  defp add_template(camera) do
    "<table class='table order-column'>\
      <tbody>\
      <tr>\
        '#{thumbnail(camera, camera.is_public)}'\
      </tr>\
        <tr>\
          <th></th>\
          <td>\
            <div>\
              <strong>\
                <a href='https://dash.evercam.io/v2/cameras/#{camera.exid}/live?api_id=#{camera.owner.api_id}&api_key=#{camera.owner.api_key}' target='_blank'>\
                  #{camera.name} <i class='fa fa-external-link-alt'></i>\
                </a>\
              </strong>\
            </div>\
          </td>\
        </tr>\
        <tr>\
        <th>Data Processor</th>\
          <td>Camba.tv Ltd. 01-5383333</td>\
        </tr>\
        <tr>\
          <th>Data Controller</th>\
          <td>#{camera.owner.username}</td>\
        </tr>\
        <tr>\
          <th>Status ?</th>\
          <td>#{camera_status(camera.status)}</td>\
        </tr>\
        <tr>\
          <th>Public ?</th>\
          <td>#{humanize_status(camera.is_public)}</td>\
        </tr>\
        <tr>\
          <th>Vendor/Model</th>\
          <td>#{logo_url(camera.vendor_model)}</td>
        </tr>\
      </tbody>\
    </table>"
  end

  defp humanize_status(true), do: "Yes"
  defp humanize_status(false), do: "No"

  defp camera_status(status), do: String.capitalize(status)

  defp logo_url(nil), do: ""
  defp logo_url(vendor_model), do: "<img width='60' src='http://evercam-public-assets.s3.amazonaws.com/#{vendor_model.vendor.exid}/logo.jpg' />/#{vendor_model.name}"

  defp thumbnail(camera, true), do: "<img class='map-thumbnail-img' style='width: 300px' src='https://media.evercam.io/v2/cameras/#{camera.exid}/thumbnail?' />"
  defp thumbnail(camera, false), do: "<img class='map-thumbnail-img' style='width: 300px' src='https://media.evercam.io/v2/cameras/#{camera.exid}/thumbnail?api_id=#{camera.owner.api_id}&api_key=#{camera.owner.api_key}' />"

  defp status_peg("online"), do: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABUAAAAiCAYAAACwaJKDAAAABmJLR0QA/wD/AP+gvaeTAAAC5UlEQVRIia2WP2gUQRSHv5ndmztjIVgYvVhZCSKCgkkRtYhVMILYiKAJgkVACaKNXbCKlaiFlRKjIiopEg0qiKJGISkEMRJIYwQ1+ActcjG4tzvPYvZMctm7vcT84Jjl9v0+5s1781hFdW0BmoEGQAMW+AwMA+9TvIu0FxgFJK+UtGgtBzxPWrSWvFICSPx+by0wBfQosG2eJ0PGyIdcTibLfkPGSJvniXI774l9CyDzny+shq5LxtCideoOnlhLVxAwAxeBU3EGePNiurLQfcMYmmsAAmxSikatGYiipgh+ASPzoXlg4KzvZ/Z5XkVIkvJKUQe8sHY30AtMl7bU2aBUXYfvLwlYUrvvs1GpOqATXJsA7D/oeSwPCT5w0GW4vwT1gM2NVc7xlbWcD0PGrK0Ys9P5NwOeD2QAk1cqMfiTCO1BQAj0Aa+zWdYkxMZ+A2RSy/xVhDB+ngEKaQZc+gEQfBJJDNiuNR2eR4NSnPZ9GqpkVGKV7vP4SIXzUkB3JsOrbJaTVboj9o8DtpT+YH8UUUzPLFEh0B9FAIMw11JXpkQKV8Owkq+qroUhUyIF4ArM3agCMD1ibWuj1myscG5JGrWWM8UiEZwGns6Huvew9mEUNe7SmvoawGPWciQImIVLwLnS/+VOBdysV+rwfWNYVwX8S4TWIGBK5C5wiHhCJUEBVgEje7Te2mtMYgDAiWKRB1E0AeygrH2Tmn8WOPrc2nDAVXSRhq3lgXt3vByYpssblJKJsqn/IZeTbVoLcG8psJLWAb97MpkF0NvGCO7CbK1krHb3vwF918t695ZL+ynwbjk7BdgOyKNsViZzOXmXy0nWVflwNVPalHoDTDyOC/Y8ivjjCjn4P1CAoeF42Lx06zNSKl4L9NlbaynybxI9qcGTqvWA3DFGlDvPppWAAnw/5vuCm3Kr0oJr+2qAyVGX+kdcoVYE+uPjHDRVtUJ/Trt1eiWhX+P1y0pCp+J1spbgv12YFzTkkOBTAAAAAElFTkSuQmCC"
  defp status_peg(_), do: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABUAAAAiCAYAAACwaJKDAAAABmJLR0QA/wD/AP+gvaeTAAADR0lEQVRIia2WTUgjZxzGf5MxG7ogMxQP2goDhg4LfuQWBUsPsh7Sw14820u3hz0tpVDorbSHQi+lvWzpoa4rXkoRslChYLpQlGpWSmOUmOCEDKKjbakZoubDmbw9mOwm6+TDxecyzPs+z2/m/77vfxiJ9hoG3gXeBnxAFTgAVoGdDtkrugvEAaEoitB1XYyNjQld14WiKAIQtfm7XmHJ4/4rSZI+HR4eliYnJ+nv70eSmm2WZbG2tsbOzo4QQnwNfFZ70BWoBHwTCAQezszMoOt6x3LS6TRLS0uUy+VvgY/rYLnB87Cnp+fz2dlZhoaGOgIB+vr60DSNZDI5Ua1WT4CNRuhbQHR6eto/MjLSFbAuRVHw+/0YhvEe8Bgo+GpzD1RVvR0Oh68FrCscDqOq6m3gAVweE4B7oVAIWZZbJ9tIlmVCoRDAvTpUBu5omtYylM1mWVlZwbKslp5a/g4g+wA/cEtRFE9zPp9ncXGR1dVV5ubmKBaLnr5a/hbg93k6GlQoFHBdF4BKpUK5XO4UwQdUgEo+n/c0DA4OMj4+jqqqTE1Noapqy4rqrB4u+zllmmYoGAxeMUuSRCQSIRKJtH070zQBUkC1Xv7TRCLxoszrynVdEokEwFN4eaQe2bZ9ur6+/lrQjY0NbNs+BR7By446BQqmab6vaVrLdfOSaZpEo1Gq1eonwG+NUIC4EOLNVCo1HgwG6e3t7Qi0LIuFhQUuLi6+A76oj7/aQr+6rvtOJpMZHR0dJRAItASen58zPz/P2dnZT8D9xrlXz6kA7hcKhWQ0GkUIQSstLy9j23YG+JCGb6kXFKAIfLC3t+ckk0lPYDabZXt7G+AjLvejSa066i/g+1gshuM4zaUIQSwWA/gZ+N0r3K5Nv7Rtu7i1tdU0mMvlODg4EDRszHWgfwNP4vF40+Dm5iZcHh3vtekABfjh6OiI4+NjAEqlEul0GuDHdqFO0D+BzO7uLgCGYeA4TpFaO74uFOAXwzBeQIFneOz4daHPDg8PcV2XXC4HsNIp0A30ueM47O/vc3JyAvBHF5mu9M/ExIQAHOCNm4I+HxgYEIDRjbmb8gH+rZVu3iT0v1KpBFC4Sehx7Xp4k9D6X0SuG/P/l/VHykP7TBoAAAAASUVORK5CYII="
end
