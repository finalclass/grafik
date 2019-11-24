defmodule Grafik.Repo.Migrations.ProjectDescription do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :description, :string
    end
  end
end
