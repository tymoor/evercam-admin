defmodule EvercamAdminWeb.IntercomController do
  use EvercamAdminWeb, :controller

  @intercom_url "https://api.intercom.io" #System.get_env["INTERCOM_URL"]
  @intercom_token "dG9rOmM3NDcyOGIyXzA2NDNfNDBkN185OWQzXzlmNzEzOWFlNDczNDoxOjA=" #System.get_env["INTERCOM_ACCESS_TOKEN"]

  def index(conn, params) do
    [column, order] = params["sort"] |> String.split("|")
    per_page = String.to_integer(params["per_page"])
    page = String.to_integer(params["page"])
    with {:ok, %HTTPoison.Response{body: body}} <- companies(per_page, page) do
      companies = Jason.decode!(body)
      total_records = companies["total_count"]
      d_length = String.to_integer(params["per_page"])
      display_length = if d_length < 0, do: total_records, else: d_length
      display_start = if String.to_integer(params["page"]) <= 1, do: 0, else: (String.to_integer(params["page"]) - 1) * display_length + 1
      index_e = ((String.to_integer(params["page"]) - 1) * display_length) + display_length
      index_end = if index_e > total_records, do: total_records - 1, else: index_e
      last_page = Float.round(total_records / (display_length / 1))

      data =
        Enum.reduce(companies["companies"], [], fn company, acc ->
          comp = %{
            company_id: company["company_id"],
            name: company["name"],
            session_count: company["session_count"],
            user_count: company["user_count"],
            created_at: company["created_at"]
          }
          acc ++ [comp]
        end) |> perform_sorting(column, order)

      records = %{
        data: (if total_records < 1, do: [], else: data),
        total: total_records,
        per_page: display_length,
        from: display_start,
        to: index_end,
        current_page: String.to_integer(params["page"]),
        last_page: last_page,
        next_page_url: (if String.to_integer(params["page"]) == last_page, do: "", else: "/v1/intercom_companies?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) + 1}"),
        prev_page_url: (if String.to_integer(params["page"]) < 1, do: "", else: "/v1/intercom_companies?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) - 1}")
      }
      json(conn, records)
    else
      _ ->
        json(conn, %{})
    end
  end

  defp companies(per_page, page) do
    url = "#{@intercom_url}/companies?per_page=#{per_page}&page=#{page}"
    headers = ["Authorization": "Bearer #{@intercom_token}", "Accept": "Accept:application/json"]
    response = HTTPoison.get(url, headers) |> elem(1)
    case response.status_code do
      200 -> {:ok, response}
      _ -> {:error, response}
    end
  end

  defp perform_sorting(data, column, order) do
    sorting(data, column, order)
  end

  defp sorting(data, "name", "asc"), do: Enum.sort_by(data, &(&1.name), &Kernel.<=/2)
  defp sorting(data, "name", "desc"), do: Enum.sort_by(data, &(&1.name), &Kernel.>=/2)

  defp sorting(data, "company_id", "asc"), do: Enum.sort_by(data, &(&1.name), &Kernel.<=/2)
  defp sorting(data, "company_id", "desc"), do: Enum.sort_by(data, &(&1.name), &Kernel.>=/2)

  defp sorting(data, "user_count", "asc"), do: Enum.sort_by(data, &(&1.name), &Kernel.<=/2)
  defp sorting(data, "user_count", "desc"), do: Enum.sort_by(data, &(&1.name), &Kernel.>=/2)

  defp sorting(data, "session_count", "asc"), do: Enum.sort_by(data, &(&1.name), &Kernel.<=/2)
  defp sorting(data, "session_count", "desc"), do: Enum.sort_by(data, &(&1.name), &Kernel.>=/2)

  defp sorting(data, "created_at", "asc"), do: Enum.sort_by(data, &(&1.name), &Kernel.<=/2)
  defp sorting(data, "created_at", "desc"), do: Enum.sort_by(data, &(&1.name), &Kernel.>=/2)
end


  # "pages" => %{
  #   "next" => "https://api.intercom.io/companies?per_page=15&page=2",
  #   "page" => 1,
  #   "per_page" => 15,
  #   "total_pages" => 16,
  #   "type" => "pages"
  # },
  # "total_count" => 229,
  # "type" => "company.list"
