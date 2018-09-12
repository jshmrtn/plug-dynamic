# Plug Dynamic

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/jshmrtn/plug-dynamic/master/LICENSE)
[![Build Status](https://travis-ci.org/jshmrtn/plug-dynamic.svg?branch=master)](https://travis-ci.org/jshmrtn/plug-dynamic)
[![Hex.pm Version](https://img.shields.io/hexpm/v/plug_dynamic.svg?style=flat)](https://hex.pm/packages/plug_dynamic)
[![InchCI](https://inch-ci.org/github/jshmrtn/plug-dynamic.svg?branch=master)](https://inch-ci.org/github/jshmrtn/plug-dynamic)
[![Coverage Status](https://coveralls.io/repos/github/jshmrtn/plug-dynamic/badge.svg?branch=master)](https://coveralls.io/github/jshmrtn/plug-dynamic?branch=master)


Allows registration of every Plug with dynamic configuration.

## Installation

The package can be installed by adding `plug_dynamic` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:plug_dynamic, "~> 1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). The docs can be found at
[https://hexdocs.pm/plug_dynamic](https://hexdocs.pm/plug_dynamic).

## Usage Example

For detailed instructions check the [documentation](https://hexdocs.pm/plug_dynamic).

```elixir
defmodule Acme.Endpoint do
  use Plug.Builder
  use PlugDynamic

  dynamic_plug Plug.IpWhitelist.IpWhitelistEnforcer, [reevaluate: :first_usage] do
    Application.fetch_env!(:acme, Plug.IpWhitelist.IpWhitelistEnforcer)
  end
end
```
