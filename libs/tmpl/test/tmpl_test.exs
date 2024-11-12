defmodule TmplTest do
  use ExUnit.Case
  doctest Tmpl

  test "greets the world" do
    assert Tmpl.hello() == :world
  end
end
