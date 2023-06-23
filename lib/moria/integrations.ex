defmodule Moria.Integrations do
  @moduledoc """
  The Integrations context.
  """

  import Ecto.Query, warn: false
  alias Moria.Repo

  alias Moria.Integrations.Integration
  alias Moria.Integrations.ShopifyCustomer
  alias Moria.Integrations.ShopifyOrder
  alias Moria.Integrations.ShopifyProduct

  @doc """
  Returns the list of integrations.

  ## Examples

      iex> list_integrations()
      [%Integration{}, ...]

  """
  def list_integrations(user) do
    Integration
    |> where(user_id: ^user.id)
    |> Repo.all()
  end

  @doc """
  Gets a single integration.

  Raises `Ecto.NoResultsError` if the Integration does not exist.
  """
  def get_integration!(id) do
    Integration
    |> Repo.get!(id)
    |> Repo.preload(:user)
  end

  @doc """
  Gets a single integration by the shop name
  """
  def get_by_shop(shop) do
    Integration
    |> Repo.get_by(shop: shop)
    |> Repo.normalize_one_result()
  end

  @doc """
  Gets a single integration by user id
  """
  def get_by_user(user) do
    Integration
    |> Repo.get_by(user_id: user.id)
    |> Repo.normalize_one_result()
  end

  @doc """
  Creates a integration.

  ## Examples

      iex> create_integration(type, %{field: value})
      {:ok, %Integration{}}

      iex> create_integration(type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_integration(attrs \\ %{}) do
    %Integration{}
    |> Integration.changeset(attrs)
    |> Repo.insert()
  end

  def upsert_integration(attrs \\ %{}) do
    %Integration{}
    |> Integration.changeset(attrs)
    |> Repo.insert(
      on_conflict: [set: [access_token: attrs.access_token]],
      conflict_target: :shop
    )
  end

  @doc """
  Updates a integration.

  ## Examples

      iex> update_integration(integration, %{field: new_value})
      {:ok, %Integration{}}

      iex> update_integration(integration, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_integration(%Integration{} = integration, attrs) do
    integration
    |> Integration.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a integration.

  ## Examples

      iex> delete_integration(integration)
      {:ok, %Integration{}}

      iex> delete_integration(integration)
      {:error, %Ecto.Changeset{}}

  """
  def delete_integration(%Integration{} = integration) do
    Repo.delete(integration)
  end

  def delete_shopify_data(%Integration{} = integration) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(
      :delete_all_products,
      from(sp in ShopifyProduct, where: sp.integration_id == ^integration.id)
    )
    |> Ecto.Multi.delete_all(
      :delete_all_customers,
      from(sc in ShopifyCustomer, where: sc.integration_id == ^integration.id)
    )
    |> Ecto.Multi.delete_all(
      :delete_all_orders,
      from(so in ShopifyOrder, where: so.integration_id == ^integration.id)
    )
    |> Repo.transaction()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking integration changes.

  ## Examples

      iex> change_integration(integration)
      %Ecto.Changeset{data: %Integration{}}

  """
  def change_integration(%Integration{} = integration, attrs \\ %{}) do
    Integration.changeset(integration, attrs)
  end

  @spec bulk_insert_resource(
          ShopifyCustomer.t() | ShopifyOrder.t() | ShopifyProduct.t(),
          List.t(),
          integer()
        ) :: :ok
  def bulk_insert_resource(resource_type, list_of_resources, integration_id) do
    batch_size = get_batch_size(list_of_resources)

    list_of_resources
    |> Enum.map(fn resource -> build_shopify_resource(resource_type, resource, integration_id) end)
    |> Enum.chunk_every(batch_size)
    |> Task.async_stream(fn chunk_of_resources ->
      Moria.Repo.insert_all(resource_type, chunk_of_resources,
        on_conflict: {:replace_all_except, [:shopify_id]},
        conflict_target: [:shopify_id]
      )
    end)
    |> Enum.to_list()
    |> case do
      [ok: _] -> :ok
      error -> {:error, error}
    end
  end

  @default 65_535
  defp get_batch_size(nil), do: @default

  defp get_batch_size([resource | _rest]) do
    div(@default, length(Map.keys(resource)))
  end

  defp build_shopify_resource(ShopifyProduct, product, integration_id) do
    now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    %{
      shopify_id: product["id"],
      shopify_created_at: iso8601(product["created_at"]),
      shopify_updated_at: iso8601(product["updated_at"]),
      title: product["title"],
      status: product["status"],
      body_html: product["body_html"],
      handle: product["handle"],
      options: product["options"],
      product_type: product["product_type"],
      published_at: iso8601(product["published_at"]),
      vendor: product["vendor"],
      integration_id: integration_id,
      inserted_at: now,
      updated_at: now
    }
  end

  defp build_shopify_resource(ShopifyCustomer, customer, integration_id) do
    now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    %{
      shopify_id: customer["id"],
      shopify_created_at: iso8601(customer["created_at"]),
      shopify_updated_at: iso8601(customer["updated_at"]),
      first_name: customer["first_name"],
      last_name: customer["last_name"],
      email: customer["email"],
      email_marketing_consent: customer["email_marketing_consent"],
      verified_email: customer["verified_email"],
      phone: customer["phone"],
      sms_marketing_consent: customer["sms_marketing_consent"],
      total_spent: Decimal.new(customer["total_spent"]),
      integration_id: integration_id,
      inserted_at: now,
      updated_at: now
    }
  end

  defp build_shopify_resource(ShopifyOrder, order, integration_id) do
    now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    %{
      shopify_id: order["id"],
      shopify_created_at: iso8601(order["created_at"]),
      shopify_updated_at: iso8601(order["updated_at"]),
      shopify_customer_id: order["customer"]["id"],
      email: order["email"],
      line_items: order["line_items"],
      name: order["name"],
      number: order["number"],
      order_number: order["order_number"],
      processed_at: iso8601(order["processed_at"]),
      source_url: order["source_url"],
      total_price: Decimal.new(order["total_price"]),
      integration_id: integration_id,
      inserted_at: now,
      updated_at: now
    }
  end

  defp iso8601(nil), do: nil

  defp iso8601(datetime) do
    {:ok, datetime, _} = DateTime.from_iso8601(datetime)
    datetime
  end

  def list_all_orders(integration_id) do
    from(orders in ShopifyOrder,
      where: orders.integration_id == ^integration_id
    )
    |> Repo.all()
  end

  def list_all_products(integration_id) do
    from(products in ShopifyProduct,
      where: products.integration_id == ^integration_id
    )
    |> Repo.all()
  end

  def list_all_customers(integration_id) do
    from(customer in ShopifyCustomer,
      where: customer.integration_id == ^integration_id
    )
    |> Repo.all()
  end
end
