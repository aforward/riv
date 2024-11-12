defmodule Kore.Pdf do
  def p(nil, path), do: path
  def p(uri, path), do: Phoenix.VerifiedRoutes.unverified_url(uri, path)

  def assign(%Phoenix.LiveView.Socket{} = socket, k, v) do
    Phoenix.Component.assign(socket, k, v)
  end

  def assign(%Plug.Conn{} = conn, k, v) do
    Plug.Conn.assign(conn, k, v)
  end

  @doc """
  This is based on chromic_pdf
  https://github.com/bitcrowd/chromic_pdf

  It needs an application, so add to your children before you can call it.

      # lib/my_app/application.ex
      def MyApp.Application do
        def start(_type, _args) do
          children = [
            # other apps...
            ChromicPDF
          ]

          Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
        end
      end

  This generated a PDF based on the provided content.
  """
  def generate(content) do
    [
      content: content,
      print_to_pdf: %{
        marginTop: 0,
        marginLeft: 0,
        marginRight: 0,
        marginBottom: 0,
        printBackground: true
      }
    ]
    |> ChromicPDF.Template.source_and_options()
    |> ChromicPDF.print_to_pdf()
  end

  @doc """
  This is based on chromic_pdf
  https://github.com/bitcrowd/chromic_pdf

  It needs an application, so add to your children before you can call it.

      # lib/my_app/application.ex
      def MyApp.Application do
        def start(_type, _args) do
          children = [
            # other apps...
            ChromicPDF
          ]

          Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
        end
      end

  This call saves the URL to the provided filename.
  """
  def save(url, filename) do
    ChromicPDF.print_to_pdf(
      {:url, url},
      output: filename,
      print_to_pdf: %{
        marginTop: 0,
        marginLeft: 0,
        marginRight: 0,
        marginBottom: 0,
        printBackground: true
      }
    )
  end

  def send_document({name, content}, conn, params) do
    case params["debug"] do
      "on" -> html_reply(name, content, conn)
      _else -> pdf_reply(name, content, conn)
    end
  end

  defp pdf_reply(name, content, conn) do
    content
    |> Phoenix.HTML.Safe.to_iodata()
    |> generate()
    |> then(fn {:ok, pdf} ->
      Phoenix.Controller.send_download(
        conn,
        {:binary, Base.decode64!(pdf)},
        content_type: "application/pdf",
        filename: "#{name}.pdf"
      )
    end)
  end

  defp html_reply(name, content, conn) do
    content
    |> Phoenix.HTML.Safe.to_iodata()
    |> then(fn content ->
      Phoenix.Controller.send_download(
        conn,
        {:binary, content},
        content_type: "text/html",
        filename: "#{name}.html"
      )
    end)
  end
end
