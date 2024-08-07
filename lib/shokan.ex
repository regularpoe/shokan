defmodule Shokan do
  def main(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        switches: [schema: :string, number: :integer],
        aliases: [s: :schema, n: :number]
      )

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

  defp generate_data(schema, count) do
    for _ <- 1..count do
      Enum.map(schema, fn {key, value} ->
        {key, generate_value(value)}
      end)
      |> Enum.into(%{})
    end
  end

  defp generate_value("name"), do: Faker.Person.name()
  defp generate_value("address"), do: Faker.Address.street_address()
  defp generate_value("email"), do: Faker.Internet.email()
  defp generate_value(_), do: "Unknown"
end
