base:
  '*':
    - ntp
    - mysqldb
  'controller':
    - mysql
    - mysql.create
    - rabbitmq

