defmodule GrafikWeb.Api.ProjectController do
  use GrafikWeb, :controller
  
  alias Grafik.Projects

  def index(conn, _params) do
    projects = Projects.list_full_projects()
    render(conn, "index.json", projects: projects)
  end

  def show(conn, _params) do
    conn
  end
end
