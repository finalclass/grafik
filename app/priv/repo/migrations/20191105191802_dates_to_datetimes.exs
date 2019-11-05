defmodule Grafik.Repo.Migrations.ClientAddresses do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      modify :start_at, :utc_datetime
    end

    alter table(:tasks) do
      modify :sent_at, :utc_datetime
    end
  end
  
end
