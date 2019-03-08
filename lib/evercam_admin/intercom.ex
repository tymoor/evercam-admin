defmodule Intercom do

  @intercom_scroll_url "#{System.get_env["INTERCOM_URL"]}" <> "/companies/scroll?scroll_param="
  @intercom_base_url   "#{System.get_env["INTERCOM_URL"]}" <> "/companies/scroll"
  @intercom_headers    ["Authorization": "Bearer #{System.get_env["INTERCOM_ACCESS_TOKEN"]}", "Accept": "Accept:application/json"]

  @max_retries 5

  alias HTTPoison.Response, as: Resp

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