defmodule Kore do
  @moduledoc """
  `Kore` helper methods.
  """

  def map_get(data, key, default_if_missing \\ nil) do
    Map.get(data, key) || Map.get(data, Atom.to_string(key)) || default_if_missing
  end

  def person_names(nil), do: [nil, nil, nil]

  def person_names(full_name) do
    case String.split(full_name, ~r/\s+/, parts: 2) do
      [first, last] -> [full_name, first, last]
      [last] -> [full_name, "", last]
      _ -> [nil, nil, nil]
    end
  end
end
