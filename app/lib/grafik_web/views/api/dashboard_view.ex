defmodule GrafikWeb.Api.DashboardView do
  use GrafikWeb, :view

  def render("index.json", %{projects: projects, workers: workers}) do
    %{
      projects: render_many(projects, GrafikWeb.Api.ProjectView, "project.json"),
      workers: render_many(workers, GrafikWeb.Api.WorkerView, "worker.json")
    }
  end
  
end
