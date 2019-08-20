defmodule Utils do
  def paginator(display_start, index_end, sort, total_records, per_page, current_page, data, report, last_page) do
    %{
      data: (if total_records < 1, do: [], else: data),
      total: total_records,
      per_page: per_page,
      from: display_start,
      to: index_end,
      current_page: current_page,
      last_page: last_page,
      next_page_url: (if current_page == last_page, do: "", else: "/v1/#{report}?sort=#{sort}&per_page=#{per_page}&page=#{current_page + 1}"),
      prev_page_url: (if current_page < 1, do: "", else: "/v1/#{report}?sort=#{sort}&per_page=#{per_page}&page=#{current_page - 1}")
    }
  end

  def pagination_info(total_records, per_page, current_page) do
    last_page = ((total_records / per_page) + (if rem(total_records, per_page) == 0, do: 0, else: 1) |> Float.ceil) - 1
    display_start = (current_page - 1) * per_page + 1
    index_end = display_start + per_page - 1
    index_end = if index_end > total_records, do: total_records, else: index_end
    {last_page, display_start, index_end}
  end
end