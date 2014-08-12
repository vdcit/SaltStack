SaltStack
=========
Nói qua về SaltStack: <br>
Đây là một trình quản lý mã nguồn mở dùng để quản lý cấu hình một cách tự động mà không dùng SSH. <br>
Lợi ích:
- Tự động hóa công việc cài đặt, dễ dàng cấu hình
- Có thể triển khai với hàng nghìn máy một lúc, giảm thời gian cấu hình xuống n lần với hệ thống có n máy.
- Có thể sử dụng lại trên hệ thống khác nhanh chóng.
- Dễ dàng chia nhỏ công việc vì nó có tính module
- Hỗ trợ nhiều hệ điều hành, kể cả window
Tổng quát:
Cách hoạt động của SaltStack khá đơn giản, một hoặc một số máy tính đóng vai trò là Master, nó điều khiển n máy con là Minion.
Việc cấu hình cài đặt dựa trên việc viết file cấu hình trên máy Master rồi chạy hệ thống file đó là có thể cài đặt trên n máy Minion.

###1. Cài đặt và cấu hình Salt
####1.1. Trên máy Master:
Mỗi OS sẽ có đôi chút sự khác nhau về cách cài đặt, nhưng có điểm chung nhất là đều phải cài gói **salt-master**
Có thể tham khảo cách cài đặt trên hệ điều hành khác [*tại đây*](http://docs.saltstack.com/en/latest/topics/installation/index.html#quick-install) <br>
*Ví dụ:* Đối với **Ubuntu server**: <br>
Trước tiên phải add repository cho nó:

    add-apt-repository ppa:saltstack/salt

Nếu lệnh này không hoạt động, cần cài gói python-software-properties rồi add lại.

    apt-get install software-properties-common
    
Sau đó update hệ thống:
    
    apt-get update

Cài đặt với lệnh sau:

    apt-get install salt-master

Sau khi cài đặt, đối với mọi OS đều phải cấu hình cho nó:
Ở Ubuntu, sửa file cấu hình sau:

    vim /etc/salt/master

Tìm và sửa file như sau:

    interface: 0.0.0.0
  
    file_roots:
    base:
      - /srv/salt

Nghĩa là bỏ dấu # đầu dòng. Cấu hình như vậy đơn giản là để Master lắng nghe mọi IP và file chạy (top file) sẽ nằm ở /srv/salt <br>
Save file lại rồi restart service:

    service salt-master restart

Như vậy là đã xong trên máy Master

####1.2 Trên máy Minion:
Cũng như Master, cần phải add repository cho nó. Sau đó cài gói salt-minion:

    apt-get install salt-minion

Cấu hình minion (trên mọi máy minion): <br>
Sửa nội dung file minion như sau: <br>
Đối với Ubuntu:

    vim /etc/salt/minion
  
Tìm và sửa nội dung file để quy định máy master(trỏ đến IP của máy master), ví dụ:

    master: 172.16.69.19

Save file và restart service:

    service salt-minion restart

####1.3 Cấp phép cho Minion:
Sau khi cài đặt, cấu hình và bật dịch vụ, các máy minion sẽ tự động gửi request đến máy master theo IP đã cấu trình ở trên.
Để kiểm tra request, dùng lệnh sau trên máy master:

    salt-key -L

Màn hình sẽ hiển thị ra list key đã và chưa chấp nhận ở dạng hostname của máy minion. Để accept minion, dùng lệnh sau:

    salt-key -a 'tên_minion'

Để accpept mọi request:

    salt-key -A

Có thể kiểm tra lại list accept để xem các máy con. Vậy là đã hoàn thành cấu hình hệ thống sử dụng salt.

###2. Cấu trúc của Salt
####2.1. State
Salt sử dụng hệ thống file cấu hình gọi là SLS (SaLt State file) để cấu hình dịch vụ cho máy minion.
Các file này nằm trong thư mục */srv/salt* trên máy master như cấu hình lúc đầu.<br>
Một state mô tả trạng thái mà hệ thống cần phải có như: phần mềm được cài, tên dịch vụ, file cấu hình tồn tại, lệnh thực thi...
Các state của Salt được chứa trong file có phần mở rộng là *sls*. Ví dụ về một state để cài mysql database cho máy minion chạy Ubuntu:

    mysql:
      pkg:
        - name: mysql-server
        - installed
      service:
        - name: mysql 
        - running
        - enable: true

**Note:** Nếu không có trường *name*, hệ thống sẽ tìm dựa theo tên ở trên cùng là *mysql*. Do đó trong ví dụ này, phần *service* không cần có trường *name*.
Sau khi lưu file này (tên file là mysql.sls)có thể thực hiện cài cho minion với lệnh sau trên máy master:

    salt 'tên_minion' state.sls mysql

Hoặc cài trên tất cả các máy:

    salt '*' state.sls mysql

Đó là cách cài đặt đơn giản một gói phần mềm cho minion. Nhưng chỉ là demo, vì thông thường người ta không dùng cách này, nó sẽ không được gọi là tự động nữa! <br>
Như đã đề cập ở trên, state có một file gọi là top file (top.sls). Trong file này sẽ chứa toàn bộ các gói cho từng máy minion. <br>
Khi người quản trị gõ lệnh:

    salt '*' state.highstate

Thì Master sẽ tự động tìm đến file top.sls để chạy nó. <br>
Ví dụ về một file top.sls:

    base:
      "com1":
        - ub.mysql
        - ub.nginx
      "com2":
        - cen.httpd
        - cen.rabbit

Trong đó, *com1* và *com2* là tên của 2 máy minion, *ub* và *cen* là thư mục chứa các gói bên trong, *mysql* là gói cài đặt như ví dụ ở trên.
Làm như trên vẫn chưa thể gọi là tự động được, vì vẫn phải định nghĩa từng gói chuẩn cho từng hệ điều hành.
Do chưa nghiên cứu được detect OS nên cứ tạm vậy đã :)
### 
Còn một điều cần chú ý. Các file state sử dụng định dạng YAML. Định dạng này rất đơn giản, biểu diễn như sau:
- Sử dụng 2 dấu cách để thụt lề biểu diễn cấu trúc (giống 4 dấu cách trong python - không sử dụng tab)
- Dấu 2 chấm ":" : cấu trúc dữ liệu từ điển, bên trái là key, bên phải là value
- Dấu gạch "-" : cấu trúc dữ liệu danh sách.
- Ký tự "#" để comment

