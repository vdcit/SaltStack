create_database:
  mysql_database.present:
    - name: keystone
    - require:
      - pkg: mysql-server

create_user:
  mysql_user.present:
    - name: keystone
    - host: '%'
    - password: '1'
    - require:
      - pkg: mysql-server

grant_privileges:
  mysql_grants.present:
    - grant: all privileges
    - database: keystone.*
    - user: keystone
    - require:
      - pkg: mysql-server
