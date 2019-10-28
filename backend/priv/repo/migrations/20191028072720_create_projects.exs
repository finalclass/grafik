defmodule Grafik.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string
      add :deadline, :date

      timestamps()
    end

  end
end
