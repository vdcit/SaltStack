mysqldb:
  pkg.installed:
    - name: python-mysqldb
    - refresh: False
  file.managed:
    - name: /etc/salt/minion
    - source: salt://conf/minion
  service.running:
    - name: salt-minion
    - watch:
      - file: mysqldb
