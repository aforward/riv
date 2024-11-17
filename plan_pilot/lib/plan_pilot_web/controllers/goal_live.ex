defmodule PlanPilotWeb.GoalLive do
  use PlanPilotWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> reply(:ok)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-white">
      <div class="mx-auto max-w-7xl px-6 lg:px-8 py-20">
        <h2 class="text-pretty text-3xl font-semibold tracking-tight text-gray-900 sm:text-4xl">
          Goals
        </h2>
      </div>
    </div>
    """
  end

  defp reply(socket, ok), do: {ok, socket}
end
