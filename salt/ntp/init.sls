ntp_setup:
  pkg.installed:
    - name: ntp
    - refresh: False
/etc/ntp.conf:
  file.managed:
    - source: salt://ntp/file/ntp.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - pkg: ntp
  service.running:
    - name: ntp
    - watch:
      - file: /etc/ntp.conf
    - require:
      - pkg: ntp

