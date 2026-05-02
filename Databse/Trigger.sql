use btl2;
DELIMITER $$
create trigger RB1 before insert on `user`
for each row
begin 
	if timestampdiff(year, new.Bdate, curdate()) < 18 then signal sqlstate '45000' set message_text = 'Nguoi dung nho hon 18 tuoi';
    end if;
end $$

create trigger RB2 before insert on apply
for each row
begin
	declare cvPath varchar(255);
	if new.upLoadCV is null or new.upLoadCV = ' ' then
		select savedCV into cvPath
        from `profile`
        where CandidateID = new.CandidateID;
        set new.upLoadCV = cvPath;
    end if;
end $$

create trigger RB6 before insert on apply
for each row
begin
	declare stt varchar(10);
    declare expireday date;
    
    select JobStatus, ExpireDate into stt, expireday
    from job
    where JobID = new.JobID;
    if stt = 'Close' then signal sqlstate '45000' set message_text = 'Khong the ung tuyen vi job da dong';
    end if;
 
    if curdate() > expireday then signal sqlstate '45000' set message_text = 'Khong the ung tuyen vi job da het han';
    end if;
end $$

create trigger RB7 before insert on apply
for each row
begin
	declare prf_id int;
    declare missing int default 0;
    
    select ProfileID into prf_id
    from `profile`
    where CandidateID = new.CandidateID
    limit 1;
    
    select count(*) into missing
    from `require` r
    where r.JobID = new.JobID and 
		not exists (
			select 1 from include i 
            where i.SkillName = r.SkillName and i.ProfileID = prf_id);
	
    if missing > 0  then signal sqlstate '45000' set message_text = 'Ung cu vien khong du dieu kien de ung tuyen';
    end if;
end $$

create trigger RB11 before insert on review
for each row
begin
	declare rvcname varchar(50);
    declare counthiscname int;
    
    select CName into rvcname
    from company
    where EmployerID = new.EmployerID;
    
    select count(jh.HistoryID) into counthiscname
    from job_history jh join profile p on jh.ProfileID = p.ProfileID
    where p.CandidateID = new.CandidateID and jh.CompanyName = rvcname;
   
	if counthiscname = 0 then signal sqlstate '45000' set message_text = 'Khong du dieu kien de danh gia';
    end if;
end $$

create trigger RB14 before insert on inbox
for each row
begin
	declare checksendertype int;
    
    select count(ID) into checksendertype
    from employer 
    where ID = new.SenderID;

    if checksendertype = 0 then
		if not exists (select 1 from inbox 
			where SenderID = new.ReceiverID
              AND ReceiverID = new.SenderID
              AND SenderRole = 'employer')
		then signal sqlstate '45000' set message_text = 'Ung cu vien khong the gui tin nhan truoc';
        else set new.SenderRole = 'candidate';
        end if;
	else set new.SenderRole = 'employer';
    end if;
end $$

create trigger RB13b before insert on inbox
for each row
begin
	declare purchaseday date;
    declare timegold int;
    
    select max(purchaseDate) into purchaseday
    from purchase
    where PackageName = 'Gold' and (EmpID = new.SenderID or EmpID = new.ReceiverID);
    
    select time into timegold
    from package
    where PackageName = 'Gold';
        
    if purchaseday is null then signal sqlstate '45000' set message_text = 'Khong du dieu kien de thuc hien gui tin nhan';
    end if;
	if curdate() > purchaseday + interval timegold day then signal sqlstate '45000' set message_text = 'Khong du dieu kien de thuc hien gui tin nhan';
	end if;
	
end $$ 

create trigger RB13a before insert on job
for each row
begin
	declare purchaseday date;
    declare timepackage int;
    declare pname varchar(30);
    
    select purchaseDate, PackageName into purchaseday, pname
    from purchase
    where EmpID = new.EmployerID
    order by purchaseDate desc limit 1;
    
    if purchaseday is null or pname is null then signal sqlstate '45000' set message_text = 'Khong du dieu kien de thuc hien dang bai';
    end if;
    
    select time into timepackage
    from package
    where PackageName = pname;
    
    if curdate() > purchaseday + interval timepackage day then signal sqlstate '45000' set message_text = 'Khong du dieu kien de thuc hien dang bai';
	end if;
