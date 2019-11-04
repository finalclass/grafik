defmodule GrafikWeb.Api.DashboardView do
  use GrafikWeb, :view

  def render("index.json", %{projects: projects, workers: workers, statuses: statuses}) do
    %{
      projects: render_many(projects, GrafikWeb.Api.ProjectView, "project.json"),
      workers: render_many(workers, GrafikWeb.Api.WorkerView, "worker.json"),
      statuses: statuses
    }
  end
  
end
