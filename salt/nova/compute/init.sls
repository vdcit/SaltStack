nova_compute_install:
  pkg.installed:
    - refresh: False
    - pkgs:
{% for pkg in salt['pillar.get']('nova_compute:pkgs', []) %}
      - {{ pkg }}
{% endfor %}
  file.managed:
    - name: /etc/nova/nova.conf
    - source: {{pillar['nova_compute']['source']}}
    - user: nova
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - pkg: nova_compute_install

/etc/kernel/postinst.d/statoverride:
  file.managed:
    - source: salt://nova/file/statoverride
    - mode: 755
    - template: jinja
    
rm_/var/lib/nova/nova.sqlite:
  file.absent:
    - name: /var/lib/nova/nova.sqlite
    - require:
      - pkg: nova_compute_install

compute_reload:
  service.running:
    - name: nova-compute
    - watch:
      - file: nova_compute_install

