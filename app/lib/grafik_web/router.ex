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
    resources "/tasks", TaskController

    get "/projects/:id/tasks/new", TaskController, :add_task_to_project
    get "/workers/:id/print", WorkerController, :print
  end

  # Other scopes may use custom stacks.
  scope "/api", GrafikWeb.Api, as: :api do
    pipe_through :api

    get "/all", DashboardController, :index
    post "/projects/:project_id/tasks/", TaskController, :create_empty
    delete "/projects/:project_id/tasks/:task_id", TaskController, :delete
    put "/projects/:project_id/tasks/:task_id", TaskController, :update
    resources "/clients", ClientController, only: [:create, :update]
    resources "/projects", ProjectController, only: [:create, :update]
  end
end
