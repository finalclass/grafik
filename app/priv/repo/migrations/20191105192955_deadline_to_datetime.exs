defmodule Grafik.Repo.Migrations.DeadlineToDatetime do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      modify :deadline, :utc_datetime
    end
  end
end
