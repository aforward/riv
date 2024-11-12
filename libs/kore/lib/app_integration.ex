defmodule Kore.AppIntegration do
  alias Kore.InmemoryStore

  @template %{
    application: nil,
    oauth2_url: nil,
    client_name: nil,
    client_id: nil,
    client_secret: nil
  }

  def all() do
    InmemoryStore.get("kore.app_integrations", [])
    |> Enum.map(&find/1)
  end

  def all_for_application(application) do
    all() |> Enum.filter(fn i -> i.application == application end)
  end

  def all_for_client(client_name) do
    all() |> Enum.filter(fn i -> i.client_name == client_name end)
  end

  def find({application, client_name}) do
    InmemoryStore.get("kore.integration:::#{application}:::#{client_name}")
  end

  def upsert(%{application: app, client_name: client_name} = data) do
    case find({app, client_name}) do
      nil ->
        integration = Map.merge(@template, data)
        InmemoryStore.set("kore.integration:::#{app}:::#{client_name}", integration)

        InmemoryStore.update(
          "kore.app_integrations",
          [{app, client_name}],
          &Enum.sort([{app, client_name} | &1])
        )

        integration

      found ->
        integration = Map.merge(found, data)
        InmemoryStore.set("kore.integration:::#{app}:::#{client_name}", integration)
        integration
    end
  end
end
