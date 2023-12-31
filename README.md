# Grafik

Project management tool written in elixir + elm

## How to start

You need two scripts:

fc-postgres:

```bash
#!/bin/bash

function stop {
    docker stop postgres
    docker rm postgres
}

function start {
    docker run \
           --name postgres \
           --volume $PWD/postgres-data:/var/lib/postgresql/data \
           --net host \
           --detach \
           --restart=always \
           -e POSTGRES_PASSWORD=___PASSWORD___ \
           -e POSTGRES_USER=postgres \
           postgres:12-alpine
}

function restart {
    stop && start
}

function reload {
    docker exec postgres postgres -s reload
}

$*
```

And fc-grafik:

```bash
#!/bin/bash

function restart {
	stop && start
}

function stop {
	docker stop grafik
	docker rm grafik
}

function start {
	docker run \
		--name grafik \
		--detach \
		--net host \
		--ulimit nofile=65536:65536 \
		-e DATABASE_URL=ecto://postgres:___PASSWORD___@localhost/grafik \
		-e "SECRET_KEY_BASE=___SECRET___" \
		-e MIX_ENV=prod \
		--restart=always \
		finalclass/grafik
}

function logs {
	docker logs -f grafik
}

function sync {
	docker pull finalclass/grafik:latest
	restart
}

$*
```

Replace `___PASSWORD___` and `___SECRET___`. The `___SECRET___` must be big enough. You can generate it with `mix phx.gen.secret`.

Then you can start the database with `fc-postgres start` and the grafik with `fc-grafik start`.
