defmodule PlugDynamic do
  @moduledoc """
  Moves any plugs configuration from compile time to runtime.

  ### Usage Example (plain)

      defmodule Acme.Endpoint do
        use Plug.Builder

        plug(
          PlugDynamic,
          plug: Plug.IpWhitelist.IpWhitelistEnforcer,
          options: {__MODULE__, :ip_whitelist_options, 0},
          reevaluate: :first_usage
        )

        def ip_whitelist_options,
          do: Application.fetch_env!(:acme, Plug.IpWhitelist.IpWhitelistEnforcer)
      end

  ### Usage Example (macro)

      defmodule Acme.Endpoint do
        use Plug.Builder
        use PlugDynamic

        dynamic_plug Plug.IpWhitelist.IpWhitelistEnforcer, [reevaluate: :first_usage] do
          Application.fetch_env!(:acme, Plug.IpWhitelist.IpWhitelistEnforcer)
        end
      end

  ### Options

    * `options` - anonymous function or `{Module, :function, [args]}` tuple to fetch the configuration
    * `reevaluate` - default: `:first_usage` - one of the following values
      - `:first_usage` - Evaluate Options when it is used for the first time. The resulting value will be cached in ets.
      - `:always` - Evaluate Options for every request. (Attention: This can cause a severe performance impact.)

  """

  @behaviour Plug

  alias Plug.Conn
  alias PlugDynamic.{Builder, Storage}

  require Logger

  @type options_fetcher :: (() -> any) | {atom, atom, [any]} | mfa
  @type reevaluate :: :first_usage | :always
  @type plug :: atom

  @typep options_fetcher_normalized :: (() -> any)

  @enforce_keys [:options_fetcher, :reevaluate, :plug, :reference]
  defstruct @enforce_keys

  defmacro __using__ do
    quote do
      import unquote(Builder), only: [dynamic_plug: 1, dynamic_plug: 2, dynamic_plug: 3]
    end
  end

  @impl Plug
  @doc false
  def init(options) do
    plug = Keyword.fetch!(options, :plug)

    %__MODULE__{
      plug: plug,
      options_fetcher: options |> Keyword.get(:options, {__MODULE__, :empty_opts, 0}),
      reevaluate: options |> Keyword.get(:reevaluate, :first_usage),
      reference: :"#{plug}.#{inspect(make_ref())}"
    }
  end

  @impl Plug
  @doc false
  def call(%Conn{} = conn, %{reevaluate: :always, plug: plug, options_fetcher: options_fetcher}),
    do: plug.call(conn, plug.init(normalize_options_fetcher(options_fetcher).()))

  def call(%Conn{} = conn, %{
        reevaluate: :first_usage,
        plug: plug,
        options_fetcher: options_fetcher,
        reference: reference
      }) do
    options = fetch_or_create_options(plug, reference, options_fetcher)
    plug.call(conn, options)
  end

  @spec fetch_or_create_options(
          plug :: atom,
          reference :: atom,
          options_fetcher :: options_fetcher
        ) :: any
  defp fetch_or_create_options(plug, reference, options_fetcher) do
    reference
    |> Storage.fetch()
    |> case do
      {:ok, options} ->
        options

      :error ->
        options = plug.init(normalize_options_fetcher(options_fetcher).())

        Logger.debug(fn ->
          "Options for Plug `#{inspect(plug)}` (#{inspect(reference, pretty: true)}) not found, storing"
        end)

        Storage.store(reference, options)

        options
    end
  end

  @spec normalize_options_fetcher(fun :: options_fetcher) :: options_fetcher_normalized
  defp normalize_options_fetcher(fun) when is_function(fun, 0), do: fun

  defp normalize_options_fetcher(fun) when is_function(fun),
    do: raise("Option fetching function must have 0 arity")

  defp normalize_options_fetcher({module, function, arguments})
       when is_atom(module) and is_atom(function) and is_list(arguments),
       do: fn -> apply(module, function, arguments) end

  if function_exported?(Function, :capture, 2) do
    defp normalize_options_fetcher({module, function, 0})
         when is_atom(module) and is_atom(function),
         do: Function.capture(module, function, 0)
  else
    defp normalize_options_fetcher({module, function, 0})
         when is_atom(module) and is_atom(function),
         do: fn -> apply(module, function, []) end
  end

  defp normalize_options_fetcher({module, function, arity})
       when is_atom(module) and is_atom(function) and is_integer(0) and arity > 0,
       do: raise("Option fetching function must have 0 arity")

  @doc false
  @spec empty_opts :: []
  def empty_opts, do: []
end
