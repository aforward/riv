defmodule Kore.Website do
  alias Kore.Website.{UserAgent, Referer}

  def request(conn) do
    conn
    |> Map.from_struct()
    |> Map.delete(:adapter)
    |> scrub_pids()
    |> scrub_assigns()
    |> scrub_private()
    |> fix_req_headers()
    |> fix_resp_headers()
    |> fix_remote_ip()
    |> fix_unfetched()
  end

  def extract(request) do
    ip = lookup_ipaddress(request)

    %{
      page: get_in(request, [:request_path]),
      campaign: get_in(request, [:params, "utm_campaign"]),
      medium: get_in(request, [:params, "utm_medium"]),
      source: get_in(request, [:params, "utm_source"]),
      ipaddress: ip,
      trackaddress: hash(ip),
      user_agent: UserAgent.categorize(request),
      referer: Referer.categorize(request),
      cookie: get_cookie(request)
    }
  end

  def hash(nil), do: nil

  def hash(str) do
    :crypto.hash(:sha256, str)
    |> Base.encode16()
    |> String.downcase()
  end

  def header(nil, _header), do: nil

  def header(req, header) do
    case Map.get(req, :req_headers) do
      nil ->
        nil

      headers ->
        headers
        |> Enum.map(fn
          [h, k] -> {h, k}
          {h, k} -> {h, k}
        end)
        |> Enum.find(fn {h, _k} -> h == header end)
        |> case do
          nil -> nil
          {_, ua} -> ua
        end
    end
  end

  defp scrub_pids(map), do: Map.delete(map, :owner)

  defp scrub_assigns(map), do: Map.delete(map, :assigns)

  defp scrub_private(%{private: private} = map) do
    private
    |> Map.delete(:before_send)
    |> Map.delete(:plug_session)
    |> Enum.reject(fn {_k, v} -> is_tuple(v) end)
    |> Enum.into(%{})
    |> replace_field(map, :private)
  end

  defp scrub_private(asis), do: asis

  defp fix_req_headers(%{req_headers: headers} = map) do
    headers
    |> Enum.map(fn
      {k, v} -> [k, v]
      asis -> asis
    end)
    |> replace_field(map, :req_headers)
  end

  defp fix_req_headers(asis), do: asis

  defp fix_resp_headers(%{resp_headers: headers} = map) do
    headers
    |> Enum.map(fn {k, v} -> [k, v] end)
    |> replace_field(map, :resp_headers)
  end

  defp fix_resp_headers(asis), do: asis

  defp fix_remote_ip(%{remote_ip: address} = map) do
    address
    |> fix_ip_address()
    |> replace_field(map, :remote_ip)
  end

  defp fix_remote_ip(asis), do: asis

  defp lookup_ipaddress(request) do
    default_ip = get_in(request, [:remote_ip])

    case Map.get(request, :req_headers) do
      nil ->
        default_ip

      headers ->
        headers
        |> Stream.filter(fn
          {k, _v} -> k == "fly-client-ip"
          [k, _v] -> k == "fly-client-ip"
        end)
        |> Enum.take(1)
        |> case do
          [] -> default_ip
          [{_, ip}] -> ip
          [[_, ip]] -> ip
        end
    end
  end

  defp get_cookie(request) do
    (get_in(request, [:cookies]) || %{})
    |> Enum.filter(fn {k, _v} -> String.ends_with?(k, "_key") end)
    |> Enum.map(fn {_k, v} -> v end)
    |> List.first()
  end

  def fix_unfetched(map) do
    map
    |> Enum.map(fn
      {k, %Plug.Conn.Unfetched{}} -> {k, nil}
      asis -> asis
    end)
    |> Enum.into(%{})
  end

  defp fix_ip_address({a, b, c, d}), do: "#{a}.#{b}.#{c}.#{d}"
  defp fix_ip_address(asis), do: "#{asis |> inspect()}"

  defp replace_field(new_value, map, field), do: Map.put(map, field, new_value)
end
