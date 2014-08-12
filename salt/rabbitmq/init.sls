rabbitmq:
  pkg:
    - name: rabbitmq-server
    - installed
  service:
    - name: rabbitmq-server
    - running
    - enable: true
  cmd.run:
    - name: rabbitmqctl change_password guest 1

