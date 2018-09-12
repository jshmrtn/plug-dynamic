defmodule PlugDynamic.Application do
  @moduledoc false

  use Application

  alias PlugDynamic.Storage

  def start(_type, _args),
    do:
      Supervisor.start_link(
        [Storage],
        strategy: :one_for_one,
        name: PlugDynamic.Supervisor
      )
end
