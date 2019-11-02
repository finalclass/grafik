defmodule Grafik.Repo.Migrations.CreateClient do
  use Ecto.Migration

  def change do
    create table(:clients) do
      add :name, :string
      add :wrifma_id, :string

      timestamps()
    end

  end
end
