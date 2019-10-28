defmodule GrafikWeb.PageController do
  use GrafikWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

end
