defmodule GrafikWeb.Api.DashboardController do
  use GrafikWeb, :controller
  
  alias Grafik.Projects

  def index(conn, _params) do
    projects = Projects.list_not_archived_projects()
    workers = Grafik.Workers.list_workers()
    statuses = Projects.list_statuses()
    render(conn, "index.json", projects: projects, workers: workers, statuses: statuses)
  end

  def show(conn, _params) do
    conn
  end
end
