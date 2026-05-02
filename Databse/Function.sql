-- Hàm thống kê số lượng ứng viên ứng tuyển vào các job của một công ty
DELIMITER $$
DROP FUNCTION IF EXISTS ThongKeUngTuyen$$
CREATE FUNCTION ThongKeUngTuyen(p_EmployerID INT)
RETURNS JSON
DETERMINISTIC
READS SQL DATA
COMMENT 'Thong ke so luong ho so ung tuyen theo tung job dang mo'
BEGIN
    DECLARE v_result JSON DEFAULT NULL;
    -- Validate input
    IF p_EmployerID IS NULL OR p_EmployerID <= 0 THEN
        RETURN JSON_ARRAY(JSON_OBJECT(
            'JobID', NULL,
            'JobName', 'Loi: Ma nha tuyen dung khong hop le hoac am',
            'CreatedDate', NULL,
            'Location', NULL,
            'SalaryRange', NULL,
            'TongHoSo', 0
        ));
    END IF;
    
    -- Kiem tra co job dang mo khong
    IF NOT EXISTS (
        SELECT 1 FROM job
        WHERE EmployerID = p_EmployerID AND JobStatus = 'Open'
    ) THEN
        RETURN JSON_ARRAY(JSON_OBJECT(
            'JobID', NULL,
            'JobName', 'Khong co cong viec nao dang mo',
            'CreatedDate', NULL,
            'Location', NULL,
            'SalaryRange', NULL,
            'TongHoSo', 0
        ));
    END IF;
    
    -- Thuc hien thong ke
    SELECT JSON_ARRAYAGG(data.obj) INTO v_result
    FROM (
        SELECT JSON_OBJECT(
            'JobID', j.JobID,
            'JobName', j.JobName,
            'CreatedDate', DATE(j.PostDate),
            'Location', j.Location,
            'SalaryRange', CONCAT(FORMAT(j.SalaryFrom, 0), '- ',
            FORMAT(j.SalaryTo, 0)),
            'TongHoSo', COALESCE(COUNT(a.CandidateID), 0)
            ) AS obj
        FROM job j
        LEFT JOIN apply a ON a.JobID = j.JobID
        WHERE j.EmployerID = p_EmployerID
            AND j.JobStatus = 'Open'
        GROUP BY j.JobID, j.JobName, j.PostDate, j.Location,j.SalaryFrom, j.SalaryTo
        ORDER BY j.PostDate DESC
    ) AS data;
    RETURN COALESCE(v_result, JSON_ARRAY());
END$$
DELIMITER ;

-- Hàm tính điểm uy tín (TrustScore) của nhà tuyển dụng dựa trên các yếu tố
DELIMITER $$
DROP FUNCTION IF EXISTS fn_TinhDiemUyTinEmployer $$
CREATE FUNCTION fn_TinhDiemUyTinEmployer(p_EmpID INT)
RETURNS JSON
DETERMINISTIC
BEGIN
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_rank INT;
    DECLARE v_content VARCHAR(200);

    DECLARE v_avgReview FLOAT DEFAULT 0;
    DECLARE v_followCount INT DEFAULT 0;
    DECLARE v_openJobCount INT DEFAULT 0;
    DECLARE v_totalReview INT DEFAULT 0;

    DECLARE v_jsonReview LONGTEXT DEFAULT '';

    DECLARE cur CURSOR FOR
        SELECT `Rank`, Content
        FROM review
        WHERE EmployerID = p_EmpID;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
    
    -- Validate input
    IF p_EmpID IS NULL OR p_EmpID <= 0 THEN
        RETURN JSON_OBJECT("Error", "EmployerID khong hop le");
    END IF;

    IF (SELECT COUNT(*) FROM employer WHERE ID = p_EmpID) = 0 THEN
        RETURN JSON_OBJECT("Error", "Employer khong ton tai");
    END IF;
    
    -- Count follows
    SELECT COUNT(*) INTO v_followCount
    FROM follow
    WHERE EmployerID = p_EmpID;

    -- Count open jobs
    SELECT COUNT(*) INTO v_openJobCount
    FROM job
    WHERE EmployerID = p_EmpID
        AND JobStatus = 'Open';
        
    -- Count reviews
    SELECT COUNT(*) INTO v_totalReview
    FROM review
    WHERE EmployerID = p_EmpID;
    
    -- Avg review
    IF v_totalReview = 0 THEN
        SET v_avgReview = 3;-- Default rating
    ELSE
        SELECT AVG(`Rank`) INTO v_avgReview
        FROM review
        WHERE EmployerID = p_EmpID;
    END IF;
    
    -- Build JSON list of reviews
    OPEN cur;

    review_loop: LOOP
        FETCH cur INTO v_rank, v_content;
        IF v_done = 1 THEN
            LEAVE review_loop;
        END IF;

        IF v_jsonReview = '' THEN
            SET v_jsonReview = CONCAT(
                '{"Rank": ', v_rank,
                ', "Content": "', v_content, '"}'
            );
        ELSE
            SET v_jsonReview = CONCAT(
                v_jsonReview, ', ',
                '{"Rank": ', v_rank,
                ', "Content": "', v_content, '"}'
            );
        END IF;
    END LOOP;

    CLOSE cur;
    
    -- Calculate trust score
    SET @TrustScore =
        v_avgReview * 0.6
        + v_followCount * 0.2
        + v_openJobCount * 0.2;
        
    -- Build JSON list of reviews
    -- v_jsonReview da build xong, dung CONCAT de tao array
    SET @ReviewsJson = CONCAT('[', v_jsonReview, ']');
    SET @TrustScore = v_avgReview * 0.6 + v_followCount * 0.2 + v_openJobCount * 0.2;
    
    -- RETURN JSON object
    RETURN JSON_OBJECT(
        "EmployerID", p_EmpID,
        "AvgReview", ROUND(v_avgReview,2),
        "TotalReview", v_totalReview,
        "FollowerCount", v_followCount,
        "OpenJobCount", v_openJobCount,
        "TrustScore", ROUND(@TrustScore,2),
        "Reviews", @ReviewsJson
    );
END$$
DELIMITER ;