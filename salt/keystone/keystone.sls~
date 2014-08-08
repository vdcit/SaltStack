keystone:
  pkg:
    - latest
  service:
    - running
    - enable: true


/etc/keystone/keystone.conf:
  file.managed:
    - source: salt://conf/keystone.conf
    - require:
      - pkg: keystone
  cmd.run:
    - name: service keystone restart
    

 

	
