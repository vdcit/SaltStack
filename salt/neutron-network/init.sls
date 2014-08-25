neutron_network:
  pkg.installed:
    - pkgs:
{% for pkg in salt['pillar.get']('neutron_network:pkgs', []) %}
      - {{ pkg }}
{% endfor %}

{% for file in salt['pillar.get']('neutron_network:files', [])%}
file_{{ file['name'] }}:
  file.managed:
    - name: {{file['name']}}
    - source: {{file['source']}}
    - user: neutron
    - group: root
    - template: jinja
    - require:
      - pkg: neutron_network
{% endfor %}

{% for service in salt['pillar.get']('neutron_network:services', [])%}
{{service}}:
  service.running:
    - watch:
      - file: file_/etc/sysctl.conf
      - file: file_/etc/neutron/neutron.conf
      - file: file_/etc/neutron/l3_agent.ini
      - file: file_/etc/neutron/dhcp_agent.ini
      - file: file_/etc/neutron/metadata_agent.ini
      - file: file_/etc/neutron/plugins/ml2/ml2_conf.ini
{% endfor %}

create_int:
  cmd.run:
    - name: ovs-vsctl add-br br-int   
    - unless: ovs-vsctl list-br | grep br-int
    - require:
      - service: openvswitch-switch
 
create_ex:
  cmd.run:
    - name: |
        ovs-vsctl add-br br-ex
        ovs-vsctl add-port br-ex {{pillar['neutron_network']['br-ex']}}
    - unless: ovs-vsctl list-br | grep br-ex 
    - require:
      - service: openvswitch-switch
 
profile_1:
  file.managed:
    - name: /root/.profile
    - source: salt://keystone/file/profile
    - template: jinja

admin_openrc:
  file.managed:
    - name: /root/admin-openrc.sh
    - source: salt://keystone/file/admin-openrc.sh
    - template: jinja
