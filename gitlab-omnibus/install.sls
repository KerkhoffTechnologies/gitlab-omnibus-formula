{% from "gitlab-omnibus/map.jinja" import gitlab_omnibus with context %}

include:
  - gitlab-omnibus.repository

gitlab.install:
  pkg.installed:
    - pkgs: {{ gitlab_omnibus.pkgs|json }}

{%- if grains["virtual"]|lower == 'lxc' %}
gitlab.patch.lxc:
  file.replace:
    - name: /opt/gitlab/embedded/cookbooks/package/resources/sysctl.rb
    - pattern: 'command "cat.*$'
    - repl: 'command "true"'
    - show_changes: True
    - backup: False
    - require:
      - pkg: gitlab.install
{%- endif %}

#gitlab-reconfigure:
  #cmd.wait:
    #- name: "gitlab-ctl reconfigure"
    #- env:
        #EXTERNAL_URL: {{ gitlab_omnibus.url }}
    #- watch:
      #- pkg: gitlab.install
      #- file: gitlab.patch.lxc
    #- require:
      #- file: gitlab.patch.lxc
