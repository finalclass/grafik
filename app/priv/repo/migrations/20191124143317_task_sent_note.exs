defmodule Grafik.Repo.Migrations.TaskSentNote do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      remove :sent_at
      add :sent_note, :string
    end
  end
end
