defmodule Moria.Integrations do
  @moduledoc """
  The ShopifyShops context.
  """

  import Ecto.Query, warn: false
  alias Moria.Repo

  alias Moria.ShopifyShops.ShopifyShop
  alias Moria.ShopifyShops.ShopifyCustomer
  alias Moria.ShopifyShops.ShopifyOrder
  alias Moria.ShopifyShops.ShopifyProduct

  @doc """
  Gets a single shop.

  Raises `Ecto.NoResultsError` if the ShopifyShop does not exist.
  """
  def get_shop!(id) do
    ShopifyShop
    |> Repo.get!(id)
  end

  @doc """
  Gets a single shop by the shop name
  """
  def get_by_url(url) do
    ShopifyShop
    |> Repo.get_by(url: url)
    |> Repo.normalize_one_result()
  end

  @doc """
  Creates a shop.

  ## Examples

      iex> create_shop(type, %{field: value})
      {:ok, %ShopifyShop{}}

      iex> create_shop(type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shop(attrs \\ %{}) do
    %ShopifyShop{}
    |> ShopifyShop.changeset(attrs)
    |> Repo.insert()
  end

  def upsert_shop(attrs \\ %{}) do
    %ShopifyShop{}
    |> ShopifyShop.changeset(attrs)
    |> Repo.insert(
      on_conflict: [set: [access_token: attrs.access_token]],
      conflict_target: :shop
    )
  end

  @doc """
  Updates a shop.

  ## Examples

      iex> update_shop(shop, %{field: new_value})
      {:ok, %ShopifyShop{}}

      iex> update_shop(shop, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_shop(%ShopifyShop{} = shop, attrs) do
    shop
    |> ShopifyShop.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a shop.

  ## Examples

      iex> delete_shop(shop)
      {:ok, %ShopifyShop{}}

      iex> delete_shop(shop)
      {:error, %Ecto.Changeset{}}

  """
  def delete_shop(%ShopifyShop{} = shop) do
    Repo.delete(shop)
  end

  def delete_shopify_data(%ShopifyShop{} = shop) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(
      :delete_all_products,
      from(sp in ShopifyProduct, where: sp.shop_id == ^shop.id)
    )
    |> Ecto.Multi.delete_all(
      :delete_all_customers,
      from(sc in ShopifyCustomer, where: sc.shop_id == ^shop.id)
    )
    |> Ecto.Multi.delete_all(
      :delete_all_orders,
      from(so in ShopifyOrder, where: so.shop_id == ^shop.id)
    )
    |> Repo.transaction()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking shop changes.

  ## Examples

      iex> change_shop(shop)
      %Ecto.Changeset{data: %ShopifyShop{}}

  """
  def change_shop(%ShopifyShop{} = shop, attrs \\ %{}) do
    ShopifyShop.changeset(shop, attrs)
  end

  @spec bulk_insert_resource(
          ShopifyCustomer.t() | ShopifyOrder.t() | ShopifyProduct.t(),
          List.t(),
          integer()
        ) :: :ok
  def bulk_insert_resource(resource_type, list_of_resources, shop_id) do
    batch_size = get_batch_size(list_of_resources)

    list_of_resources
    |> Enum.map(fn resource -> build_shopify_resource(resource_type, resource, shop_id) end)
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

  defp build_shopify_resource(ShopifyProduct, product, shop_id) do
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
      shop_id: shop_id,
      inserted_at: now,
      updated_at: now
    }
  end

  defp build_shopify_resource(ShopifyCustomer, customer, shop_id) do
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
      shop_id: shop_id,
      inserted_at: now,
      updated_at: now
    }
  end

  defp build_shopify_resource(ShopifyOrder, order, shop_id) do
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
      shop_id: shop_id,
      inserted_at: now,
      updated_at: now
    }
  end

  defp iso8601(nil), do: nil

  defp iso8601(datetime) do
    {:ok, datetime, _} = DateTime.from_iso8601(datetime)
    datetime
  end

  def list_all_orders(shop_id) do
    from(orders in ShopifyOrder,
      where: orders.shop_id == ^shop_id
    )
    |> Repo.all()
  end

  def list_all_products(shop_id) do
    from(products in ShopifyProduct,
      where: products.shop_id == ^shop_id
    )
    |> Repo.all()
  end

  def list_all_customers(shop_id) do
    from(customer in ShopifyCustomer,
      where: customer.shop_id == ^shop_id
    )
    |> Repo.all()
  end
end
