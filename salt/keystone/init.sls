keystone:
  pkg:
    - latest
  service:
    - running
    - enable: true

{% set OS_SERVICE_TOKEN="ADMIN" %}
{% set OS_SERVICE_ENDPOINT="http://controller:35357/v2.0" %}












create_file:
  file.managed:
    - name: /root/admin-openrc.sh
    - source: salt://keystone/file/admin-openrc.sh
  cmd.run:
    - name: source admin-openrc.sh
