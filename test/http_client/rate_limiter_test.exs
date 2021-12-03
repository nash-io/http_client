defmodule HttpClient.RateLimiterTest do
  use ExUnit.Case

  alias HttpClient.RateLimiter

  test "rate_limit(url) | no config" do
    {:ok, _} = RateLimiter.rate_limit("http://mydomain.com")
  end

  test "rate_limit(url) | config available" do
    Application.put_env(:http_client, :rate_limits, "mydomain2.com": [{:timer.seconds(2), 2}])

    now_1 = now()
    {:ok, _} = RateLimiter.rate_limit("http://mydomain2.com")
    {:ok, _} = RateLimiter.rate_limit("http://mydomain2.com")
    now_2 = now()
    {:ok, _} = RateLimiter.rate_limit("http://mydomain2.com")
    now_3 = now()

    assert now_2 - now_1 < 500
    assert div(now_3, 1_000) != div(now_2, 1_000)
  end

  defp now, do: :erlang.system_time(:micro_seconds)
end
