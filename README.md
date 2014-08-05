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
Có thể tham khảo cách cài đặt trên hệ điều hành khác tại [đây](http://docs.saltstack.com/en/latest/topics/installation/index.html#quick-install) <br>
*Ví dụ:* Đối với **Ubuntu server**: <br>
Trước tiên phải add repository cho nó:

    add-apt-repository ppa:saltstack/salt

Nếu lệnh này không hoạt động, cần cài gói python-software-properties rồi add lại.

    apt-get install python-software-properties

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

**note:** Nếu không có trường *name*, hệ thống sẽ tìm dựa theo tên ở trên cùng là *mysql*. Do đó trong ví dụ này, phần *service* không cần có trường *name*.
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





