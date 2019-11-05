defmodule Grafik.Repo.Migrations.ClientAddresses do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :sent_at, :date
    end
  end
  
end
