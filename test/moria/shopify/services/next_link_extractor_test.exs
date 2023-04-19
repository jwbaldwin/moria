defmodule Moria.Shopify.Services.NextLinkExtractorTest do
  use ExUnit.Case, async: true

  alias Moria.Shopify.Services.NextLinkExtractor

  test "extracts the next link given just a next link" do
    link_header = [
      {"link", "<next_link>; rel=\"next\""}
    ]

    assert "next_link" == NextLinkExtractor.call(link_header)
  end

  test "extracts the next link given both a next and prev link header" do
    link_header = [
      {"link", "<previous_link>; rel=\"previous\", <next_link>; rel=\"next\""}
    ]

    assert "next_link" == NextLinkExtractor.call(link_header)
  end

  test "returns nil if there is no next link in the header" do
    link_header = [
      {"link", "<previous_link>; rel=\"previous\""}
    ]

    assert nil == NextLinkExtractor.call(link_header)
  end
end
