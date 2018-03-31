{% from "gitlab-omnibus/map.jinja" import gitlab_omnibus with context %}

include:
  - gitlab-omnibus.repository

# Separate salt generated file so we don't have to manage the huge main one
# In time, if the templated one can be complete enough, we can switch to
# fully generated and vet/implement every single config change from upstream
gitlab.config:
  file.managed:
    - name: {{ gitlab_omnibus.config_file }}
    - source: {{ gitlab_omnibus.config_file_source }}
    - template: jinja
    - mode: 644

# Include the salt generated gitlab config file
gitlab.config.include:
  file.append:
    - name : /etc/gitlab/gitlab.rb
    - text :
      - "from_file '{{ gitlab_omnibus.config_file }}'"
    - require:
      - file: gitlab.config

# Run the gitlab reconfigure command on changes
# TODO Should also trigger the service restart
gitlab.reconfigure:
  cmd.wait:
    - name: "gitlab-ctl reconfigure"
    - watch:
      - file: gitlab.config
    - require:
      - file: gitlab.config.include
      - file: gitlab.config
