ntp:
  pkg:
    - installed
  service:
    - running
    - enable: true
    - cmd.run:
      - name: sleep 3
/etc/ntp.conf:
  file.managed:
    - source: salt://ntp/file/ntp.conf
