defmodule Kore.Slugger do
  alias Kore.Slugger.SpecialChars

  @separator_char "-"

  @doc """
  Return a string in form of a lowercase slug for a given string.

  ## Examples

      iex> Kore.Slugger.slugify(" Hello # world ")
      "hello-world"

      iex> Kore.Slugger.slugify("Über draußen Tore")
      "ueber-draussen-tore"

      iex> Kore.Slugger.slugify("Wikipedia mode", separator: ?_)
      "wikipedia_mode"

      iex> Kore.Slugger.slugify("_trimming_and___removing_fat___")
      "trimming-and-removing-fat"

  """
  def slugify(text, opts \\ []) do
    separator = Keyword.get(opts, :separator, @separator_char)

    text
    |> handle_possessives()
    |> SpecialChars.replace()
    |> String.downcase()
    |> remove_unwanted_chars(separator, ~r/([^a-z0-9가-힣])+/)
  end

  defp remove_unwanted_chars(text, separator, pattern) do
    sep_binary = to_string([separator])

    text
    |> String.replace(pattern, sep_binary)
    |> String.trim(sep_binary)
  end

  defp handle_possessives(text) do
    String.replace(text, ~r/['’]s/u, "s")
  end
end
