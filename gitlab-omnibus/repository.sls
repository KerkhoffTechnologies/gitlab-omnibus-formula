{% from "gitlab-omnibus/map.jinja" import gitlab_omnibus with context %}

{% if grains['os_family'] in ['Debian'] %}
gitlab.apt.https:
  pkg.installed:
    - name: apt-transport-https
    - require_in:
      - pkgrepo: gitlab.repository
{% endif %}

gitlab.repository:
  {% if grains['os_family'] in ['Debian'] %}
  pkgrepo.managed:
    - humanname: Gitlab upstream package repository
    - file: {{ gitlab_omnibus.apt_source_file }}
    - name: deb {{ gitlab_omnibus.apt_repository_url }}/{{ grains['os'].lower() }}/ {{ grains['oscodename'] }} main
    - key_url: https://packages.gitlab.com/gitlab/gitlab-ce/gpgkey
    - require_in:
      - pkg: gitlab.install
  {% endif %}
