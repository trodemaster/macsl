# macsl
sudo port install lima
limactl create --name=macsl macsl.yaml

# rebuild
limactl factory-reset macsl
cp ~/code/macsl/macsl.yaml ~/.lima/macsl/lima.yaml
limactl start macsl
