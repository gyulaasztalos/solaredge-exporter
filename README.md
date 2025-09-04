# solaredge-exporter
Custom Docker image for SolarEdge-Exporter

Daily running GitHub Actions workflow which creates docker image of the latest source of SolarEdge-Exporter
(https://github.com/tomirgang/SolarEdge-Exporter/ forked from dave92082/SolarEdge-Exporter)

Using custom Dockerfile with alpine base image and non-root user.
Only x86_64 and ARM64 are supported.

The image is available on DockerHub: https://hub.docker.com/r/asztalosgyula/solaredge-exporter
