defmodule GrafikWeb.WorkerView do
  use GrafikWeb, :view

  def show_worker_button(conn, worker) do
    link worker.name, to: Routes.worker_path(conn, :show, worker)
  end
  
  def new_worker_button(conn) do
    new_button Routes.worker_path(conn, :new), "Dodaj pracownika" 
  end
  
  def list_workers_button(conn) do
    list_button Routes.worker_path(conn, :index)
  end

  def edit_worker_button(conn, worker) do
    edit_button Routes.worker_path(conn, :edit, worker)
  end

  def delete_worker_button(conn, worker) do
    delete_button Routes.worker_path(conn, :delete, worker), worker.name
  end
end
