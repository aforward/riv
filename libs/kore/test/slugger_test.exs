defmodule Kore.SluggerTest do
  use ExUnit.Case
  alias Kore.Slugger
  doctest Slugger

  describe "slugify/x" do
    test "do nothing" do
      assert Slugger.slugify("abc") == "abc"
    end

    test "downcase" do
      assert Slugger.slugify("AbC") == "abc"
    end

    test "funky" do
      assert Slugger.slugify("AbC") == "abc"
    end

    test "string to lower" do
      assert Slugger.slugify("ABC") == "abc"
    end

    test "removing space at beginning lowercase" do
      assert Slugger.slugify(" \t \n ABC") == "abc"
    end

    test "removing space at ending lowercase" do
      assert Slugger.slugify("ABC \n  \t \n ") == "abc"
    end

    test "removing space at ending and ending lowercase" do
      assert Slugger.slugify(" \n  \t \n ABC \n  \t \n ") == "abc"
    end

    test "replace whitespace inside with seperator lowercase" do
      assert Slugger.slugify("   A B  C  ") == "a-b-c"
      assert Slugger.slugify("   A B  C  ", separator: ?_) == "a_b_c"
    end

    test "removing space between possessives lowercase" do
      assert Slugger.slugify("Sheep's Milk") == "sheeps-milk"
    end

    test "crazy strings" do
      "test/fixtures/slugs.json"
      |> File.read!()
      |> Jason.decode!()
      |> Enum.each(fn string ->
        assert is_binary(Slugger.slugify(string))
      end)
    end
  end
end
