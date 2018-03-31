{% from "gitlab-omnibus/map.jinja" import gitlab_omnibus with context %}

gitlab.service:
{% if salt['pillar.get']('gitlab_omnibus:enable', True) %}
  service.running:
    - name: {{ gitlab_omnibus.service }}
    - enable: True
    - reload: True
    - require:
      - pkg: gitlab.install
      - file: gitlab.config
{% else %}
  service.dead:
    - name: {{ gitlab_omnibus.service }}
    - enable: False
{% endif %}
