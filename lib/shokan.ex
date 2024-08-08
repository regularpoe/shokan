defmodule Shokan do
  @faker_modules [
    Faker.Address
  ]

  def main(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        switches: [schema: :string, number: :integer, info: :boolean],
        aliases: [s: :schema, n: :number, i: :info]
      )

    if opts[:info] do
      print_available_functions()
    else
      schema_file = opts[:schema]
      number_of_objects = opts[:number]

      if schema_file && number_of_objects do
        {:ok, schema} = File.read(schema_file)

        case Jason.decode(schema) do
          {:ok, schema_map} ->
            generate_data(schema_map, number_of_objects)
            |> Jason.encode!()
            |> IO.puts()

          {:error, _} ->
            IO.puts("Invalid JSON schema")
        end
      else
        IO.puts("Usage: shokan -s schema.json -n <number_of_objects>")
      end
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
end
