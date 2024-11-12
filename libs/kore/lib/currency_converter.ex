defmodule Kore.CurrencyConverter do
  alias Kore.Pretty

  def convert(nil, _exchange_rate, _filter_keys), do: nil

  def convert(struct, exchange_rate, filter_keys) when is_map(struct) do
    Enum.reduce(filter_keys, struct, fn k, new_struct ->
      Map.update!(new_struct, k, &convert(&1, exchange_rate))
    end)
  end

  def convert(nil, _exchange_rate), do: nil

  def convert(vals, exchange_rate) when is_map(vals) do
    vals
    |> Enum.map(fn {k, v} -> {k, convert(v, exchange_rate)} end)
    |> Enum.into(%{})
  end

  def convert(vals, exchange_rate) when is_list(vals) do
    Enum.map(vals, &convert(&1, exchange_rate))
  end

  def convert(val, exchange_rate) do
    Pretty.money(val * exchange_rate, format: :float)
  end
end
