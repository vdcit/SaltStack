include:
  - keystone

{% set OS_SERVICE_TOKEN=salt['pillar.get']('keystone:admin_token', 'ADMIN') %}
{% set OS_SERVICE_ENDPOINT='http://'~ salt['pillar.get']('keystone:bind-address', '127.0.0.1') ~':35357/v2.0' %}
{% set keystone="keystone --os-token=" ~ OS_SERVICE_TOKEN ~ " --os-endpoint=" ~ OS_SERVICE_ENDPOINT %}

{% for tenant in salt['pillar.get']('keystone:tenants', []) %}
create_tenant_{{ tenant['name'] }}:
  cmd.run:
    - name: {{ keystone }} tenant-create --name="{{ tenant['name'] }}" --description="{{ tenant['description'] }}"
    - unless: {{ keystone }} tenant-list | grep {{ tenant['name'] }}
{% endfor %}

create_role_{{ pillar['keystone']['role'] }}:
  cmd.run:
    - name: {{ keystone }} role-create --name="{{ pillar['keystone']['role'] }}"
    - unless: {{ keystone }} role-list | grep {{ pillar['keystone']['role'] }}


{% for user in salt['pillar.get']('keystone:users', []) %}
create_user_{{ user['name'] }}:
  cmd.run:
    - name: {{ keystone }} user-create --name="{{ user['name'] }}" --pass="{{ user['pass'] }}" --email="{{ user['email'] }}"
    - unless: {{ keystone }} user-list | grep {{ user['name'] }}
{% for role in user['roles'] %}
user_{{ user['name'] }}_role_{{ role }}:
  cmd.run:
    - name: {{ keystone }} user-role-add --user="{{ user['name'] }}" --tenant="{{user['tenant']}}" --role="{{ role }}"
    - unless: {{ keystone }} user-role-list --user {{ user['name'] }} --tenant {{ user['tenant'] }} | grep $({{ keystone }} user-list | grep {{ user['name'] }} | awk '{print $2}')
    - require:
      - cmd: create_tenant_{{ user['tenant'] }}
      - cmd: create_user_{{ user['name'] }}
      - cmd: create_role_{{ pillar['keystone']['role'] }}
{% endfor %}
{% endfor %}

{% for service in salt['pillar.get']('keystone:service', []) %}
create_service_{{ service['name'] }}:
  cmd.run:
    - name: {{ keystone }} service-create --name="{{ service['name'] }}" --type="{{ service['type'] }}" --description="{{ service['description'] }}"
    - unless: {{ keystone }} service-list | grep {{ service['name'] }}
{% endfor %}
    
{% for endpoint in salt['pillar.get']('keystone:endpoint', []) %}
create_endpoint_{{ endpoint['service'] }}:
  cmd.run:
    - name: {{ keystone }} endpoint-create --service-id="$({{ keystone }} service-list | awk '/ {{ endpoint['type'] }} / {print $2}')" --publicurl="{{ endpoint['publicurl']}}" --internalurl="{{ endpoint['internalurl']}}" --adminurl="{{ endpoint['adminurl']}}"
    - unless: {{ keystone }} endpoint-list | grep $({{ keystone }} service-list | awk '/ {{ endpoint['type'] }} / {print $2}')
    - require:
      - cmd: create_service_{{ endpoint['service'] }}
{% endfor %}

/root/admin-openrc.sh:
  file.managed:
    - source: salt://keystone/file/admin-openrc.sh
    - template: jinja

profile:
  file.managed:
    - name: /root/.profile
    - source: salt://keystone/file/profile
    - template: jinja
    - require:
      - cmd: create_user_admin
      - cmd: create_endpoint_keystone

