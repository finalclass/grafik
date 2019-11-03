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
    resources "/clients", ClientController
    resources "/projects", ProjectController
    resources "/workers", WorkerController
    resources "/tasks", TaskController

    get "/projects/:id/tasks/new", TaskController, :add_to_project
  end

  # Other scopes may use custom stacks.
  scope "/api", GrafikWeb.Api, as: :api do
    pipe_through :api

    resources "/projects/", ProjectController, only: [:index]
    post "/projects/:project_id/tasks/", TaskController, :create_empty
    delete "/projects/:project_id/tasks/:task_id", TaskController, :delete
  end
end
