# Documents related to backup up whole Docker containers

# backup from a Docker image:
1. `docker commit [container_id] [container-name_backup-image]`
1. `docker save -o container-name_backup.tar [container-name-backup-image]`

# backup from a Docker container:
`docker export -o container-name-backup.tar [container_id]`

# backup volumes
1. `docker-volumes.sh [container_id] save name-volumes.tar`
1. `gzip name-volumes.tar`

# restore image from tar file
docker load -i /tmp/repel-infrastructure-scraper-backup.tar
