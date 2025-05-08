defmodule HttpClientTest do
  use ExUnit.Case

  import Mox

  alias HttpClient.HttpClientMockImpl

  setup :verify_on_exit!

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
    expect(HttpClientMockImpl, :post, fn _, _, _ ->
      {:ok, %HTTPoison.Response{status_code: 200, body: "ok"}}
    end)

    expect(HttpClientMockImpl, :post, fn _, _, _, _ ->
      {:ok, %HTTPoison.Response{status_code: 200, body: "ok"}}
    end)

    assert {:ok, _} = HttpClient.post("example.com", "", [])
    assert {:ok, _} = HttpClient.post("example.com", "", [], [])
  end

  test "put" do
    expect(HttpClientMockImpl, :put, fn _, _, _ ->
      {:ok, %HTTPoison.Response{status_code: 200, body: "ok"}}
    end)

    expect(HttpClientMockImpl, :put, fn _, _, _, _ ->
      {:ok, %HTTPoison.Response{status_code: 200, body: "ok"}}
    end)

    assert {:ok, _} = HttpClient.put("example.com", "", [])
    assert {:ok, _} = HttpClient.put("example.com", "", [], [])
  end

  test "patch" do
    expect(HttpClientMockImpl, :patch, fn _, _, _ ->
      {:ok, %HTTPoison.Response{status_code: 200, body: "ok"}}
    end)

    expect(HttpClientMockImpl, :patch, fn _, _, _, _ ->
      {:ok, %HTTPoison.Response{status_code: 200, body: "ok"}}
    end)

    assert {:ok, _} = HttpClient.patch("example.com", "", [])
    assert {:ok, _} = HttpClient.patch("example.com", "", [], [])
  end

  test "delete" do
    expect(HttpClientMockImpl, :delete, fn _ ->
      {:ok, %HTTPoison.Response{status_code: 200, body: "ok"}}
    end)

    expect(HttpClientMockImpl, :delete, fn _, _ ->
      {:ok, %HTTPoison.Response{status_code: 200, body: "ok"}}
    end)

    assert {:ok, _} = HttpClient.delete("example.com")
    assert {:ok, _} = HttpClient.delete("example.com", [])
  end
end