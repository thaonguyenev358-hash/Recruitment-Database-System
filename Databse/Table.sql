use btl2;
create table `user` (
	ID int primary key auto_increment,
    Username varchar (30) not null unique,
    Email varchar(100) not null unique check (Email regexp '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'),
    `Password` varchar(255) not null check (length(Password) > 8),
    FName varchar (20) not null,
    LName varchar (20) not null,
    Created_date date not null,
    Address varchar (50) not null,
    Phonenumber char(10) not null check (Phonenumber regexp '^0[0-9]{9}$'),
    Profile_Picture varchar(255),
    Bdate date not null
);

create table candidate (
	ID int primary key not null,
    constraint fk_u_c_id foreign key (ID) references user (ID) 
		on delete cascade on update cascade
);

create table package (
	PackageName varchar (30) primary key,
    cost int not null default 0,
    desciption text,
    time int
); 

create table employer (
	ID int primary key not null,
    NumberOfOpenedJob int unsigned default 0,
    constraint fk_u_emp_id foreign key (ID) references user (ID) 
		on delete cascade on update cascade
);

create table purchase (
	pID int primary key auto_increment,
	EmpID int not null,
    PackageName varchar (30) not null,
    purchaseDate date not null,
    constraint fk_pack_pur_n foreign key (PackageName) references package (PackageName) 
		on delete restrict on update cascade,
	constraint fk_emp_pur_id foreign key (EmpID) references employer(ID)
		on update cascade on delete cascade
);

create table follow (
	CandidateID int not null,
    EmployerID int not null,
    primary key (CandidateID, EmployerID),
    constraint fk_emp_fl_id foreign key (EmployerID) references employer(ID)
		on delete cascade on update cascade,
    constraint fk_can_fl_id foreign key (CandidateID) references candidate(ID)
		on delete cascade on update cascade
);

create table social_media_link (
	SMLID int not null,
    UserID int not null,
    SMLlink varchar(255) not null unique check (SMLlink regexp '^http://' or SMLlink regexp '^https://'),
    primary key (SMLID, UserID),
    constraint fk_user_sml_id foreign key (UserID) references user(ID)
		on delete cascade on update cascade
);

create table feedback (
	FeedID int primary key auto_increment,
    Image varchar(500) not null,
    Topic varchar(50) not null,
    Content varchar(200), 
    UserID int not null,
    constraint fk_user_feed_id foreign key (UserID) references user(ID)
		on delete cascade on update cascade
);

create table inbox (
	MID int primary key auto_increment,
	SenderID int not null,
    ReceiverID int not null,
    SenderRole varchar(20),
    Content varchar(500),
    TimeSent datetime,
    constraint fk_user_sen_id foreign key (SenderID) references user(ID),
    constraint fk_user_re_id foreign key (ReceiverID) references user(ID)
);

create table review (
	rID int primary key auto_increment,
    `Rank` tinyint unsigned not null check (`Rank` between 1 and 5),
    Content varchar(200),
    CandidateID int,
    EmployerID int not null,
    constraint fk_emp_r_id foreign key (EmployerID) references employer(ID)
		on delete cascade on update cascade,
    constraint fk_can_r_id foreign key (CandidateID) references candidate(ID)
		on delete set null on update cascade
);

create table `profile` (
	ProfileID int primary key,
    Award varchar(500),
    savedCv varchar(255) not null,
    YearOfExperience int  not null default 0,
    CandidateID int not null,
    constraint fk_can_prf_id foreign key (CandidateID) references candidate(ID)
		on delete cascade on update cascade
);

create table Foreign_Language (
	ProfileId int not null,
    `Name` varchar(30) not null,
    `Level` varchar(20) not null,
    primary key (ProfileID, `Name`, `Level`),
    constraint fk_prf_l_id foreign key (ProfileID) references `profile`(ProfileID)
		on delete cascade on update cascade
);

create table company (
	CompanyID int primary key auto_increment,
    CNationality varchar(10),
    CName varchar(50) not null,
    Website varchar(255) not null check (Website regexp '^http://' or Website regexp '^https://'),
    Industry varchar(30) not null,
    CompanySize mediumint,
    Logo varchar(255) not null,
    `Description` varchar(200),
    TaxNumber varchar(13) not null unique check (TaxNumber regexp '^[0-9]{10}$' or TaxNumber regexp '^[0-9]{13}$'),
    EmployerID int not null,
    constraint fk_emp_c_id foreign key (EmployerID) references employer(ID)
		on delete cascade on update cascade
); 
	
create table job_history (
	HistoryID int not null,
	CompanyName varchar(50) not null,
    Starttime date not null,
    Endtime date not null,
    Position varchar(30) not null,
    ProfileID int not null,
    primary key (HistoryID, ProfileID),
    constraint ck_jh_time check (Starttime < Endtime),
    constraint fk_prf_j_id foreign key (ProfileID) references `profile`(ProfileID)
		on delete cascade on update cascade
);

create table project (
	`Name` varchar(50) not null,
    Link varchar(255) not null check (Link regexp '^http://' or Link regexp '^https://'),
    `Role` varchar(20),
    Starttime date,
    Endtime date,
    HistoryID int not null,
    ProfileID int not null,
    primary key (`Name`, HistoryID, ProfileID),
    constraint ck_prj_time check (Starttime < Endtime),
    constraint fk_his_id foreign key (HistoryID, ProfileID) references job_history(HistoryID, ProfileID)
		on delete cascade on update cascade
);

