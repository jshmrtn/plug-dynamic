defmodule PlugDynamic.BuilderTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Plug.Test

  import ExUnit.CaptureLog

  defmodule Endpoint do
    @moduledoc false

    use Plug.Builder
    import PlugDynamic.Builder

    dynamic_plug Plug.Logger

    dynamic_plug Plug.Logger, reevaluate: :always

    dynamic_plug Plug.Logger, reevaluate: :always, options: {__MODULE__, :test, 0}

    dynamic_plug Plug.Logger, reevaluate: :always, options: {__MODULE__, :test, []}

    dynamic_plug Plug.Logger, reevaluate: :always do
      [log: :error]
    end

    dynamic_plug Plug.Logger do
      [log: :error]
    end

    def test, do: [log: :warn]
  end

  describe "dynamic_plug/1,2,3" do
    test "EndpointSimple works" do
      log =
        capture_log(fn ->
          :get
          |> conn("/foo?bar=10")
          |> Endpoint.call(Endpoint.init([]))
        end)

      assert length(Regex.scan(~r/\[error\]/, log)) == 2
      assert length(Regex.scan(~r/\[warn\]/, log)) == 2
      assert length(Regex.scan(~r/\[info\]/, log)) == 2
    end
  end
end
