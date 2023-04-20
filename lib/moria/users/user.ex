defmodule Moria.Users.User do
  use Ecto.Schema
  use Pow.Ecto.Schema
  use Ecto.Schema

  use Pow.Extension.Ecto.Schema,
    extensions: [PowResetPassword, PowEmailConfirmation]

  schema "users" do
    pow_user_fields()
    # :email 
    # :password_hash
    # :current_password (virtual)
    # :password (virtual)

    field :name, :string

    timestamps()
  end

  def changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> pow_changeset(attrs)
    |> Ecto.Changeset.cast(attrs, [:name])
    |> Ecto.Changeset.validate_required([:name])
  end
end
