defmodule GrafikWeb.Api.DashboardController do
  use GrafikWeb, :controller
  
  alias Grafik.Projects

  def index(conn, _params) do
    projects = Projects.list_not_archived_projects()
    workers = Grafik.Workers.list_workers()
    statuses = Projects.list_statuses()
    # header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
    # header("Cache-Control: post-check=0, pre-check=0", false);
    # header("Pragma: no-cache");
    conn
    |> put_resp_header("cache-control", "no-store, no-cache, must-revalidate, max-age=0")
    |> put_resp_header("pragma", "no-cache")
    |> render("index.json", projects: projects, workers: workers, statuses: statuses)
  end

  def show(conn, _params) do
    conn
  end
end
