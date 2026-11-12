

USE master;
GO

IF DB_ID(N'CityPoliceDB') IS NOT NULL
    ALTER DATABASE CityPoliceDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE IF EXISTS CityPoliceDB;
GO

CREATE DATABASE CityPoliceDB;
GO

USE CityPoliceDB;
GO

/* ---------- Drop tables if they exist (children first, parents last) ---------- */
DROP TABLE IF EXISTS dbo.Arrest;
DROP TABLE IF EXISTS dbo.CaseSuspect;
DROP TABLE IF EXISTS dbo.Document;
DROP TABLE IF EXISTS dbo.PhotoVideo;
DROP TABLE IF EXISTS dbo.DigitalFile;
DROP TABLE IF EXISTS dbo.PhysicalItem;
DROP TABLE IF EXISTS dbo.Evidence;
DROP TABLE IF EXISTS dbo.[Case];
DROP TABLE IF EXISTS dbo.WitnessStatement;
DROP TABLE IF EXISTS dbo.Incident;
DROP TABLE IF EXISTS dbo.Suspect;
DROP TABLE IF EXISTS dbo.Witness;
DROP TABLE IF EXISTS dbo.Complainant;
DROP TABLE IF EXISTS dbo.Person;
DROP TABLE IF EXISTS dbo.VehicleAssignment;
DROP TABLE IF EXISTS dbo.DutyShift;
DROP TABLE IF EXISTS dbo.Vehicle;
DROP TABLE IF EXISTS dbo.AdministrativeStaff;
DROP TABLE IF EXISTS dbo.Officer;
DROP TABLE IF EXISTS dbo.Employee_Phone;
DROP TABLE IF EXISTS dbo.Employee;
DROP TABLE IF EXISTS dbo.Station;
GO

/* ---------- 1. Station ---------- */
CREATE TABLE dbo.Station (
    StationID        INT IDENTITY(1,1) NOT NULL,
    Name             VARCHAR(100)      NOT NULL,
    Address          VARCHAR(200)      NOT NULL,
    PhoneNumber      VARCHAR(20)       NOT NULL,
    JurisdictionArea VARCHAR(100)      NOT NULL,
    CONSTRAINT PK_Station PRIMARY KEY (StationID)
);
GO

/* ---------- 2. Employee ---------- */
CREATE TABLE dbo.Employee (
    EmployeeID  INT IDENTITY(1,1) NOT NULL,
    FirstName   VARCHAR(50)       NOT NULL,
    MiddleName  VARCHAR(50)       NULL,
    LastName    VARCHAR(50)       NOT NULL,
    Address     VARCHAR(200)      NOT NULL,
    Email       VARCHAR(100)      NOT NULL,
    HireDate    DATE              NOT NULL,
    Salary      DECIMAL(10,2)     NOT NULL,
    StationID   INT               NOT NULL,
    CONSTRAINT PK_Employee PRIMARY KEY (EmployeeID),
    CONSTRAINT FK_Employee_Station FOREIGN KEY (StationID) REFERENCES dbo.Station (StationID),
    CONSTRAINT CK_Employee_Salary CHECK (Salary > 0)
);
GO

/* ---------- 3. Employee_Phone ---------- */
CREATE TABLE dbo.Employee_Phone (
    EmployeePhoneID INT IDENTITY(1,1) NOT NULL,
    EmployeeID      INT               NOT NULL,
    PhoneNumber     VARCHAR(20)       NOT NULL,
    CONSTRAINT PK_Employee_Phone PRIMARY KEY (EmployeeID, PhoneNumber),
    CONSTRAINT UQ_Employee_Phone_EmployeePhoneID UNIQUE (EmployeePhoneID),
    CONSTRAINT FK_EmployeePhone_Employee FOREIGN KEY (EmployeeID) REFERENCES dbo.Employee (EmployeeID)
);
GO

