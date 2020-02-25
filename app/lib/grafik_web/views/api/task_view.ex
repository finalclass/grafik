defmodule GrafikWeb.Api.TaskView do
  use GrafikWeb, :view

  def render("task.json", %{task: task}) do
    %{
      id: task.id,
      project_id: task.project_id,
      name: task.name,
      status: task.status,
      worker_id: task.worker_id || 0,
      sent_note: task.sent_note || "",
      price: task.price || 0.0
    }
  end

  def render("deletion-result.json", %{result: result}) do
    %{ ok: result }
  end
     
end
