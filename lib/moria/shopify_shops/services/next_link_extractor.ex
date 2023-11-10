defmodule Moria.Shopify.Services.NextLinkExtractor do
  @moduledoc """
  Extract the next link from the headers or return :error
  """

  @spec call(List.t()) :: {:ok, String.t()} | nil
  def call(headers) do
    case List.keyfind(headers, "link", 0) do
      {"link", link} ->
        links = String.split(link, ",")

        Enum.find_value(links, fn link ->
          case String.contains?(link, "rel=\"next\"") do
            true -> extract_link(link)
            false -> nil
          end
        end)

      nil ->
        nil
    end
  end

  def extract_link(link) do
    [next_link | _] = String.split(link, ">")

    next_link
    |> String.trim()
    |> String.slice(1..-1)
  end
end