####2.2 Renderers
Nói nôm na, nó giống như người phiên dịch, dịch ngôn ngữ từ file SLS (có thể viết bằng nhiều ngôn ngữ lập trình khác nhau) sang dạng mà salt có thể hiểu được.
Các renders có sẵn trong salt như: py, jinja, mako. Mặc định Salt sử dụng định sạng YAML để viết SLS với renderer là jinja.

####2.3 Pillar
Dùng để lưu trữ các loại dữ liệu như:
- Mật khẩu, khóa bí mật...
- Các biến
- Dữ liệu tùy ý

####2.4 Grains
Grains giúp truy cập các thông tin phần cứng, cũng như OS của minion. Ta có thể chọn một các máy có dùng điểm chung ví dụ như hệ điều hành, để cài đặt một số gói đặc biệt chẳng hạn.
VD:

    salt '*' grains.item os os_family kernel

Với lệnh này, ta sẽ biết được OS, họ, nhân của mọi máy minion.

###3. Quá trình chạy SLS
Khi master chỉ định chạy một SLS trên một máy minion nào đó, renderer bắt đầu thực hiện quá trình xử lý và biến đổi file SLS. Tại đây, các biến số, các giá trị Granis, Pillar được thay bằng các giá trị thực, các vòng lặp, câu lệnh điều kiện được thực hiện để tạo ra một SLS chỉ gồm các dữ liệu có thể biến đổi về dạng dict và list. <br>
Sau khi quá trình render SLS thành công, master chuyển SLS vào minion cần chạy. Minion nhận được SLS, thực hiện chạy các lệnh tương ứng với các state được khai báo. <br>
Sau khi tất cả state được thực hiện, minion gửi kết quả về trạng thái của các state về cho master.

###4. DEMO
Trong phần này mình sẽ thực hiện cài đặt một số gói cơ bản trên ba máy Minion, cụ thể là mysql-server, python-mysqldb, ntp, rabbitmq-server, và sửa file cấu hình mysql. <br>
Ba máy Minion lần lượt là Controller, Network, Compute (dự định cài OpenStack bằng Salt nhưng mới chỉ cài được các gói cơ bản). <br>
Phần cài đặt và cấu hình cho master và minion mình đã nói ở trên, sẽ không nhắc lại nữa. Ở phần này mình chỉ nói về ý tưởng và cách Salt hoạt động. <br>
Đầu tiên là các gói cài đặt. Các gói này sẽ đặt trong thư mục salt.<br>
Nội dung cụ thể như sau: <br>
- rabbitmq:

        rabbitmq-server:
          pkg:
            - installed
          service:
            - running
            - enable: true

