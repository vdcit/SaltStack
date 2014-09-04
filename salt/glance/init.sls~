include:
  - create_user_tenant

glance_install:
  pkg.installed:
    - refresh: False
    - pkgs:
{% for pkg in salt['pillar.get']('glance:pkgs', []) %}
      - {{ pkg }}
{% endfor %}

/etc/glance/glance-api.conf:
  file.managed:
    - source: salt://glance/file/glance-api.conf
    - mode: 644
    - user: glance
    - group: root
    - template: jinja
    - require:
      - pkg: glance_install

/etc/glance/glance-registry.conf:
  file.managed:
    - source: salt://glance/file/glance-registry.conf
    - mode: 644
    - user: glance
    - group: root
    - template: jinja
    - require:
      - pkg: glance_install
      
/var/lib/glance/glance.sqlite:
  file.absent:
    - require:
      - pkg: glance_install

glance_db_sync:
  cmd.run:
    - name: glance-manage db_sync
    - unless: mysql -e 'show tables from glance' | grep images
    - require:
      - file: /etc/glance/glance-registry.conf
      - file: /etc/glance/glance-api.conf
     
{% for service in salt['pillar.get']('glance:services', []) %}
service_{{ service }}_reload:
  service.running:
    - name: {{ service }}
    - watch:
      - file: /etc/glance/{{ service }}.conf
    - require:
      - pkg: glance_install
{% endfor %} 

test_glane:
  cmd.run:
    - name: |
        glance image-create --name "cirros-0.3.2-x86_64" --is-public true --container-format bare --disk-format qcow2 --location http://cdn.download.cirros-cloud.net/0.3.2/cirros-0.3.2-x86_64-disk.img
        glance image-list























