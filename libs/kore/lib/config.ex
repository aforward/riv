defmodule Kore.Config do
  @test_key "32jyWHPEsjc4w4gUX5fG2hDy9n5v88YPXp7oYGR8huk="

  @doc """
  Show all the values of the environment variables we care about
  """
  def all(env_vars), do: backup(env_vars) |> Enum.into(%{})

  @doc """
  Backup all environment variables into a map
  """
  def backup(env_vars) do
    Enum.map(env_vars, fn name ->
      {name, System.get_env(name)}
    end)
  end

  @doc """
  Restore all previously backed up env vars
  """
  def restore(env_vars) do
    Enum.each(env_vars, fn {name, original_value} ->
      upsert_env(name, original_value)
    end)
  end

  @doc """
  Useful for testing where we replace "real"
  environment values with "other" values.
  """
  def replace(env_names) do
    Enum.map(env_names, fn {real_name, replace_name} ->
      real_val = System.get_env(real_name)
      replace_val = System.get_env(replace_name)
      upsert_env(real_name, replace_val)

      {real_name, real_val}
    end)
    |> Enum.into(%{})
  end

  @doc """
  Lookup a Cloak compatible key on the System environment.
  This is used within your `runtime.exs` for example:

      config :giftdb, Giftdb.Vault,
        ciphers: [
          default: {
            Cloak.Ciphers.AES.GCM,
            tag: "AES.GCM.V2",
            key: Kore.Config.cloak_key("V2"),
            iv_length: 12
          },
          retired: {
            Cloak.Ciphers.AES.GCM,
            tag: "AES.GCM.V1",
            key: Kore.Config.cloak_key(nil),
            iv_length: 12
          }
        ]

  This will lookup `CLOAK_KEY` if no version is provided and
  `CLOAK_KEY_V2` if you provide a `version = "V2"`
  """
  def cloak_key(version \\ nil) do
    env_var =
      case version do
        nil -> "CLOAK_KEY"
        found -> "CLOAK_KEY_#{found}"
      end

    Base.decode64!(System.get_env(env_var) || @test_key)
  end

  defp upsert_env(name, value) do
    case value do
      nil -> System.delete_env(name)
      exists -> System.put_env(name, exists)
    end
  end
end
