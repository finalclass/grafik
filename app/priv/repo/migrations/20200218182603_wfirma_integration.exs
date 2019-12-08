defmodule Grafik.Repo.Migrations.WfirmaIntegration do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :price, :string
      add :wfirma_invoicecontent_id, :integer
    end
    alter table(:clients) do
      add :wfirma_contractor_id, :integer
    end
  end
end
