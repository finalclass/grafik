defmodule GrafikWeb.Api.ProjectView do
  use GrafikWeb, :view
  
  def render("project.json", %{project: project}) do
    %{
      id: project.id,
      client_id: project.client_id,
      name: project.name,
      tasks: render_many(project.tasks, GrafikWeb.Api.TaskView, "task.json"),
      is_deadline_rigid: project.is_deadline_rigid,
      deadline: if project.deadline do DateTime.to_unix(project.deadline) * 1000 else 0 end,
      invoice_number: project.invoice_number,
      price: project.price,
      paid: project.paid
    }
  end
end
