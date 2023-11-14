#!/usr/bin/python3
# this script makes systemd user files to limit memory usage
# usage: python3 make_user_mem_limit_files.py
# based on: https://unix.stackexchange.com/questions/351466/set-a-default-resource-limit-for-all-users-with-systemd-cgroups

# mem_max = '243G'  # 95% aegypti RAM
# mem_max = '486G'  # 95% prospero RAM
mem_max = '95%'   # percentage value allowed

def make_sysd_file(uid, mem_max):
    full_path = '/etc/systemd/system/user-' + str(uid) + '.slice'
    with open(full_path, 'w') as out_file:
        out_file.write('[Slice]\n')
        out_file.write('Slice=user.slice\n')
        out_file.write('MemoryMax={}\n'.format(mem_max))

with open('/etc/passwd', 'r') as in_file:
    for line in in_file:
        line_list = line.split(':')
        uid = int(line_list[2])
        if uid >= 1000 and uid <= 60000:
            make_sysd_file(uid, mem_max)