/* ---------- 4. Officer ---------- */
CREATE TABLE dbo.Officer (
    OfficerRowID             INT IDENTITY(1,1) NOT NULL,
    EmployeeID               INT               NOT NULL,
    BadgeNumber              VARCHAR(20)       NOT NULL,
    Rank                     VARCHAR(50)       NOT NULL,
    Specialization           VARCHAR(100)      NULL,
    FirearmCertificationDate DATE              NULL,
    SupervisorID             INT               NULL,
    CONSTRAINT PK_Officer PRIMARY KEY (EmployeeID),
    CONSTRAINT UQ_Officer_OfficerRowID UNIQUE (OfficerRowID),
    CONSTRAINT FK_Officer_Employee FOREIGN KEY (EmployeeID) REFERENCES dbo.Employee (EmployeeID),
    CONSTRAINT FK_Officer_Supervisor FOREIGN KEY (SupervisorID) REFERENCES dbo.Officer (EmployeeID)
);
GO

/* ---------- 5. AdministrativeStaff ---------- */
CREATE TABLE dbo.AdministrativeStaff (
    AdminStaffRowID INT IDENTITY(1,1) NOT NULL,
    EmployeeID      INT               NOT NULL,
    JobTitle        VARCHAR(100)      NOT NULL,
    Department      VARCHAR(100)      NOT NULL,
    CONSTRAINT PK_AdministrativeStaff PRIMARY KEY (EmployeeID),
    CONSTRAINT UQ_AdministrativeStaff_AdminStaffRowID UNIQUE (AdminStaffRowID),
    CONSTRAINT FK_AdministrativeStaff_Employee FOREIGN KEY (EmployeeID) REFERENCES dbo.Employee (EmployeeID)
);
GO

/* ---------- 6. Vehicle ---------- */
CREATE TABLE dbo.Vehicle (
    VIN          VARCHAR(17)       NOT NULL,
    VehicleID    INT IDENTITY(1,1) NOT NULL,
    LicensePlate VARCHAR(20)       NOT NULL,
    Make         VARCHAR(50)       NOT NULL,
    Model        VARCHAR(50)       NOT NULL,
    Year         INT               NOT NULL,
    VehicleType  VARCHAR(50)       NOT NULL,
    Status       VARCHAR(30)       NOT NULL,
    StationID    INT               NOT NULL,
    CONSTRAINT PK_Vehicle PRIMARY KEY (VIN),
    CONSTRAINT UQ_Vehicle_VehicleID UNIQUE (VehicleID),
    CONSTRAINT FK_Vehicle_Station FOREIGN KEY (StationID) REFERENCES dbo.Station (StationID),
    CONSTRAINT CK_Vehicle_Year CHECK (Year BETWEEN 1990 AND 2030)
);
GO

/* ---------- 7. DutyShift ---------- */
CREATE TABLE dbo.DutyShift (
    ShiftID    INT IDENTITY(1,1) NOT NULL,
    ShiftDate  DATE              NOT NULL,
    StartTime  TIME              NOT NULL,
    EndTime    TIME              NOT NULL,
    OfficerID  INT               NOT NULL,
    StationID  INT               NOT NULL,
    CONSTRAINT PK_DutyShift PRIMARY KEY (ShiftID),
    CONSTRAINT FK_DutyShift_Officer FOREIGN KEY (OfficerID) REFERENCES dbo.Officer (EmployeeID),
    CONSTRAINT FK_DutyShift_Station FOREIGN KEY (StationID) REFERENCES dbo.Station (StationID),
    CONSTRAINT CK_DutyShift_Times CHECK (EndTime > StartTime)
);
GO

/* ---------- 8. VehicleAssignment ---------- */
CREATE TABLE dbo.VehicleAssignment (
    AssignmentID INT IDENTITY(1,1) NOT NULL,
    OfficerID    INT               NOT NULL,
    VIN          VARCHAR(17)       NOT NULL,
    StartDate    DATE              NOT NULL,
    ReturnDate   DATE              NULL,
    CONSTRAINT PK_VehicleAssignment PRIMARY KEY (AssignmentID),
    CONSTRAINT FK_VehicleAssignment_Officer FOREIGN KEY (OfficerID) REFERENCES dbo.Officer (EmployeeID),
    CONSTRAINT FK_VehicleAssignment_Vehicle FOREIGN KEY (VIN) REFERENCES dbo.Vehicle (VIN),
    CONSTRAINT CK_VehicleAssignment_Dates CHECK (ReturnDate >= StartDate)
);
GO

