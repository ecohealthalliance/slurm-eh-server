# Documents about manager server memory

## adjust swapfile size
1. Check available disk space: `df -h`
1. Check existing swap: `sudo swapon --show`
1. Turn off all swap: `sudo swapoff -a`
1. Resize swap: `sudo dd if=/dev/zero of=/swapfile bs=1G count=8`
  * Assumes /swapfile exists
  * New space is 8G = bs (1G) x count (8)
1. Change permissions: `sudo chmod 600 /swapfile`
1. Make swapfile usable as swap: `sudo mkswap /swapfile`
1. Activate swap file: `sudo swapon /swapfile`
1. Update /etc/fstab by adding: `/swapfile none swap sw 0 0`
1. Check available swap: `grep SwapTotal /proc/meminfo`

## add user systemd limit for user
1. create file /etc/systemd/system/user-1000.slice (for user with UID = 1000)
  * file contents: `[Slice]\nSlice=user.slice\nMemoryHigh=1G\nMemoryMax=2G`

## memory limit script added to reservoir
1. added script in reservoir/scripts
1. Added script to reservoir/Dockerfile.base and reservoir/Dockerfile.gpu: `COPY /scripts/make_user_mem_limit_files.py /reservoir_scripts/make_user_mem_limit_files.py`
1. Run script during deploy by adding lines to eha-servers/deploy-reservoir.yml at line 58:
  * name: add systemd user memory limit files\ncommand: docker exec -it reservoir_rstudio_1