create table education (
	EduType varchar(10) not null,
    Address varchar(50) not null,
    EduName varchar(50) not null,
    primary key (EduType, Address, EduName)
);

create table study (
	ProfileID int not null,
    EduType varchar(10) not null,
    Address varchar(50) not null,
    EduName varchar(50) not null,
    Degree varchar(20),
    Major varchar(20),
    StartYear date not null,
    EndYear date,
    primary key (ProfileID, EduType, Address, EduName),
    constraint ck_std_time check (StartYear < EndYear),
    constraint fk_std_prf_id foreign key (ProfileID) references profile(ProfileID)
		on delete cascade on update cascade,
    constraint fk_std_edu foreign key (EduType, Address, EduName) references education(EduType, Address, EduName)
		on delete cascade on update cascade
);

create table skill (
	SkillName varchar(20) primary key,
    `Description` varchar(200) not null
);

create table include (
	SkillName varchar(20) not null,
    ProfileID int not null,
    primary key (SkillName, ProfileID),
    constraint fk_sk_n foreign key (SkillName) references skill(SkillName),
    constraint fk_prf_i_id foreign key (ProfileID) references `profile`(ProfileID)
		on delete cascade on update cascade
);

create table certificate (
	ProfileID int not null,
    CertID int not null,
    CertName varchar(30) not null,
    Score int not null,
    `Organization` varchar(50) not null,
    Link varchar(255) check (Link regexp '^http://' or Link regexp '^https://'),
    issueDate date not null,
    `Description` varchar(300),
    primary key (ProfileID, CertID),
    constraint fk_cert_prf_id foreign key (ProfileID) references `profile`(ProfileID)
		on delete cascade on update cascade
);

create table job (
	JobID int primary key auto_increment,
    JobName varchar(20) not null,
    JD varchar(500) not null,
    JobType varchar(20) not null,
    ContractType varchar(20) not null,
    `Level` varchar(20) not null,
    Quantity int unsigned not null check (Quantity >= 1),
    SalaryFrom int not null,
    SalaryTo int not null,
    RequiredExpYear int not null,
    Location varchar(30) not null,
    PostDate date not null,
    ExpireDate date not null,
    JobStatus varchar(10) not null,
    NumberOfApplicant int unsigned default 0,
    EmployerID int not null,
    constraint ck_j_time check (ExpireDate > PostDate),
    constraint ck_j_sl check (SalaryFrom > 0 and SalaryTo > SalaryFrom),
    constraint fk_emp_j_id foreign key (EmployerID) references employer(ID)
		on delete cascade on update cascade
);

create table `require` (
	JobID int not null,
    SkillName varchar(20) not null,
    primary key (JobID, SkillName),
    constraint fk_j_r_id foreign key (JobID) references job(JobID)
		on delete cascade on update cascade,
    constraint fk_sk_r_n foreign key (SkillName) references skill(SkillName)
);

create table job_category (
	JCName varchar(20) primary key,
    Specialty varchar(200) not null
);

create table related (
	JCName1 varchar(20) not null,
    JCName2 varchar(20) not null,
    primary key (JCName1, JCName2),
    constraint fk_relate_1 foreign key(JCName1) references job_category(JCName)
		on delete cascade on update cascade,
    constraint fk_relate_2 foreign key(JCName2) references job_category(JCName)
		on delete cascade on update cascade
);

create table `in` (
	JobID int not null,
    JCName varchar(20) not null,
    primary key (JobID, JCName),
    constraint fk_in_job foreign key (JobID) references job(JobID)
		on delete cascade on update cascade,
    constraint fk_in_jc foreign key (JCName) references job_category(JCName)
		on delete cascade on update cascade
);

create table notification (
	nID int primary key auto_increment,
    Title varchar(30) not null,
    Content varchar(200) not null,
    `Time` datetime not null,
    CandidateID int not null,
    EmployerID int not null,
    JobID int not null,
    constraint fk_can_noti foreign key (CandidateID) references candidate(ID),
    constraint fk_emp_noti foreign key (EmployerID) references employer(ID),
    constraint fk_j_noti foreign key (JobID) references job(JobID)
);

create table favourite (
	CandidateID int not null,
    JobID int not null,
    `Date` date not null,
    primary key (CandidateID, JobID),
    constraint fk_can_fv foreign key (CandidateID) references candidate(ID)
		on delete cascade on update cascade,
    constraint fk_j_fv foreign key (JobID) references job(JobID)
		 on delete cascade on update cascade
);

create table apply (
	CandidateID int not null,
    JobID int not null,
    upLoadCV varchar(50) not null default ' ',
    CoverLetter varchar(50),
    Status_apply varchar(20) not null default 'Đang duyệt',
    primary key (CandidateID, JobID),
    constraint fk_can_a foreign key (CandidateID) references candidate(ID)
		on delete cascade on update cascade,
    constraint fk_j_a foreign key (JobID) references job(JobID)
		on delete cascade on update cascade
);

create table personal_project (
	`Name` varchar(50) not null,
    Link varchar(255) not null check (Link regexp '^http://' or Link regexp '^https://'),
    `Role` varchar(20),
    Starttime date,
    Endtime date,
    ProfileID int not null,
    primary key (`Name`, ProfileID),
    constraint ck_per_time check (Starttime < Endtime),
    constraint fk_per_prf_id foreign key (ProfileID) references profile(ProfileID)
		on delete cascade on update cascade
);