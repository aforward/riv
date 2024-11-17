defmodule PlanPilotWeb.TemplateLive do
  use PlanPilotWeb, :live_view

  alias PlanPilot.Models.{Template, Tag}

  @colour_codes [:red, :yellow, :green, :blue, :indigo, :purple, :pink]

  @num_colours Enum.count(@colour_codes)

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:form, editable_form(nil))
    |> assign(:tag_toggles, %{})
    |> assign_tags()
    |> assign_templates()
    |> reply(:ok)
  end

  @impl true
  def handle_event("save", %{"template" => params}, socket) do
    Template.upsert(params)

    socket
    |> assign_templates()
    |> reply(:noreply)
  end

  @impl true
  def handle_event("toggle_tag", %{"tag" => name}, socket) do
    colours = socket.assigns[:tag_colours]
    toggles = socket.assigns[:tag_toggles]

    updated =
      case Map.get(toggles, name) do
        nil ->
          Map.put(toggles, name, colours[name])

        _found ->
          Map.delete(toggles, name)
      end

    socket
    |> assign(:tag_toggles, updated)
    |> filter_tags()
    |> reply(:noreply)
  end

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    socket
    |> assign_templates()
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
    |> assign_templates()
    |> reply(:noreply)
  end

  @impl true
  def handle_event("refresh_tags", _params, socket) do
    Tag.refresh_all()

    socket
    |> assign_tags()
    |> filter_tags()
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

                <div class="mt-2">
                  <div class="rounded-md px-3 pb-1.5 pt-2.5 shadow-sm ring-1 ring-inset ring-gray-300 focus-within:ring-2 focus-within:ring-indigo-600">
                    <label for="template_tags" class="block text-xs font-medium text-gray-900">
                      Name
                      <span class="ml-2 text-slate-400">used to embed template into document</span>
                    </label>
                    <input
                      type="text"
                      id="template_name"
                      name="template[name]"
                      class="block w-full border-0 p-0 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm/6"
                      value={Map.get(@form.data, :name)}
                    />
                  </div>
                </div>

                <div class="mt-2">
                  <div class="rounded-md px-3 pb-1.5 pt-2.5 shadow-sm ring-1 ring-inset ring-gray-300 focus-within:ring-2 focus-within:ring-indigo-600">
                    <label for="template_tags" class="block text-xs font-medium text-gray-900">
                      Tags <span class="ml-2 text-slate-400">comma, separated, please</span>
                    </label>
                    <input
                      type="text"
                      id="template_taglist"
                      name="template[taglist]"
                      class="block w-full border-0 p-0 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm/6"
                      value={(Map.get(@form.data, :tags) || []) |> Enum.join(", ")}
                    />
                  </div>
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
            <div class="mt-10">
              <h3 class="font-bold text-slate-500">
                Tag Filters
                <button class="ml-2" phx-click="refresh_tags">
                  <.icon name="hero-arrow-path" class="w-5 h-5 text-slate-500" />
                </button>
              </h3>
              <div class="mt-2">
                <%= for t <- @tags do %>
                  <button phx-click="toggle_tag" phx-value-tag={t.name}>
                    <.tag name={t.name} colour={Map.get(@tag_toggles, t.name, :grey)} />
                  </button>
                <% end %>
              </div>
            </div>
          </div>
          <%= if !Enum.empty?(@filtered) do %>
            <div class="mt-10 lg:col-span-7 lg:mt-0">
              <dl class="space-y-4">
                <%= for t <- @filtered do %>
                  <.template t={t} tag_colours={@tag_colours} />
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
      <dt class="text-base/7 font-semibold text-gray-900">
        <%= @t.name %> <span class="text-slate-500">(<%= @t.slug %>)</span>
      </dt>
      <dd class="text-base/7 text-gray-600">
        <%= @t.text %>
      </dd>
      <dd class="mt-4">
        <%= for name <- @t.placeholders do %>
          <.placeholder name={name} />
        <% end %>
      </dd>
      <dd class="mt-4">
        <%= for name <- @t.tags || [] do %>
          <.tag name={name} colour={@tag_colours[name]} />
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

  # Done this way so the tailwind colours get included
  def tag(assigns) do
    ~H"""
    <%= case assigns[:colour] do %>
      <% :gray -> %>
        <span class="inline-flex items-center rounded-md bg-gray-50 px-2 py-1 text-xs font-medium text-gray-600 ring-1 ring-inset ring-gray-500/10">
          <%= @name %>
        </span>
      <% :red -> %>
        <span class="inline-flex items-center rounded-md bg-red-50 px-2 py-1 text-xs font-medium text-red-700 ring-1 ring-inset ring-red-600/10">
          <%= @name %>
        </span>
      <% :yellow -> %>
        <span class="inline-flex items-center rounded-md bg-yellow-50 px-2 py-1 text-xs font-medium text-yellow-800 ring-1 ring-inset ring-yellow-600/20">
          <%= @name %>
        </span>
      <% :green -> %>
        <span class="inline-flex items-center rounded-md bg-green-50 px-2 py-1 text-xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20">
          <%= @name %>
        </span>
      <% :blue -> %>
        <span class="inline-flex items-center rounded-md bg-blue-50 px-2 py-1 text-xs font-medium text-blue-700 ring-1 ring-inset ring-blue-700/10">
          <%= @name %>
        </span>
      <% :indigo -> %>
        <span class="inline-flex items-center rounded-md bg-indigo-50 px-2 py-1 text-xs font-medium text-indigo-700 ring-1 ring-inset ring-indigo-700/10">
          <%= @name %>
        </span>
      <% :purple -> %>
        <span class="inline-flex items-center rounded-md bg-purple-50 px-2 py-1 text-xs font-medium text-purple-700 ring-1 ring-inset ring-purple-700/10">
          <%= @name %>
        </span>
      <% :pink -> %>
        <span class="inline-flex items-center rounded-md bg-pink-50 px-2 py-1 text-xs font-medium text-pink-700 ring-1 ring-inset ring-pink-700/10">
          <%= @name %>
        </span>
      <% _else -> %>
        <span class="inline-flex items-center rounded-md bg-gray-50 px-2 py-1 text-xs font-medium text-gray-600 ring-1 ring-inset ring-gray-500/10">
          <%= @name %>
        </span>
    <% end %>
    """
  end

  defp editable_form(id) do
    (Template.find(id) || %Template{})
    |> Template.changeset(%{})
    |> to_form()
  end

  defp assign_templates(socket) do
    socket
    |> assign(:all, Template.all())
    |> filter_tags()
  end

  defp assign_tags(socket) do
    tags = Tag.all()

    tag_colours =
      tags
      |> Enum.with_index()
      |> Enum.map(fn {t, i} ->
        {t.name, Enum.at(@colour_codes, rem(i, @num_colours))}
      end)
      |> Enum.into(%{})

    socket
    |> assign(:tags, tags)
    |> assign(:tag_colours, tag_colours)
  end

  defp filter_tags(socket) do
    toggles = socket.assigns[:tag_toggles]

    filtered =
      if Enum.empty?(toggles) do
        socket.assigns[:all]
      else
        socket.assigns[:all]
        |> Enum.filter(fn t ->
          Enum.any?(t.tags, fn tag -> Map.has_key?(toggles, tag) end)
        end)
      end

    socket
    |> assign(:filtered, filtered)
  end

  defp reply(socket, ok), do: {ok, socket}
end
