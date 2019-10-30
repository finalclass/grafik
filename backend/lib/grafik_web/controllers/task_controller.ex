defmodule GrafikWeb.TaskController do
  use GrafikWeb, :controller

  alias Grafik.Projects
  alias Grafik.Projects.Task

  def index(conn, _params) do
    tasks = Projects.list_tasks()
    render(conn, "index.html", tasks: tasks)
  end

  def new(conn, _params) do
    changeset = Projects.change_task(%Task{})
    conn
    |> init_workers()
    |> init_projects()
    |> render("new.html", changeset: changeset)
  end

  def create(conn, %{"task" => task_params}) do
    case Projects.create_task(task_params) do
      {:ok, task} ->
        conn
        |> put_flash(:info, "Utworzony nowe zadanie.")
        |> redirect(to: Routes.task_path(conn, :show, task))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> init_workers()
        |> init_projects()
        |> render("new.html", changeset: changeset)
    end
  end

  defp init_projects(conn) do
    projects = Grafik.Projects.list_projects() |> Enum.map(&{&1.name, &1.id})
    conn |> assign(:projects, projects)
  end
  
  defp init_workers(conn) do
    workers = Grafik.Workers.list_workers() |> Enum.map(&{&1.name, &1.id})
    conn |> assign(:workers, workers)
  end
  
  def show(conn, %{"id" => id}) do
    task = Projects.get_task!(id)
    render(conn, "show.html", task: task)
  end

  def edit(conn, %{"id" => id}) do
    task = Projects.get_task!(id)
    changeset = Projects.change_task(task)
    conn
    |> init_workers()
    |> init_projects()
    |> render("edit.html", task: task, changeset: changeset)
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    task = Projects.get_task!(id)

    case Projects.update_task(task, task_params) do
      {:ok, task} ->
        conn
        |> put_flash(:info, "Zmodyfikowano zadanie.")
        |> redirect(to: Routes.task_path(conn, :show, task))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> init_workers()
        |> init_projects()
        |> render("edit.html", task: task, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    task = Projects.get_task!(id)
    {:ok, _task} = Projects.delete_task(task)

    conn
    |> put_flash(:info, "Zadanie zostało usunięte.")
    |> redirect(to: Routes.task_path(conn, :index))
  end
end
