sysctl_network:
  file.managed:  
    - name: /etc/sysctl.conf
    - source: salt://neutron-network/file/sysctl.conf

sysctl_apply:
  cmd.run:
    - name: sysctl -p
    - require:
      - file: sysctl_network

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
    - mode: 644
    - template: jinja
    - require:
      - pkg: neutron_network
{% endfor %}

{% for service in salt['pillar.get']('neutron_network:services', [])%}
{{service}}:
  service.running:
    - watch:
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

edit_network:
  file.managed:
    - name: /etc/network/interfaces
    - source: salt://neutron-network/file/interfaces
    - require:
      - cmd: create_ex

restart_network:
  cmd.run:
    - name: |
        ifdown eth1 && ifup eth1
        ifdown br-ex && ifup br-ex
    - require:
      - file: edit_network

dnsmasq:
  cmd.run:
    - name: |
        echo port=5353 >> /etc/dnsmasq.conf
        service dnsmasq restart
    - unless: service dnsmasq status | grep running

profile_1:
  file.managed:
    - name: /root/.profile
    - source: salt://keystone/file/profile
    - template: jinja

admin_openrc_network:
  file.managed:
    - name: /root/admin-openrc.sh
    - source: salt://keystone/file/admin-openrc.sh
    - template: jinja

