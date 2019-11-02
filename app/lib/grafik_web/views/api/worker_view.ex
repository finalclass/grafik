defmodule GrafikWeb.Api.WorkerView do
  use GrafikWeb, :view

  def render("worker.json", %{worker: worker}) do
    %{
      id: worker.id,
      name: worker.name
    }
  end
     
end
