mysql-server:
  pkg:
    - installed
  file.managed:
    - name: /etc/mysql/my.cnf
    - source: salt://mysql/file/my.cnf
    - user: root
    - password: '1'
    - group: root
  require:
    - pkg: mysql-server
    - file: /etc/mysql/my.cnf
  service:
    - name: mysql
    - running
    - reload: true
    - enable: true
  cmd.run:
    - name: sleep 3

/etc/salt/minion:
  file.managed:
    - source: salt://mysql/file/minion