/* ---------- 9. Person ---------- */
CREATE TABLE dbo.Person (
    PersonID    INT IDENTITY(1,1) NOT NULL,
    FirstName   VARCHAR(50)       NOT NULL,
    MiddleName  VARCHAR(50)       NULL,
    LastName    VARCHAR(50)       NOT NULL,
    DateOfBirth DATE              NULL,
    Address     VARCHAR(200)      NULL,
    PhoneNumber VARCHAR(20)       NULL,
    CONSTRAINT PK_Person PRIMARY KEY (PersonID)
);
GO

/* ---------- 10. Complainant ---------- */
CREATE TABLE dbo.Complainant (
    ComplainantRowID       INT IDENTITY(1,1) NOT NULL,
    PersonID               INT               NOT NULL,
    RelationshipToIncident VARCHAR(100)      NOT NULL,
    CONSTRAINT PK_Complainant PRIMARY KEY (PersonID),
    CONSTRAINT UQ_Complainant_ComplainantRowID UNIQUE (ComplainantRowID),
    CONSTRAINT FK_Complainant_Person FOREIGN KEY (PersonID) REFERENCES dbo.Person (PersonID)
);
GO

/* ---------- 11. Witness ---------- */
CREATE TABLE dbo.Witness (
    WitnessRowID    INT IDENTITY(1,1) NOT NULL,
    PersonID        INT               NOT NULL,
    ReliabilityNote VARCHAR(200)      NULL,
    CONSTRAINT PK_Witness PRIMARY KEY (PersonID),
    CONSTRAINT UQ_Witness_WitnessRowID UNIQUE (WitnessRowID),
    CONSTRAINT FK_Witness_Person FOREIGN KEY (PersonID) REFERENCES dbo.Person (PersonID)
);
GO

/* ---------- 12. Suspect ---------- */
CREATE TABLE dbo.Suspect (
    SuspectRowID       INT IDENTITY(1,1) NOT NULL,
    PersonID           INT               NOT NULL,
    IdentificationDate DATE              NOT NULL,
    Description        VARCHAR(200)      NULL,
    Status             VARCHAR(30)       NOT NULL,
    CONSTRAINT PK_Suspect PRIMARY KEY (PersonID),
    CONSTRAINT UQ_Suspect_SuspectRowID UNIQUE (SuspectRowID),
    CONSTRAINT FK_Suspect_Person FOREIGN KEY (PersonID) REFERENCES dbo.Person (PersonID)
);
GO

/* ---------- 13. Incident ---------- */
CREATE TABLE dbo.Incident (
    IncidentNumber   INT IDENTITY(1,1) NOT NULL,
    IncidentDateTime DATETIME          NOT NULL,
    Location         VARCHAR(200)      NOT NULL,
    Type             VARCHAR(50)       NOT NULL,
    Description      VARCHAR(500)      NULL,
    ReportDate       DATE              NOT NULL,
    ComplainantID    INT               NOT NULL,
    CONSTRAINT PK_Incident PRIMARY KEY (IncidentNumber),
    CONSTRAINT FK_Incident_Complainant FOREIGN KEY (ComplainantID) REFERENCES dbo.Complainant (PersonID)
);
GO

