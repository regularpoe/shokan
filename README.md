# Shokan

shokan is a command line tool to quickly create fake JSON data. It uses Jason library for dealing with JSON, and Faker library to generate fake data.

To see all available modules, check [Faker docs](https://hexdocs.pm/faker/Faker.html)

## TODO

    - write tests

## Usage

To use this tool, clone the repo and build it by running:

```bash
mix escript.build
```

To see available functions, run the binary:

```bash
./shokan
```

Faker has a lot of modules for data, you can see which ones are supported by running:

```bash
./shokan -i
```

This will print the available Faker modules currently supported, output looks like this:

```bash
Available Faker functions:

Faker.Address:
  building_number/0
  city/0
  city_prefix/0
  city_suffix/0
  country/0
  country_code/0
  geohash/0
  latitude/0
  longitude/0
  postcode/0
  secondary_address/0
  state/0
  state_abbr/0
  street_address/0
  street_address/1
  street_name/0
  street_suffix/0
  time_zone/0
  zip/0
  zip_code/0

Faker.Airports:
  iata/0
  icao/0
  name/0

...
```

Then you can create a schema file, such as `schema.json` and use it to generate fake data:

```json
{
    "address": "Faker.Address.street_name"
}
```

and feed it to the `shokan`

```bash
./shokan -s schema.json -n 2
```

This will generate fake data:

```json
[
  {
    "address": "Leopoldo Drive"
  },
  {
    "address": "Emil Corners",
  }
]
```

If you don't want to manually write schema, you can use `-g` switch to let `shokan` generate one for you:

```bash
./shokan -g "address:Address" > schema.json
```

This will yield the following:

```json
{
  "address": "Faker.Address.street_address"
}
```

and then run it again for fake data:

```bash
./shokan -s schema.json -n 5
```

To see all available shortcust when generating schema, run `shokan -l`