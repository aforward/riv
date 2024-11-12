defmodule Kore.Emailer do
  use Swoosh.Mailer, otp_app: :kore, api_client: false, adapter: Swoosh.Adapters.Local

  def to_email(%{"email" => data}), do: to_email(data)

  def to_email(data) do
    Swoosh.Email.new(
      to: extract_to(data),
      from: {f(data, "from_name"), f(data, "from_email")},
      subject: f(data, "subject"),
      html_body: f(data, "html_body"),
      text_body: f(data, "text_body")
    )
  end

  def extract(%{"email" => data}, key), do: extract(data, key)
  def extract(data, key) when is_atom(key), do: f(data, Atom.to_string(key))
  def extract(data, key), do: f(data, key)

  defp f(data, key), do: data[key] || ""

  defp extract_to(data) do
    primary = {f(data, "to_name"), f(data, "to_email")}

    others = f(data, "other_tos")

    cond do
      others == "" ->
        []

      Enum.count(others) == 2 && is_binary(Enum.at(others, 0)) ->
        [others]

      :else ->
        others
    end
    |> case do
      [] -> primary
      all -> [primary] ++ Enum.map(all, fn [name, email] -> {name, email} end)
    end
  end
end
