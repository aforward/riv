defmodule Kore.TokenTest do
  use ExUnit.Case
  alias Kore.Token
  doctest Token

  describe "generate/x" do
    test "default to 10 chars" do
      assert Token.generate() |> String.length() == 10
    end

    test "override length" do
      assert Token.generate(length: 20) |> String.length() == 20
    end

    test "unique" do
      expected = 100

      actual =
        for _ <- 1..expected do
          Token.generate(length: 20)
        end
        |> Enum.uniq()
        |> Enum.count()

      assert expected == actual
    end
  end
end
