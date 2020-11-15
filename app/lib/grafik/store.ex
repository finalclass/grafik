defmodule Grafik.Store do
  
  @moduledoc """
  Manipulate store. Add/remove prodcts and materials
  """

  import Ecto.Query
  alias Grafik.Repo
  alias Grafik.Store.Product
  alias Grafik.Store.Material
   
  def list_products do
    Repo.all(from p in Product)
  end

  def list_materials do
    Repo.all(from m in Material)
  end
  
end
