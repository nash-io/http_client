defmodule HttpClient.Application do
  @moduledoc """
  Application module that start supervision tree.
  It is only used to start an agent that will initialize an ETS table
  """
  use Application
  alias HttpClient.RateLimiter

  @impl Application
  def start(_type, _args) do
    config = [{Agent, fn -> RateLimiter.init() end}]
    Supervisor.start_link(config, strategy: :one_for_one, name: HttpClient.Supervisor)
  end
end
