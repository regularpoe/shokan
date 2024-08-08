defmodule Shokan do
  @faker_modules [
    Faker.Address,
    Faker.Airports
  ]

  @schema_map %{
    "Address" => "Faker.Address.street_address",
    "Airport" => "Faker.Airports.name"
  }

  def main(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        switches: [schema: :string, number: :integer, info: :boolean, generate: :string, list: :boolean],
        aliases: [s: :schema, n: :number, i: :info, g: :generate, l: :list]
      )

    cond do
      opts[:info] ->
        print_available_functions()

      opts[:list] ->
        list_of_shortcuts()

      opts[:generate] ->
        generate_schema(opts[:generate])

      opts[:schema] && opts[:number] ->
        {:ok, schema} = File.read(opts[:schema])

        case Jason.decode(schema) do
          {:ok, schema_map} ->
            generate_data(schema_map, opts[:number])
            |> Jason.encode!()
            |> IO.puts()

          {:error, _} ->
            IO.puts("Invalid JSON schema.")
        end

      true ->
        IO.puts(
          "Usage: shokan -s schema.json -n <number of objects> | -g \"name:Name,address:Address,email:Email\" | -i"
        )
    end
  end

  defp print_available_functions() do
    IO.puts("Available Faker functions:")

    @faker_modules
    |> Enum.each(&print_available_functions/1)
  end

  defp print_available_functions(module) do
    IO.puts("\n#{inspect(module)}:")

    if Code.ensure_loaded?(module) do
      functions = module.__info__(:functions)

      Enum.each(functions, fn {func, arity} ->
        IO.puts("  #{func}/#{arity}")
      end)
    else
      IO.puts("  Module not loaded or doesn't exist.")
    end
  end

  defp list_of_shortcuts do
    IO.puts("Available shortcuts in generate function:")

    @schema_map
    |> Map.keys()
    |> Enum.each(fn key -> IO.puts("  #{key}: #{@schema_map[key]}") end)
  end

  defp generate_data(schema, count) do
    for _ <- 1..count do
      Enum.map(schema, fn {key, value} ->
        {key, generate_value(value)}
      end)
      |> Enum.into(%{})
    end
  end

  defp generate_value(function_path) do
    [module_name | func_parts] = String.split(function_path, ".")
    func_name = List.last(func_parts) |> String.to_atom()
    module_name = Module.concat([String.to_atom(module_name), List.first(func_parts)])

    if Code.ensure_loaded?(module_name) && function_exported?(module_name, func_name, 0) do
      apply(module_name, func_name, [])
    else
      "Unknown"
    end
  end

  defp generate_schema(user_input) do
    schema =
      user_input
      |> String.split(",")
      |> Enum.map(fn pair ->
        [field, type] = String.split(pair, ":")
        {field, Map.get(@schema_map, type, "Unknown")}
      end)
      |> Enum.into(%{})

    schema_json = Jason.encode!(schema, pretty: true)
    IO.puts(schema_json)
  end
end
