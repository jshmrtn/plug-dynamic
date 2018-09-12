defmodule PlugDynamic.Storage do
  @moduledoc false
  # Store Options so that they do not have to be re-evaluated

  use GenServer

  @server __MODULE__

  @type t :: %__MODULE__{
          table_name: atom
        }

  @enforce_keys [:table_name]
  defstruct @enforce_keys

  @doc false
  @spec start_link(options :: Keyword.t()) :: GenServer.on_start()
  def start_link(options),
    do: GenServer.start_link(__MODULE__, options, name: Keyword.get(options, :name, @server))

  @doc false
  @impl GenServer
  @spec init(options :: Keyword.t()) :: {:ok, t}
  def init(options),
    do:
      {:ok,
       %__MODULE__{
         table_name: options |> Keyword.get(:name, @server) |> table_name |> ets_table
       }}

  @doc false
  @impl GenServer
  @spec handle_cast(request :: {:store, reference :: atom, options :: any}, t) :: {:noreply, t}
  def handle_cast({:store, reference, options}, %__MODULE__{table_name: table_name} = state) do
    :ets.insert(table_name, {reference, options})
    {:noreply, state}
  end

  @doc false
  @spec fetch(server :: GenServer.name(), reference :: atom) :: {:ok, any} | :error
  def fetch(server \\ @server, reference) when is_atom(reference) do
    server
    |> table_name
    |> :ets.lookup(reference)
    |> case do
      [{^reference, options}] -> {:ok, options}
      _ -> :error
    end
  end

  @doc false
  @spec store(server :: GenServer.name(), reference :: atom, options :: any) :: :ok
  def store(server \\ @server, reference, options) when is_atom(reference),
    do: GenServer.cast(server, {:store, reference, options})

  @spec ets_table(table_name :: atom) :: atom
  defp ets_table(table_name), do: :ets.new(table_name, [:protected, :ordered_set, :named_table])

  @spec table_name(server :: GenServer.name()) :: atom
  defp table_name(server)
  defp table_name(server) when is_atom(server), do: Module.concat(server, Table)

  defp table_name({:global, server}) when is_atom(server),
    do: {:global, Module.concat(server, Table)}

  defp table_name({:via, _, server}) when is_atom(server),
    do: raise("Server is not supported with :via name")
end
