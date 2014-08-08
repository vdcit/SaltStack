{% if grains['host'] == 'controller' %}
mysql: mysql-server
my_ser: mysql
{% else %}
mysql: python-mysqldb
my_ser: ntp
{% endif %}
