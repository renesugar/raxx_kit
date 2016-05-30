defmodule HtmlView do
  @escapes [
    {?<, "&lt;"},
    {?>, "&gt;"},
    {?&, "&amp;"},
    {?", "&quot;"},
    {?', "&#39;"}
  ]

  Enum.each @escapes, fn { match, insert } ->
    defp escape_char(unquote(match)), do: unquote(insert)
  end

  defp escape_char(char), do: << char >>

  def escape(buffer) do
    IO.iodata_to_binary(for <<char <- buffer>>, do: escape_char(char))
  end

  defmacro __using__(opts) do
    quote do
      require EEx
      opts = case unquote(opts) do
        list when is_list(list) -> Enum.into(list, %{})
        opts -> opts
      end

      template_file = String.replace_suffix(Map.get(opts, :template_file, __ENV__.file), ".ex", ".html.eex")
      EEx.function_from_file :defp, :render_template, template_file, [:assigns]

      def html(assigns \\ %{}) do
        assigns
        |> Enum.map(&escape_assigned_values/1)
        # |> Enum.into(%{})
        |> render_template
      end

      defp escape_assigned_values({key, value}) do
        {key, HtmlView.escape(value)}
      end
    end
  end

end