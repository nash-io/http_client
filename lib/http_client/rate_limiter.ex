defmodule HttpClient.RateLimiter do
  @moduledoc """
  Module used to rate limit calls to certain host

  In `config.exs` :

  config :http_client, :rate_limits,
    "google.com": [{:timer.seconds(1), 5}, {:timer.hours(24), 500_000}]
  """

  @spec rate_limit(String.t()) :: :ok
  def rate_limit(url) do
    case retrieve_rate_limit_config(url) do
      {:ok, {host, rate_limits}} ->
        :ok = enforce_rate_limits(host, rate_limits)

      :error ->
        :ok
    end
  end

  @spec enforce_rate_limits(atom(), list({non_neg_integer(), non_neg_integer()})) :: :ok
  defp enforce_rate_limits(_host, []), do: :ok

  defp enforce_rate_limits(host, [{scale, limit} | remaining_limits] = rate_limits) do
    bucket = {host, scale}
    {_, _, ms_to_next_bucket, _, _} = ExRated.inspect_bucket(bucket, scale, limit)

    case ExRated.check_rate(bucket, scale, limit) do
      {:ok, _} ->
        enforce_rate_limits(host, remaining_limits)

      _ ->
        Process.sleep(ms_to_next_bucket)
        enforce_rate_limits(host, rate_limits)
    end
  end

  @spec retrieve_rate_limit_config(String.t()) ::
          {:ok, {atom(), list({non_neg_integer(), non_neg_integer()})}} | :error
  defp retrieve_rate_limit_config(url) do
    %URI{host: host} = URI.parse(url)
    host_atom = String.to_existing_atom(host)
    {:ok, rate_limits} = Application.fetch_env(:http_client, :rate_limits)
    {:ok, value} = Keyword.fetch(rate_limits, host_atom)
    {:ok, {host_atom, value}}
  rescue
    _ -> :error
  end
end
