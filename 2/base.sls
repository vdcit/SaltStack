network_conf:
  file.managed:
    - name: /etc/network/interfaces
    - source: salt://conf/ip2
net_reload:
  cmd.run:
    - name: ifdown eth0 eth1 eth2 && ifup eth0 eth1 eth2


hostname:
  file.managed:
    - name: /etc/hosts
    - source: salt://conf/hosts


ntp:
  pkg:
    - installed
  service:
    - running
    - enable: true


mysql:
  pkg:
    - name: python-mysqldb
    - installed


minion_mysql:
  file.managed:
    - name: /etc/salt/minion
    - source: salt://conf/minion
  cmd.run:
    - name: service salt-minion restart







