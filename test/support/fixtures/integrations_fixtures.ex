defmodule Moria.IntegrationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Moria.Integrations` context.
  """

  @doc """
  Generate a integration.
  """
  def integration_fixture(attrs \\ %{}) do
    {:ok, integration} =
      attrs
      |> Enum.into(%{
        access_token: "some access_token",
        store: "some store",
        type: "some type"
      })
      |> Moria.Integrations.create_integration()

    integration
  end
end
