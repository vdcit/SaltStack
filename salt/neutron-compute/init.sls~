sysctl_compute:
  cmd.run:
    - name: sysctl -p

neutron_compute:
  pkg.installed:
    - pkgs:
{% for pkg in salt['pillar.get']('neutron_compute:pkgs', [])%}
      - {{ pkg }}
{% endfor %}

{% for file in salt['pillar.get']('neutron_compute:files', [])%}
{{file['name']}}_compute:
  file.managed:
    - name: {{file['name']}}
    - source: {{file['source']}}
    - user: neutron
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - pkg: neutron_compute
{%endfor%}

create_network:
  cmd.run:
    - name: ovs-vsctl add-br br-int   
    - unless: ovs-vsctl list-br | grep br-int
    - require:
      - service: openvswitch-switch

edit_hypervisor:
  cmd.run:
    - name: sed -i -r 's/virt_type.*/virt_type=qemu/g' /etc/nova/nova-compute.conf

{% for service in salt['pillar.get']('neutron_compute:services', [])%}
re_ld{{service}}:
  service.running:
    - name: {{ service }}
    - watch:
      - file: /etc/neutron/neutron.conf_compute
      - file: /etc/neutron/plugins/ml2/ml2_conf.ini_compute
{%endfor%}


