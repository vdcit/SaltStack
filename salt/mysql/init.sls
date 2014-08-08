mysql:
  pkg.installed:
    - pkgs:
      - python-mysqldb
      - {{ pillar['mysql'] }}
  service.running:
    - name: {{ pillar['my_ser'] }}
