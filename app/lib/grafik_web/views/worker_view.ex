defmodule GrafikWeb.WorkerView do
  use GrafikWeb, :view

  def show_button(conn, worker) do
    link worker.name, to: Routes.worker_path(conn, :show, worker)
  end
  
  def new_button(conn) do
    link "Nowy pracownik", to: Routes.worker_path(conn, :new)
  end
  
  def list_button(conn) do
    link "Powrót do listy", to: Routes.worker_path(conn, :index)
  end

  def edit_button(conn, worker) do
    link "Edytuj", to: Routes.worker_path(conn, :edit, worker)
  end

  def delete_button(conn, worker) do
    link "Usuń",
      to: Routes.worker_path(conn, :delete, worker),
      method: :delete,
      data: [confirm: "Na pewno usunąć \"" <> worker.name <> "\"?"]
  end
end
