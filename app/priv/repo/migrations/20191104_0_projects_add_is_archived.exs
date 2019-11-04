defmodule Grafik.Repo.Migrations.ProjectsAddIsArchived do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :is_archived, :boolean
    end
  end
end
