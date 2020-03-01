defmodule GrafikWeb.Router do
  use GrafikWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]

  end

  scope "/", GrafikWeb do
    pipe_through :browser

    get "/", DashboardController, :index
    resources "/workers", WorkerController

    get "/workers/:id/print", WorkerController, :print
    get "/backups", BackupController, :index
    get "/backups/:file_name", BackupController, :show
  end

  # Other scopes may use custom stacks.
  scope "/api", GrafikWeb.Api, as: :api do
    pipe_through :api

    get "/all", DashboardController, :index
    get "/projects/import/:invoice_number", ProjectController, :wfirma_import
    post "/projects/:project_id/tasks/", TaskController, :create
    delete "/projects/:project_id/tasks/:task_id", TaskController, :delete
    put "/projects/:project_id/tasks/:task_id", TaskController, :update
    
    resources "/clients", ClientController, only: [:create, :update]
    resources "/projects", ProjectController, only: [:create, :update]
  end
end
