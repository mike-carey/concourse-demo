# Concourse Demo

## Cloning
```
git clone --recursive https://github.com/mcarey-solstice/concourse-demo
```

## Requirements
- [GNU Make](https://www.gnu.org/software/make/) (Default with UNIX and Linux)
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

## Docker Services

### Starting the Concourse Services
Creates three docker containers: database, worker, web.
```
make start
```

The Web UI can be accessed at __http://localhost:8080__

### Stopping the Concourse Services
Stop the docker services defined in the `docker-compose` file.
```
make stop
```

### Destroying the Concourse Services
Destroy all the docker services and generated keys.
```
make destroy
```

## Pipelines

### Running all pipelines
```
make pipelines
```

### Seeing all available pipelines
```
make list-pipelines
```

### Running a certain pipeline
Given a pipeline called `$foo` and a directory in `pipelines/[0-9][0-9]_$foo`:
```
make $foo
```
