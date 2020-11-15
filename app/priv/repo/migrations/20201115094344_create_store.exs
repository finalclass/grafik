defmodule Grafik.Repo.Migrations.Store do
  use Ecto.Migration

  def change do
    create table(:product) do
      add :name, :string
      add :fixed_price, :integer # in cents (grosze)
      add :wfirma_id, :integer

      timestamps()
    end

    create table(:material) do
      add :name, :string
      add :price, :integer # in cents (grosze)

      timestamps()
    end

    create table(:product_material) do
      add :product_id, references(:product, on_delete: :delete_all)
      add :material_id, references(:material, on_delete: :delete_all)
      add :quantity, :integer
      
      timestamps()
    end

    create index("product_material", [:product_id])
  end
end
