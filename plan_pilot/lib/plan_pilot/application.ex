defmodule PlanPilot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PlanPilotWeb.Telemetry,
      PlanPilot.Repo,
      {DNSCluster, query: Application.get_env(:plan_pilot, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PlanPilot.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PlanPilot.Finch},
      # Start a worker by calling: PlanPilot.Worker.start_link(arg)
      # {PlanPilot.Worker, arg},
      # Start to serve requests, typically the last entry
      PlanPilotWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PlanPilot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PlanPilotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
