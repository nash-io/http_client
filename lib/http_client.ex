defmodule HttpClient do
  @moduledoc false
  alias HttpClient.Instrumenter
  alias HttpClient.RateLimiter

  @callback get(String.t()) :: {:ok, any()} | {:error, any()}
  @callback get(String.t(), list()) :: {:ok, any()} | {:error, any()}
  @callback get(String.t(), list(), Keyword.t()) :: {:ok, any()} | {:error, any()}

  @callback post(String.t(), String.t()) :: {:ok, any()} | {:error, any()}
  @callback post(String.t(), String.t(), list()) :: {:ok, any()} | {:error, any()}
  @callback post(String.t(), String.t(), list(), list()) :: {:ok, any()} | {:error, any()}

  @callback put(String.t(), String.t()) :: {:ok, any()} | {:error, any()}
  @callback put(String.t(), String.t(), list()) :: {:ok, any()} | {:error, any()}
  @callback put(String.t(), String.t(), list(), list()) :: {:ok, any()} | {:error, any()}

  @callback patch(String.t(), String.t()) :: {:ok, any()} | {:error, any()}
  @callback patch(String.t(), String.t(), list()) :: {:ok, any()} | {:error, any()}
  @callback patch(String.t(), String.t(), list(), list()) :: {:ok, any()} | {:error, any()}

  @callback delete(String.t()) :: {:ok, any()} | {:error, any()}
  @callback delete(String.t(), list()) :: {:ok, any()} | {:error, any()}
  @callback delete(String.t(), list(), Keyword.t()) :: {:ok, any()} | {:error, any()}

  def get(url), do: request(:get, [url])
  def get(url, headers), do: request(:get, [url, headers])
  def get(url, headers, options), do: request(:get, [url, headers, options])

  def post(url, body), do: request(:post, [url, body])
  def post(url, body, headers), do: request(:post, [url, body, headers])
  def post(url, body, headers, options), do: request(:post, [url, body, headers, options])

  def put(url, body), do: request(:put, [url, body])
  def put(url, body, headers), do: request(:put, [url, body, headers])
  def put(url, body, headers, options), do: request(:put, [url, body, headers, options])

  def patch(url, body), do: request(:patch, [url, body])
  def patch(url, body, headers), do: request(:patch, [url, body, headers])
  def patch(url, body, headers, options), do: request(:patch, [url, body, headers, options])

  def delete(url), do: request(:delete, [url])
  def delete(url, headers), do: request(:delete, [url, headers])
  def delete(url, headers, options), do: request(:delete, [url, headers, options])

  defp request(method, [url | _] = args) do
    RateLimiter.rate_limit(url, fn ->
      fn -> apply(impl(), method, args) end
      |> :timer.tc()
      |> Instrumenter.instrument(url)
    end)
  end

  defp impl, do: Application.get_env(:http_client, :http_client_impl, HTTPoison)
end
