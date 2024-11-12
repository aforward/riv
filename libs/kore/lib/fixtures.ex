defmodule Kore.Fixtures do
  def exists?(filename), do: File.exists?(filename)

  # sobelow_skip ["Traversal.FileModule"]
  def load_json(filename, default_if_missing \\ nil) do
    if exists?(filename) do
      filename
      |> File.read!()
      |> Jason.decode!()
    else
      default_if_missing
    end
  end

  def token_path(appname), do: "./test/fixtures/#{appname}_token.json"

  def fixture_token?(appname), do: exists?(token_path(appname))

  def fixture_token(appname) do
    filename = token_path(appname)

    if exists?(filename) do
      filename
      |> load_json()
      |> then(&Map.put(&1, "application", appname))
    else
      %{}
    end
  end
end
