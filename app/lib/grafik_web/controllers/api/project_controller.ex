defmodule GrafikWeb.Api.ProjectController do
  use GrafikWeb, :controller

  alias Grafik.Projects
  alias Grafik.WFirma

  def update(conn, project_params) do
    project = Projects.get_project!(project_params["id"])

    case Projects.update_project(project, project_params) do
      {:ok, project} ->
        render(conn, "project.json", project: Projects.get_project_with_tasks!(project.id))

      {:error, err} ->
        IO.inspect(err)
        conn
        |> put_status(500)
        |> render("project-save-error.json")
    end
    
  end

  def create(conn, project_params) do
    case Projects.create_project(project_params) do
      {:ok, project} ->
        render(conn, "project.json", project: project)

      {:error, err} ->
        IO.inspect(err)
        conn
        |> put_status(500)
        |> render("project-save-error.json")
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
