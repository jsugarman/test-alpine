# Dockerized Rails on alpine

Example rails 5 app using docker compose to run the app in an Alpine (linux) container

## Prerequisites

- clone repo
- install docker v3+ (for mac or otherwise)

#### Building using docker-compose

For docker-compose certain options should ideally be set in
the `docker-compose.yml` file. Environment variables, in particular,
are better specified in there using the `environment:` key.

Build containers:

```bash
docker-compose build
```

Run containers:

```bash
docker-compose up
```

Build and run:

```bash
docker-compose up --build
```

Create/migrate DB: with the docker containers running (`docker-compose up`)
in another terminal

```bash
# In another terminal while containers running
docker-compose run --rm web bundle exec rails db:setup
docker-compose run --rm web bundle exec rails db:migrate
```

Interactive shell in web (app) container:

```text
$ docker-compose exec web sh
/app # rails console
irb(main):001:0> Employee.first
```

Interactive shell in db container, login to postgres,
connect to apps db, query first employee

```text
$ docker-compose exec db sh
/# psql -U postgres
postgres=# \c db
db=# select * from employees limit(1);
```

Test:
[localhost](http://localhost)

#### Building Using plain docker

WARNING: For this to work you will need to uncomment/create an ENTRYPOINT/CMD in the
dockerfile add `ENV DATABASE_URL=postgres://postgres@db` to the Dockerfile. I have
not test this since moving to docker-compose though.

Build:

```bash
docker build -f Dockerfile -t rails-alpine-test:latest .
```

Run:

```bash
docker run -it -p 80:5000 rails-alpine-test:latest
```

### Docker cleanup cheatsheet

see [linuxize](https://linuxize.com/post/how-to-remove-docker-images-containers-volumes-and-networks/)

- cleanup containers

```bash
# list all containers
docker container ls -a
```

```bash
# remove all stopped containers, dangling images
# and unused networks (and volumes with option)
docker system prune
docker system prune --volumes
```

```bash
# list all stopped containers
docker container ls -a --filter status=exited --filter status=created
```

```bash
# remove all stopped containers
docker container prune
```

- cleanup images

```bash
# list all images
docker image ls -a
```

```bash
# remove all images not referenced by an existing container
docker image prune -a
```

```bash
# remove all images not referenced by an existing container created more than 12hours ago
docker image prune -a --filter "until=12h"
```

```bash
# Hard ball it
# Stop all containers, remove all containers, remove all unreferenced images
docker container stop $(docker container ls -aq)
docker container prune
docker image prune -a
```

#### Useful links

[dockerize-a-rails-5-postgres-redis-sidekiq-action-cable-app-with-docker-compose](https://nickjanetakis.com/blog/dockerize-a-rails-5-postgres-redis-sidekiq-action-cable-app-with-docker-compose)

[linuxize](https://linuxize.com/post/how-to-remove-docker-images-containers-volumes-and-networks/)