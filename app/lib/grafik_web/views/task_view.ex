defmodule GrafikWeb.TaskView do
  use GrafikWeb, :view

  def show_task_button(conn, task) do
    link task.name, to: Routes.task_path(conn, :show, task)
  end
  
  def new_task_button(conn) do
    new_button Routes.task_path(conn, :new), "Dodaj zadanie"
  end
  
  def list_tasks_button(conn) do
    list_button Routes.task_path(conn, :index)
  end

  def edit_task_button(conn, task) do
    edit_button Routes.task_path(conn, :edit, task)
  end

  def delete_task_button(conn, task) do
    delete_button Routes.task_path(conn, :delete, task), task.name
  end

  def task_status_to_human(status) do
    Grafik.Projects.list_statuses()
    |> Enum.find(nil, fn s -> s.id == status end)
    |> Map.get(:name)
  end

  def task_statuses_select_options() do
    Grafik.Projects.list_statuses() |> Enum.map(fn status -> {status.name, status.id} end)
  end
end
