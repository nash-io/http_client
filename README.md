# HttpClient

Httpoison boosted with telemetry, mox and rate limit.

```elixir
HttpClient.get("http://mydomain.com")
```

## Installation

The package can be installed by adding `http_client` to your list of dependencies
in `mix.exs`:

```elixir
def deps do
  [
    {:http_client, "~> 0.2.3"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/http_client](https://hexdocs.pm/http_client).

## Configuration

```elixir
# Will rate limit calls to mydomain.com to 5 per seconds
# HttpClient.get("http://mydomain.com/any_path")
config :http_client, :rate_limits, "mydomain.com": [{:timer.seconds(1), 5}]
```
