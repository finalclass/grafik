defmodule GrafikWeb.WorkerController do
  use GrafikWeb, :controller

  alias Grafik.Workers
  alias Grafik.Workers.Worker
  alias Grafik.Projects

  def index(conn, _params) do
    workers = Workers.list_workers()
    render(conn, "index.html", workers: workers)
  end

  def new(conn, _params) do
    changeset = Workers.change_worker(%Worker{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"worker" => worker_params}) do
    case Workers.create_worker(worker_params) do
      {:ok, worker} ->
        conn
        |> put_flash(:info, "Utworzono pracownika.")
        |> redirect(to: Routes.worker_path(conn, :show, worker))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    worker = Workers.get_worker!(id)
    projects = Projects.get_worker_tasks!(id)
    render(conn, "show.html", worker: worker, projects: projects)
  end

  def edit(conn, %{"id" => id}) do
    worker = Workers.get_worker!(id)
    changeset = Workers.change_worker(worker)
    render(conn, "edit.html", worker: worker, changeset: changeset)
  end

  def update(conn, %{"id" => id, "worker" => worker_params}) do
    worker = Workers.get_worker!(id)

    case Workers.update_worker(worker, worker_params) do
      {:ok, worker} ->
        conn
        |> put_flash(:info, "Zmodyfikowano pracownika.")
        |> redirect(to: Routes.worker_path(conn, :show, worker))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", worker: worker, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    worker = Workers.get_worker!(id)
    {:ok, _worker} = Workers.delete_worker(worker)

    conn
    |> put_flash(:info, "Pracownik został usunięty.")
    |> redirect(to: Routes.worker_path(conn, :index))
  end
end
