defmodule Kore.Token do
  @default_length 10

  @alphanumeric "ABCDEFGHJKLMNPQRSTUVWXYZabcdefhijkmnpqrstuvwxyz123456789"
                |> String.split("", trim: true)

  @doc """
  Generate an unguessable (non incremented) public identifier
  """
  def generate(opts \\ []) do
    len = Keyword.get(opts, :length, @default_length)

    Enum.reduce(1..len, [], fn _, acc ->
      [Enum.random(@alphanumeric) | acc]
    end)
    |> Enum.join("")
  end
end
