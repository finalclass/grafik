defmodule GrafikWeb.TaskView do
  use GrafikWeb, :view

  def show_button(conn, task) do
    link task.name, to: Routes.task_path(conn, :show, task)
  end
  
  def new_button(conn) do
    link "Nowe zadanie", to: Routes.task_path(conn, :new)
  end
  
  def list_button(conn) do
    link "Powrót do listy", to: Routes.task_path(conn, :index)
  end

  def edit_button(conn, task) do
    link "Edytuj", to: Routes.task_path(conn, :edit, task)
  end

  def delete_button(conn, task) do
    link "Usuń",
      to: Routes.task_path(conn, :delete, task),
      method: :delete,
      data: [confirm: "Na pewno usunąć \"" <> task.name <> "\"?"]
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