/* ---------- 14. WitnessStatement ---------- */
CREATE TABLE dbo.WitnessStatement (
    StatementID    INT IDENTITY(1,1) NOT NULL,
    StatementDate  DATE              NOT NULL,
    Summary        VARCHAR(500)      NOT NULL,
    WitnessID      INT               NOT NULL,
    IncidentNumber INT               NOT NULL,
    CONSTRAINT PK_WitnessStatement PRIMARY KEY (StatementID),
    CONSTRAINT FK_WitnessStatement_Witness FOREIGN KEY (WitnessID) REFERENCES dbo.Witness (PersonID),
    CONSTRAINT FK_WitnessStatement_Incident FOREIGN KEY (IncidentNumber) REFERENCES dbo.Incident (IncidentNumber)
);
GO

/* ---------- 15. Case ---------- */
CREATE TABLE dbo.[Case] (
    CaseNumber     INT IDENTITY(1,1) NOT NULL,
    OpenDate       DATE              NOT NULL,
    CloseDate      DATE              NULL,
    Status         VARCHAR(30)       NOT NULL,
    Priority       VARCHAR(20)       NOT NULL,
    IncidentNumber INT               NOT NULL,
    OfficerID      INT               NOT NULL,
    CONSTRAINT PK_Case PRIMARY KEY (CaseNumber),
    CONSTRAINT FK_Case_Incident FOREIGN KEY (IncidentNumber) REFERENCES dbo.Incident (IncidentNumber),
    CONSTRAINT FK_Case_Officer FOREIGN KEY (OfficerID) REFERENCES dbo.Officer (EmployeeID),
    CONSTRAINT CK_Case_Dates CHECK (CloseDate >= OpenDate),
    -- Business rule 11: an incident results in zero or one case
    CONSTRAINT UQ_Case_IncidentNumber UNIQUE (IncidentNumber)
);
GO

/* ---------- 16. Evidence ---------- */
CREATE TABLE dbo.Evidence (
    EvidenceID      INT IDENTITY(1,1) NOT NULL,
    EvidenceType    VARCHAR(30)       NOT NULL,
    DateCollected   DATE              NOT NULL,
    Description     VARCHAR(300)      NULL,
    StorageLocation VARCHAR(100)      NOT NULL,
    CaseNumber      INT               NOT NULL,
    OfficerID       INT               NOT NULL,
    CONSTRAINT PK_Evidence PRIMARY KEY (EvidenceID),
    CONSTRAINT FK_Evidence_Case FOREIGN KEY (CaseNumber) REFERENCES dbo.[Case] (CaseNumber),
    CONSTRAINT FK_Evidence_Officer FOREIGN KEY (OfficerID) REFERENCES dbo.Officer (EmployeeID),
    CONSTRAINT CK_Evidence_EvidenceType CHECK (EvidenceType IN ('Physical','Document','PhotoVideo','Digital'))
);
GO

/* ---------- 17. PhysicalItem ---------- */
CREATE TABLE dbo.PhysicalItem (
    PhysicalItemRowID INT IDENTITY(1,1) NOT NULL,
    EvidenceID        INT               NOT NULL,
    ItemCategory      VARCHAR(50)       NOT NULL,
    ItemCondition     VARCHAR(50)       NOT NULL,
    CONSTRAINT PK_PhysicalItem PRIMARY KEY (EvidenceID),
    CONSTRAINT UQ_PhysicalItem_PhysicalItemRowID UNIQUE (PhysicalItemRowID),
    CONSTRAINT FK_PhysicalItem_Evidence FOREIGN KEY (EvidenceID) REFERENCES dbo.Evidence (EvidenceID)
);
GO

/* ---------- 18. DigitalFile ---------- */
CREATE TABLE dbo.DigitalFile (
    DigitalFileRowID INT IDENTITY(1,1) NOT NULL,
    EvidenceID       INT               NOT NULL,
    FileFormat       VARCHAR(20)       NOT NULL,
    FileSize         INT               NOT NULL,
    CONSTRAINT PK_DigitalFile PRIMARY KEY (EvidenceID),
    CONSTRAINT UQ_DigitalFile_DigitalFileRowID UNIQUE (DigitalFileRowID),
    CONSTRAINT FK_DigitalFile_Evidence FOREIGN KEY (EvidenceID) REFERENCES dbo.Evidence (EvidenceID)
);
GO

