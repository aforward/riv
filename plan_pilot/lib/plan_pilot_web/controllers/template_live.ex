defmodule PlanPilotWeb.TemplateLive do
  use PlanPilotWeb, :live_view

  alias PlanPilot.Models.Template

  @impl true
  def mount(_params, _session, socket) do
    form =
      %Template{}
      |> Template.changeset(%{})
      |> to_form()

    socket
    |> assign(:form_new, form)
    |> assign(:all, Template.all())
    |> reply(:ok)
  end

  @impl true
  def handle_event("create", %{"template" => params}, socket) do
    Template.add(params)

    socket
    |> assign(:all, Template.all())
    |> reply(:noreply)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-white">
      <div class="mx-auto max-w-7xl px-6 lg:px-8 py-20">
        <div class="lg:grid lg:grid-cols-12 lg:gap-8">
          <div class="lg:col-span-5">
            <h2 class="text-pretty text-3xl font-semibold tracking-tight text-gray-900 sm:text-4xl">
              Templates
            </h2>
            <p class="mt-2 text-pretty text-base/7 text-gray-500">
              Manage placeholders with <code>{curly}</code> - <code>{brackets}</code>.
            </p>

            <.form for={@form_new} phx-submit="create">
              <div class="col-span-full">
                <label for="about" class="sr-only">Template</label>
                <div class="mt-2">
                  <textarea
                    id="template_text"
                    name="template[text]"
                    rows="3"
                    class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm/6"
                  ></textarea>
                </div>
              </div>
              <div class="mt-3">
                <button
                  type="submit"
                  class="rounded px-10 py-1 font-semibold text-slate-200 border border-slate-800 bg-slate-800 shadow-sm hover:bg-slate-600 hover:text-slate-200"
                >
                  Add template
                </button>
              </div>
            </.form>
          </div>
          <%= if !Enum.empty?(@all) do %>
            <div class="mt-10 lg:col-span-7 lg:mt-0">
              <dl class="space-y-4">
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
    <div class="border p-4">
      <dt class="text-base/7 font-semibold text-gray-900"><%= @t.name %></dt>
      <dd class="text-base/7 text-gray-600">
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
