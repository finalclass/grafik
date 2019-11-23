defmodule GrafikWeb.Api.ClientController do
  use GrafikWeb, :controller

  alias Grafik.Clients

  def update(conn, client_params) do
    client = Clients.get_client!(client_params["id"])

    case Clients.update_client(client, client_params) do
      {:ok, client} ->
        render(conn, "client.json", client: client)

      {:error, err} ->
        IO.inspect(err)
        conn
        |> put_status(500)
        |> render("client-save-error.json")
    end
    
  end
  
  def create(conn, client_params) do
    case Clients.create_client(client_params) do
      {:ok, client} ->
        render(conn, "client.json", client: client)

      {:error, err} ->
        IO.inspect(err)
        conn
        |> put_status(500)
        |> render("client-save-error.json")
    end
  end

end
