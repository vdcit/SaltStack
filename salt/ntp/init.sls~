ntp:
  pkg:
    - installed
  service:
    - running
    - enable: true

/etc/ntp.conf:
  file.managed:
    - source: salt://ntp/file/ntp.conf
