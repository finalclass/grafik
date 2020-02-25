defmodule Grafik.WFirma do

  @auth_encoded [
      Application.get_env(:grafik, :wfirma_login),
      Application.get_env(:grafik, :wfirma_password)
    ]
    |> Enum.join(":")
    |> Base.encode64()
  
  @url "https://api2.wfirma.pl"
  
  @headers [
    "Authorization": "Basic #{@auth_encoded}",
    "Content-type": "application/json"
  ]
  
  @format "inputFormat=json&outputFormat=json"
  
  def import_offer(offer_number) do
    find_params = %{
      invoices: %{
        parameters: %{
          limit: 1,
          conditions: %{
            condition: %{
              field: "fullnumber",
              operator: "like",
              value: offer_number
            }
          }
        }
      }
    } |> Jason.encode!()
    
    result = HTTPoison.post!(@url <> "/invoices/find?" <> @format, find_params, @headers)
    |> Map.get(:body)
    |> Jason.decode!()

    case result["status"] do
      %{"code" => "OK"} ->
        total = result |> Map.get("invoices", %{}) |> Map.get("parameters", %{}) |> Map.get("total", "0") |> String.to_integer()
        if total == 1 do
          {:ok, filter_find_offer_result(result)}
        else
          {:error, "not_found"}
        end
      _ ->
        {:error, "invalid_response"}
    end
  end

  defp filter_find_offer_result(result) do
    invoice = result |> Map.get("invoices") |> Map.get("0") |> Map.get("invoice")
    client = invoice["contractor_detail"]
    wfirma_id = to_int!(invoice["id"])
    tasks = invoice |> Map.get("invoicecontents") |> Enum.map(fn row ->
      item = row |> elem(1) |> Map.get("invoicecontent")
      %{
        "name" => item["name"],
        "price" => to_float!(item["price"]),
        "count" => item["count"] |> to_float!() |> round(),
        "wfirma_id" => to_int!(item["id"]),
        "wfirma_good_id" => to_int!(item |> Map.get("good") |> Map.get("id"))
      }
    end)
    %{
      "wfirma_id" => wfirma_id,
      "price" => to_float!(invoice["netto"]),
      "tasks" => tasks,
      "client" => %{
        "wfirma_client_id" => to_int!(client["id"]),
        "name" => client["name"],
        "city" => client["city"],
        "country" => client["country"],
        "street" => client["street"],
        "zip" => client["zip"],
        "email" => client["email"],
        "phone" => client["phone"],
        "nip" => client["nip"]
      }
    }
  end

  def to_float!(str) do
    try do
      String.to_float(str)
    rescue
      _ -> 0
    end
  end

  def to_int!(str, default \\ 0) do
    try do
      String.to_integer(str)
    rescue
      _ -> default
    end
  end
  
end
