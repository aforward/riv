defmodule Kore.Cli do
  def puts(msg) do
    IO.puts(msg)
  end

  def prompt(msg) do
    IO.write(msg)
    "" |> IO.gets() |> String.trim()
  end
end
