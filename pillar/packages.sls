pkg:
{% if grains['os_family'] == 'RedHat' %}
  apache: httpd
  mysql: mysqld
{% elif grains['os_family'] == 'Debian' %}
  mysql: mysql-server
  apache: apache2
{% endif %}
