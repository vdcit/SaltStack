neutron_controller:
  pkg.installed:
    - pkgs:
{% for pkg in salt['pillar.get']('neutron_controller:pkgs', [])%}
      - {{ pkg }}
{% endfor %}

{% for file in salt['pillar.get']('neutron_controller:files', [])%}
{{ file['name']}}:
  file.managed:
    - source: {{ file['source']}}
    - user: neutron
    - group: root
    - template: jinja
{% endfor %}

{% set ADMIN='admin'%}
{% set PASS=salt['pillar.get']('keystone:admin_pass', '1') %}
{% set AUTH_URL=salt['pillar.get']('keystone:adminurl', '') %}
{% set TENANT='admin' %}
{% set keystone="keystone --os-username=" ~ ADMIN ~ " --os-password=" ~ PASS ~ " --os-tenant-name=" ~ TENANT ~ " --os-auth-url=" ~ AUTH_URL %}

nova_admin_tenant_id:
 cmd.run:
  - name: sed -r -i "s/^nova_admin_tenant_id.*/nova_admin_tenant_id = $({{ keystone }} tenant-get service | awk '/ id / {print $4}')/" /etc/neutron/neutron.conf
  - require:
     - file: /etc/neutron/neutron.conf


{% for service in salt['pillar.get']('neutron_controller:services', [])%}
rd_{{ service }}:
  service.running:
    - name: {{ service }}
    - watch:
      - file: /etc/neutron/neutron.conf
      - file: /etc/neutron/plugins/ml2/ml2_conf.ini
{% endfor %}


