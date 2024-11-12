defmodule Kore.Website.UserAgentTest do
  use ExUnit.Case
  alias Kore.Website.UserAgent
  doctest UserAgent

  describe "categorize/1" do
    test "handle nil" do
      assert UserAgent.categorize(nil) == nil
      assert UserAgent.categorize("") == nil
    end

    test "can parse a request" do
      req = %{
        req_headers: [
          ["host", "corporategiftbot.com"],
          ["x-request-start", "t=1727272707703573"],
          [
            "user-agent",
            "Better Uptime Bot Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"
          ],
          ["accept-encoding", "gzip"],
          ["accept", "*/*"]
        ]
      }

      assert UserAgent.categorize(req) == "bot_betteruptime"
      assert UserAgent.categorize(%{}) == nil
      assert UserAgent.categorize(%{req_headers: []}) == nil
    end

    test "found in the wild (1)" do
      assert "bot_betteruptime" ==
               UserAgent.categorize(
                 "Better Uptime Bot Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Safari/605.1.15"
               )

      assert "bot_bing" ==
               UserAgent.categorize(
                 "Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm) Chrome/116.0.1938.76 Safari/537.36"
               )

      assert "bot_facebook" ==
               UserAgent.categorize(
                 "facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.5938.132 Safari/537.36"
               )

      assert "bot_bytespider" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (compatible; Bytespider; spider-feedback@bytedance.com) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.0.0 Safari/537.36"
               )

      assert "linux_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36"
               )

      assert "bot_googlesearch" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.6613.137 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Mobile/15E148 Safari/604.1"
               )

      assert "iphone_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Mobile/15E148 Safari/604.1"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36"
               )

      assert "iphone_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1"
               )

      assert "bot_bytespider" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; Android 5.0) AppleWebKit/537.36 (KHTML, like Gecko) Mobile Safari/537.36 (compatible; Bytespider; spider-feedback@bytedance.com)"
               )

      assert "windows_edge" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36 Edg/129.0.0.0"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.6422.114 Safari/537.36"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.6422.141 Safari/537.36"
               )

      assert "bot_ahrefs" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (compatible; AhrefsBot/7.0; +http://ahrefs.com/robot/)"
               )

      assert "bot_googlesnippets" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36 Google-PageRenderer Google (+https://developers.google.com/+/web/snippet/)"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
               )

      assert "bot_apple" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15 (Applebot/0.1; +http://www.apple.com/go/applebot)"
               )

      assert "bot_headlesschrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/92.0.4515.159 Safari/537.36"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36"
               )

      assert "windows_ie" ==
               UserAgent.categorize(
                 "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; WOW64; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729)"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36"
               )

      assert "iphone_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1"
               )

      assert "bot_golang" == UserAgent.categorize("Go-http-client/1.1")

      assert "linux_firefox" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (X11; Linux x86_64; rv:40.0) Gecko/20100101 Firefox/40.0"
               )

      assert "bot_expanse" ==
               UserAgent.categorize(
                 "Expanse, a Palo Alto Networks company, searches across the global IPv4 space multiple times per day to identify customers&#39; presences on the Internet. If you would like to be excluded from our scans, please send IP addresses/domains to: scaninfo@paloaltonetworks.com"
               )

      assert "android_samsung" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/26.0 Chrome/122.0.0.0 Mobile Safari/537.36"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.3809.100 Safari/537.36"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.97 Safari/537.36 OPR/64.0.3417.92"
               )

      assert "windows_edge" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36 Edg/128.0.0.0"
               )

      assert "iphone_facebook" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/21G93 [FBAN/FBIOS;FBAV/481.1.0.52.106;FBBV/641447568;FBDV/iPhone12,1;FBMD/iPhone;FBSN/iOS;FBSV/17.6.1;FBSS/2;FBID/phone;FBLC/en_US;FBOP/5;FBRV/645309951;IABMV/1]"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.6422.78 Safari/537.36"
               )

      assert "android_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Mobile Safari/537.36"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.6422.143 Safari/537.36"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.6523.4 Safari/537.36"
               )

      assert "linux_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36 Edg/108.0.1462.54"
               )

      assert "bot_headlesschrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/126.0.0.0 Safari/537.36"
               )

      assert "bot_slacklinkchecker" ==
               UserAgent.categorize("Slackbot-LinkExpanding 1.0 (+https://api.slack.com/robots)")

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36"
               )

      assert "bot_skypeuripreview" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 6.1; WOW64) SkypeUriPreview Preview/0.5 skype-url-preview@microsoft.com"
               )

      assert "windows_firefox" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:130.0) Gecko/20100101 Firefox/130.0"
               )

      assert "linux_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.6422.142 Safari/537.36"
               )

      assert "bot_googleother" == UserAgent.categorize("GoogleOther")

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Safari/605.1.15"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36"
               )

      assert "bot_dnb" == UserAgent.categorize("DnBCrawler-Analytics")

      # HERE

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.71 Safari/537.36"
               )

      assert "iphone_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1 Ddg/17.0"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4.1 Safari/605.1.15"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.89 Safari/537.36"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.3"
               )

      assert "windows_edge" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36 Edg/91.0.864.54"
               )

      assert "bot_googlesearch" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
               )

      assert "iphone_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 16_1_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.1 Mobile/15E148 Safari/604.1"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.0 Safari/537.36"
               )

      assert "bot_semrush" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (compatible; SemrushBot; +http://www.semrush.com/bot.html)"
               )

      assert "linux_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36"
               )

      assert "windows_firefox" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:67.0) Gecko/20100101 Firefox/67.0"
               )

      assert "iphone_instagram" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/21G93 Instagram 349.1.11.46.85 (iPhone14,5; iOS 17_6_1; en_CA; en-CA; scale=3.00; 1170x2532; 643271179; IABMV/1)"
               )

      assert "iphone_instagram" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/21G93 Instagram 349.0.8.36.85 (iPhone14,5; iOS 17_6_1; en_US; en-US; scale=3.00; 1170x2532; 642214400; IABMV/1)"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 DuckDuckGo/7 Safari/605.1.15"
               )

      assert "bot_curl" == UserAgent.categorize("curl/7.54.0")

      assert "bot_curl" == UserAgent.categorize("curl/7.29.0")

      assert "iphone_linkedin" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 [LinkedInApp]/9.30.1753"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.72 Safari/537.36"
               )

      assert "bot_dotbot" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (compatible; DotBot/1.2; +https://opensiteexplorer.org/dotbot; help@moz.com)"
               )

      assert "bot_imagesift" ==
               UserAgent.categorize("Mozilla/5.0 (compatible; ImagesiftBot; +imagesift.com)")

      assert "iphone_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1"
               )

      assert "bot_internetmeasurement" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (compatible; InternetMeasurement/1.0; +https://internet-measurement.com/)"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5.1 Mobile/15E148 Safari/604.1"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5.1 Safari/605.1.15"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko)Chrome/74.0.3729.169 Safari/537.36"
               )

      assert "iphone_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/129.0.6668.46 Mobile/15E148 Safari/604.1"
               )

      assert "android_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Mobile Safari/537.36"
               )

      assert "windows_edge" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.140 Safari/537.36 Edge/18.17763"
               )

      assert "linux_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36"
               )

      assert "bot_linkedin" ==
               UserAgent.categorize(
                 "LinkedInBot/1.0 (compatible; Mozilla/5.0; Apache-HttpClient +http://www.linkedin.com)"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36"
               )

      assert "bot_headlesschrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/124.0.6367.91 Safari/537.36"
               )

      assert "bot_python" == UserAgent.categorize("Python/3.11 aiohttp/3.9.3")

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36"
               )

      assert "windows_edge" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.141 Safari/537.36 Edg/87.0.664.75"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36"
               )

      assert "windows_firefox" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; WOW64; rv:91.0) Gecko/20100101 Firefox/91.0"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36"
               )

      assert "linux_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36"
               )

      assert "bot_webexteams" == UserAgent.categorize("WebexTeams")

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.5938.92 Safari/537.36"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36"
               )

      assert "android_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; Android 10; itel L5006C) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.181 Mobile Safari/537.36"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.162 Safari/537.36"
               )

      assert "bot_headlesschrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/94.0.4606.61 Safari/537.36"
               )

      assert "bot_headlesschrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (X11; Linux armv7l) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/84.0.4147.105 Safari/537.36"
               )

      assert "bot_rsiteauditor" ==
               UserAgent.categorize("Mozilla/5.0 (compatible; RSiteAuditor)")

      assert "bot_python" ==
               UserAgent.categorize("python-requests/2.32.3")

      assert "windows_edge" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0"
               )

      assert "iphone_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4.1 Mobile/15E148 Safari/604.1"
               )

      assert "iphone_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.3.1 Mobile/15E148 Safari/604.1"
               )

      assert "iphone_instagram" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/21G93 Instagram 341.0.1.29.93 (iPhone15,3; iOS 17_6_1; en_CA; en; scale=3.00; 1290x2796; 624397202; IABMV/1)"
               )

      assert "iphone_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/128.0.6613.98 Mobile/15E148 Safari/604.1"
               )

      assert "bot_req" == UserAgent.categorize("req/0.5.6")

      assert "bot_plausible" ==
               UserAgent.categorize(
                 "Plausible Verification Agent - if abused, contact support@plausible.io"
               )

      assert "iphone_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/99.0.4844.47 Mobile/15E148 Safari/604.1"
               )

      assert "linux_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
               )

      assert "windows_ie" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; Trident/6.0)"
               )

      assert "bot_googleappengine" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.5 Safari/605.1.15 AppEngine-Google; (+http://code.google.com/appengine; appid: s~virustotalcloud)"
               )

      assert "bot_googleappengine" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36 AppEngine-Google; (+http://code.google.com/appengine; appid: s~virustotalcloud)"
               )

      assert "bot_googleappengine" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; Android 13; Pixel 4a (5G) Build/TQ2A.230505.002; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/112.0.5615.136 Mobile Safari/537.36 GoogleApp/14.16.27.29.arm64 AppEngine-Google; (+http://code.google.com/appengine; appid: s~virustotalcloud)"
               )

      assert "bot_googleappengine" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36 AppEngine-Google; (+http://code.google.com/appengine; appid: s~virustotalcloud)"
               )

      assert "iphone_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/129.0.6668.46 Mobile/15E148 Safari/604.1"
               )

      assert "bot_domainsproject" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (compatible; Domains Project/1.3.7; +https://domainsproject.org)"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.0 Safari/537.36"
               )

      assert "android_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; Android 7.0; SM-G930V Build/NRD90M) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.125 Mobile Safari/537.36"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.141 YaBrowser/22.3.4.734 Yowser/2.5 Safari/537.36"
               )

      assert "linux_firefox" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.88 Safari/537.36"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"
               )

      assert "bot_df" == UserAgent.categorize("DF Bot 1.0")

      assert "windows_firefox" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:65.0) Gecko/20100101 Firefox/65.0"
               )

      assert "bot_googlesearch" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.90 Safari/537.36"
               )

      assert "windows_firefox" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:47.0) Gecko/20100101 Firefox/47.0"
               )

      assert "android_samsung" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; U; Android 4.1.2; ja-jp; SC-06D Build/JZO54K) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30"
               )

      assert "android_samsung" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; Android 5.0; SAMSUNG SM-G900F Build/LRX21T) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/3.0"
               )

      assert "windows_generic" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows; U; Windows NT 5.1; ru; rv:1.9.0.1) Gecko/2008070208"
               )

      assert "bot_semrush" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (compatible; SemrushBot/7~bl; +http://www.semrush.com/bot.html)"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.71 Safari/537.36"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/601.6.17 (KHTML, like Gecko) Version/9.1.1 Safari/601.6.17"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/603.3.8 (KHTML, like Gecko) Version/10.1.2 Safari/603.3.8"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36,"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0.0; Win64; x64; ) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.6367.60 Chrome/124.0.6367.60 Not-A.Brand/99  Safari/537.36"
               )

      assert "iphone_linkedin" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 [LinkedInApp]/9.30.1558"
               )

      assert "android_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; Android 14; SM-S901B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.280 Mobile Safari/537.36 OPR/80.4.4244.7786"
               )

      assert "windows_ie" ==
               UserAgent.categorize("Mozilla/4.0+(compatible;+MSIE+8.0;+Windows+NT+5.2)")

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36"
               )

      assert "windows_generic" ==
               UserAgent.categorize("Mozilla/5.0 (Windows NT 10.0; Win64; x64)")

      assert "bot_mixrank" ==
               UserAgent.categorize("Mozilla/5.0 (compatible; MixrankBot; crawler@mixrank.com)")

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.82 Safari/537.36 Quark/3.6.2.993 Mobile"
               )

      assert "windows_edge" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36 Edg/122.0.0.0"
               )

      assert "iphone_instagram" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/21G93 Instagram 348.0.4.31.86 (iPhone14,7; iOS 17_6_1; en_US; en-US; scale=3.00; 1170x2532; 639518546; IABMV/1)"
               )

      assert "bot_googlesearch" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.6613.119 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Safari/605.1.15"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Safari/605.1.15"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.6478.36 Safari/537.36"
               )

      assert "iphone_instagram" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/21G93 Instagram 347.2.5.30.88 (iPhone15,2; iOS 17_6_1; en_GB; en-GB; scale=3.00; 1179x2556; 638879998; IABMV/1)"
               )

      assert "windows_firefox" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:124.0) Gecko/20100101 Firefox/124.0"
               )

      assert "iphone_instagram" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/21G93 Instagram 347.2.5.30.88 (iPhone13,1; iOS 17_6_1; en_CA; en-CA; scale=3.00; 1125x2436; 638879998; IABMV/1)"
               )

      assert "windows_edge" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.5; Win64; x64; en-US) AppleWebKit/533.49 (KHTML, like Gecko) Chrome/54.0.3557.263 Safari/601.5 Edge/14.58537"
               )

      assert "android_instagram" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; Android 13; SM-G986W Build/TP1A.220624.014; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/127.0.6533.103 Mobile Safari/537.36 Instagram 348.0.0.46.105 Android (33/13; 450dpi; 1080x2192; samsung; SM-G986W; y2q; qcom; en_CA; 640256660)"
               )

      assert "iphone_instagram" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 16_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/20B82 Instagram 346.0.7.32.89 (iPhone13,2; iOS 16_1; en_CA; en-CA; scale=3.00; 1170x2532; 635436977; IABMV/1)"
               )

      assert "linux_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; U; Linux i571 ) AppleWebKit/601.12 (KHTML, like Gecko) Chrome/49.0.1390.335 Safari/534"
               )

      assert "windows_edge" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows; U; Windows NT 10.2; Win64; x64) AppleWebKit/537.9 (KHTML, like Gecko) Chrome/48.0.3312.256 Safari/536.1 Edge/8.25301"
               )

      assert "iphone_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 8_8_0; like Mac OS X) AppleWebKit/603.9 (KHTML, like Gecko) Chrome/50.0.1993.296 Mobile Safari/601.8"
               )

      assert "iphone_instagram" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/21G93 Instagram 348.0.4.31.86 (iPhone15,4; iOS 17_6_1; en_CA; en-CA; scale=3.00; 1179x2556; 639518546) NW/3"
               )

      assert "iphone_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36"
               )

      assert "iphone_instagram" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/21G93 Instagram 327.1.6.30.88 (iPhone15,3; iOS 17_6_1; en_CA; en; scale=3.00; 1290x2796; 588348860)"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36 OPR/112.0.0.0"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36"
               )

      assert "bot_googleappengine" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Android 13; Mobile; rv:109.0) Gecko/112.0 Firefox/112.0 AppEngine-Google; (+http://code.google.com/appengine; appid: s~virustotalcloud)"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 11_2_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.150 Safari/537.36 Edg/88.0.705.63"
               )

      assert "iphone_linkedin" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 [LinkedInApp]/9.30.1317"
               )

      assert "windows_firefox" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:84.0) Gecko/20100101 Firefox/84.0"
               )

      assert "mac_firefox" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 11.2; rv:78.0) Gecko/20100101 Firefox/78.0"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36"
               )

      assert "android_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; Android 11; LM-X420) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.105 Mobile Safari/537.36"
               )

      assert "bot_ccleaner" == UserAgent.categorize("Mozilla/4.0 (CCleaner, 5.37.6309)")

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
               )

      assert "bot_googlesearch" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.6613.113 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
               )

      assert "iphone_instagram" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/21G93 Instagram 347.2.5.30.88 (iPhone16,2; iOS 17_6_1; en_CA; en-CA; scale=3.00; 1290x2796; 638879998) NW/1"
               )

      assert "iphone_instagram" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/21G93 Instagram 347.2.5.30.88 (iPhone16,2; iOS 17_6_1; en_CA; en-CA; scale=3.00; 1290x2796; 638879998; IABMV/1)"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0.0; Win64; x64; ) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.6367.63 Chrome/124.0.6367.63 Not-A.Brand/99  Safari/537.36"
               )

      assert "android_facebook" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; Android 12; SM-A217F Build/SP1A.210812.016; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/127.0.6533.103 Mobile Safari/537.36 [FBAN/AudienceNetworkForWindows;FBDV/SM-A217F;FBSV/12;FBAV/423.0.0.12.114;FBLC/en_US]"
               )

      assert "iphone_instagram" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 16_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/20G81 Instagram 345.3.3.38.86 (iPhone14,5; iOS 16_6_1; en_CA; en-CA; scale=3.00; 1170x2532; 634675901; IABMV/1)"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.6.1 Safari/605.1.15"
               )

      assert "iphone_linkedin" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 [LinkedInApp]/9.29.2621"
               )

      assert "linux_firefox" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (X11; Linux i686; rv:109.0) Gecko/20100101 Firefox/120.0"
               )

      assert "bot_facebook" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/601.2.4 (KHTML, like Gecko) Version/9.0.1 Safari/601.2.4 facebookexternalhit/1.1 Facebot Twitterbot/1.0"
               )

      assert "iphone_linkedin" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 [LinkedInApp]/9.28.8363"
               )

      assert "iphone_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/128.0.6613.98 Mobile/15E148 Safari/604.1"
               )

      assert "iphone_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/124.0.6367.111 Mobile/15E148 Safari/604.1"
               )

      assert "linux_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36"
               )

      assert "android_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; Android 7.0; SM-G930V Build/NRD90M) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.125 Mobile Safari/537.36 (compatible; Google-Read-Aloud; +https://support.google.com/webmasters/answer/1061943)"
               )

      assert "bot_meta" ==
               UserAgent.categorize(
                 "meta-externalagent/1.1 (+https://developers.facebook.com/docs/sharing/webmasters/crawler)"
               )

      assert "windows_edge" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36 Edg/127.0.0.0"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4758.11 Safari/537.36"
               )

      assert "android_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; U; Android 13; sk-sk; Xiaomi 11T Pro Build/TKQ1.220829.002) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/112.0.5615.136 Mobile Safari/537.36 XiaoMi/MiuiBrowser/14.4.0-g"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36"
               )

      assert "android_firefox" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Android; Linux armv7l; rv:2.0.1) Gecko/20100101 Firefox/4.0.1 Fennec/2.0.1"
               )

      assert "bot_mj12" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (compatible; MJ12bot/v1.4.8; http://mj12bot.com/)"
               )

      assert "linux_firefox" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (X11; Linux x86_64; rv:83.0) Gecko/20100101 Firefox/83.0"
               )

      assert "bot_yandex" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (compatible; YandexBot/3.0; +http://yandex.com/bots)"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.0.0 Safari/537.36"
               )

      assert "iphone_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_2_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Mobile/15E148 Safari/604.1"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36"
               )

      assert "iphone_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko)"
               )

      assert "bot_chatgpt" ==
               UserAgent.categorize(
                 "Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; GPTBot/1.0; +https://openai.com/gptbot)"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.56 Safari/535.11"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh;                 Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML,                 like Gecko) Chrome/39.0.2171.95 Safari/537.36"
               )

      assert "bot_censys" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (compatible; CensysInspect/1.1; +https://about.censys.io/)"
               )

      assert "android_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.6613.113 Mobile Safari/537.36 (compatible; GoogleOther)"
               )

      assert "windows_firefox" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-GB; rv:1.8.1.16) Gecko/20080702 Firefox/2.0.0.16"
               )

      assert "iphone_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/128.0.6613.92 Mobile/15E148 Safari/604.1"
               )

      assert "bot_2ip" == UserAgent.categorize("2ip bot/1.1 (+http://2ip.io)")

      assert "android_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36"
               )

      assert "bot_ebgermany" == UserAgent.categorize("crawler_eb_germany_2.0")

      assert "windows_ie" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0; BOIE9;RURU)"
               )

      assert "windows_ie" ==
               UserAgent.categorize(
                 "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)"
               )

      assert "android_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; Android 10; LIO-AN00 Build/HUAWEILIO-AN00; wv) MicroMessenger Weixin QQ AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/78.0.3904.62 XWEB/2692 MMWEBSDK/200901 Mobile Safari/537.36"
               )

      assert "iphone_instagram" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/21F90 Instagram 346.0.7.32.89 (iPhone14,5; iOS 17_5_1; en_NZ; en-NZ; scale=3.00; 1170x2532; 635436977; IABMV/1)"
               )

      assert "android_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36"
               )

      assert "windows_edge" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/12.246"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Iron Safari/537.36"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4895.86 Safari/537.36"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36"
               )

      assert "bot_curl" == UserAgent.categorize("curl/7.61.1")

      assert "windows_firefox" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:108.0) Gecko/20100101 Firefox/108.0"
               )

      assert "bot_googlesearch" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.6533.119 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
               )

      assert "bot_zgrab" == UserAgent.categorize("Mozilla/5.0 zgrab/0.x")

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36 (scanner.ducks.party)"
               )

      assert "windows_firefox" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:31.0) Gecko/20130401 Firefox/31.0"
               )

      assert "android_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; Android 11; M2004J15SC) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.5060.114 Mobile Safari/537.36"
               )

      assert "linux_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36"
               )

      assert "android_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; Android 9; LM-G710VM) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.111 Mobile Safari/537.36"
               )

      assert "bot_archiveorg" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (compatible; archive.org_bot +http://archive.org/details/archive.org_bot) Zeno/349e035 warc/v0.8.43"
               )

      assert "iphone_instagram" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/21F90 Instagram 346.0.7.32.89 (iPhone14,5; iOS 17_5_1; en_CA; en-CA; scale=3.00; 1170x2532; 635436977; IABMV/1)"
               )

      assert "linux_firefox" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (X11; Linux i686; rv:10.0) Gecko/20100101 Firefox/10.0"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.3"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36"
               )

      assert "android_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; Android 6.0; HTC One M9 Build/MRA125617) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.1123.98 Mobile Safari/537.3"
               )

      assert "android_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; Android 6.0; HTC One M9 Build/MRA58K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.98 Mobile Safari/537.3"
               )

      assert "bot_yandex" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (compatible; YandexBot/3.0; +http://yandex.com/bots) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0"
               )

      assert "ipad_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (iPad; CPU OS 12_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Mobile/15E148 Safari/604.1"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.3"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.3.1 Safari/605.9.26"
               )

      assert "mac_safari" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_6) AppleWebKit/537.78.2 (KHTML, like Gecko) Version/7.0.6 Safari/537.78.2"
               )
    end

    test "found in the wild (2)" do
      assert "bot_apache" == UserAgent.categorize("Apache-HttpClient/4.5.14 (Java/1.8.0_392)")

      assert "bot_java" == UserAgent.categorize("Java/1.8.0_265")

      assert "linux_generic" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (X11; CrOS x86_64 13729.56.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.95 Safari/537.36"
               )
    end

    test "found in the wild (3)" do
      assert "bot_wpbot" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (compatible; wpbot/1.1; +https://forms.gle/ajBaxygz9jSR8p8G9)"
               )

      assert "bot_googleads" ==
               UserAgent.categorize("AdsBot-Google (+http://www.google.com/adsbot.html)")

      assert "bot_netcraft" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (compatible; NetcraftSurveyAgent/1.0; +info@netcraft.com)"
               )

      assert "bot_lua" == UserAgent.categorize("lua-resty-http/0.07 (Lua) ngx_lua/10025")

      assert "mac_trident" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Apple Mac OS X v10.9.3; Trident/7.0; rv:11.0) like Gecko"
               )

      assert "bot_barracuda" == UserAgent.categorize("Barracuda Sentinel (EE)")

      assert "bot_googleads" ==
               UserAgent.categorize(
                 "Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; Mozilla/5.0, Google-AdWords-Express) Chrome/129.0.6668.70 Safari/537.36"
               )

      assert "windows_chrome" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (10.0; Win64; x6410.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36"
               )

      assert "bot_googleads" ==
               UserAgent.categorize("Google-Adwords-Instant (+http://www.google.com/adsbot.html)")

      assert "bot_google" == UserAgent.categorize("Google")

      assert "bot_googleads" ==
               UserAgent.categorize(
                 "Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; Mozilla/5.0, Google-AdWords-Express) Chrome/128.0.6613.137 Safari/537.36"
               )

      assert "bot_googleads" == UserAgent.categorize("Google-Ads-Creatives-Assistant")
      assert "bot_chrome" == UserAgent.categorize("Chrome")

      assert "android_uc" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; U; Android 4.4.2; en-US; HM NOTE 1W Build/KOT49H) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 UCBrowser/11.0.5.850 U3/0.8.0 Mobile Safari/534.30"
               )

      assert "bot_perplexity" ==
               UserAgent.categorize(
                 "Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; PerplexityBot/1.0; +https://docs.perplexity.ai/docs/perplexity-bot)"
               )

      assert "android_firefox" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Android 14; Mobile; rv:123.0) Gecko/123.0 Firefox/123"
               )

      assert "bot_fellow" == UserAgent.categorize("Fellow Links Parser Robot")

      assert "android_galaxy" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (Linux; U; Android 4.0.3; de-de; Galaxy S II Build/GRJ22) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30"
               )

      assert "os2_firefox" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (OS/2; Warp 4.5; rv:31.0) Gecko/20100101 Firefox/31.0"
               )

      assert "android_opera" ==
               UserAgent.categorize(
                 "Opera/9.80 (Android; Opera Mini/43.3.2254/150.36; U; en) Presto/2.12.423 Version/12.16"
               )

      assert "linux_fennec" ==
               UserAgent.categorize(
                 "Mozilla/5.0 (X11; U; Linux armv61; en-US; rv:1.9.1b2pre) Gecko/20081015 Fennec/1.0a1"
               )
    end
  end
end
