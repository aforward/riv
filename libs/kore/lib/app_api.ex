defmodule Kore.AppApi do
  def lookup(application) do
    m = Module.concat([String.capitalize(application), "Api"])

    if Code.ensure_loaded?(m) do
      {:ok, m}
    else
      {:error, "Unknown module #{m}"}
    end
  end
end
