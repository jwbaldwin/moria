defmodule Moria.Money do

  @spec format(Decimal.t()) :: String.t()
  def format(amount) do
    Money.to_string(Money.parse!(amount, :USD))
  end
end
