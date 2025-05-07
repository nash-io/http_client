defmodule HttpClient.RateLimiter do
  @moduledoc """
  Module used to rate limit calls to certain host

  In `config.exs` :

  config :http_client, :rate_limits,
    "google.com": [{:timer.seconds(1), 5}, {:timer.hours(24), 500_000}]
  """

  import Ex2ms

  @ets_table_name :http_client_rate_limits

  @type record :: {term(), non_neg_integer(), non_neg_integer()}

  @doc """
  Function that needs to be called before using the rate limiter
  It should be ran by a long running process, if the procees gets killed,
  the ETS table is also killed
  """
  @spec init() :: :ok
  def init do
    :ets.new(@ets_table_name, [
      :named_table,
      :ordered_set,
      :public,
      {:read_concurrency, true},
      {:write_concurrency, true}
    ])

    :ok
  end

  @spec rate_limit(String.t(), (-> any())) :: any()
  def rate_limit(url, function) do
    {:ok, callback} = rate_limit(url)
    result = function.()
    callback.()
    result
  end

  @spec rate_limit(String.t()) :: {:ok, (-> :ok)}
  def rate_limit(url) do
    case retrieve_rate_limit_config(url) do
      {:ok, {host, rate_limits}} ->
        {:ok, records} = enforce_rate_limits(host, rate_limits, [])
        {:ok, fn -> update_records(records) end}

      :error ->
        {:ok, &nothing/0}
    end
  end

  @spec nothing() :: :ok
  def nothing, do: :ok

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

  @spec update_records(list(record)) :: :ok
  defp update_records(records) do
    :ok =
      Enum.each(
        records,
        fn {host, scale, unique_id} ->
          bucket = {host, scale}

          case :ets.take(@ets_table_name, {bucket, unique_id}) do
            [_] -> insert_unique(bucket)
            _ -> :ok
          end

          nil
        end
      )
  end

  @spec enforce_rate_limits(atom(), list({non_neg_integer(), non_neg_integer()}), list(record())) ::
          {:ok, list(record())}
  defp enforce_rate_limits(_host, [], acc), do: {:ok, acc}

  defp enforce_rate_limits(host, [{scale, limit} | remaining_limits] = rate_limits, acc) do
    case check_rate(host, scale, limit) do
      {:ok, {_, unique_id}} ->
        enforce_rate_limits(host, remaining_limits, [{host, scale, unique_id} | acc])

      {:error, wait_time} ->
        Process.sleep(wait_time)
        enforce_rate_limits(host, rate_limits, acc)
    end
  end

  defp check_rate(id, scale, limit, first_pass \\ true) do
    bucket = {id, scale}
    # We use an optmistic logic here,
    delete_count = if first_pass, do: 0, else: prune_table(id, scale)

    case :ets.update_counter(
           @ets_table_name,
           {bucket, :counter},
           [{2, -delete_count}, {2, 1, limit, limit}],
           {{bucket, :counter}, 0}
         ) do
      [^limit, ^limit] when first_pass ->
        # We make a recursive call that will trigger the deletion of items if needed
        check_rate(id, scale, limit, false)

      [^limit, ^limit] when not first_pass ->
        {result, _} =
          :ets.select(
            @ets_table_name,
            fun do
              {{^bucket, timestamp}, _} -> timestamp
            end,
            1
          )

        wait_time =
          if Enum.count(result) == 1,
            do: max(0, div(hd(result), 1_000) + scale - div(now(), 1_000)),
            else: scale

        {:error, wait_time}

      [_, count] ->
        {:ok, now} = insert_unique(bucket)

        {:ok, {count, now}}
    end
  end

  @spec insert_unique(any()) :: {:ok, non_neg_integer()}
  defp insert_unique(bucket) do
    now = now()

    if :ets.insert_new(@ets_table_name, {{bucket, now}, 0}) do
      {:ok, now}
    else
      insert_unique(bucket)
    end
  end

  @spec prune_table(any(), non_neg_integer()) :: non_neg_integer()
  defp prune_table(id, scale) do
    now = now()
    bucket = {id, scale}
    outdated = now - scale * 1_000
    range_bottom = {bucket, 0}
    range_top = {bucket, outdated}

    :ets.select_delete(
      @ets_table_name,
      fun do
        {key, _} when key > ^range_bottom and key < ^range_top -> true
      end
    )
  end

  @spec now() :: non_neg_integer()
  defp now, do: :erlang.system_time(:micro_seconds)
end
