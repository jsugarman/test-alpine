# README

Example rails 5 app with Dockerfile to run the app in an Alpine (linux) container

* Prerequisites
  - clone repo
  - install docker (for mac or otherwise)


* Build and run locally

Build:
```
docker build -f Dockerfile -t rails-alpine-test:latest .
```

Run:
```
docker run -it -p 3000:3000 rails-alpine-test:latest
```

Test:
[localhost:3000](http://localhost:3000)
