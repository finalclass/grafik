defmodule GrafikWeb.TaskController do
  use GrafikWeb, :controller

  alias Grafik.Projects
  alias Grafik.Projects.Task

  def index(conn, _params) do
    tasks = Projects.list_tasks()
    render(conn, "index.html", tasks: tasks)
  end

  def new(conn, _params) do
    conn
    |> assign(:changeset, Projects.change_task(%Task{}))
    |> render_new_page()
  end

  def add_task_to_project(conn, %{"id" => id}) do
    conn
    |> assign(:changeset, Projects.change_task(%Task{project_id: id}))
    |> assign(:project, Projects.get_project!(id))
    |> render_new_page()
  end

  defp render_new_page(conn) do
    conn
    |> init_workers()
    |> init_projects()
    |> render("new.html")
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
    project = Projects.get_project!(task.project_id)
    render(conn, "show.html", task: task, project: project)
  end

  def edit(conn, %{"id" => id}) do
    task = Projects.get_task!(id)
    project = Projects.get_project!(task.project_id)
    changeset = Projects.change_task(task)

    conn
    |> init_workers()
    |> init_projects()
    |> assign(:project, project) 
    |> render("edit.html", task: task, changeset: changeset)
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    task = Projects.get_task!(id)
    project = Projects.get_project!(task.project_id)

    case Projects.update_task(task, task_params) do
      {:ok, task} ->
        conn
        |> put_flash(:info, "Zmodyfikowano zadanie.")
        |> redirect(to: Routes.task_path(conn, :show, task))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> init_workers()
        |> init_projects()
        |> assign(:project, project)
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