end $$


create trigger RB4 before insert on apply
for each row
begin
	declare check_per int;
    declare check_jh int;
    declare check_cer int;
    declare check_std int;
    declare check_fl int;
    declare check_inc int;
    declare prfid int;
    
    select ProfileID into prfid
    from profile
    where CandidateID = new.CandidateID;
    
    select count(ProfileID) into check_jh
    from job_history
    where ProfileID = prfid;
    
    select count(ProfileID) into check_per
    from personal_project
    where ProfileID = prfid;
    
    select count(ProfileID) into check_cer
    from certificate
    where ProfileID = prfid;
    
    select count(ProfileID) into check_fl
    from foreign_language
    where ProfileID = prfid;
    
    select count(ProfileID) into check_std
    from study
    where ProfileID = prfid;
    
    select count(ProfileID) into check_inc
    from include
    where ProfileID = prfid;
    
    if (check_jh = 0 and check_per = 0) or check_cer = 0  or check_std = 0 or check_fl = 0 or check_inc = 0
		then signal sqlstate '45000' set message_text = 'Ung cu vien chua hoan thanh ly lich';
	end if;
end $$

create trigger package_trial before insert on purchase
for each row
begin
	if new.PackageName = 'Trial' then
		if exists(
			select 1
			from purchase
			where EmpID = new.EmpID and PackageName = 'Trial') then  signal sqlstate '45000' set message_text = 'Da het luot dung thu';
		end if;
	end if;
end $$

create trigger notify_apply_job before insert on notification
for each row
begin
	if not exists (select 1 from job where JobID = new.JobID and EmployerID = new.EmployerID) then
		signal sqlstate '45000' set message_text = 'JobID khong thuoc ve EmployerID';
	end if;
    
    if not exists (select 1 from apply where CandidateID = new.CandidateID and JobID = new.JobID) then
		signal sqlstate '45000' set message_text = 'Candidate chua apply vao JobID nay';
	end if;
end $$

create trigger status_aplly_notification after insert on notification
for each row
begin
	if new.Title = 'Hồ sơ phù hợp' then 
    update apply
    set Status_apply = 'Đã duyệt'
    where CandidateID = new.CandidateID and JobID = new.JobID;
    end if;
    
    if new.Title = 'Hồ sơ không phù hợp' then 
    update apply
    set Status_apply = 'Từ chối'
    where CandidateID = new.CandidateID and JobID = new.JobID;
    end if;
end $$ 

create trigger increase_opened_job after insert on job
for each row
begin
    update employer
    set NumberOfOpenedJob = NumberOfOpenedJob + 1
    where ID = NEW.EmployerID;
end $$

create trigger increase_year_of_experience after insert on job_history
for each row
begin
    update profile
    set YearOfExperience = YearOfExperience + TIMESTAMPDIFF(YEAR, NEW.Starttime, NEW.Endtime)
    where ProfileID = NEW.ProfileID;
end $$

CREATE TRIGGER increase_applicant AFTER INSERT ON apply
FOR EACH ROW
BEGIN
	UPDATE job
    SET NumberOfApplicant = NumberOfApplicant + 1
    WHERE JobID = NEW.JobID;
END $$


CREATE TRIGGER decrease_applicant AFTER DELETE ON apply
FOR EACH ROW
BEGIN
    UPDATE job
    SET NumberOfApplicant = NumberOfApplicant - 1
    WHERE JobID = OLD.JobID;
END $$


CREATE TRIGGER update_applicant_count AFTER UPDATE ON apply
FOR EACH ROW
BEGIN
    IF OLD.JobID != NEW.JobID THEN
        UPDATE job
        SET NumberOfApplicant = NumberOfApplicant - 1
        WHERE JobID = OLD.JobID;

        UPDATE job
        SET NumberOfApplicant = NumberOfApplicant + 1
        WHERE JobID = NEW.JobID;
    END IF;
END $$