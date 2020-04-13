defmodule HttpClientTest do
  use ExUnit.Case
  import Mox
  alias HttpClient.HttpClientMockImpl

  test "get" do
    expect(HttpClientMockImpl, :get, fn _ ->
      {:ok, %HTTPoison.Response{status_code: 200, body: "ok"}}
    end)

    expect(HttpClientMockImpl, :get, fn _, _ ->
      {:ok, %HTTPoison.Response{status_code: 200, body: "ok"}}
    end)

    assert {:ok, _} = HttpClient.get("example.com")
    assert {:ok, _} = HttpClient.get("example.com", [])
  end

  test "post" do
    expect(HttpClientMockImpl, :post, fn _, _ ->
      {:ok, %HTTPoison.Response{status_code: 200, body: "ok"}}
    end)

    expect(HttpClientMockImpl, :post, fn _, _, _ ->
      {:ok, %HTTPoison.Response{status_code: 200, body: "ok"}}
    end)

    assert {:ok, _} = HttpClient.get("example.com", [])
    assert {:ok, _} = HttpClient.get("example.com", [], [])
  end
end
