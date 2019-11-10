defmodule GrafikWeb.Api.TaskController do
  use GrafikWeb, :controller

  alias Grafik.Projects

  def create_empty(conn, %{"project_id" => project_id, "name" => name}) do
    {:ok, task} =
      Projects.create_task(%{
        project_id: project_id,
        name: name,
        status: "todo"
      })

    render(conn, "empty-task.json", task: task)
  end

  def delete(conn, %{"task_id" => task_id}) do
    task = Projects.get_task!(task_id)
    {:ok, _} = Projects.delete_task(task)
    render(conn, "deletion-result.json", result: true)
  end

  def update(conn, %{"task" => task_data, "task_id" => task_id}) do
    task = Projects.get_task!(task_id)
    {:ok, _} = Projects.update_task(task, task_data)
    task = Projects.get_task!(task_id)
    render(conn, "task.json", task: task)
  end

end
