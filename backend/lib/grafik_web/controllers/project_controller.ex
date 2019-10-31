defmodule GrafikWeb.ProjectController do
  use GrafikWeb, :controller

  alias Grafik.Projects
  alias Grafik.Projects.Project
  alias Grafik.Clients

  def index(conn, _params) do
    projects = Projects.list_projects()
    render(conn, "index.html", projects: projects)
  end

  def new(conn, _params) do
    changeset = Projects.change_project(%Project{})

    conn
    |> assign_clients()
    |> render("new.html", changeset: changeset)
  end

  def create(conn, %{"project" => project_params}) do
    case Projects.create_project(project_params) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Utworzono projekt.")
        |> redirect(to: Routes.project_path(conn, :show, project))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> assign_clients()
        |> render("new.html", changeset: changeset)
    end
  end

  defp assign_clients(conn) do
    clients = Clients.list_client() |> Enum.map(&{&1.name, &1.id})
    conn |> assign(:clients, [{"", ""} | clients])
  end

  def show(conn, %{"id" => id}) do
    project = Projects.get_project_with_tasks!(id)
    IO.inspect(project)
    render(conn, "show.html", project: project)
  end

  def edit(conn, %{"id" => id}) do
    project = Projects.get_project!(id)

    conn
    |> assign_clients()
    |> render("edit.html",
      changeset: Projects.change_project(project),
      project: project
    )
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
    project = Projects.get_project!(id)

    case Projects.update_project(project, project_params) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Zmodyfikowano projekt.")
        |> redirect(to: Routes.project_path(conn, :show, project))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", project: project, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    project = Projects.get_project!(id)
    {:ok, _project} = Projects.delete_project(project)

    conn
    |> put_flash(:info, "Projekt został usunięty.")
    |> redirect(to: Routes.project_path(conn, :index))
  end
end
