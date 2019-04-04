defmodule IntercomUsers do

  @intercom_scroll_url "#{System.get_env["INTERCOM_URL"]}" <> "/users/scroll?scroll_param="
  @intercom_base_url   "#{System.get_env["INTERCOM_URL"]}" <> "/users/scroll"
  @intercom_headers    ["Authorization": "Bearer #{System.get_env["INTERCOM_ACCESS_TOKEN"]}", "Accept": "Accept:application/json"]

  @max_retries 5

  alias HTTPoison.Response, as: Resp

  def get_users(acc \\ [], scroll_param \\ nil, errors \\ [], retries \\ 0)
  def get_users(acc, scroll_param, errors, retries) when retries < @max_retries do
    case get_users_request(scroll_param) do
      {200, %{"users" => []}} ->

        {:ok, :lists.flatten(acc)}

      {200, %{"users" => users, "scroll_param" => scroll_param} = _body} ->
        get_users([users | acc], scroll_param, errors, 0)

      {:ok, sc, body} ->
        {:error, {:unexpected_status_code, {sc, body}}}

      {:error, reason} ->
        get_users(acc, scroll_param, [reason | errors], retries + 1)
    end
  end

  def get_users(acc, _scroll_param, errors, _), do: {:error, {errors, acc}}

  defp get_users_request(nil), do: HTTPoison.get(@intercom_base_url, @intercom_headers) |> send_status_code_body_json
  defp get_users_request(sp), do: HTTPoison.get(@intercom_scroll_url <> sp, @intercom_headers) |> send_status_code_body_json

  defp send_status_code_body_json({:ok, %Resp{status_code: 200, body: body}}), do:
    {200, Jason.decode!(body)}
  defp send_status_code_body_json({:ok, %Resp{status_code: sc, body: body}}), do: {:ok, sc, Jason.decode!(body)}
  defp send_status_code_body_json({:error, %HTTPoison.Error{reason: reason}}), do: {:error, reason}
end