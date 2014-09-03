base:
  'controller':
    - ntp.controller
    - mysql
    - rabbitmq
    - keystone
    - create_user_tenant
    - glance
    - nova
    - neutron-controller
    - horizon
  'compute':
    - ntp
    - mysqldb
    - nova.compute
    - neutron-compute
  'network':
    - ntp
    - mysqldb
    - neutron-network

