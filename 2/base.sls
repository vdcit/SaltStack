network_conf:
  file.managed:
    - name: /etc/network/interfaces
    - source: salt://conf/ip2
net_reload:
  cmd.run:
    - name: ifdown eth0 eth1 eth2 && ifup eth0 eth1 eth2


hostname:
  cmd.run:
    - name: |
       echo compute > /etc/hostname
       hostname compute
  file.managed:
    - name: /etc/hosts
    - source: /conf/hosts


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
  service:
    - running
    - enable: true


minion_mysql:
  file.managed:
    - name: /etc/salt/minion
    - source: salt://conf/minion
  cmd.run:
    - name: service salt-minion restart







