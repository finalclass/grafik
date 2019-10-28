defmodule Grafik.Repo.Migrations.CreateWorkers do
  use Ecto.Migration

  def change do
    create table(:workers) do
      add :name, :string

      timestamps()
    end

  end
end
