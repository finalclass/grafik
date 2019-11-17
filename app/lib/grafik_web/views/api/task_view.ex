defmodule GrafikWeb.Api.TaskView do
  use GrafikWeb, :view

  def render("task.json", %{task: task}) do
    %{
      id: task.id,
      project_id: task.project_id,
      name: task.name,
      status: task.status,
      worker_id: task.worker_id || 0,
      sent_at: if task.sent_at do DateTime.to_unix(task.sent_at) * 1000 else 0 end
    }
  end

  def render("empty-task.json", %{task: task}) do
    %{
      id: task.id,
      project_id: task.project_id,
      name: task.name,
      status: task.status,
      worker_id: 0
    }
  end

  def render("deletion-result.json", %{result: result}) do
    %{ ok: result }
  end
     
end
