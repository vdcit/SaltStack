base:
  '*':
    - ntp
    - mysqldb
  'controller':
    - mysql
    - rabbitmq
    - keystone
    - keystone.create
    - glance
    - create_user_tenant
    - nova
    - neutron-controller
    - horizon
  'compute':
    - nova.compute
    - neutron-compute
  'network':
    - neutron-network

