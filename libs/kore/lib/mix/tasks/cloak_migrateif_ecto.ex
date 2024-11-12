defmodule Mix.Tasks.Cloak.Migrateif.Ecto do
  use Mix.Task

  @shortdoc "Runs 'mix cloak.migrate.ecto'if there is a :retired key present"
  def run(_) do
    Mix.Task.run("app.start", [])
    app_name = Mix.Project.config()[:app]

    if migrating?(app_name) do
      repo = Application.get_env(app_name, :cloak_repo)
      {:ok, _pid} = Supervisor.start_link([repo], strategy: :one_for_one)
      Mix.Task.run("cloak.migrate.ecto", [])
    else
      IO.puts("No #{app_name} cloak values to migrate.")
    end
  end

  defp vault_module(app_name) do
    Module.concat([String.to_existing_atom(String.capitalize(to_string(app_name))), :Vault])
  end

  defp migrating?(app_name) do
    !is_nil(Application.get_env(app_name, vault_module(app_name))[:ciphers][:retired])
  end
end
