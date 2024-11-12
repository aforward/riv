defmodule Kore.AppToken do
  alias Kore.InmemoryStore

  @template %{
    application: nil,
    api_domain: nil,
    access_token: nil,
    expires_in: nil,
    refresh_token: nil,
    scope: nil,
    token_type: nil
  }

  def all() do
    InmemoryStore.get("kore.app_tokens", [])
    |> Enum.map(&find/1)
  end

  def find(application), do: InmemoryStore.get("kore.app_token:::#{application}")

  def upsert({:ok, data}, application) do
    {:ok,
     data
     |> Enum.map(fn {k, v} -> {String.to_existing_atom(k), v} end)
     |> Enum.into(%{})
     |> Map.put(:application, application)
     |> upsert()}
  end

  def upsert({:error, %{"error" => error}}, _application) do
    {:error, error}
  end

  def upsert({:error, error}, _application) when is_binary(error) do
    {:error, error}
  end

  def upsert(%{application: app} = data) do
    case find(app) do
      nil ->
        token = Map.merge(@template, data)
        InmemoryStore.set("kore.app_token:::#{app}", token)
        InmemoryStore.update("kore.app_tokens", [app], &Enum.sort([app | &1]))
        token

      found ->
        token = Map.merge(found, data)
        InmemoryStore.set("kore.app_token:::#{app}", token)
        token
    end
  end
end
