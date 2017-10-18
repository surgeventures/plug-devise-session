# Plug for Devise Session

***Simple plug for sharing Devise session in Elixir***

Features:

- one line configuration (depending on Rails version)
- supports multiple Rails session serializers (pre and post Rails 4.1)
- supports dynamic runtime configuration using system tuples (uses `Confix` package)

## Getting Started

Add `plug_devise_session` as a dependency to your project in `mix.exs`:

```elixir
defp deps do
  [{:plug_devise_session, "~> x.x.x"}]
end
```

Then run `mix deps.get` to fetch it.

## Documentation

Visit documentation on [HexDocs](https://hexdocs.pm/plug_devise_session) for a complete API
reference.
