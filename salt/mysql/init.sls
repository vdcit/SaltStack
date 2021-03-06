include:
  - mysqldb

mysql-server:
  pkg:
    - installed
    - refresh: False
  file.managed:
    - name: /etc/mysql/my.cnf
    - source: {{ pillar['mysql']['server']['source'] }}
    - user: root
    - group: root
    - mode: 644
    - template: jinja
  service.running:
    - name: mysql
    - require:
      - pkg: mysql-server
    - watch:
      - file: mysql-server

{% for db in salt['pillar.get']('mysql:database', []) %}
create_db_{{ db }}:
  mysql_database.present:
    - name: {{ db }}
    - require:
      - pkg: mysqldb
      - service: mysql-server
{% endfor %}

{% for user in salt['pillar.get']('mysql:users', []) %}
{% for host in user['host'] %}
create_user_{{ user['name'] }}_host_{{ host }}:
  mysql_user.present:
    - name: {{ user['name'] }}
    - host: "{{ host }}"
    - password: "{{ user['pass'] }}"
    - require:
      - pkg: mysqldb
      - service: mysql-server
  mysql_grants.present:
    - grant: "{{ user['privileges'] }}"
    - database: "{{ user['db_name'] }}.*"
    - user: {{ user['name'] }}
    - host: "{{ host }}"
    - require:
      - mysql_database: create_db_{{ user['db_name'] }}
      - mysql_user: create_user_{{ user['name'] }}_host_{{ host }}
{% endfor %}
{% endfor %}
