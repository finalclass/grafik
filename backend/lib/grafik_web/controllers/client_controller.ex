defmodule GrafikWeb.ClientController do
  use GrafikWeb, :controller

  alias Grafik.Clients
  alias Grafik.Clients.Client

  def index(conn, _params) do
    client = Clients.list_client()
    render(conn, "index.html", client: client)
  end

  def new(conn, _params) do
    changeset = Clients.change_client(%Client{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"client" => client_params}) do
    case Clients.create_client(client_params) do
      {:ok, client} ->
        conn
        |> put_flash(:info, "Utworzono klienta.")
        |> redirect(to: Routes.client_path(conn, :show, client))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    client = Clients.get_client!(id)
    render(conn, "show.html", client: client)
  end

  def edit(conn, %{"id" => id}) do
    client = Clients.get_client!(id)
    changeset = Clients.change_client(client)
    render(conn, "edit.html", client: client, changeset: changeset)
  end

  def update(conn, %{"id" => id, "client" => client_params}) do
    client = Clients.get_client!(id)

    case Clients.update_client(client, client_params) do
      {:ok, client} ->
        conn
        |> put_flash(:info, "Zmodyfikowano klienta.")
        |> redirect(to: Routes.client_path(conn, :show, client))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", client: client, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    client = Clients.get_client!(id)
    {:ok, _client} = Clients.delete_client(client)

    conn
    |> put_flash(:info, "Klient został usunięty.")
    |> redirect(to: Routes.client_path(conn, :index))
  end
end
