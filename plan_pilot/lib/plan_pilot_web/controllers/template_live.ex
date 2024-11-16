defmodule PlanPilotWeb.TemplateLive do
  use PlanPilotWeb, :live_view

  alias PlanPilot.Models.Template

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:form, editable_form(nil))
    |> assign(:all, Template.all())
    |> reply(:ok)
  end

  @impl true
  def handle_event("save", %{"template" => params}, socket) do
    Template.upsert(params)

    socket
    |> assign(:all, Template.all())
    |> reply(:noreply)
  end

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    socket
    |> assign(:all, Template.all())
    |> assign(:form, editable_form(id))
    |> reply(:noreply)
  end

  @impl true
  def handle_event("cancel", _params, socket) do
    socket
    |> assign(:form, editable_form(nil))
    |> reply(:noreply)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    Template.mark_deleted(id)

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

            <.form for={@form} phx-submit="save">
              <% identifier = Map.get(@form.data, :identifier) %>
              <input
                type="hidden"
                id="template_identifier"
                name="template[identifier]"
                value={identifier}
              />
              <div class="col-span-full">
                <label for="about" class="sr-only">Template</label>
                <div class="mt-2">
                  <textarea
                    id="template_text"
                    name="template[text]"
                    rows="3"
                    class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm/6"
                  ><%= Map.get(@form.data, :text)%></textarea>
                </div>
              </div>
              <div class="mt-3 flex gap-x-3">
                <button
                  type="submit"
                  class="rounded px-10 py-1 font-semibold text-slate-200 border border-slate-800 bg-slate-800 shadow-sm hover:bg-slate-600 hover:text-slate-200"
                >
                  <%= if identifier, do: "Update template", else: "Add template" %>
                </button>
                <%= if identifier do %>
                  <button type="button" phx-click="cancel" class="text-slate-500 hover:underline">
                    cancel
                  </button>
                <% end %>
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
      <div class="relative w-full bg-red-100">
        <div class="absolute right-0 flex gap-x-2">
          <button phx-click="edit" phx-value-id={@t.identifier}>
            <.icon name="hero-pencil-square" class="w-6 h-6 bg-slate-500" />
          </button>
          <button phx-click="delete" phx-value-id={@t.identifier}>
            <.icon name="hero-trash" class="w-6 h-6 bg-red-500" />
          </button>
        </div>
      </div>
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

  defp editable_form(id) do
    (Template.find(id) || %Template{})
    |> Template.changeset(%{})
    |> to_form()
  end

  defp reply(socket, ok), do: {ok, socket}
end
