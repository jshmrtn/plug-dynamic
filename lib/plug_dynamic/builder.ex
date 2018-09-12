defmodule PlugDynamic.Builder do
  @moduledoc """
  Exposes Plug Builder Macros
  """

  defmacro dynamic_plug(plug, config \\ [], options \\ [])

  defmacro dynamic_plug(plug, [do: block], []) do
    config = [plug: plug]
    {fun_definition, ref} = inplace_config(plug, block)

    [
      fun_definition,
      quote bind_quoted: [config: config, plug: plug, ref: ref] do
        plug(PlugDynamic, config ++ [options: {__MODULE__, :__dynamic_plug_config, [plug, ref]}])
      end
    ]
  end

  defmacro dynamic_plug(plug, config, do: block) do
    config = Keyword.put_new(config, :plug, plug)
    {fun_definition, ref} = inplace_config(plug, block)

    [
      fun_definition,
      quote bind_quoted: [config: config, plug: plug, ref: ref] do
        plug(PlugDynamic, config ++ [options: {__MODULE__, :__dynamic_plug_config, [plug, ref]}])
      end
    ]
  end

  defmacro dynamic_plug(plug, config, []) do
    config = Keyword.put_new(config, :plug, plug)

    quote bind_quoted: [config: config] do
      plug(PlugDynamic, config)
    end
  end

  defp inplace_config(plug, block) do
    ref = :"#{inspect(make_ref())}"

    fun_definition =
      quote do
        @doc false
        def __dynamic_plug_config(unquote(plug), unquote(ref)) do
          unquote(block)
        end
      end

    {fun_definition, ref}
  end
end
