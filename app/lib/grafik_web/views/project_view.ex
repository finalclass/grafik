defmodule GrafikWeb.ProjectView do
  use GrafikWeb, :view

  def show_button(conn, project) do
    link project.name, to: Routes.project_path(conn, :show, project)
  end
  
  def new_button(conn) do
    ~e"""
    <a href="<%= Routes.project_path(conn, :new) %>"
       class="button">
        <i class="icon icon-plus"></i>
        Nowy projekt
    </a>
    """
  end
  
  def list_button(conn) do
    ~e"""
    <a href="<%= Routes.project_path(conn, :index) %>"
       class="button">
        <i class="icon icon-laquo"></i>
        Lista
    </a>
    """
  end

  def edit_button(conn, project) do
    ~e"""
    <a href="<%= Routes.project_path(conn, :edit, project) %>"
       class="button">
        <i class="icon icon-recycle"></i>
        Edytuj
    </a>
    """
  end

  def delete_button(conn, project) do
    link "Usuń",
      to: Routes.project_path(conn, :delete, project),
      method: :delete,
      data: [confirm: "Na pewno usunąć \"" <> project.name <> "\"?"]
  end

  def add_task(conn, project) do
    ~e"""
    <a href="<%= Routes.task_path(conn, :add_to_project, project) %>"
       class="button">
        <i class="icon icon-plus"></i>
        Nowe zadanie
    </a>
    """
  end
end
