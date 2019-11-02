defmodule Grafik.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :client_id, references(:client)
    end
  end
end
