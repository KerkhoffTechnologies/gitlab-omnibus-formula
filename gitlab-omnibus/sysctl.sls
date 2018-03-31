{% from "gitlab-omnibus/map.jinja" import gitlab_omnibus with context %}

{# If sysctl kernel.shmmax is read only                 #}
{# Then we are in container and gitlab config will fail #}

test-sysctl:
  cmd.run:
    - name: "cat /proc/sys/kernel/shmall > /proc/sys/kernel/shmall"
