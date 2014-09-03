rabbitmq:
  pkg.installed:
    - name: rabbitmq-server
    - refresh: False
  service.running:
    - name: rabbitmq-server
    - require:
      - pkg: rabbitmq-server
