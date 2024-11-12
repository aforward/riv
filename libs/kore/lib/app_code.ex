defmodule Kore.AppCode do
  alias Kore.InmemoryStore

  def all() do
    InmemoryStore.get("kore.app_codes", [])
    |> Enum.map(fn code ->
      {code, find(code)}
    end)
  end

  def create(lookup \\ :ok), do: add(code(), lookup)

  def peek() do
    [code | _] = InmemoryStore.get("kore.app_codes", [nil])
    code
  end

  def find(code), do: InmemoryStore.get("kore.app_code:::#{code}")

  def exists?(code), do: !is_nil(find(code))

  def verify(code, compare \\ nil) do
    case find(code) do
      nil ->
        {:error, :unknown_code}

      found ->
        delete(code)

        cond do
          is_nil(compare) ->
            {:ok, found}

          found == compare ->
            {:ok, found}

          :else ->
            {:error, :lookup_mismatch}
        end
    end
  end

  defp add(code, lookup) do
    all_codes = InmemoryStore.get("kore.app_codes", [])
    InmemoryStore.set("kore.app_codes", [code | all_codes])
    InmemoryStore.set("kore.app_code:::#{code}", lookup)
    code
  end

  defp delete(code) do
    InmemoryStore.get("kore.app_codes", [])
    |> List.delete(code)
    |> then(&InmemoryStore.set("kore.app_codes", &1))

    InmemoryStore.delete("kore.app_code:::#{code}")
  end

  def code() do
    Enum.random(20..32)
    |> :crypto.strong_rand_bytes()
    |> Base.encode16(padding: false)
    |> String.downcase()
  end
end
