defmodule GrafikWeb.ProjectView do
  use GrafikWeb, :view

  def show_project_button(conn, project) do
    link(project.name, to: Routes.project_path(conn, :show, project))
  end

  def new_project_button(conn) do
    new_button(Routes.project_path(conn, :new), "Dodaj projekt")
  end

  def list_projects_button(conn) do
    list_button(Routes.client_path(conn, :index))
  end

  def edit_project_button(conn, project) do
    edit_button(Routes.project_path(conn, :edit, project))
  end

  def delete_project_button(conn, project) do
    delete_button(Routes.project_path(conn, :delete, project), project.name)
  end

  def add_project_task(conn, project) do
    new_button(Routes.task_path(conn, :add_to_project, project), "Dodaj zadanie")
  end
end