/* ---------- 19. PhotoVideo ---------- */
CREATE TABLE dbo.PhotoVideo (
    PhotoVideoRowID INT IDENTITY(1,1) NOT NULL,
    EvidenceID      INT               NOT NULL,
    MediaFormat     VARCHAR(30)       NOT NULL,
    CaptureDate     DATE              NOT NULL,
    Duration        INT               NULL,
    CONSTRAINT PK_PhotoVideo PRIMARY KEY (EvidenceID),
    CONSTRAINT UQ_PhotoVideo_PhotoVideoRowID UNIQUE (PhotoVideoRowID),
    CONSTRAINT FK_PhotoVideo_Evidence FOREIGN KEY (EvidenceID) REFERENCES dbo.Evidence (EvidenceID)
);
GO

/* ---------- 20. Document ---------- */
CREATE TABLE dbo.Document (
    DocumentRowID INT IDENTITY(1,1) NOT NULL,
    EvidenceID    INT               NOT NULL,
    DocumentType  VARCHAR(50)       NOT NULL,
    PageCount     INT               NOT NULL,
    StatementID   INT               NULL,
    CONSTRAINT PK_Document PRIMARY KEY (EvidenceID),
    CONSTRAINT UQ_Document_DocumentRowID UNIQUE (DocumentRowID),
    CONSTRAINT FK_Document_Evidence FOREIGN KEY (EvidenceID) REFERENCES dbo.Evidence (EvidenceID),
    CONSTRAINT FK_Document_WitnessStatement FOREIGN KEY (StatementID) REFERENCES dbo.WitnessStatement (StatementID)
);
GO

/* ---------- 21. CaseSuspect ---------- */
CREATE TABLE dbo.CaseSuspect (
    CaseSuspectID INT IDENTITY(1,1) NOT NULL,
    CaseNumber    INT               NOT NULL,
    SuspectID     INT               NOT NULL,
    RoleInCase    VARCHAR(50)       NOT NULL,
    DateLinked    DATE              NOT NULL,
    CONSTRAINT PK_CaseSuspect PRIMARY KEY (CaseNumber, SuspectID),
    CONSTRAINT UQ_CaseSuspect_CaseSuspectID UNIQUE (CaseSuspectID),
    CONSTRAINT FK_CaseSuspect_Case FOREIGN KEY (CaseNumber) REFERENCES dbo.[Case] (CaseNumber),
    CONSTRAINT FK_CaseSuspect_Suspect FOREIGN KEY (SuspectID) REFERENCES dbo.Suspect (PersonID)
);
GO

/* ---------- 22. Arrest ---------- */
CREATE TABLE dbo.Arrest (
    ArrestID   INT IDENTITY(1,1) NOT NULL,
    ArrestDate DATE              NOT NULL,
    ArrestTime TIME              NOT NULL,
    Charge     VARCHAR(200)      NOT NULL,
    Location   VARCHAR(200)      NOT NULL,
    OfficerID  INT               NOT NULL,
    SuspectID  INT               NOT NULL,
    CaseNumber INT               NOT NULL,
    CONSTRAINT PK_Arrest PRIMARY KEY (ArrestID),
    CONSTRAINT FK_Arrest_Officer FOREIGN KEY (OfficerID) REFERENCES dbo.Officer (EmployeeID),
    CONSTRAINT FK_Arrest_Suspect FOREIGN KEY (SuspectID) REFERENCES dbo.Suspect (PersonID),
    CONSTRAINT FK_Arrest_Case FOREIGN KEY (CaseNumber) REFERENCES dbo.[Case] (CaseNumber),
    -- Business rule 21: the suspect in an arrest must already be linked to that case in CaseSuspect
    CONSTRAINT FK_Arrest_CaseSuspect FOREIGN KEY (CaseNumber, SuspectID) REFERENCES dbo.CaseSuspect (CaseNumber, SuspectID)
);
GO
