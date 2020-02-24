defmodule GrafikWeb.Api.ProjectController do
  use GrafikWeb, :controller

  alias Grafik.Projects
  alias Grafik.WFirma

  defp project_save_error(conn, err) do
    IO.inspect(err)

    conn
    |> put_status(500)
    |> render("project-save-error.json")
  end

  def update(conn, %{"project" => project_params, "tasks" => tasks}) do
    with {_, project} <- {:project, Projects.get_project!(project_params["id"])},
         {_, {:ok, project}} <- {:update, Projects.update_project(project, project_params)},
         {_, :ok} <- {:tasks, Projects.sync_project_tasks(project.id, tasks)} do
      render(conn, "project.json", project: Projects.get_project_with_tasks!(project.id))
    else
      {:project, nil} ->
        project_save_error(conn, nil)

      {:update, {:error, err}} ->
        project_save_error(conn, err)

      {:tasks, {:error, err}} ->
        project_save_error(conn, err)
    end
  end

  def create(conn, %{"project" => project_params, "tasks" => tasks}) do
    with {_, {:ok, project}} <- {:create, Projects.create_project(project_params)},
         {_, :ok} <- {:sync, Projects.sync_project_tasks(project.id, tasks)} do
      render(conn, "project.json", project: project)
    else
      {:create, {:error, err}} ->
        project_save_error(conn, err)
    end
  end

  def wfirma_import(conn, %{"invoice_number" => invoice_number}) do
    case WFirma.import_offer(invoice_number) do
      {:ok, data} ->
        render(conn, "wfirma-import.json", data: data)

      {:error, err} ->
        IO.inspect(err)

        conn
        |> put_status(500)
        |> render("project-wfirma-import-error.json")
    end
  end
end
