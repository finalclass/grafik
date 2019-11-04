defmodule GrafikWeb.ClientView do
  use GrafikWeb, :view

  def entity_name(client), do: client.name

  def show_client_button(conn, client) do
    link(client.name, to: Routes.client_path(conn, :show, client))
  end

  def new_client_button(conn) do
    new_button(Routes.client_path(conn, :new), "Dodaj klienta")
  end

  def list_clients_button(conn) do
    list_button(Routes.client_path(conn, :index))
  end

  def edit_client_button(conn, client) do
    edit_button(Routes.client_path(conn, :edit, client))
  end

  def delete_client_button(conn, client) do
    delete_button(Routes.client_path(conn, :delete, client), client.name)
  end
end
