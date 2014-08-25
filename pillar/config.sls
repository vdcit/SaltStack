{% set host1='controller' %}
{% set host2='compute' %}
{% set host3='network' %}

{% set controller_ip='10.10.10.81' %}
{% set compute_ip='10.10.10.82' %}
{% set network_ip='10.10.10.83' %}

{% set compute_tunnel='10.10.20.82' %}
{% set network_tunnel='10.10.20.83' %}

{% set DEFAULT_PASS='1'%}
{% set RABBIT_PASS=DEFAULT_PASS %}
{% set MYSQL_PASS=DEFAULT_PASS %}
{% set ADMIN_TOKEN='admin123' %}

{% set ADMIN_PASS=DEFAULT_PASS %}
{% set ADMIN_EMAIL='trananhkma@admin.com' %}

{% set DEMO_PASS=DEFAULT_PASS %}
{% set DEMO_EMAIL='trananhkma@demo.com' %}

{% set GLANCE_PASS=DEFAULT_PASS %}
{% set GLANCE_EMAIL='trananhkma@glance.com' %}

{% set NOVA_PASS=DEFAULT_PASS %}
{% set NOVA_EMAIL='trananhkma@nova.com' %}

{% set NEUTRON_PASS=DEFAULT_PASS %}
{% set NEUTRON_EMAIL='trananhkma@neutron.com' %}

{% set KEYSTONE_DBPASS=DEFAULT_PASS %}
{% set GLANCE_DBPASS=DEFAULT_PASS %}
{% set NOVA_DBPASS=DEFAULT_PASS %}
{% set NEUTRON_DBPASS=DEFAULT_PASS %}

{% set MYSQL_SERVER=host1 %}
{% set KEYSTONE_SERVER=host1 %}
{% set GLANCE_SERVER=host1%}
{% set NOVA_SERVER=host1 %}
{% set NEUTRON_SERVER=host1%}
{% set RABBIT_HOST=host1 %}

{% set METADATA_SECRET=ADMIN_TOKEN %}
{% set INTERFACE_NAME='eth1'%}

rabbitmq:
  rabbit_pass: {{ RABBIT_PASS }}
  rpc_backend: rabbit
  host: {{ RABBIT_HOST }}
mysql:
  server:
    source: salt://mysql/file/my.cnf
    root_pass: {{ MYSQL_PASS }}
    bind-address: {{ MYSQL_SERVER }}
  users:
    - name: keystone
      host: ['localhost', '%']
      pass: {{ KEYSTONE_DBPASS }}
      privileges: all privileges
      db_name: keystone
    - name: glance
      host: ['localhost', '%']
      pass: {{ GLANCE_DBPASS }}
      privileges: all privileges
      db_name: glance
    - name: nova
      host: ['localhost', '%']
      pass: {{ NOVA_DBPASS }}
      privileges: all privileges
      db_name: nova
    - name: neutron
      host: ['localhost', '%']
      pass: {{ NEUTRON_DBPASS }}
      privileges: all privileges
      db_name: neutron
  database:
    - keystone
    - glance
    - nova
    - neutron
  
users:
  - name: glance
    pass: {{ GLANCE_PASS }}
    email: {{ GLANCE_EMAIL }}
    roles: ['admin']
    tenant: service
  
  - name: nova
    pass: {{ NOVA_PASS }}
    email: {{ NOVA_EMAIL }}
    roles: ['admin']
    tenant: service

  - name: neutron
    pass: {{ NEUTRON_PASS }}
    email: {{ NEUTRON_EMAIL }}
    roles: ['admin']
    tenant: service


services:
  - name: glance
    type: image
    description: OpenStack Image Service
  - name: nova
    type: compute
    description: OpenStack Compute
  - name: neutron
    type: network
    description: OpenStack Networking

endpoints:
  - service: glance
    publicurl: 'http://{{ GLANCE_SERVER }}:9292'
    internalurl: 'http://{{ GLANCE_SERVER }}:9292'
    adminurl: 'http://{{ GLANCE_SERVER }}:9292'
    type: image

  - service: nova
    publicurl: http://{{ NOVA_SERVER }}:8774/v2/%\(tenant_id\)s
    internalurl: http://{{ NOVA_SERVER }}:8774/v2/%\(tenant_id\)s
    adminurl: http://{{ NOVA_SERVER }}:8774/v2/%\(tenant_id\)s
    type: compute
    
  - service: neutron
    publicurl: 'http://{{ NEUTRON_SERVER }}:9696'
    adminurl: 'http://{{ NEUTRON_SERVER }}:9696'
    internalurl: 'http://{{ NEUTRON_SERVER }}:9696'
    type: network

