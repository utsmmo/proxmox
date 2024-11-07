#!/bin/bash

# Kiểm tra xem người dùng có nhập đủ tham số chưa
if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <vm_id_to_clone> <start_id> <end_id> [base_ip]"
  base_ip="192.168.3"  # Giá trị mặc định nếu không có tham số base_ip
else
  vm_id_to_clone=$1
  start_id=$2
  end_id=$3
  base_ip=${4:-"192.168.3"}  # Nếu không nhập base_ip, sẽ dùng giá trị mặc định
fi
# Duyệt qua các VM ID từ start_id đến end_id
for i in $(seq $start_id $end_id)
do
  # Clone VM từ ID được nhập
  qm clone $vm_id_to_clone $i --full

  # Đổi tên VM thành ID
  qm set $i --name "$i"

  # Bật VM
  qm start $i

  # Kiểm tra xem VM đã khởi động chưa
  while ! qm status $i | grep -q 'running'; do
    echo "Đang chờ VM $i khởi động..."
    sleep 5
  done

  # Set cấu hình mạng cho VM khi máy đã khởi động
  qm guest exec $i -- netsh interface ipv4 set address name="Ethernet" static $base_ip.$i 255.255.255.0 192.168.3.1
  
  echo "VM $i đã được tạo và cấu hình mạng thành $base_ip.$i"
done
