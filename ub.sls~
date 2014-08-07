network-conf:
  file.managed:
    - name: /etc/network/interfaces
    - source: salt://base/interfaces

net-reload:
  cmd.run:
    - name: ifdown eth0 eth1 && ifup eth0 eth1

apache2:
  pkg:
    - installed
  service:
    - running
    - enable: true

ntp:
  pkg:
    - installed
  service:
    - running
    - enable: true

mysql:
  pkg:
    - installed
    - pkgs:
      - python-mysqldb
      - mysql-server
mysql-cfg:
  file.managed:
    - name: /etc/mysql/my.cnf
    - source: salt://base/my.cnf
mysql-reload:
  cmd.run:
    - name: service mysql restart

minion-mysql:
  file.managed:
    - name: /etc/salt/minion
    - source: salt://base/minion
  cmd.run:
    - name: service salt-minion restart

