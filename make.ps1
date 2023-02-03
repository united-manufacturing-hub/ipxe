# Cleanup output directory
Remove-Item -Path output -Recurse -Force | Out-Null

# Create output directory
New-Item -Path output -ItemType Directory | Out-Null

docker run -v ${PWD}\output:/output -it $(docker build -q .)
