defmodule Grafik.Repo.Migrations.ProductRemoveDescription do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      remove :description
    end
  end
end
