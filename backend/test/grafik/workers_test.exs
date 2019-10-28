defmodule Grafik.WorkersTest do
  use Grafik.DataCase

  alias Grafik.Workers

  describe "workers" do
    alias Grafik.Workers.Worker

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def worker_fixture(attrs \\ %{}) do
      {:ok, worker} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Workers.create_worker()

      worker
    end

    test "list_workers/0 returns all workers" do
      worker = worker_fixture()
      assert Workers.list_workers() == [worker]
    end

    test "get_worker!/1 returns the worker with given id" do
      worker = worker_fixture()
      assert Workers.get_worker!(worker.id) == worker
    end

    test "create_worker/1 with valid data creates a worker" do
      assert {:ok, %Worker{} = worker} = Workers.create_worker(@valid_attrs)
      assert worker.name == "some name"
    end

    test "create_worker/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Workers.create_worker(@invalid_attrs)
    end

    test "update_worker/2 with valid data updates the worker" do
      worker = worker_fixture()
      assert {:ok, %Worker{} = worker} = Workers.update_worker(worker, @update_attrs)
      assert worker.name == "some updated name"
    end

    test "update_worker/2 with invalid data returns error changeset" do
      worker = worker_fixture()
      assert {:error, %Ecto.Changeset{}} = Workers.update_worker(worker, @invalid_attrs)
      assert worker == Workers.get_worker!(worker.id)
    end

    test "delete_worker/1 deletes the worker" do
      worker = worker_fixture()
      assert {:ok, %Worker{}} = Workers.delete_worker(worker)
      assert_raise Ecto.NoResultsError, fn -> Workers.get_worker!(worker.id) end
    end

    test "change_worker/1 returns a worker changeset" do
      worker = worker_fixture()
      assert %Ecto.Changeset{} = Workers.change_worker(worker)
    end
  end
end
