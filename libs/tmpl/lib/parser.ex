defmodule Tmpl.Parser do
  def extract_vars(nil), do: []

  def extract_vars(text) do
    Regex.scan(~r/\{(.*?)\}/, text)
    |> Enum.map(fn [_, var] -> var end)
    |> Enum.uniq()
    |> Enum.sort()
  end
end
