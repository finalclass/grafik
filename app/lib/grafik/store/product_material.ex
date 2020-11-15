defmodule Grafik.Store.ProductMaterial do
  use Ecto.Schema

  @primary_key false
  schema "product_material" do
    belongs_to :product, Grafik.Store.Product
    belongs_to :material, Grafik.Store.Material
    field :quantity, :integer

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, [:product_id, :material_id, :quantity])
    |> Ecto.Changeset.validate_required([:product_id, :material_id, :quantity])
  end
  
end
