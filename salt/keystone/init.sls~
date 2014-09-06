include:
  - mysql

keystone_pkgs:
  pkg.installed:
    - refresh: False
    - pkgs:
{% for pkg in salt['pillar.get']('keystone:pkgs', []) %}
      - {{ pkg }}
{% endfor %}

  file.managed:
    - name: /etc/keystone/keystone.conf
    - source: salt://keystone/file/keystone.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - pkg: keystone_pkgs
  cmd.run:
    - name: keystone-manage db_sync
    - unless: mysql -e 'show tables from {{ pillar['keystone']['db_name'] }}' | grep user
    - require:
      - service: mysql-server
      - mysql_database: create_db_keystone
      - file: keystone_pkgs
  service.running:
    - name: keystone
    - watch:
      - file: keystone_pkgs
      - cmd: keystone_pkgs
    - require:
      - pkg: keystone_pkgs

/var/lib/keystone/keystone.db:
  file:
    - absent
    - require:
      - pkg: keystone_pkgs

cron:
  cmd.run:
    - name: (crontab -l -u keystone 2>&1 | grep -q token_flush) || echo '@hourly /usr/bin/keystone-manage token_flush >/var/log/keystone keystone-tokenflush.log 2>&1' >> /var/spool/cron/crontabs/keystone
