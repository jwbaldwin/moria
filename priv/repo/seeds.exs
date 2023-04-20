# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Moria.Repo.insert!(%Moria.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Moria.Users.create(%{
  email: "nolan@kept.com",
  name: "Nolan Chase",
  password: "password123",
  password_confirmation: "password123"
})

Moria.Users.create(%{
  email: "james@kept.com",
  name: "James Baldwin",
  password: "password123",
  password_confirmation: "password123"
})
