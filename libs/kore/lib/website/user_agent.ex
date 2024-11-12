defmodule Kore.Website.UserAgent do
  alias Kore.Website

  # Based on https://useragent.wcode.net
  def categorize(nil), do: nil

  def categorize(req) when is_map(req) do
    case Website.header(req, "user-agent") do
      nil -> nil
      ua -> categorize(ua)
    end
  end

  def categorize(ua) when is_binary(ua) do
    cond do
      # specific bots
      ua == "GoogleOther" -> "bot_googleother"
      ua =~ "2ip bot" -> "bot_2ip"
      ua =~ "AdsBot-Google" -> "bot_googleads"
      ua =~ "AhrefsBot" -> "bot_ahrefs"
      ua =~ "AppEngine-Google" -> "bot_googleappengine"
      ua =~ "Applebot" -> "bot_apple"
      ua =~ "Barracuda Sentinel" -> "bot_barracuda"
      ua =~ "Better Uptime Bot" -> "bot_betteruptime"
      ua =~ "Bytespider" -> "bot_bytespider"
      ua =~ "CCleaner" -> "bot_ccleaner"
      ua =~ "CensysInspect" -> "bot_censys"
      ua =~ "DF Bot" -> "bot_df"
      ua =~ "DnBCrawler" -> "bot_dnb"
      ua =~ "Domains Project" -> "bot_domainsproject"
      ua =~ "DotBot" -> "bot_dotbot"
      ua =~ "Expanse" -> "bot_expanse"
      ua =~ "Fellow Links Parser Robot" -> "bot_fellow"
      ua =~ "GPTBot" -> "bot_chatgpt"
      ua =~ "Go-http-client" -> "bot_golang"
      ua =~ "Google-AdWords-Express" -> "bot_googleads"
      ua =~ "Google-Ads-Creatives-Assistant" -> "bot_googleads"
      ua =~ "Google-Adwords-Instant" -> "bot_googleads"
      ua =~ "Google-PageRenderer" -> "bot_googlesnippets"
      ua =~ "Googlebot" -> "bot_googlesearch"
      ua =~ "HeadlessChrome" -> "bot_headlesschrome"
      ua =~ "ImagesiftBot" -> "bot_imagesift"
      ua =~ "InternetMeasurement" -> "bot_internetmeasurement"
      ua =~ "LinkedInBot" -> "bot_linkedin"
      ua =~ "MJ12bot" -> "bot_mj12"
      ua =~ "MixrankBot" -> "bot_mixrank"
      ua =~ "NetcraftSurveyAgent" -> "bot_netcraft"
      ua =~ "PerplexityBot" -> "bot_perplexity"
      ua =~ "Plausible Verification Agent" -> "bot_plausible"
      ua =~ "Python" -> "bot_python"
      ua =~ "RSiteAuditor" -> "bot_rsiteauditor"
      ua =~ "SemrushBot" -> "bot_semrush"
      ua =~ "SkypeUriPreview" -> "bot_skypeuripreview"
      ua =~ "Slackbot-LinkExpanding" -> "bot_slacklinkchecker"
      ua =~ "WebexTeams" -> "bot_webexteams"
      ua =~ "YandexBot" -> "bot_yandex"
      ua =~ "archive.org_bot" -> "bot_archiveorg"
      ua =~ "bingbot" -> "bot_bing"
      ua =~ "crawler_eb_germany" -> "bot_ebgermany"
      ua =~ "curl" -> "bot_curl"
      ua =~ "facebookexternalhit" -> "bot_facebook"
      ua =~ "meta-externalagent" -> "bot_meta"
      ua =~ "ngx_lua" -> "bot_lua"
      ua =~ "python-requests" -> "bot_python"
      ua =~ "req/" -> "bot_req"
      ua =~ "wpbot" -> "bot_wpbot"
      ua =~ "zgrab" -> "bot_zgrab"
      # generic bots
      ua =~ "Apache-HttpClient" -> "bot_apache"
      ua =~ "Java/" -> "bot_java"
      ua == "Google" -> "bot_google"
      ua == "Chrome" -> "bot_chrome"
      # devices
      ua =~ "MSIE" -> "windows_ie"
      ua =~ "Android" and ua =~ "Instagram" -> "android_instagram"
      ua =~ "Android" and ua =~ "FBAN" -> "android_facebook"
      ua =~ "Android" and ua =~ "SamsungBrowser" -> "android_samsung"
      ua =~ "Android" and ua =~ "SC-06D" -> "android_samsung"
      ua =~ "Android" and ua =~ "Chrome" -> "android_chrome"
      ua =~ "Android" and ua =~ "UCBrowser" -> "android_uc"
      ua =~ "Android" and ua =~ "Firefox" -> "android_firefox"
      ua =~ "Android" and ua =~ "Galaxy" -> "android_galaxy"
      ua =~ "Android" and ua =~ "Opera" -> "android_opera"
      ua =~ "iPhone" and ua =~ "Safari" -> "iphone_safari"
      ua =~ "iPhone" and ua =~ "FBIOS" -> "iphone_facebook"
      ua =~ "iPhone" and ua =~ "Instagram" -> "iphone_instagram"
      ua =~ "iPhone" and ua =~ "LinkedInApp" -> "iphone_linkedin"
      ua =~ "iPad" and ua =~ "Safari" -> "ipad_safari"
      ua =~ "Windows NT" and ua =~ "Edg" -> "windows_edge"
      ua =~ "Windows NT" and ua =~ "Chrome" -> "windows_chrome"
      ua =~ "Windows NT" and ua =~ "Firefox" -> "windows_firefox"
      ua =~ "Win64" and ua =~ "Chrome" -> "windows_chrome"
      ua =~ "Macintosh" and ua =~ "Firefox" -> "mac_firefox"
      ua =~ "Macintosh" and ua =~ "Safari" -> "mac_safari"
      ua =~ "Apple" and ua =~ "Trident" -> "mac_trident"
      ua =~ "Linux" and ua =~ "HeadlessChrome" -> "linux_headlesschrome"
      ua =~ "Linux" and ua =~ "Chrome" -> "linux_chrome"
      ua =~ "Linux" and ua =~ "Firefox" -> "linux_firefox"
      ua =~ "Linux" and ua =~ "Fennec" -> "linux_fennec"
      ua =~ "OS/2" and ua =~ "Firefox" -> "os2_firefox"
      # Generic desktops
      ua =~ "CrOS" -> "linux_generic"
      ua =~ "Mozilla/5.0 (Windows; U; Windows NT 5.1; ru; rv:1.9.0.1)" -> "windows_generic"
      ua =~ "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit" -> "mac_safari"
      ua =~ "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" -> "windows_generic"
      :else -> nil
    end
  end
end
