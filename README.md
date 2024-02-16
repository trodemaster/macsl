# macsl
sudo port install lima
limactl create --name=macsl macsl.yaml

# rebuild
limactl factory-reset macsl
cp ~/code/macsl/macsl.yaml ~/.lima/macsl/lima.yaml
limactl start macsl

# docker usage from host
docker context create lima-macsl --docker "host=unix:///Users/blake/.lima/macsl/sock/docker.sock"
docker context use lima-macsl
docker run --rm -ti --platform linux/amd64 ubuntu:latest