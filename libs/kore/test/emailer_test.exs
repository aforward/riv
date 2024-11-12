defmodule Kore.EmailerTest do
  use ExUnit.Case, async: false
  alias Kore.Emailer
  doctest Kore.AppCode

  @email_data %{
    "to_name" => "a",
    "to_email" => "a@email.local",
    "from_name" => "b",
    "from_email" => "b@email.local",
    "subject" => "c",
    "html_body" => "<h1>d</h1>",
    "text_body" => "d"
  }

  describe "extract/1" do
    test "directly" do
      assert Emailer.extract(@email_data, "from_email") == "b@email.local"
      assert Emailer.extract(@email_data, "from_name") == "b"
    end

    test "as atoms" do
      assert Emailer.extract(@email_data, :from_email) == "b@email.local"
      assert Emailer.extract(@email_data, :from_name) == "b"
    end

    test "via email" do
      assert Emailer.extract(%{"email" => @email_data}, "from_email") == "b@email.local"
      assert Emailer.extract(%{"email" => @email_data}, :from_email) == "b@email.local"
    end
  end

  describe "to_email/1" do
    test "convert JSON map to Email struct" do
      assert Emailer.to_email(@email_data) ==
               Swoosh.Email.new(
                 to: {"a", "a@email.local"},
                 from: {"b", "b@email.local"},
                 subject: "c",
                 html_body: "<h1>d</h1>",
                 text_body: "d"
               )
    end

    test "support other TOs (list of 1)" do
      email_data = %{
        "to_name" => "a",
        "to_email" => "a@email.local",
        "other_tos" => [["x", "x@email.local"]],
        "from_name" => "b",
        "from_email" => "b@email.local",
        "subject" => "c",
        "html_body" => "<h1>d</h1>",
        "text_body" => "d"
      }

      assert Emailer.to_email(email_data) ==
               Swoosh.Email.new(
                 to: [{"a", "a@email.local"}, {"x", "x@email.local"}],
                 from: {"b", "b@email.local"},
                 subject: "c",
                 html_body: "<h1>d</h1>",
                 text_body: "d"
               )
    end

    test "support other TOs (list of 2)" do
      email_data = %{
        "to_name" => "a",
        "to_email" => "a@email.local",
        "other_tos" => [["x", "x@email.local"], ["y", "y@email.local"]],
        "from_name" => "b",
        "from_email" => "b@email.local",
        "subject" => "c",
        "html_body" => "<h1>d</h1>",
        "text_body" => "d"
      }

      assert Emailer.to_email(email_data) ==
               Swoosh.Email.new(
                 to: [{"a", "a@email.local"}, {"x", "x@email.local"}, {"y", "y@email.local"}],
                 from: {"b", "b@email.local"},
                 subject: "c",
                 html_body: "<h1>d</h1>",
                 text_body: "d"
               )
    end

    test "support other TOs (list of 3)" do
      email_data = %{
        "to_name" => "a",
        "to_email" => "a@email.local",
        "other_tos" => [["x", "x@email.local"], ["y", "y@email.local"], ["z", "z@email.local"]],
        "from_name" => "b",
        "from_email" => "b@email.local",
        "subject" => "c",
        "html_body" => "<h1>d</h1>",
        "text_body" => "d"
      }

      assert Emailer.to_email(email_data) ==
               Swoosh.Email.new(
                 to: [
                   {"a", "a@email.local"},
                   {"x", "x@email.local"},
                   {"y", "y@email.local"},
                   {"z", "z@email.local"}
                 ],
                 from: {"b", "b@email.local"},
                 subject: "c",
                 html_body: "<h1>d</h1>",
                 text_body: "d"
               )
    end

    test "support other TOs (just name/email)" do
      email_data = %{
        "to_name" => "a",
        "to_email" => "a@email.local",
        "other_tos" => ["x", "x@email.local"],
        "from_name" => "b",
        "from_email" => "b@email.local",
        "subject" => "c",
        "html_body" => "<h1>d</h1>",
        "text_body" => "d"
      }

      assert Emailer.to_email(email_data) ==
               Swoosh.Email.new(
                 to: [{"a", "a@email.local"}, {"x", "x@email.local"}],
                 from: {"b", "b@email.local"},
                 subject: "c",
                 html_body: "<h1>d</h1>",
                 text_body: "d"
               )
    end

    test "support 'email' data" do
      assert Emailer.to_email(%{"email" => @email_data}) ==
               Swoosh.Email.new(
                 to: {"a", "a@email.local"},
                 from: {"b", "b@email.local"},
                 subject: "c",
                 html_body: "<h1>d</h1>",
                 text_body: "d"
               )
    end

    test "convert nil to empty strings" do
      assert Emailer.to_email(%{"to_email" => "a", "from_email" => "b"}) ==
               Swoosh.Email.new(
                 to: {"", "a"},
                 from: {"", "b"},
                 subject: "",
                 html_body: "",
                 text_body: ""
               )
    end
  end
end
