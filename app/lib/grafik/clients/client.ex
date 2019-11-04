defmodule Grafik.Clients.Client do
  use Ecto.Schema
  import Ecto.Changeset

  schema "clients" do
    field :name, :string
    
    field :invoice_name, :string
    field :invoice_street, :string
    field :invoice_postcode, :string
    field :invoice_city, :string
    field :invoice_nip, :string

    field :delivery_name, :string
    field :delivery_street, :string
    field :delivery_postcode, :string
    field :delivery_city, :string
    field :delivery_contact_person, :string
    field :phone_number, :string
    field :email, :string
    
    has_many :projects, Grafik.Projects.Project

    timestamps()
  end

  @doc false
  def changeset(client, attrs) do
    client
    |> cast(attrs, [
          :name,
          :invoice_name,
          :invoice_street,
          :invoice_postcode,
          :invoice_city,
          :invoice_nip,
          :delivery_name,
          :delivery_street,
          :delivery_postcode,
          :delivery_city,
          :delivery_contact_person,
          :phone_number,
          :email,
        ])
    |> validate_required([:name])
  end
end
