defmodule Intercom do

  @intercom_scroll_url "#{System.get_env["INTERCOM_URL"]}" <> "/companies/scroll?scroll_param="
  @intercom_base_url   "#{System.get_env["INTERCOM_URL"]}" <> "/companies/scroll"
  @intercom_url "#{System.get_env["INTERCOM_URL"]}" <> "/users"
  @intercom_token "#{System.get_env["INTERCOM_ACCESS_TOKEN"]}"
  @intercom_headers    ["Authorization": "Bearer #{System.get_env["INTERCOM_ACCESS_TOKEN"]}", "Accept": "Accept:application/json"]
  @max_retries 5

  alias HTTPoison.Response, as: Resp

  def get_user(user_id) do
    url = "#{@intercom_url}?user_id=#{user_id}"
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
    IO.inspect HTTPoison.post(url, json, headers)
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