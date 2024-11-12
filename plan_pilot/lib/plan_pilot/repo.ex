defmodule PlanPilot.Repo do
  use Ecto.Repo,
    otp_app: :plan_pilot,
    adapter: Ecto.Adapters.Postgres
end
