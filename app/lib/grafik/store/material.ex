defmodule Grafik.Store.Material do
  use Ecto.Schema

  schema "material" do
    field :name, :string
    field :price, :integer # w groszach

    timestamps()

    many_to_many :products, Grafik.Store.Product, join_through: "product_material"
  end

end
