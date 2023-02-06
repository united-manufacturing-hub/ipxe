# Cleanup output directory
Remove-Item -Path output -Recurse -Force | Out-Null

# Create output directory
New-Item -Path output -ItemType Directory | Out-Null

# Update submodules
git submodule update --init --recursive

docker build -t unitedmanufacturinghub/ipxe:latest --build-arg CACHEBUST=$((New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date)).TotalSeconds) .
docker run -v ${PWD}\output:/output -it unitedmanufacturinghub/ipxe:latest
sleep 5
docker rmi unitedmanufacturinghub/ipxe:latest
