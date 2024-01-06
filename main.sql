create database ClubNetwork;

use ClubNetwork;

-- Таблиця ClubNetwork
CREATE TABLE ClubNetwork (
  Network_ID INT PRIMARY KEY,
  Name VARCHAR(25)
); -- ready 

select ClubNetwork.Network_ID from ClubNetwork
inner join club on club.network_id = ClubNetwork.network_id;

-- Таблиця Club
CREATE TABLE Club (
  Club_ID INT PRIMARY KEY,
  Name VARCHAR(25),
  Address VARCHAR(50),
  Phone VARCHAR(20),
  WorkingHours VARCHAR(255),
  Network_ID INT,
  FOREIGN KEY (Network_ID) REFERENCES ClubNetwork(Network_ID)
); -- ready


-- Таблиця ClubMember
CREATE TABLE ClubMember (
  Member_ID INT PRIMARY KEY,
  Name CHAR(25),
  Gender VARCHAR(10),
  Address VARCHAR(50),
  Phone VARCHAR(20),
  BirthDate DATE,
  Club_ID INT,
  Subscription_ID INT,
  Service_ID INT,
  FOREIGN KEY (Club_ID) REFERENCES Club(Club_ID),
  FOREIGN KEY (Subscription_ID) REFERENCES Subscription(Subscription_ID),
  FOREIGN KEY (Service_ID) REFERENCES ClubService(Service_ID)
); -- ready 

-- Таблиця ClubTrainer
CREATE TABLE ClubTrainer (
  Trainer_ID INT PRIMARY KEY,
  Name CHAR(25),
  Phone VARCHAR(20),
  Specialization VARCHAR(25),
  WorkSchedule VARCHAR(255),
  Description TEXT,
  Salary DECIMAL(10, 2),
  Club_ID INT,
  FOREIGN KEY (Club_ID) REFERENCES Club(Club_ID)
); -- ready

-- Таблиця ClubService
CREATE TABLE ClubService (
  Service_ID INT PRIMARY KEY,
  Name VARCHAR(25),
  Description TEXT,
  Price DECIMAL(10, 2),
  Club_ID INT,
  FOREIGN KEY (Club_ID) REFERENCES Club(Club_ID)
); -- ready

-- Таблиця ClubInventory
CREATE TABLE ClubInventory (
  Inventory_ID INT PRIMARY KEY,
  Name VARCHAR(25),
  Quantity INT,
  Club_ID INT,
  FOREIGN KEY (Club_ID) REFERENCES Club(Club_ID)
); -- ready

-- Таблиця ClubInformation
CREATE TABLE ClubInformation (
  Information_ID INT PRIMARY KEY,
  Description TEXT,
  Rating INT,
  Club_ID INT,
  FOREIGN KEY (Club_ID) REFERENCES Club(Club_ID)
); -- ready 

-- Таблиця Subscription
CREATE TABLE Subscription (
  Subscription_ID INT PRIMARY KEY,
  Type VARCHAR(255),
  Price DECIMAL(10, 2),
  StartDate DATE,
  EndDate DATE,
  Member_ID INT,
  Club_ID INT,
  FOREIGN KEY (Member_ID) REFERENCES ClubMember(Member_ID),
  FOREIGN KEY (Club_ID) REFERENCES Club(Club_ID)
); -- ready

-- Таблиця ClubSession
CREATE TABLE ClubSession (
  Session_ID INT PRIMARY KEY,
  Name VARCHAR(25),
  DateAndTime DATETIME,
  Duration INT,
  Trainer_ID INT,
  Club_ID INT,
  Member_ID INT,
  MaxParticipants INT,
  FOREIGN KEY (Trainer_ID) REFERENCES ClubTrainer(Trainer_ID),
  FOREIGN KEY (Club_ID) REFERENCES Club(Club_ID),
  FOREIGN KEY (Member_ID) REFERENCES ClubMember(Member_ID)
); -- ready


