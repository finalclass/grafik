defmodule GrafikWeb.ProjectView do
  use GrafikWeb, :view

  def show_button(conn, project) do
    link project.name, to: Routes.project_path(conn, :show, project)
  end
  
  def new_button(conn) do
    link "Nowy projekt", to: Routes.project_path(conn, :new)
  end
  
  def list_button(conn) do
    link "Powrót do listy", to: Routes.project_path(conn, :index)
  end

  def edit_button(conn, project) do
    link "Edytuj", to: Routes.project_path(conn, :edit, project)
  end

  def delete_button(conn, project) do
    link "Usuń",
      to: Routes.project_path(conn, :delete, project),
      method: :delete,
      data: [confirm: "Na pewno usunąć \"" <> project.name <> "\"?"]
  end
end
