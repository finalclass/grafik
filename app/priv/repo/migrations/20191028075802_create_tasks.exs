defmodule Grafik.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :name, :string
      add :status, :string
      add :description, :text
      add :project_id, references(:projects)
      add :worker_id, references(:workers)

      timestamps()
    end

  end
end
