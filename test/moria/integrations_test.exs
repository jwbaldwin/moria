defmodule Moria.IntegrationsTest do
  use Moria.DataCase

  alias Moria.Integrations
  alias Moria.Integrations.Integration
  alias Moria.Integrations.ShopifyCustomer
  alias Moria.Integrations.ShopifyOrder
  alias Moria.Integrations.ShopifyProduct

  describe "integrations" do
    @invalid_attrs %{access_token: nil, shop: nil, type: nil}

    test "list_integrations/0 returns all integrations" do
      user = insert(:user)
      integration = insert(:integration, user: user)
      assert [response_integration] = Integrations.list_integrations(user)
      assert response_integration.id == integration.id
      assert response_integration.user_id == user.id
    end

    test "get_integration!/1 returns the integration with given id" do
      integration = insert(:integration)
      assert Integrations.get_integration!(integration.id) == integration
    end

    test "create_integration/1 with valid data creates a integration" do
      user = insert(:user)

      valid_attrs = %{
        access_token: "some access_token",
        shop: "some shop",
        type: :shopify,
        user_id: user.id
      }

      assert {:ok, %Integration{} = integration} = Integrations.create_integration(valid_attrs)
      assert integration.access_token == "some access_token"
      assert integration.shop == "some shop"
      assert integration.type == :shopify
    end

    test "create_integration/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Integrations.create_integration(@invalid_attrs)
    end

    test "update_integration/2 with valid data updates the integration" do
      integration = insert(:integration)

      update_attrs = %{
        access_token: "some updated access_token",
        shop: "some updated shop",
        type: :shopify
      }

      assert {:ok, %Integration{} = integration} =
               Integrations.update_integration(integration, update_attrs)

      assert integration.access_token == "some updated access_token"
      assert integration.shop == "some updated shop"
      assert integration.type == :shopify
    end

    test "update_integration/2 with invalid data returns error changeset" do
      integration = insert(:integration)

      assert {:error, %Ecto.Changeset{}} =
               Integrations.update_integration(integration, @invalid_attrs)

      assert integration == Integrations.get_integration!(integration.id)
    end

    test "delete_integration/1 deletes the integration" do
      integration = insert(:integration)
      assert {:ok, %Integration{}} = Integrations.delete_integration(integration)
      assert_raise Ecto.NoResultsError, fn -> Integrations.get_integration!(integration.id) end
    end

    test "change_integration/1 returns a integration changeset" do
      integration = insert(:integration)
      assert %Ecto.Changeset{} = Integrations.change_integration(integration)
    end

    test "delete_shopify_data/1 deletes all related shopify data" do
      integration = insert(:integration)

      customer = insert(:shopify_customer, integration: integration)
      insert(:shopify_order, shopify_customer: customer, integration: integration)
      insert(:shopify_product, integration: integration)

      refute [] == Moria.Repo.all(ShopifyCustomer)
      refute [] == Moria.Repo.all(ShopifyOrder)
      refute [] == Moria.Repo.all(ShopifyProduct)

      assert {:ok, _} = Integrations.delete_shopify_data(integration)

      assert [] == Moria.Repo.all(ShopifyCustomer)
      assert [] == Moria.Repo.all(ShopifyOrder)
      assert [] == Moria.Repo.all(ShopifyProduct)
    end
  end
end
