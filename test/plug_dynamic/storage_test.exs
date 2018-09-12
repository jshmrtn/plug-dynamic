defmodule PlugDynamic.StorageTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias PlugDynamic.Storage

  setup %{test: test_name} do
    name = :"#{__MODULE__}.#{test_name}"
    start_supervised!({Storage, name: name})
    {:ok, storage: name}
  end

  describe "fetch/2" do
    test "error when not exists", %{storage: storage, test: test_name} do
      assert :error = Storage.fetch(storage, test_name)
    end

    test "ok when exists", %{storage: storage, test: test_name} do
      Storage.store(storage, test_name, :hello)

      Process.sleep(10)

      assert {:ok, :hello} = Storage.fetch(storage, test_name)
    end
  end

  describe "store/3" do
    test "write works", %{storage: storage, test: test_name} do
      Storage.store(storage, test_name, :hello)

      Process.sleep(10)

      assert {:ok, :hello} = Storage.fetch(storage, test_name)
    end

    test "overwrite works", %{storage: storage, test: test_name} do
      Storage.store(storage, test_name, :hello)
      Storage.store(storage, test_name, :foo)

      Process.sleep(10)

      assert {:ok, :foo} = Storage.fetch(storage, test_name)
    end
  end
end
