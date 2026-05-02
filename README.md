## 📖 Tổng quan (Overview)

Dự án này xây dựng một hệ thống cơ sở dữ liệu quan hệ cho nền tảng tuyển dụng, nhằm quản lý thông tin người dùng, tin tuyển dụng, hồ sơ ứng tuyển và tương tác giữa các bên.

**Trọng tâm của dự án là:**

Thiết kế database schema chặt chẽ
Xây dựng business logic trực tiếp tại tầng database
Đảm bảo tính toàn vẹn và nhất quán dữ liệu (data integrity)

## 🎯 Mục tiêu (Objectives)
Mô hình hóa dữ liệu cho hệ thống tuyển dụng thực tế
Xây dựng các ràng buộc và logic nghiệp vụ ở tầng database
Đảm bảo dữ liệu hợp lệ trước khi được ghi vào hệ thống

## 🏗️ Thiết kế hệ thống (Database Design)
🔹 **Các thực thể chính**
User: thông tin người dùng (ứng viên / nhà tuyển dụng)
Job: thông tin tin tuyển dụng
Application: hồ sơ ứng tuyển của ứng viên
Inbox: hệ thống nhắn tin giữa các bên

🔹 **Đặc điểm thiết kế**
Sử dụng mô hình Relational Database với các khóa chính / khóa ngoại
Chuẩn hóa dữ liệu để giảm dư thừa (normalization)
Thiết lập các constraints để đảm bảo tính hợp lệ dữ liệu
⚙️ Business Logic tại Database Layer

🔹 **Triggers**
Sử dụng trigger để tự động xử lý các quy tắc nghiệp vụ:
- Kiểm soát quyền gửi tin nhắn giữa các user
- Tự động cập nhật trạng thái hồ sơ ứng tuyển
- Ràng buộc các điều kiện liên quan đến gói dịch 
- Thực hiện validation dữ liệu và enforce các ràng buộc khi xảy ra các thao tác INSERT/UPDATE

🔹 **Stored Procedures (Thủ tục lưu trữ)**
Đóng gói các truy vấn phức tạp, xử lý transaction nhiều bước và trả về các báo cáo/thống kê (Result Sets):
- `sp_FindJobsByCompanyAndLocation`: Tìm kiếm thông tin công việc linh hoạt dựa trên tên (hoặc một phần tên) công ty và địa điểm làm việc.
- `sp_StatisticApplicationsByCompany`: Thống kê số lượng ứng viên đã nộp hồ sơ vào từng bài đăng tuyển của doanh nghiệp, có hỗ trợ tính năng lọc theo mức ứng viên tối thiểu.
- Xử lý các logic nghiệp vụ phức tạp (như mua gói dịch vụ, tạo tin tuyển dụng) và trả về thông báo lỗi thông qua xử lý exception.

## 🛠️ Công nghệ sử dụng (Tech Stack)
- SQL (MySQL / PostgreSQL)
- Stored Procedures & Functions
- Triggers
- Relational Database Design

## 📌 Đóng góp của tôi (My Contributions)
- Thiết kế và xây dựng các bảng trong hệ thống cơ sở dữ liệu quan hệ cho nền tảng tuyển dụng
- Phát triển Triggers để xử lý business logic (quyền gửi tin nhắn, trạng thái hồ sơ, ràng buộc nghiệp vụ)
- Hỗ trợ xây dựng Stored Procedures / Functions để thực hiện validation dữ liệu và xử lý logic
- Đảm bảo data integrity thông qua constraints và kiểm tra ở tầng database

## 🚀 Hướng phát triển (Future Improvements)
- Tối ưu hiệu năng truy vấn (indexing, query optimization)
- Mở rộng hệ thống phân quyền chi tiết hơn
- Tích hợp với backend API để xây dựng hệ thống hoàn chỉnh

## 🎯 Điểm mạnh của project
- Thể hiện khả năng thiết kế database thực tế
- Áp dụng business logic ở tầng database (advanced SQL)
- Không chỉ dừng ở query mà đi vào system-level thinking