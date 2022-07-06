[![GitHub license](https://img.shields.io/github/license/huqedato/Exapisd)](https://github.com/huqedato/Exapisd)

# Exapisd
A simple web API for serving data from json, SQLite or csv static files to json.

## Installation and setup

To start Exapisd:

  * Run `git clone...` from the repository
  * Install dependencies with `mix deps.get`
  * Run `mix compile`
  * Set the repository path `repo` in `config.exs` 
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check Phoenix deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Usage
The API's web links serves the data as it is structured in the file repository on the server.
### Example
Considering the repository path is `./temp/repo` and in the sub-directory `/test/` there is `test.json` file:
`./temp/repo/json/test.json`. Then the web API link will be http://localhost:4000/json
The repository structure can be nested as well: for `./temp/repo/json/another/test2.json` you get http://localhost:4000/json/another

Other examples:
 - `./temp/repo/sqlite/testsqlite.db` -> http://localhost:4000/sqlite
 - `./temp/repo/csv/large/foe.csv` -> http://localhost:4000/csv/large

The application serves the first alphabetically file found in it. If you have both `bar.json` and `foe.csv` in the same directory, the `bar.json` will be fetched. 

## TODOs
 - tests/benchmarks
 - add support for more data files types: xls, tsv, xml, unstructured
 - handle errors related to corrupt files in a better way.
 - documentation; ExDoc (?)

## Who is using it?
This application is in production (used internally) at the Joint Research Center of the European Commission.

## License
Copyright © 2022 Quda Theo.

Exapisd source code is released under **[AGPL-3.0-or-later](https://www.gnu.org/licenses/agpl-3.0.html)**.
