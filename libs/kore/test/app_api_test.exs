defmodule Kore.AppApiTest do
  use ExUnit.Case, async: false
  alias Kore.AppApi
  doctest Kore.AppApi

  describe "lookup/x" do
    test "find the module" do
      {:ok, m} = AppApi.lookup("kore")
      assert m == Kore.Api
      assert m.name() == "kore"
    end

    test "do not find the module" do
      assert AppApi.lookup("goop") == {:error, "Unknown module Elixir.Goop.Api"}
    end
  end
end
