# Cleanup output directory
Remove-Item -Path output -Recurse -Force | Out-Null

# Create output directory
New-Item -Path output -ItemType Directory | Out-Null

# Update submodules
git submodule update --init --recursive

docker build -t unitedmanufacturinghub/ipxe:latest .
docker run -v ${PWD}\output:/output -it unitedmanufacturinghub/ipxe:latest
