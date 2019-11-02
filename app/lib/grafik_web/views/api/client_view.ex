defmodule GrafikWeb.Api.ClientView do
  use GrafikWeb, :view

  def render("client.json", %{client: client}) do
    %{
      id: client.id,
      name: client.name
    }
  end
     
end
