defmodule Grafik.Repo.Migrations.ProjectDetails do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :invoice_number, :string
      add :price, :float
      add :paid, :float
      add :start_at, :date
      add :is_deadline_rigid, :boolean
    end
  end
end
