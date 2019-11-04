defmodule GrafikWeb.ClientView do
  use GrafikWeb, :view

  def show_button(conn, client) do
    link client.name, to: Routes.client_path(conn, :show, client)
  end
  
  def new_button(conn) do
    ~e"""
    <a href="<%= Routes.client_path(conn, :new) %>"
       class="button">
        <i class="icon icon-plus"></i>
        Nowy klient
    </a>
    """
  end
  
  def list_button(conn) do
    ~e"""
    <a href="<%= Routes.client_path(conn, :index) %>"
       class="button">
        <i class="icon icon-laquo"></i>
        Lista
    </a>
    """
  end

  def edit_button(conn, client) do
    ~e"""
    <a href="<%= Routes.client_path(conn, :edit, client) %>"
       class="button">
        <i class="icon icon-recycle"></i>
        Edytuj
    </a>
    """
  end

  def delete_button(conn, client) do
    link "Usuń",
      to: Routes.client_path(conn, :delete, client),
      method: :delete,
      data: [confirm: "Na pewno usunąć \"" <> client.name <> "\"?"]
  end

end
