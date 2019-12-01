defmodule GrafikWeb.BackupController do
    use GrafikWeb, :controller

  alias Grafik.BackupsDataAccess

  
  def index(conn, _params) do
    conn |> render("index.html", backups: BackupsDataAccess.list())
  end

  def show(conn, %{"file_name" => file_name}) do
    conn |> render("show.html", backup: BackupsDataAccess.get(file_name))
  end
  
end
