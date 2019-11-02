defmodule GrafikWeb.ClientView do
  use GrafikWeb, :view

  def show_button(conn, client) do
    link client.name, to: Routes.client_path(conn, :show, client)
  end
  
  def new_button(conn) do
    link "Nowy klient", to: Routes.client_path(conn, :new)
  end
  
  def list_button(conn) do
    link "Powrót do listy", to: Routes.client_path(conn, :index)
  end

  def edit_button(conn, client) do
    link "Edytuj", to: Routes.client_path(conn, :edit, client)
  end

  def delete_button(conn, client) do
    link "Usuń",
      to: Routes.client_path(conn, :delete, client),
      method: :delete,
      data: [confirm: "Na pewno usunąć \"" <> client.name <> "\"?"]
  end
end
