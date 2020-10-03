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
