defmodule GrafikWeb.Api.TaskView do
  use GrafikWeb, :view

  def render("task.json", %{task: task}) do
    %{
      id: task.id,
      project_id: task.project_id,
      name: task.name,
      status: task.status,
      worker: render_one(task.worker, GrafikWeb.Api.WorkerView, "worker.json")
    }
  end

  def render("empty-task.json", %{task: task}) do
    %{
      id: task.id,
      project_id: task.project_id,
      name: task.name,
      status: task.status,
      worker: %{
        id: 0,
        name: ""
      }
    }
  end

  def render("deletion-result.json", %{result: result}) do
    %{ ok: result }
  end
     
end
