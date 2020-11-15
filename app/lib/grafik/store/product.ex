defmodule Grafik.Store.Product do
  use Ecto.Schema

  schema "product" do
    field :name, :string
    field :fixed_price, :integer # w groszach
    field :wfirma_id, :integer
    
    timestamps()

    many_to_many :materials, Grafik.Store.Material, join_through: "product_material"
  end

end
