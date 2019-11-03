defmodule GrafikWeb.Api.DashboardController do
  use GrafikWeb, :controller
  
  alias Grafik.Projects

  def index(conn, _params) do
    projects = Projects.list_full_projects()
    workers = Grafik.Workers.list_workers()
    render(conn, "index.json", projects: projects, workers: workers)
  end

  def show(conn, _params) do
    conn
  end
end
