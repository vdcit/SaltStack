include:
  - mysql
  - keystone
  - keystone.create

{% set ADMIN='admin'%}
{% set PASS=salt['pillar.get']('keystone:admin_pass', '1') %}
{% set AUTH_URL=salt['pillar.get']('keystone:adminurl', '') %}
{% set TENANT='admin' %}
{% set keystone="keystone --os-username=" ~ ADMIN ~ " --os-password=" ~ PASS ~ " --os-tenant-name=" ~ TENANT ~ " --os-auth-url=" ~ AUTH_URL %}

{% for user in salt['pillar.get']('users', []) %}
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
{% endfor %}
{% endfor %}

{% for service in salt['pillar.get']('services', []) %}
create_service_{{ service['name'] }}:
  cmd.run:
    - name: {{ keystone }} service-create --name="{{ service['name'] }}" --type="{{ service['type'] }}" --description="{{ service['description'] }}"
    - unless: {{ keystone }} service-list | grep {{ service['name'] }}
{% endfor %}
    
{% for endpoint in salt['pillar.get']('endpoints', []) %}
create_endpoint_{{ endpoint['service'] }}:
  cmd.run:
    - name: {{ keystone }} endpoint-create --service-id=$({{ keystone }} service-list | awk '/ {{ endpoint['type'] }} / {print $2}') --publicurl={{ endpoint['publicurl']}} --internalurl={{ endpoint['internalurl']}} --adminurl={{ endpoint['adminurl']}}
    - unless: {{ keystone }} endpoint-list | grep $({{ keystone }} service-list | awk '/ {{ endpoint['type'] }} / {print $2}')
    - require:
      - cmd: create_service_{{ endpoint['service'] }}
{% endfor %}
