defmodule Kore.PdfTest do
  use ExUnit.Case
  alias Kore.Pdf
  doctest Pdf

  setup do
    start_supervised!(ChromicPDF)
    :ok
  end

  describe "p/2" do
    test "no URI just the path" do
      assert Pdf.p(nil, "/a/b/c") == "/a/b/c"
    end

    test "yes URI and a path" do
      assert Pdf.p(URI.parse("http://localhost:4000"), "/a/b/c") == "http://localhost:4000/a/b/c"
    end
  end

  describe "generate/1" do
    test "hello world" do
      {ok, _content} = Pdf.generate("hello world")

      assert ok == :ok
    end
  end

  describe "assign/3" do
    test "liveview socket" do
      assert Kore.Pdf.assign(%Phoenix.LiveView.Socket{}, :a, "b").assigns == %{
               a: "b",
               __changed__: %{a: true}
             }
    end

    test "plug conn" do
      assert Kore.Pdf.assign(%Plug.Conn{}, :a, "b").assigns == %{a: "b"}
    end
  end
end