create table clubaction (
  Action_ID INT PRIMARY KEY,
  Name VARCHAR(25),
  StartDate DATE,
  EndDate DATE,
  Description VARCHAR(255),
  Club_ID INT,
  FOREIGN KEY (Club_ID) REFERENCES Club(Club_ID)
); -- ready


DELIMITER //

CREATE FUNCTION GetClubMembersCount(ClubID INT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE membersCount INT;
    SELECT COUNT(*) INTO membersCount
    FROM ClubMember
    WHERE Club_ID = ClubID;
    RETURN membersCount;
END //

DELIMITER ;

SELECT ClubNetwork.GetClubMembersCount(2) AS MembersCount;

DELIMITER //

CREATE FUNCTION GetClubServicesCount(ClubID INT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE servicesCount INT;
    SELECT COUNT(*) INTO servicesCount
    FROM ClubService
    WHERE Club_ID = ClubID;
    RETURN servicesCount;
END //

DELIMITER ;

DELIMITER //

CREATE FUNCTION GetTotalClubMembers() RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE totalMembers INT;
    SELECT COUNT(*) INTO totalMembers
    FROM ClubMember;
    RETURN totalMembers;
END //

DELIMITER ;

SELECT ClubNetwork.GetTotalClubMembers() AS TotalMembers;

DELIMITER //

CREATE FUNCTION GetClubAverageRating(ClubID INT) RETURNS DECIMAL(3, 2)
DETERMINISTIC
BEGIN
    DECLARE avgRating DECIMAL(3, 2);
    SELECT AVG(Rating) INTO avgRating
    FROM ClubInformation
    WHERE Club_ID = ClubID;
    RETURN avgRating;
END //

DELIMITER ;

SELECT ClubNetwork.GetClubAverageRating(3) AS Avgaer;

DELIMITER //

CREATE PROCEDURE UpdateClubMemberClub(IN MemberID INT, IN NewClubID INT)
BEGIN
    UPDATE ClubMember
    SET Club_ID = NewClubID
    WHERE Member_ID = MemberID;
END //

DELIMITER ;

CALL UpdateClubMemberClub(1, 3);

DELIMITER //
CREATE PROCEDURE ChangeClubForMember(
    IN p_MemberID INT,
    IN p_NewClubID INT
)
BEGIN
    UPDATE ClubMember
    SET Club_ID = p_NewClubID
    WHERE Member_ID = p_MemberID;
END //
DELIMITER ;

CALL ChangeClubForMember(1, 2);

DELIMITER //

CREATE PROCEDURE GetClubMemberInfo(
    IN p_MemberID INT
)
BEGIN
    SELECT *
    FROM ClubMember
    WHERE Member_ID = p_MemberID;
END //

DELIMITER ;

CALL GetClubMemberInfo(1);

DELIMITER //

CREATE TRIGGER SetActionDatesTrigger
BEFORE INSERT ON ClubAction
FOR EACH ROW
BEGIN
    SET NEW.StartDate = NOW();
    SET NEW.EndDate = NOW() + INTERVAL 7 DAY;  -- Припустимо, що кожна дія триває 7 днів.
END //

DELIMITER ;


INSERT INTO ClubAction (Action_ID, Name) VALUES (1001, 'Нова дія');
select * from clubAction;

-- 1 
SELECT Club.Name, AVG(YEAR(CURDATE()) - YEAR(BirthDate)) AS AverageAge
FROM Club
LEFT JOIN ClubMember ON Club.Club_ID = ClubMember.Club_ID
GROUP BY Club.Club_ID;

-- 2
SELECT Club.Name, AVG(Rating) AS AverageRating
FROM Club
LEFT JOIN ClubInformation ON Club.Club_ID = ClubInformation.Club_ID
GROUP BY Club.Club_ID;

-- 3
SELECT Subscription.Type, COUNT(DISTINCT ClubMember.Member_ID) AS SubscribedMembers
FROM Subscription
INNER JOIN ClubMember ON Subscription.Member_ID = ClubMember.Member_ID
GROUP BY Subscription.Type;

-- 4
SELECT ClubTrainer.Name, AVG(Salary) AS AverageSalary
FROM ClubTrainer
GROUP BY ClubTrainer.Trainer_ID;

-- 5
SELECT Club.Name, AVG(MaxParticipants) AS AvgParticipantsPerSession
FROM Club
LEFT JOIN ClubSession ON Club.Club_ID = ClubSession.Club_ID
GROUP BY Club.Club_ID;

-- 6
SELECT COUNT(DISTINCT ClubMember.Member_ID) AS TotalMembers
FROM ClubMember;

-- 7
SELECT ClubTrainer.Name AS TrainerName, COUNT(ClubSession.Trainer_ID) AS TrainingCount
FROM ClubTrainer
LEFT JOIN ClubSession ON ClubTrainer.Trainer_ID = ClubSession.Trainer_ID
GROUP BY ClubTrainer.Trainer_ID
ORDER BY TrainingCount DESC
LIMIT 1;

-- 8 
SELECT Club.Name, COUNT(ClubMember.Member_ID) AS MemberCount
FROM Club
LEFT JOIN ClubMember ON Club.Club_ID = ClubMember.Club_ID
GROUP BY Club.Club_ID
ORDER BY MemberCount ASC
LIMIT 1;

-- 9 
SELECT ClubMember.Name AS MemberName
FROM ClubMember
WHERE Member_ID IN (
   SELECT Member_ID
   FROM Subscription
   GROUP BY Member_ID
   HAVING COUNT(DISTINCT Service_ID) = (SELECT COUNT(DISTINCT Service_ID) FROM ClubService WHERE Club_ID = 1)
);

-- 10
SELECT ClubTrainer.Name AS TrainerName
FROM ClubTrainer
WHERE Trainer_ID IN (
   SELECT Trainer_ID
   FROM Club
   GROUP BY Trainer_ID
   HAVING COUNT(DISTINCT Club_ID) = (SELECT COUNT(DISTINCT Club_ID) FROM Club)
);

-- 11
SELECT Club.Name, AVG(Duration) AS AverageTrainingDuration
FROM Club
LEFT JOIN ClubSession ON Club.Club_ID = ClubSession.Club_ID
GROUP BY Club.Club_ID
HAVING AverageTrainingDuration > 60;

-- 12
SELECT Club.Name AS ClubName, COUNT(DISTINCT ClubTrainer.Trainer_ID) AS TrainerCount
FROM Club
LEFT JOIN ClubTrainer ON Club.Club_ID = ClubTrainer.Club_ID
GROUP BY Club.Club_ID
HAVING TrainerCount > 1;

-- 13
SELECT ClubTrainer.Name AS TrainerName, ClubService.Name AS ServiceName
FROM ClubTrainer
LEFT JOIN Club ON ClubTrainer.Club_ID = Club.Club_ID
LEFT JOIN ClubService ON Club.Club_ID = ClubService.Club_ID;

-- 14
SELECT Club.Name, COUNT(ClubService.Service_ID) AS ServiceCount
FROM Club
LEFT JOIN ClubService ON Club.Club_ID = ClubService.Club_ID
GROUP BY Club.Club_ID
ORDER BY ServiceCount DESC
LIMIT 1;

-- 15
SELECT ClubMember.Name AS MemberName
FROM ClubMember
WHERE Member_ID IN (
   SELECT Member_ID
   FROM Subscription
   WHERE Club_ID = 1
   GROUP BY Member_ID
   HAVING COUNT(DISTINCT Service_ID) = (SELECT COUNT(DISTINCT Service_ID) FROM ClubService WHERE Club_ID = 1)
);

-- 16 
SELECT Club.Club_ID, Club.Name, COUNT(DISTINCT ClubTrainer.Trainer_ID) AS UniqueTrainersCount
FROM Club
LEFT JOIN ClubTrainer ON Club.Club_ID = ClubTrainer.Club_ID
GROUP BY Club.Club_ID;


-- 17 
SELECT ClubSession.Trainer_ID, ClubTrainer.Name AS TrainerName, COUNT(DISTINCT ClubSession.Member_ID) AS ParticipantsCount
FROM ClubSession
LEFT JOIN ClubTrainer ON ClubSession.Trainer_ID = ClubTrainer.Trainer_ID
WHERE ClubSession.Trainer_ID = 1  -- ID конкретного тренера
GROUP BY ClubSession.Trainer_ID;

-- 18
SELECT Club.Name AS ClubName, COUNT(DISTINCT ClubService.Service_ID) AS ServiceCount
FROM Club
LEFT JOIN ClubService ON Club.Club_ID = ClubService.Club_ID
GROUP BY Club.Club_ID;

-- 19
SELECT ClubTrainer.Name AS TrainerName, COUNT(ClubSession.Trainer_ID) AS TrainingCount
FROM ClubTrainer
LEFT JOIN ClubSession ON ClubTrainer.Trainer_ID = ClubSession.Trainer_ID
GROUP BY ClubTrainer.Trainer_ID
ORDER BY TrainingCount ASC;

-- 20
SELECT ClubMember.Name AS MemberName, MAX(Subscription.EndDate) AS LastPaymentDate
FROM ClubMember
LEFT JOIN Subscription ON ClubMember.Member_ID = Subscription.Member_ID
WHERE Subscription.EndDate IS NOT NULL
GROUP BY ClubMember.Member_ID;

CREATE INDEX idx_fk_ClubMember_Club_ID ON ClubMember(Club_ID);
CREATE INDEX idx_fk_ClubTrainer_Club_ID ON ClubTrainer(Club_ID);
CREATE INDEX idx_fk_ClubService_Club_ID ON ClubService(Club_ID);
CREATE INDEX idx_ClubSession_DateAndTime ON ClubSession(DateAndTime);
CREATE INDEX idx_Subscription_StartDate_EndDate ON Subscription(StartDate, EndDate);

SELECT Club.Name, AVG(YEAR(CURDATE()) - YEAR(BirthDate)) AS AverageAge
FROM Club
LEFT JOIN ClubMember ON Club.Club_ID = ClubMember.Club_ID
GROUP BY Club.Club_ID;

CREATE INDEX idx_ClubMember_Club_ID_BirthDate ON ClubMember(Club_ID, BirthDate);

SELECT Club.Name, AVG(Rating) AS AverageRating
FROM Club
LEFT JOIN ClubInformation ON Club.Club_ID = ClubInformation.Club_ID
GROUP BY Club.Club_ID;

CREATE INDEX idx_ClubInformation_Club_ID_Rating ON ClubInformation(Club_ID, Rating);






















CREATE VIEW TrainingParticipants AS
SELECT
   ClubSession.Session_ID,
   ClubSession.DateAndTime,
   ClubSession.Duration,
   Club.Name AS ClubName,
   ClubTrainer.Name AS TrainerName,
   ClubMember.Name AS ParticipantName
FROM
   ClubSession
INNER JOIN Club ON ClubSession.Club_ID = Club.Club_ID
INNER JOIN ClubTrainer ON ClubSession.Trainer_ID = ClubTrainer.Trainer_ID
INNER JOIN ClubMember ON ClubSession.Member_ID = ClubMember.Member_ID;

-- Вибірка всіх учасників тренувань з представлення TrainingParticipants
SELECT *
FROM UniqueClubMembers;

CREATE VIEW ClubServices AS
SELECT
   Club.Name AS ClubName,
   ClubService.Service_ID,
   ClubService.Name AS ServiceName,
   ClubService.Description,
   ClubService.Price
FROM
   Club
LEFT JOIN ClubService ON Club.Club_ID = ClubService.Club_ID;

CREATE VIEW UniqueClubMembers AS
SELECT DISTINCT
   Club.Club_ID,
   Club.Name AS ClubName,
   ClubMember.Member_ID,
   ClubMember.Name AS MemberName,
   ClubMember.Gender,
   ClubMember.BirthDate
FROM
   Club
INNER JOIN ClubMember ON Club.Club_ID = ClubMember.Club_ID;









