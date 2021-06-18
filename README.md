# super-potato-docker
docker setup for [super-potato](https://github.com/cleptric/super-potato)

# Requirements
To build and run a super-potato docker container you need [docker](https://docs.docker.com/get-docker/) and [docker-compose](https://docs.docker.com/compose/install/).

# Build and Run
Init the super-potato sub module
```
git submodule init
git submodule update
```

Create an .env file:
```
cp env.example .env
```

Now you can build the container using docker-compose
```
docker-compose build
```
and run it
```
docker-compose up -d
```

The container can now be reached under http://localhost:8080.

The logs can be accessed using
```
docker-compose logs
```

# License
Published under the MIT License. See [LICENSE](./LICENSE) for details.