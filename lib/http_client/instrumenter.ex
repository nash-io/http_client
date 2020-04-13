defmodule HttpClient.Instrumenter do
  @moduledoc false

  def instrument(
        {timer,
         {:ok,
          %HTTPoison.Response{
            status_code: status_code,
            request: %HTTPoison.Request{method: method}
          }} = response},
        url
      ) do
    domain = extract_domain(url)
    timer = div(timer, 1000)

    :telemetry.execute(
      [:http_client, :response, :success],
      %{status_code: status_code, method: method, duration: timer},
      %{domain: domain}
    )

    response
  end

  def instrument({timer, {:error, %HTTPoison.Error{reason: reason}} = response}, url) do
    domain = extract_domain(url)
    timer = div(timer, 1000)

    :telemetry.execute([:http_client, :response, :error], %{duration: timer, reason: reason}, %{
      domain: domain
    })

    response
  end

  def instrument({_, response}, _), do: response

  def extract_domain(url) do
    case URI.parse(url) do
      %URI{path: path, host: nil} -> path
      %URI{host: host} -> host
    end
  end
end
