defmodule GrafikWeb.Api.ProjectView do
  use GrafikWeb, :view

  def render("index.json", %{projects: projects}) do
    %{data: render_many(projects, GrafikWeb.Api.ProjectView, "project.json")}
  end

  def render("project.json", %{project: project}) do
    %{
      id: project.id,
      name: project.name,
      client: render_one(project.client, GrafikWeb.Api.ClientView, "client.json"),
      tasks: render_many(project.tasks, GrafikWeb.Api.TaskView, "task.json")
    }
  end

end
