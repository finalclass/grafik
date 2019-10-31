defmodule GrafikWeb.Api.TaskView do
  use GrafikWeb, :view

  def render("task.json", %{task: task}) do
    IO.inspect(task)
    %{
      id: task.id,
      name: task.name,
      status: task.status,
      worker: render_one(task.worker, GrafikWeb.Api.WorkerView, "worker.json")
    }
  end
     
end
