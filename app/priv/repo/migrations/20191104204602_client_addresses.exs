defmodule Grafik.Repo.Migrations.ClientAddresses do
  use Ecto.Migration

  def change do
    alter table(:clients) do
      remove :wfirma_id
      add :invoice_name, :string
      add :invoice_street, :string
      add :invoice_postcode, :string
      add :invoice_city, :string
      add :invoice_nip, :string
      
      add :delivery_name, :string
      add :delivery_street, :string
      add :delivery_postcode, :string
      add :delivery_city, :string
      add :delivery_contact_person, :string
      add :phone_number, :string
      add :email, :string
    end
  end
end
