defmodule PlanPilotWeb.TemplateLive do
  use PlanPilotWeb, :live_view

  alias PlanPilot.Models.Template

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:all, Template.all())
    |> reply(:ok)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-white">
      <div class="mx-auto max-w-7xl px-6 py-24 sm:pt-32 lg:px-8 lg:py-40">
        <div class="lg:grid lg:grid-cols-12 lg:gap-8">
          <div class="lg:col-span-5">
            <h2 class="text-pretty text-3xl font-semibold tracking-tight text-gray-900 sm:text-4xl">
              Template
            </h2>
            <p class="mt-4 text-pretty text-base/7 text-gray-600">
              Manage placeholders with <code>{curly}</code> - <code>{brackets}</code>.
            </p>
            <!--
            <div class="mt-2">
              <button
                type="button"
                class="rounded px-10 py-1 font-semibold text-slate-200 border border-slate-800 bg-slate-800 shadow-sm hover:bg-slate-600 hover:text-slate-200"
              >
                Add another template
              </button>
            </div>
            -->
          </div>
          <%= if !Enum.empty?(@all) do %>
            <div class="mt-10 lg:col-span-7 lg:mt-0">
              <dl class="space-y-10">
                <%= for t <- @all do %>
                  <.template t={t} />
                <% end %>
              </dl>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def template(assigns) do
    ~H"""
    <div>
      <dt class="text-base/7 font-semibold text-gray-900"><%= @t.name %></dt>
      <dd class="mt-2 text-base/7 text-gray-600">
        <%= @t.text %>
      </dd>
      <dd class="mt-4">
        <%= for name <- @t.placeholders do %>
          <.placeholder name={name} />
        <% end %>
      </dd>
    </div>
    """
  end

  def placeholder(assigns) do
    ~H"""
    <span class="inline-flex items-center rounded-md bg-blue-100 px-2 py-1 text-xs font-medium text-blue-700">
      <%= @name %>
    </span>
    """
  end

  defp reply(socket, ok), do: {ok, socket}
end
