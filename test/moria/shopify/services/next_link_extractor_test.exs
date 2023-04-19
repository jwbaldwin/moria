defmodule Moria.Shopify.Services.NextLinkExtractorTest do
  use ExUnit.Case, async: true

  alias Moria.Shopify.Services.NextLinkExtractor

  test "extracts the next link given both a next and prev link header" do
    link_header = [
      {"link",
       "<https://kept-good-company.myshopify.com/admin/api/2023-04/customers.json?limit=1&fields=created_at%2Cemail%2Cemail_marketing_consent%2Cfirst_name%2Cid%2Clast_name%2Cphone%2Csms_marketing_consent%2Ctotal_spent%2Cupdated_at%2Cverified_email&page_info=eyJkaXJlY3Rpb24iOiJwcmV2IiwibGFzdF9pZCI6NjkzOTI3NzI2MzEyMiwibGFzdF92YWx1ZSI6MTY4MDIyNzg5NzAwMH0>; rel=\"previous\", <https://kept-good-company.myshopify.com/admin/api/2023-04/customers.json?limit=1&fields=created_at%2Cemail%2Cemail_marketing_consent%2Cfirst_name%2Cid%2Clast_name%2Cphone%2Csms_marketing_consent%2Ctotal_spent%2Cupdated_at%2Cverified_email&page_info=eyJkaXJlY3Rpb24iOiJuZXh0IiwibGFzdF9pZCI6NjkzOTI3NzI2MzEyMiwibGFzdF92YWx1ZSI6MTY4MDIyNzg5NzAwMH0>; rel=\"next\""}
    ]

    assert "https://kept-good-company.myshopify.com/admin/api/2023-04/customers.json?limit=1&fields=created_at%2Cemail%2Cemail_marketing_consent%2Cfirst_name%2Cid%2Clast_name%2Cphone%2Csms_marketing_consent%2Ctotal_spent%2Cupdated_at%2Cverified_email&page_info=eyJkaXJlY3Rpb24iOiJuZXh0IiwibGFzdF9pZCI6NjkzOTI3NzI2MzEyMiwibGFzdF92YWx1ZSI6MTY4MDIyNzg5NzAwMH0" ==
             NextLinkExtractor.call(link_header)
  end
end
