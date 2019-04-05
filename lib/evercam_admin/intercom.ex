defmodule Intercom do

  @intercom_scroll_url "https://api.intercom.io" <> "/companies/scroll?scroll_param="
  @intercom_base_url   "https://api.intercom.io" <> "/companies/scroll"
  @intercom_url "https://api.intercom.io" <> "/users"
  @intercom_token "dG9rOmM3NDcyOGIyXzA2NDNfNDBkN185OWQzXzlmNzEzOWFlNDczNDoxOjA="
  @intercom_headers    ["Authorization": "Bearer dG9rOmM3NDcyOGIyXzA2NDNfNDBkN185OWQzXzlmNzEzOWFlNDczNDoxOjA=", "Accept": "Accept:application/json"]
  @max_retries 5

  alias HTTPoison.Response, as: Resp

  def get_user(user_id) do
    search_string =
      case String.contains?(user_id, "@") do
        true -> "email=#{user_id}"
        _ -> "user_id=#{user_id}"
      end
    url = "#{@intercom_url}?#{search_string}"
    headers = ["Authorization": "Bearer #{@intercom_token}", "Accept": "Accept:application/json"]
    response = HTTPoison.get(url, headers) |> elem(1)
    case response.status_code do
      200 -> {:ok, response}
      _ -> {:error, response}
    end
  end

  def get_company(company_id) do
    intercom_url = @intercom_url |> String.replace("users", "companies")
    url = "#{intercom_url}?company_id=#{company_id}"
    headers = ["Authorization": "Bearer #{@intercom_token}", "Accept": "Accept:application/json"]
    response = HTTPoison.get(url, headers) |> elem(1)
    case response.status_code do
      200 -> {:ok, response.body |> Poison.decode!}
      _ -> {:error, response}
    end
  end

  def create_company(company_id, company_name) do
    intercom_url = @intercom_url |> String.replace("users", "companies")
    url = "#{intercom_url}"
    headers = ["Authorization": "Bearer #{@intercom_token}", "Accept": "Accept:application/json", "Content-Type": "application/json"]
    company_changeset = %{
      company_id: company_id,
      name: String.capitalize(company_name),
      created_at: Calendar.DateTime.now_utc |> Calendar.DateTime.Format.unix
    }

    json =
      case Poison.encode(company_changeset) do
        {:ok, json} -> json
        _ -> nil
      end
    HTTPoison.post(url, json, headers)
  end

  def get_companies(acc \\ [], scroll_param \\ nil, errors \\ [], retries \\ 0)
  def get_companies(acc, scroll_param, errors, retries) when retries < @max_retries do
    case get_companies_request(scroll_param) do
      {200, %{"companies" => []}} ->

        {:ok, :lists.flatten(acc)}

      {200, %{"companies" => companies, "scroll_param" => scroll_param} = _body} ->
        get_companies([companies | acc], scroll_param, errors, 0)

      {:ok, sc, body} ->
        {:error, {:unexpected_status_code, {sc, body}}}

      {:error, reason} ->
        get_companies(acc, scroll_param, [reason | errors], retries + 1)
    end
  end

  def get_companies(acc, _scroll_param, errors, _), do: {:error, {errors, acc}}

  defp get_companies_request(nil), do: HTTPoison.get(@intercom_base_url, @intercom_headers) |> send_status_code_body_json
  defp get_companies_request(sp), do: HTTPoison.get(@intercom_scroll_url <> sp, @intercom_headers) |> send_status_code_body_json

  defp send_status_code_body_json({:ok, %Resp{status_code: 200, body: body}}), do:
    {200, Jason.decode!(body)}
  defp send_status_code_body_json({:ok, %Resp{status_code: sc, body: body}}), do: {:ok, sc, Jason.decode!(body)}
  defp send_status_code_body_json({:error, %HTTPoison.Error{reason: reason}}), do: {:error, reason}
end