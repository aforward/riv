defmodule Kore.Website.Referer do
  alias Kore.Website

  def categorize(nil), do: nil

  def categorize(req) when is_map(req) do
    case Website.header(req, "referer") do
      nil -> nil
      ref -> categorize(ref)
    end
  end

  def categorize(""), do: nil

  def categorize(ref) when is_binary(ref) do
    ref
    |> URI.parse()
    |> then(fn
      uri ->
        host = String.replace_leading(uri.host || "", "www.", "")

        path =
          case uri.path do
            "/" -> ""
            asis -> asis
          end

        "#{host}#{path}"
    end)
  end
end
