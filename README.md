This folder contains the dockerfiles for creating the image for the ConPaaS
container.

To test it out in vagrant run "vagrant up". It should be possible to connect
via vagrant ssh or by http on localhost port 8080.

The startup for the container expects to read configuration information from
the following environment variables:

- DIRECTOR_URL
- USERNAME
- PASSWORD
- EMAIL