keystone:
  pkgs:
    - keystone
  admin_token: {{ ADMIN_TOKEN }}
  admin_pass: {{ ADMIN_PASS }}
  db_name: keystone
  db_user: keystone
  db_pass: {{ ADMIN_PASS }}
  bind-address: {{ KEYSTONE_SERVER }}
  tenants:
    - name: admin
      description: Admin Tenant
    - name: demo
      description: Demo Tenant
    - name: service
      description: Service Tenant
  service:
    - name: keystone
      type: identity
      description: OpenStacK Identity
  users:
    - name: admin
      pass: {{ ADMIN_PASS }}
      email: {{ ADMIN_EMAIL }} 
      roles: ['admin','_member_']
      tenant: admin
    - name: demo
      pass: {{ DEMO_PASS }}
      email: {{ DEMO_EMAIL }}
      roles: ['_member_']
      tenant: demo  
  role: admin
  endpoint:
    - service: keystone
      publicurl: 'http://{{ KEYSTONE_SERVER }}:5000/v2.0'
      internalurl: 'http://{{ KEYSTONE_SERVER }}:5000/v2.0'
      adminurl: 'http://{{ KEYSTONE_SERVER }}:35357/v2.0'
      type: identity
  adminurl: 'http://{{ KEYSTONE_SERVER }}:35357/v2.0'

glance:
  pkgs:
    - glance
    - python-glanceclient
  db_name: glance
  db_user: glance
  db_pass: {{ GLANCE_DBPASS }}
  bind-address: {{ GLANCE_SERVER }}
  services:
    - glance-registry
    - glance-api
  tenant: service
  user: glance
  pass: {{ GLANCE_PASS }}
    
nova:
  pkgs:
    - nova-api
    - nova-cert
    - nova-conductor
    - nova-consoleauth
    - nova-novncproxy
    - nova-scheduler
    - python-novaclient
  source: salt://nova/file/nova.conf
  db_name: nova
  db_user: nova
  db_pass: {{ NOVA_DBPASS }}
  bind-address: {{ NOVA_SERVER }}
  my_ip: {{ controller_ip }}
  services:
    - nova-api
    - nova-cert
    - nova-consoleauth
    - nova-scheduler
    - nova-conductor
    - nova-novncproxy
  tenant: service
  user: nova
  pass: {{ NOVA_PASS }}
  metadata: {{ METADATA_SECRET}}
    
nova_compute:
  pkgs:
    - nova-compute-kvm
    - python-guestfs
  source: salt://nova/file/nova-compute.conf
  db_name: nova
  db_user: nova
  db_pass: {{ NOVA_DBPASS }}
  bind-address: {{ NOVA_SERVER }}
  my_ip: {{ compute_ip }}
  services:
    - nova-compute
  tenant: service
  user: nova
  pass: {{ NOVA_PASS }}

neutron_controller:
  pkgs:
    - neutron-server
    - neutron-plugin-ml2
  files:
    - name: /etc/neutron/neutron.conf
      source: salt://neutron-controller/file/neutron.conf
    - name: /etc/neutron/plugins/ml2/ml2_conf.ini
      source: salt://neutron-controller/file/ml2_conf.ini
  db_name: neutron
  db_user: neutron
  db_pass: {{ NEUTRON_DBPASS }}
  bind-address: {{ NEUTRON_SERVER }}
  my_ip: {{ controller_ip }}
  services:
    - nova-api
    - nova-scheduler
    - nova-conductor
    - neutron-server
  tenant: service
  user: neutron
  pass: {{ NEUTRON_PASS }}
  neutron_url: 'http://{{ NEUTRON_SERVER }}:9696'
  adminurl: 'http://{{ KEYSTONE_SERVER }}:35357/v2.0'
  
neutron_compute:
  pkgs:
    - neutron-common
    - neutron-plugin-ml2
    - neutron-plugin-openvswitch-agent
  files:
    - name: /etc/neutron/neutron.conf
      source: salt://neutron-compute/file/neutron.conf
    - name: /etc/neutron/plugins/ml2/ml2_conf.ini
      source: salt://neutron-compute/file/ml2_conf.ini
    - name: /etc/sysctl.conf
      source: salt://neutron-compute/file/sysctl.conf
  services:
    - openvswitch-switch
    - nova-compute
    - neutron-plugin-openvswitch-agent
  tenant: service
  user: neutron
  pass: {{ NEUTRON_PASS }}
  tunnel: {{ compute_tunnel }}

neutron_network:
  pkgs:
    - neutron-plugin-ml2
    - neutron-plugin-openvswitch-agent
    - neutron-l3-agent
    - neutron-dhcp-agent
  files:
    - name: /etc/sysctl.conf
      source: salt://neutron-network/file/sysctl.conf
    - name: /etc/neutron/neutron.conf
      source: salt://neutron-network/file/neutron.conf
    - name: /etc/neutron/l3_agent.ini
      source: salt://neutron-network/file/l3_agent.ini
    - name: /etc/neutron/dhcp_agent.ini
      source: salt://neutron-network/file/dhcp_agent.ini
    - name: /etc/neutron/metadata_agent.ini
      source: salt://neutron-network/file/metadata_agent.ini
    - name: /etc/neutron/plugins/ml2/ml2_conf.ini
      source: salt://neutron-network/file/ml2_conf.ini
  br-ex: {{ INTERFACE_NAME}}
  tunnel: {{ network_tunnel }}
  services:
    - openvswitch-switch
    - neutron-plugin-openvswitch-agent
    - neutron-l3-agent
    - neutron-dhcp-agent
    - neutron-metadata-agent

horizon:
  pkgs:
    - apache2
    - memcached
    - libapache2-mod-wsgi
    - openstack-dashboard
  services:
    - apache2
    - memcached
  
