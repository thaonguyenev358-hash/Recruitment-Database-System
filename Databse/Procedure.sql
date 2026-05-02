-- Thủ tục tìm kiếm job theo tên công ty và địa điểm
DELIMITER $$
CREATE PROCEDURE sp_FindJobsByCompanyAndLocation (
    IN p_company_name VARCHAR(255),-- Tên công ty tìm kiếm
    IN p_location VARCHAR(255)-- Địa điểm tìm kiếm
)
BEGIN
    SELECT
        j.JobID,
        j.JobName,
        c.CName,
        j.Location,
        j.JobStatus,
        j.PostDate,
        j.ExpireDate
    FROM job j
    JOIN company c ON j.EmployerID = c.EmployerID
    WHERE
        (p_company_name IS NULL OR c.CName LIKE CONCAT('%', p_company_name, '%'))
        AND (p_location IS NULL OR j.Location LIKE CONCAT('%', p_location, '%'))
    ORDER BY
        j.PostDate DESC,
        c.CName ASC,
        j.JobName ASC;
END $$
DELIMITER ;

-- Thủ tục thống kê số lượng ứng viên ứng tuyển vào các job của một công ty
DELIMITER $$
CREATE PROCEDURE sp_StatisticApplicationsByCompany (
    IN p_company_name VARCHAR(255),-- Tên (hoặc 1 phần tên) công ty
    IN p_min_applicants INT-- Số ứng viên tối thiểu
)
BEGIN
    SELECT
        c.CName,
        j.JobID,
        j.JobName,
        COUNT(a.CandidateID) AS total_applicants
    FROM company c
    JOIN job j ON c.EmployerID = j.EmployerID
    LEFT JOIN apply a ON j.JobID = a.JobID
    WHERE
        (p_company_name IS NULL OR c.CName LIKE CONCAT('%', p_company_name, '%'))
    GROUP BY
        c.CName,
        j.JobID,
        j.JobName
    HAVING COUNT(a.CandidateID) >= p_min_applicants
    ORDER BY
        total_applicants DESC,
        c.CName ASC,
        j.JobName ASC;
END $$
DELIMITER ;