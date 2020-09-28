defmodule HttpClient do
  @moduledoc false
  alias HttpClient.Instrumenter
  @callback get(String.t()) :: {:ok, any()} | {:error, any()}
  @callback get(String.t(), list()) :: {:ok, any()} | {:error, any()}
  @callback get(String.t(), list(), Keyword.t()) :: {:ok, any()} | {:error, any()}

  @callback post(String.t(), String.t()) :: {:ok, any()} | {:error, any()}
  @callback post(String.t(), String.t(), list()) :: {:ok, any()} | {:error, any()}
  @callback post(String.t(), String.t(), list(), list()) :: {:ok, any()} | {:error, any()}

  @callback put(String.t(), String.t()) :: {:ok, any()} | {:error, any()}
  @callback put(String.t(), String.t(), list()) :: {:ok, any()} | {:error, any()}
  @callback put(String.t(), String.t(), list(), list()) :: {:ok, any()} | {:error, any()}

  @callback delete(String.t()) :: {:ok, any()} | {:error, any()}
  @callback delete(String.t(), list()) :: {:ok, any()} | {:error, any()}
  @callback delete(String.t(), list(), Keyword.t()) :: {:ok, any()} | {:error, any()}

  def get(url) do
    :timer.tc(fn ->
      impl().get(url)
    end)
    |> Instrumenter.instrument(url)
  end

  def get(url, headers) do
    :timer.tc(fn ->
      impl().get(url, headers)
    end)
    |> Instrumenter.instrument(url)
  end

  def get(url, headers, opts) do
    :timer.tc(fn ->
      impl().get(url, headers, opts)
    end)
    |> Instrumenter.instrument(url)
  end

  def post(url, body) do
    :timer.tc(fn ->
      impl().post(url, body)
    end)
    |> Instrumenter.instrument(url)
  end

  def post(url, body, headers) do
    :timer.tc(fn ->
      impl().post(url, body, headers)
    end)
    |> Instrumenter.instrument(url)
  end

  def post(url, body, headers, opts) do
    :timer.tc(fn ->
      impl().post(url, body, headers, opts)
    end)
    |> Instrumenter.instrument(url)
  end

  def put(url, body) do
    :timer.tc(fn ->
      impl().put(url, body)
    end)
    |> Instrumenter.instrument(url)
  end

  def put(url, body, headers) do
    :timer.tc(fn ->
      impl().put(url, body, headers)
    end)
    |> Instrumenter.instrument(url)
  end

  def put(url, body, headers, opts) do
    :timer.tc(fn ->
      impl().put(url, body, headers, opts)
    end)
    |> Instrumenter.instrument(url)
  end

  def delete(url) do
    :timer.tc(fn ->
      impl().delete(url)
    end)
    |> Instrumenter.instrument(url)
  end

  def delete(url, headers) do
    :timer.tc(fn ->
      impl().delete(url, headers)
    end)
    |> Instrumenter.instrument(url)
  end

  def delete(url, headers, options) do
    :timer.tc(fn ->
      impl().delete(url, headers, options)
    end)
    |> Instrumenter.instrument(url)
  end

  defp impl, do: Application.get_env(:http_client, :http_client_impl, HTTPoison)
end
