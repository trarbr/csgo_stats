# CsgoStats

This will eventually be awesome. Expect alpha quality for now.

## Running CsgoStats for development

To run CsgoStats, you need Erlang and Elixir installed on your machine. The
recommended approach is to install [asdf-vm][] and then install Erlang and
Elixir by running `asdf install`. This will install the supported versions,
which are listed in the `.tool-versions` file. With Erlang and Elixir installed,
you can fetch dependencies and run CsgoStats by executing:

[asdf-vm]: https://asdf-vm.com/guide/getting-started.html#_1-install-dependencies

```
$ mix deps.get
$ mix phx.server
```

You may also need a CS:GO game server to test with. CsgoStats connects to game
servers via. RCON, and receives logs sent from the game server via. HTTP. So if
you're working on parts which touch that integration, you will need to run a
server. There are multiple ways to do this:

1. Rent a server online. Can get expensive.
2. Run your own CS:GO dedicated server locally. If you have Docker installed,
   the included `.docker-compose.yml` file can be used for this. Instructions
   follow below.
3. I'm sure it's also possible to just run CS:GO, and connect to it spawn a
   server from inside the game - but I don't know how!

To run the CS:GO dedicated server with Docker, you first need to:

1. Copy the `.env.example` file to `.env`.
2. Go to [Steam Game Server Account Management][] to create a Game Login Token,
   and put it in the `.env` file.
3. Run `docker-compose up csgo_server`.

[Steam Game Server Account Management]: https://steamcommunity.com/dev/managegameservers

Please note that this setup has been tested on MacOS and Linux. I have not been
able to make it work on MacOS. I am not sure why. It works fine on Linux.

Once you have a CS:GO server running, you can start CS:GO, open the terminal and
connect to the server by typing: `connect <your-ip>:27016; password csgogames`.
When connected, you need to configure logging. You do that by setting these
cvars:

`mp_logdetail 3; mp_logmoney 1; mp_logdetail_items 1; log on; logaddress_add_http "http$localhost:4000/api/logs";`

## Running tests and benchmarks

```
$ mix test
$ mix bench
```

## Using logfiles for debugging

The project contains functions which are useful during development.
They re-create matches based on CS:GO server logfiles. The functions are:

- `CsgoStats.load`: This reads an entire logfile, starts a new match, and
  immediately applies all events from the logfile to the match. From the UI,
  one can then jump to any event and replay the match at normal speed from
  that event.
- `CsgoStats.playback`: This simulates a CS:GO game server by playing back
  all lines from a logfile in order, either at normal speed, or with the speed
  multiplied by the `speedup` parameter.

The source code ships with a couple logfiles in the `bench/inputs` directory.
You can use these logfiles with the above functions, for example:

```
$ iex -S mix phx.server
iex(1)> CsgoStats.load("bench/inputs/medium.log")
iex(2)> CsgoStats.playback("bench/inputs/medium.log")
```

You can then visit http://localhost:4000/matches/ - it will list the matches
`load-bench/inputs/medium.log` and `playback-bench/inputs/medium.log`, which
you can then jump to. Happy debugging!
