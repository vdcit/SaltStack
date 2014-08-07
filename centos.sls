Httpd:
  pkg:
    - installed
    - pkgs:
      - httpd
      - php
      - php-mysql

File-change:
  file.managed:
    - name: /etc/sysconfig/selinux
    - source: salt://conf/selinux

IP6:
  cmd.run:
    - name: service ip6tables stop

IP4:
  cmd.run:
    - name: service iptables stop

Httpd-reload:
  cmd.run:
    - name: service httpd restart


Mysql:
  pkg:
    - name: mysql-server
    - latest
  service:
    - name: mysqld
    - running
    - enable: true


