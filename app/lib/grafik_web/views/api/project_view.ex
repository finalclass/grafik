defmodule GrafikWeb.Api.ProjectView do
  use GrafikWeb, :view

  def render("project.json", %{project: project}) do
    %{
      id: project.id,
      client_id: project.client_id,
      name: project.name,
      tasks:
        if Ecto.assoc_loaded?(project.tasks) do
          render_many(project.tasks, GrafikWeb.Api.TaskView, "task.json")
        else
          []
        end,
      is_deadline_rigid: project.is_deadline_rigid,
      deadline:
        if project.deadline do
          DateTime.to_unix(project.deadline) * 1000
        else
          0
        end,
      invoice_number: project.invoice_number,
      price: project.price,
      paid: project.paid,
      is_archived: project.is_archived,
      start_at:
        if project.start_at do
          DateTime.to_unix(project.start_at) * 1000
        else
          0
        end
    }
  end

  def render("project-save-error.json", %{}) do
    %{status: "error"}
  end
end
