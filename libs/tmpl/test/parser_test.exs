defmodule Tmpl.ParserTest do
  use ExUnit.Case
  alias Tmpl.Parser
  doctest Parser

  describe "extract_vars" do
    test "handle empty" do
      assert Parser.extract_vars(nil) == []
      assert Parser.extract_vars("") == []
    end

    test "none" do
      assert Parser.extract_vars("hello world") == []
    end

    test "one" do
      assert Parser.extract_vars("hello {name}") == ["name"]
    end

    test "many" do
      assert Parser.extract_vars("hello {fname} {lname}") == ["fname", "lname"]
    end

    test "duplicates" do
      assert Parser.extract_vars("hello {fname} {lname}, hi {fname}") == ["fname", "lname"]
    end
  end
end
