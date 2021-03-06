include:
  - create_user_tenant

nova_install:
  pkg.installed:
    - refresh: False
    - pkgs:
{% for pkg in salt['pillar.get']('nova:pkgs', []) %}
      - {{ pkg }}
{% endfor %}
  file.managed:
    - name: /etc/nova/nova.conf
    - source: {{ pillar['nova']['source'] }}
    - user: nova
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - pkg: nova_install

/var/lib/nova/nova.sqlite:
  file.absent:
    - require:
      - pkg: nova_install

nova_db_sync:
  cmd.run:
    - name: nova-manage db sync
    - unless: mysql -e 'show tables from {{ pillar['nova']['db_name'] }}' | grep user
    - require:
      - pkg: mysql-server
      
{% for service in salt['pillar.get']('nova:services', []) %}
reload_{{ service }}:
  service.running:
    - name: {{ service }}
    - watch:
      - file: nova_install
      - cmd: nova_db_sync
{% endfor %}


test_nova:
  cmd.run:
    - name: |
        nova --os-username=admin --os-password={{pillar['keystone']['admin_pass'] }} --os-tenant-name=admin --os-auth-url=http://{{ pillar['keystone']['host_name'] }}:35357/v2.0 image-list
        nova-manage service list
