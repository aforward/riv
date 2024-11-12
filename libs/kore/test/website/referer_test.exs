defmodule Kore.Website.RefererTest do
  use ExUnit.Case
  alias Kore.Website.Referer
  doctest Referer

  describe "categorize/1" do
    test "handle nil" do
      assert Referer.categorize(nil) == nil
      assert Referer.categorize("") == nil
    end

    test "can parse a request" do
      req = %{
        req_headers: [
          ["host", "corporategiftbot.com"],
          ["x-request-start", "t=1727272707703573"],
          ["referer", "https://google.com"],
          ["accept-encoding", "gzip"],
          ["accept", "*/*"]
        ]
      }

      assert Referer.categorize(req) == "google.com"
      assert Referer.categorize(%{}) == nil
      assert Referer.categorize(%{req_headers: []}) == nil
    end

    test "handle weird data" do
      assert "goop" == Referer.categorize("goop")
      assert "a/b/c.com/d/g&^%$" == Referer.categorize("a/b/c.com/d/g&^%$#!")
      assert ":a/b/c:d" == Referer.categorize(":a/b/c:d")
    end

    for {referer, normalized} <- %{
          "android-app://com.google.android.gm/" => "com.google.android.gm",
          "android-app://com.linkedin.android/" => "com.linkedin.android",
          "google.com" => "google.com",
          "http://66.241.124.7:80/" => "66.241.124.7",
          "http://www.giftbetter.co/" => "giftbetter.co",
          "https://app.getbee.io/" => "app.getbee.io",
          "https://app.giftbetter.co/" => "app.giftbetter.co",
          "https://bing.com/" => "bing.com",
          "https://euc-word-edit.officeapps.live.com/" => "euc-word-edit.officeapps.live.com",
          "https://giftbetter-co.myshopify.com/" => "giftbetter-co.myshopify.com",
          "https://giftbetter.ca/" => "giftbetter.ca",
          "https://l.instagram.com/" => "l.instagram.com",
          "https://lnkd.in/" => "lnkd.in",
          "https://login.microsoftonline.com/" => "login.microsoftonline.com",
          "https://mail.google.com/" => "mail.google.com",
          "https://statics.teams.cdn.office.net/" => "statics.teams.cdn.office.net",
          "https://url.emailprotection.link/" => "url.emailprotection.link",
          "https://webmail.bell.net/" => "webmail.bell.net",
          "https://www.bing.com/" => "bing.com",
          "https://www.giftbetter.co/" => "giftbetter.co",
          "https://www.giftbetter.co/pages/our-customers" => "giftbetter.co/pages/our-customers",
          "https://www.google.com/" => "google.com",
          "https://www.instagram.com/" => "instagram.com",
          "https://www.linkedin.com/" => "linkedin.com"
        } do
      @referer referer
      @normalized normalized

      test "transform #{@referer}" do
        assert @normalized == Referer.categorize(@referer)
      end
    end
  end
end