Nội dung file này chỉ đơn giản là đảm bảo cho gói rabbitmq-server đã được cài đặt và dịch vụ đó luôn chạy.

- ntp
    
        ntp:
          pkg:
            - installed
          service:
            - running
            - enable: true

        /etc/ntp.conf:
          file.managed:
            - source: salt://ntp/file/ntp.conf

Đây là một state đảm bảo cho gói ntp (gói này có chức năng đồng bộ thời gian giữa các máy chủ) đã được cài đặt và service luôn chạy. Ở phần sửa file cấu hình thì sẽ tự động thay file đó bằng một file đã sửa sẵn, đặt tại máy Master.
    
- mysql
        
        mysql:
          pkg.installed:
            - pkgs:
              - python-mysqldb
              - {{ pillar['mysql'] }}
        service.running:
          - name: {{ pillar['my_ser'] }}

Ý tưởng đối với gói này là chỉ cài mysql-server trên controller, còn python-mysql thì cài trên cả ba máy.<br>
Để thực hiện điều này, cần có một file chứa biến đặt ở thư mục pillar. Mình đặt tên cho file này là packages.sls <br>
Nội dung file như sau:

    
    {% if grains['host'] == 'controller' %}
    mysql: mysql-server
    my_ser: mysql
    {% else %}
    mysql: python-mysqldb
    my_ser: ntp
    {% endif %}

Ý nghĩa đoạn code này rất đơn giản: nếu tên minion là controller thì gán biến mysql là mysql-server, gán my_ser là mysql. Còn lại đối với minion khác thì đặt là python-mysqldb và ntp. Thực ra chỗ này mình chưa tìm được cách sử dụng biến null trong salt nên đành dùng tạm cách này! 
Quay lại với file mysql ở trên, khi mình gọi biến mysql và my_ser ở trong pillar, hệ thống sẽ tìm điều kiện thỏa mãn hostname là controller để cài gói mysql-server, hai máy còn lại thì chỉ cài python-mysqldb. <br>
Trong pillar cũng cần có top file để trỏ đến file chứa biến. Trong trường hợp này sẽ là file packages.sls <br>
Nội dung top file trong pillar sẽ như sau:

    base:
      '*':
        - packages
    
Cuối cùng là top file của state, file này sẽ chỉ định những gói cần cài trên từng máy:

    base:
      "controller":
        - ntp
        - mysql
        - rabbitmq
      "compute":
        - ntp
        - mysql
      "network":
        - ntp
        - mysql

Hoặc ngắn gọn hơn:

    base:
      "*":
        - ntp
        - mysql
      "controller":
        - rabbitmq

Quá trình hoạt động sẽ như thế này: Khi người quản trị gõ lệnh ***salt '*' state.highstate***, hệ thống sẽ tìm đến file top.sls trong thư mục state để đọc những gói cần cài đối với từng minion. Những gói cài đặt trực tiếp như rabbitmq hay ntp thì hệ thống sẽ tìm gói và cài đặt luôn cho máy minion chỉ định. Còn đối với mysql, hệ thống đọc được biến từ pillar nên sẽ tìm đến file top.sls trong pillar để tìm đến file chứa biến, chính là **packages.sls**. Sau khi tìm đến file này, hệ thống sẽ thực hiện các phép toán để tìm ra điều kiện thỏa mãn và tiến hành cài đặt theo chỉ định. Khi quá trình cài đặt hoàn tất, hệ thống sẽ gửi kết quả chi tiết từ các minion về máy master.

Với hệ thống chỉ có 3 máy minion thế này, ta thấy việc sử dụng pillar là không cần thiết, vì hoàn toàn có thể tách riêng mysql-server và python-mysql thành hai state khác nhau và chỉ định cụ thể cho từng máy. Nhưng với hệ thống lớn có đến hàng nghìn đến hàng trăm nghìn máy thì sao? Nếu làm thủ công thì bạn sẽ phải lặp lại công việc đến hàng nghìn lần. Nhưng khi dùng pillar thì chỉ cần cấu hình biến và dùng một lệnh duy nhất mà thôi! Đó chính là sự khác nhau giữa state và pillar và cũng là cái hay của SaltStack. Nó thực sự hữu dụng với các hệ thống lớn.<br>
Mình xin dừng bài DEMO tại đây! Khi hoàn thành được keystone và các thành phần khác mình sẽ cập nhật tiếp! 
