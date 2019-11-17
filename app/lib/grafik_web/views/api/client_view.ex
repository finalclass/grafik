defmodule GrafikWeb.Api.ClientView do
  use GrafikWeb, :view

  def render("client.json", %{client: client}) do
    %{
      id: client.id,
      name: client.name,
      invoice_name: client.invoice_name,
      invoice_street: client.invoice_street,
      invoice_postcode: client.invoice_postcode,
      invoice_city: client.invoice_city,
      invoice_nip: client.invoice_nip,
      delivery_name: client.delivery_name,
      delivery_street: client.delivery_street,
      delivery_postcode: client.delivery_postcode,
      delivery_city: client.delivery_city,
      delivery_contact_person: client.delivery_contact_person,
      phone_number: client.phone_number,
      email: client.email
    }
  end
end
