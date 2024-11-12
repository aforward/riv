defmodule Kore.WebsiteTest do
  use ExUnit.Case, async: true
  alias Kore.Website
  doctest Website

  defp make_conn() do
    %Plug.Conn{
      private: %{
        hello: :world,
        before_send: :deleteme,
        router: {1, :deleteme}
      },
      assigns: :deleteme,
      req_headers: [{:a, 1}, {:b, 2}]
    }
    |> Plug.Adapters.Test.Conn.conn(:post, "/hello", nil)
  end

  describe "request/1" do
    test "convert Conn to Map" do
      assert Website.request(make_conn()) == %{
               body_params: nil,
               cookies: nil,
               halted: false,
               host: "www.example.com",
               method: "POST",
               params: nil,
               path_info: ["hello"],
               path_params: %{},
               port: 80,
               private: %{hello: :world},
               query_params: nil,
               query_string: "",
               remote_ip: "127.0.0.1",
               req_cookies: nil,
               req_headers: [[:a, 1], [:b, 2]],
               request_path: "/hello",
               resp_body: nil,
               resp_cookies: %{},
               resp_headers: [["cache-control", "max-age=0, private, must-revalidate"]],
               scheme: :http,
               script_name: [],
               secret_key_base: nil,
               state: :unset,
               status: nil
             }
    end

    test "remove session data" do
      request =
        %Plug.Conn{
          private: %{
            plug_session: %{
              "_csrf_token" => "xxx-4Ma",
              "token" => "gho_xxx123"
            }
          }
        }
        |> Website.request()

      assert !Map.has_key?(request.private, :plug_session)
    end

    test "should be JSONable" do
      {ok, _data} = Website.request(make_conn()) |> Jason.encode()

      assert ok == :ok
    end
  end

  describe "extract/1" do
    test "nothing" do
      assert Website.extract(%{}) == %{
               page: nil,
               ipaddress: nil,
               trackaddress: nil,
               user_agent: nil,
               referer: nil,
               cookie: nil,
               campaign: nil,
               medium: nil,
               source: nil
             }
    end

    test "track UTMS" do
      request = %{
        params: %{
          "utm_campaign" => "cgb",
          "utm_medium" => "search",
          "utm_source" => "google"
        }
      }

      assert Website.extract(request) == %{
               page: nil,
               ipaddress: nil,
               trackaddress: nil,
               user_agent: nil,
               referer: nil,
               cookie: nil,
               campaign: "cgb",
               medium: "search",
               source: "google"
             }
    end

    test "grab ip and cookies" do
      request = %{
        remote_ip: "127.0.0.2",
        cookies: %{
          "_someapp_key" =>
            "SFMyNTY.g3QAAAACbQAAAAtfY3NyZl90b2tlbm0AAAAYeTBjWW53R0E5YXRUTnJTWXZzTzgtNE1hbQAAAAV0b2tlbm0AAAAoZ2hvX1lGbzhyQThFSG1naGpRblBUUndLTVlIWU1PdWg0TTNCWlRscA.PLAlREnVu0mwze229fGwMcfZug6hA7HiD7yiQvLoAMs",
          "_anothercokie" => "ignoreme"
        }
      }

      assert Website.extract(request) == %{
               page: nil,
               ipaddress: "127.0.0.2",
               trackaddress: "1edd62868f2767a1fff68df0a4cb3c23448e45100715768db9310b5e719536a1",
               user_agent: nil,
               referer: nil,
               cookie:
                 "SFMyNTY.g3QAAAACbQAAAAtfY3NyZl90b2tlbm0AAAAYeTBjWW53R0E5YXRUTnJTWXZzTzgtNE1hbQAAAAV0b2tlbm0AAAAoZ2hvX1lGbzhyQThFSG1naGpRblBUUndLTVlIWU1PdWg0TTNCWlRscA.PLAlREnVu0mwze229fGwMcfZug6hA7HiD7yiQvLoAMs",
               campaign: nil,
               medium: nil,
               source: nil
             }
    end

    test "grab the fly-client-ip if set (tuple)" do
      request = %{
        remote_ip: "127.0.0.2",
        req_headers: [{"fly-client-ip", "127.0.0.3"}]
      }

      assert Website.extract(request) == %{
               page: nil,
               ipaddress: "127.0.0.3",
               trackaddress: "18dd41c9f2e8e4879a1575fb780514ef33cf6e1f66578c4ae7cca31f49b9f2ed",
               user_agent: nil,
               referer: nil,
               cookie: nil,
               campaign: nil,
               medium: nil,
               source: nil
             }
    end

    test "grab the fly-client-ip if set (lists)" do
      request = %{
        remote_ip: "127.0.0.2",
        req_headers: [["fly-client-ip", "127.0.0.3"]]
      }

      assert Website.extract(request) == %{
               page: nil,
               ipaddress: "127.0.0.3",
               trackaddress: "18dd41c9f2e8e4879a1575fb780514ef33cf6e1f66578c4ae7cca31f49b9f2ed",
               user_agent: nil,
               referer: nil,
               cookie: nil,
               campaign: nil,
               medium: nil,
               source: nil
             }
    end

    test "page" do
      request = %{
        request_path: "/abc"
      }

      assert Website.extract(request) == %{
               page: "/abc",
               ipaddress: nil,
               trackaddress: nil,
               user_agent: nil,
               referer: nil,
               cookie: nil,
               campaign: nil,
               medium: nil,
               source: nil
             }
    end

    test "extract headers (user_agent, referer)" do
      request = %{
        req_headers: [
          [
            "user-agent",
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15 (Applebot/0.1; +http://www.apple.com/go/applebot)"
          ],
          ["referer", "google.com"]
        ]
      }

      assert Website.extract(request) == %{
               page: nil,
               ipaddress: nil,
               trackaddress: nil,
               user_agent: "bot_apple",
               referer: "google.com",
               cookie: nil,
               campaign: nil,
               medium: nil,
               source: nil
             }
    end
  end

  describe "header" do
    test "handle nil" do
      assert Website.header(nil, "user-agent") == nil
    end

    test "not well formatted data" do
      assert Website.header(%{}, "user-agent") == nil
    end

    test "no header present" do
      assert Website.header(%{req_headers: []}, "user-agent") == nil
    end

    test "extract header (lists)" do
      req = %{
        req_headers: [
          ["host", "corporategiftbot.com"],
          ["x-request-start", "t=1727272707703573"],
          ["user-agent", "Better Uptime Bot Mozilla/5.0"],
          ["accept-encoding", "gzip"],
          ["accept", "*/*"]
        ]
      }

      assert Website.header(req, "user-agent") == "Better Uptime Bot Mozilla/5.0"
      assert Website.header(req, "accept-encoding") == "gzip"
    end

    test "extract header (tuples)" do
      req = %{
        req_headers: [
          {"host", "corporategiftbot.com"},
          {"x-request-start", "t=1727272707703573"},
          {"user-agent", "Better Uptime Bot Mozilla/5.0"},
          {"accept-encoding", "gzip"},
          {"accept", "*/*"}
        ]
      }

      assert Website.header(req, "user-agent") == "Better Uptime Bot Mozilla/5.0"
      assert Website.header(req, "accept-encoding") == "gzip"
    end
  end
end
