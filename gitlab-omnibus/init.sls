{% from "gitlab-omnibus/map.jinja" import gitlab_omnibus with context %}

{% if grains['os_family'] in ['Debian'] %}
gitlab-apt-https:
  pkg.installed:
    - name: apt-transport-https
    - require_in:
      - pkgrepo: gitlab-omnibus
{% endif %}


#  file.append:
#    - name : /etc/gitlab/gitlab.rb
#    - text :
#      - "postgresql['shared_buffers'] = \"100MB\" # recommend value is 1/4 of total RAM, up to 14GB."
#    - require: 
#      - pkg: gitlab-omnibus


#todo - Test if LXC Container as we can't set shmmax for the postgres component
#       for now, we just disable the sysctl reload.
#       Also, Proxmox LXC containers and ACLs will cause gitlab to bork on socket permissions
#       Set a fail handler if ACL support is active and container type is LXC+Proxmos
#       and alert for acl=0 rootfs option to be set (pct set rootfs)
#       Might also be possible just to wipe or set acls on /opt/gitlab /var/opt/gitlab?
#       though this is a hypervisor restrictions to don't think that will do it

#todo - Setup backup - cron

#todo - Setup https + letsencrypt.org

gitlab-patch-lxc:
  file.replace: 
    - name: /opt/gitlab/embedded/cookbooks/gitlab/definitions/sysctl.rb
    - pattern: 'command "cat.*$'
    - repl: 'command "true"'
    - show_changes: True
    - require: 
      - pkg: gitlab-omnibus

gitlab-reconfigure:
  cmd.wait:
    - name: "gitlab-ctl reconfigure"
    - watch:
      - pkg: gitlab-omnibus
      - file: gitlab-patch-lxc
    - require:
      - file: gitlab-patch-lxc

gitlab-omnibus:
  {% if grains['os_family'] in ['Debian'] %}
  pkgrepo.managed:
    - humanname: Gitlab upstream package repository
    - file: {{ gitlab_omnibus.apt_source_file }}
    - name: deb {{ gitlab_omnibus.apt_repository_url }}/{{ grains['os'].lower() }}/ {{ grains['oscodename'] }} main
    - key_url: https://packages.gitlab.com/gpg.key
    - require_in:
      - pkg: gitlab-omnibus
  {% endif %}

  pkg.installed:
    - pkgs: {{ gitlab_omnibus.pkgs|json }}

#todo - Omnibus runs via inittab on the test LXC / Proxmox container I used
#       So there is no 'service' as far as saltstack can see
#       The container template doesn't use systemd - what does Gitlab do with that ?
#         service.running:
#    - enable: True
#    - watch:
#      - pkg: gitlab-omnibus
