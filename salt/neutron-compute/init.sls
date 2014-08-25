neutron_compute:
  pkg.installed:
    - pkgs:
{% for pkg in salt['pillar.get']('neutron_compute:pkgs', [])%}
      - {{ pkg }}
{% endfor %}

{% for file in salt['pillar.get']('neutron_compute:files', [])%}
change_{{file['name']}}:
  file.managed:
    - name: {{file['name']}}
    - source: {{file['source']}}
    - user: neutron
    - group: root
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

{% for service in salt['pillar.get']('neutron_compute:services', [])%}
re_ld{{service}}:
  service.running:
    - name: {{ service }}
    - watch:
      - file: change_/etc/neutron/neutron.conf
      - file: change_/etc/neutron/plugins/ml2/ml2_conf.ini
{%endfor%}


