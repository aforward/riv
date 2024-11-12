defmodule Kore.Browser do
  alias Kore.{Cli, Config}

  @doc """
  Generate an offline token.  This will
  open up a browser to the appropriate URL and then
  return you the token.

  Because the authorization URL is probably based on environment
  variables, we need to pass it as a function, not a string.
  """
  def generate_offline_token(authorize_url_fn, generate_token_fn) do
    url = authorize_url_fn.()
    Cli.puts("Opening in browser: #{url}")
    open(url)

    Cli.prompt("Paste URL from browser: ")
    |> query_params()
    |> then(fn %{"code" => code} -> generate_token_fn.(code) end)
    |> then(fn {:ok, token} -> token end)
  end

  @doc """
  Store the generated offline token into a fixture for use in testing
  """
  def generate_fixture_token(application, fixture_path, authorize_url_fn, generate_token_fn) do
    load_env()

    cond do
      missing_env?(application) ->
        missing_env(application)

      File.exists?(fixture_path) ->
        IO.puts("\n\nAlready have an offline token (#{fixture_path}) delete to regenerate.")

        {:ok, :already_setup}

      :else ->
        replace_env(application)

        generate_offline_token(authorize_url_fn, generate_token_fn)
        |> write_fixture_token(fixture_path)

        IO.puts("\n\nOffline token stored to #{fixture_path}.")

        {:ok, :token_stored}
    end
  end

  @doc """
  An existing token has expired, so store a fresh one based on the refresh_token_fn
  """
  def refresh_fixture_token(application, fixture_path, refresh_token_fn) do
    load_env()

    cond do
      missing_env?(application) ->
        missing_env(application)

      !File.exists?(fixture_path) ->
        IO.puts(
          "\n\nMissing existing token (#{fixture_path}) to refresh, please call generate_fixture_token instead."
        )

        {:ok, :missing_token}

      :else ->
        replace_env(application)

        app_token = read_fixture_token(fixture_path)

        refresh_token_fn.(app_token)
        |> write_fixture_token(fixture_path)

        IO.puts("\n\nOffline token refreshed to #{fixture_path}.")

        {:ok, :token_stored}
    end
  end

  @doc """
  Write the token to the file system
  """
  def write_fixture_token({:ok, app_token}, fixture_path) do
    write_fixture_token(app_token, fixture_path)
  end

  # sobelow_skip ["Traversal.FileModule"]
  def write_fixture_token(app_token, fixture_path) when is_map(app_token) do
    app_token
    |> Jason.encode!(pretty: true)
    |> then(&File.write!(fixture_path, &1))
  end

  @doc """
  Read the token from the file system
  """
  # sobelow_skip ["Traversal.FileModule"]
  def read_fixture_token(fixture_path) do
    fixture_path
    |> File.read!()
    |> Jason.decode!()
  end

  @doc """
  Open the desired URL within your default
  browser.  This is primarily used for power-assisted
  things (like generated access tokens to 3rd party apps)
  """
  def open(url) do
    case :os.type() do
      {:unix, :darwin} -> System.cmd("open", [url])
      {:win32, _} -> System.cmd("start", [url])
      {:unix, _} -> System.cmd("xdg-open", [url])
      _ -> {:error, "Unsupported OS"}
    end
  end

  @doc """
  Parse the URL and extract the query params
  """
  def query_params(nil), do: %{}

  def query_params(url) do
    url
    |> URI.parse()
    |> then(fn %{query: query} -> query || "" end)
    |> URI.decode_query()
  end

  def load_env() do
    if File.exists?(".env.exs"), do: Code.eval_file(".env.exs")
  end

  defp missing_env?(application) do
    env_prefix = String.upcase(application)
    is_nil(System.get_env("#{env_prefix}_TEST_CLIENT_ID"))
  end

  defp missing_env(application) do
    env_prefix = String.upcase(application)
    IO.puts("Take a look at #{application}.md for how to configure to #{env_prefix}_TEST_*.\n\n")

    {:error, :missing_env}
  end

  defp replace_env(application) do
    env_prefix = String.upcase(application)

    Config.replace(%{
      "#{env_prefix}_CLIENT_ID" => "#{env_prefix}_TEST_CLIENT_ID",
      "#{env_prefix}_CLIENT_SECRET" => "#{env_prefix}_TEST_CLIENT_SECRET",
      "#{env_prefix}_REDIRECT_URI" => "#{env_prefix}_TEST_REDIRECT_URI"
    })
  end
end
