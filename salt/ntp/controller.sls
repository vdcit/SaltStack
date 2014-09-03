ntp_setup2:
  pkg.installed:
    - name: ntp
    - refresh: False
  service.running:
    - name: ntp
    - require:
      - pkg: ntp_setup2
