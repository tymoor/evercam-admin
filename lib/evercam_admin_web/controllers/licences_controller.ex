defmodule EvercamAdminWeb.LicencesController do
  use EvercamAdminWeb, :controller
  import Ecto.Query
  @auth_header ["Authorization": "Bearer sk_live_9g7nHGj9hct6fOj6rh2rBTaQ", "Accept": "Accept:application/json"]
  @strip_url "https://api.stripe.com/v1/customers?limit=1000"

  def index(conn, _params) do
    query = "select l.*, u.*, con.name as con_name from licences as l
            inner join users as u on l.user_id = u.id
            inner join countries as con on u.country_id = con.id"

    licences = Ecto.Adapters.SQL.query!(Evercam.Repo, query, [])
    cols = Enum.map licences.columns, &(String.to_atom(&1))
    roles = Enum.map licences.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    length = licences.num_rows
    db_data =
      case length <= 0 do
        true -> []
        _ ->
          Enum.reduce(0..length - 1, [], fn i, acc ->
            licence = Enum.at(roles, i)
            lic = %{
              email: licence[:email],
              name_link: "<a href='https://dash.evercam.io/v2/cameras?api_id=#{licence[:api_id]}&api_key=#{licence[:api_key]}' target='_blank'>#{licence[:firstname]} #{licence[:lastname]} <i class='fa fa-external-link'></i></a>",
              country_name: licence[:con_name],
              description: licence[:description],
              total_cameras: licence[:total_cameras],
              storage: licence[:storage],
              period: "custom",
              created_at: (if licence[:created_at], do: Calendar.Strftime.strftime!(licence[:created_at], "%A, %d %b %Y %l:%M %p"), else: ""),
              start_date: (if licence[:start_date], do: Calendar.Strftime.strftime!(licence[:start_date], "%A, %d %b %Y %l:%M %p"), else: ""),
              end_date: (if licence[:end_date], do: Calendar.Strftime.strftime!(licence[:end_date], "%A, %d %b %Y %l:%M %p"), else: ""),
              expiry: get_expiry(licence[:end_date]),
              amount: "&euro; #{:erlang.float_to_binary((licence[:amount] / 100), [decimals: 2])}",
              auto_renew: "No",
              status: get_status(licence[:paid]),
              payment_method: (if licence[:payment_method] == 1, do: "Custom", else: "Stripe")
            }
            acc ++ [lic]
          end)
      end

    stripe_customers = get_stripe_customers()

    stripe_length = Enum.count(stripe_customers)
    strip_data =
      case stripe_length <= 0 do
        true -> []
        _ ->
          Enum.reduce(0..stripe_length - 1, [], fn i, acc ->
            customer = Enum.at(stripe_customers, i)
            licences = customer["subscriptions"]["data"]
            licences_length = Enum.count(licences)

            results =
              case licences_length <= 0 do
                true -> []
                _ ->
                  Enum.map(licences, fn licence ->
                    user = get_user_with_strip_id(customer["id"])
                    %{
                      email: user.email,
                      name_link: "<a href='https://dash.evercam.io/v2/cameras?api_id=#{user.api_id}&api_key=#{user.api_key}' target='_blank'>#{user.firstname} #{user.lastname} <i class='fa fa-external-link'></i></a>",
                      country_name: user.country.name,
                      description: licence["plan"]["name"],
                      total_cameras: licence["quantity"],
                      storage: get_storage_plan(licence["plan"]["id"]),
                      period: (if licence["plan"]["interval"] == "month", do: "Monthly", else: "Annual"),
                      created_at: Calendar.DateTime.Parse.unix!(licence["plan"]["created"]) |> Calendar.Strftime.strftime!("%A, %d %b %Y %l:%M %p"),
                      start_date: Calendar.DateTime.Parse.unix!(licence["current_period_start"]) |> Calendar.Strftime.strftime!("%A, %d %b %Y %l:%M %p"),
                      end_date: Calendar.DateTime.Parse.unix!(licence["current_period_end"]) |> Calendar.Strftime.strftime!("%A, %d %b %Y %l:%M %p"),
                      expiry: get_stripe_expiry(licence["current_period_end"]),
                      amount: "&euro; #{:erlang.float_to_binary((licence["plan"]["amount"] / 100 * licence["quantity"]), [decimals: 2])}",
                      auto_renew: (if licence["cancel_at_period_end"], do: "No", else: "Yes"),
                      status: get_status(licence["status"]),
                      payment_method: ""
                    }
                  end)
              end
            acc ++ [results]
          end)
      end
    json(conn, %{data: db_data ++ List.flatten(strip_data)})
  end

  defp get_expiry(end_date) when end_date in ["", nil], do: ""
  defp get_expiry(end_date) do
    now = DateTime.utc_now
    case DateTime.compare(now, end_date) do
      :gt -> ""
      :lt -> (DateTime.diff(end_date, now) / (24 * 60 * 60) + 1)
    end
  end

  defp get_stripe_expiry(unix), do: Calendar.DateTime.Parse.unix!(unix) |> get_expiry()

  defp get_status(status) when status in ["true", true, "active"], do: "<span style='color: #008800;'>Paid</span>"
  defp get_status(_status), do: "<span style='color: #ff0000;'>Pending</span>"

  defp get_stripe_customers() do
    with {:ok, %HTTPoison.Response{body: body, status_code: 200}} <- HTTPoison.get(@strip_url, @auth_header) do
      Jason.decode!(body)["data"]
    else
      _ -> []
    end
  end

  defp get_user_with_strip_id(strip_id) do
    User |> where(stripe_customer_id: ^strip_id) |> preload(:country) |> Evercam.Repo.one!
  end

  defp get_storage_plan("24-hours-recording"), do: 1
  defp get_storage_plan("24-hours-recording-annual"), do: 1
  defp get_storage_plan("7-days-recording"), do: 7
  defp get_storage_plan("7-days-recording-annual"), do: 7
  defp get_storage_plan("30-days-recording"), do: 30
  defp get_storage_plan("30-days-recording-annual"), do: 30
  defp get_storage_plan("90-days-recording"), do: 90
  defp get_storage_plan("90-days-recording-annual"), do: 90
  defp get_storage_plan("infinity"), do: -1
  defp get_storage_plan("infinity-annual"), do: -1
end