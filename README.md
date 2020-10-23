# CsgoStats

This will eventually be awesome. Expect alpha quality for now.

## Running it locally

You can run this either natively or through Docker.

To run it natively:

```
$ mix deps.get
$ mix phx.server
```

To run it with Docker:

```
docker run -it -p 4000:4000 \
    -e 'SECRET_KEY_BASE=x8nYdz0kpWy4NusegPRsAblExUgvjndIjOM8Cwimv0CWbHTpyPfqiNesXASlV/9Y' \
    trarbr/csgo_stats
```

Then launch a CS:GO server and set the following cvars: `mp_logdetail 3; mp_logmoney 1; mp_logdetail_items 1; log on; logaddress_add_http "http://localhost:4000/api/logs";`

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
`load` and `playback`, which you can then jump to. Happy debugging!
