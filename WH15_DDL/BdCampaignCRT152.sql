
USE [master]
GO

/****** Object:  Database [Campaign]    Script Date: 28.05.2021 18:33:45 ******/
CREATE DATABASE [Campaign]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Campaign', FILENAME = N'D:\WORKSD\MSSQL2017\Campaing\Campaign.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Campaign_log', FILENAME = N'D:\WORKSD\MSSQL2017\Campaing\Campaign_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO

ALTER DATABASE [Campaign] SET COMPATIBILITY_LEVEL = 140
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Campaign].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [Campaign] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [Campaign] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [Campaign] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [Campaign] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [Campaign] SET ARITHABORT OFF 
GO

ALTER DATABASE [Campaign] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [Campaign] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [Campaign] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [Campaign] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [Campaign] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [Campaign] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [Campaign] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [Campaign] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [Campaign] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [Campaign] SET  DISABLE_BROKER 
GO

ALTER DATABASE [Campaign] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [Campaign] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [Campaign] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [Campaign] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [Campaign] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [Campaign] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [Campaign] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [Campaign] SET RECOVERY FULL 
GO

ALTER DATABASE [Campaign] SET  MULTI_USER 
GO

ALTER DATABASE [Campaign] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [Campaign] SET DB_CHAINING OFF 
GO

ALTER DATABASE [Campaign] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [Campaign] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO

ALTER DATABASE [Campaign] SET DELAYED_DURABILITY = DISABLED 
GO

ALTER DATABASE [Campaign] SET QUERY_STORE = OFF
GO

USE [Campaign]
GO

ALTER DATABASE SCOPED CONFIGURATION SET IDENTITY_CACHE = ON;
GO

ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO

ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
GO

ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO

ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO

ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO

ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
GO

ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO

ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
GO

ALTER DATABASE [Campaign] SET  READ_WRITE 
GO

/********************Таблицы****************************************************************/

USE Campaign;
GO

/**************** Пользователи Позволяет создавать группы пользователей **********************************/

  CREATE TABLE Users
(
    UsersId   int identity(1,1) NOT NULL, 
    UserName  nvarchar(120)  NOT NULL,           --- Короткое название пользователя, псевдоним или логин
    Lastname nvarchar(40)  NULL,               --- ФИО
    Firstname nvarchar(40) NOT NULL,
    middlename nvarchar(40)   NULL,
    UserPassword nvarchar(16)    NULL,                --- Пароль
    UsersIdGroup      int      NULL,             --- Код группы
    GroupSign    char(1)      NULL,                --- Признак группы
    FromDate     datetime2    NULL,           --- Разрешенный период времени работы
    ToDate       datetime2    NULL,
    FirstEntry   datetime2    NULL,           --- Дата первого входа
    LastEntry    datetime2    NULL,           --- Дата последнего входа
---    DepartmentsId  int    NULL,          --- Код подразделения
    Phone         nvarchar(40)     NULL,      --- Контактный телефон
    Office        nchar(10)        NULL,         --- Номер комнаты
    E_mail        nchar(254)       NULL,         --- Адрес почты
    Counter       int              NULL,     --- Количество входов
    WorkTime     bigint              NULL,     --- Общее время
    UserIdLastEditedBy int NOT NULL,
    ValidFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
    ValidTo datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
CONSTRAINT PK_Users PRIMARY KEY CLUSTERED (UsersId)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Users_Archive)
);
GO

CREATE UNIQUE INDEX UI_users_names ON Users(UserName);
GO

CREATE INDEX FI_user_user ON Users(UsersIdGroup);
GO

ALTER TABLE Users ADD CONSTRAINT FK_user_usergroup FOREIGN KEY (UsersIdGroup)  REFERENCES Users (UsersId);
GO

/***
ALTER TABLE Users ADD CONSTRAINT FK_Users_departments FOREIGN KEY (DepartmentsId)
REFERENCES Departments (DepartmentsId);
***/



CREATE TABLE Countries
(
    CountryId   int identity(1, 1) NOT NULL,
    CountryName nvarchar(250) NOT NULL,
    Continent nvarchar(30) NOT NULL,  
    UserIdLastEditedBy int NOT NULL,
    ValidFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
    ValidTo datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
CONSTRAINT PK_Countries PRIMARY KEY CLUSTERED (CountryID),
CONSTRAINT FK_Countries_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId), 
CONSTRAINT [UI_Countries_CountryName] UNIQUE NONCLUSTERED (CountryName)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Countries_Archive ));
GO

/********Федеральные округа Российской Федерации *********/

CREATE TABLE FederalDistrict
(
    FederalDistrictId   int identity(1, 1) NOT NULL,
    FederalDistrict_id  int   NOT NULL,
    FederalDistrictName nvarchar(250)   NOT NULL,
    UserIdLastEditedBy int NOT NULL,
    ValidFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
    ValidTo datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
CONSTRAINT PK_FederalDistrict PRIMARY KEY CLUSTERED (FederalDistrictId),
CONSTRAINT FK_FederalDistrict_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId),
CONSTRAINT [UI_FederalDistrict_FederalDistrictName] UNIQUE NONCLUSTERED (FederalDistrictName),
CONSTRAINT [UI_FederalDistrict_FederalDistrict_id] UNIQUE NONCLUSTERED (FederalDistrict_id)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.FederalDistrict_Archive));
GO

/*********Справочник регионов стран *********/

CREATE TABLE CountryRegions
(
    CountryRegionId  int identity(1, 1) NOT NULL,
    ContryId int NOT NULL,    --- fk Countries
    FederalDistrictId int NULL,  --- fk FederalDistrictId
    CountryRegion_id    varchar(2)      NULL,   --- код региона
    CountryRegionName  nvarchar(250)   NOT NULL,
    CountregGuid nvarchar(36) NULL, ----- уникальный идентификатор региона
    UserIdLastEditedBy int NOT NULL,
    ValidFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
    ValidTo datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
CONSTRAINT PK_CountryRegions PRIMARY KEY CLUSTERED (CountryRegionId),
CONSTRAINT FK_CountryRegions_Countries  FOREIGN KEY (ContryId) REFERENCES Countries (CountryId),
CONSTRAINT FK_CountryRegions_FederalDistrictId FOREIGN KEY (FederalDistrictId) REFERENCES FederalDistrict(FederalDistrictId),
CONSTRAINT FK_CountryRegions_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId),
CONSTRAINT [UI_CountryRegions_CountryRegionName] UNIQUE NONCLUSTERED (CountryRegionName)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.CountryRegions_Archive));
GO

CREATE INDEX FI_CountryRegions_Contry ON CountryRegions (ContryId);
GO

CREATE INDEX FI_CountryRegions_FederalDistrictId ON CountryRegions (FederalDistrictId);
GO


/* ============================================================ */
/* Справочник регионов областей.                                */
/* ============================================================ */

CREATE TABLE AreaRegions
(
    AreaRegionId   int identity(1,1) NOT NULL,
    CountryRegionId   int   NOT NULL,
    AreaRegionName    nvarchar(250) NOT NULL,
    AreaRegionGuid varchar(36) NULL, ----- уникальный идентификатор региона области
    UserIdLastEditedBy int NOT NULL,
    ValidFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
    ValidTo datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
CONSTRAINT PK_AreaRegions PRIMARY KEY CLUSTERED (AreaRegionId),
CONSTRAINT FK_AreaRegions_CountryRegions  FOREIGN KEY (CountryRegionId) REFERENCES CountryRegions (CountryRegionId),
CONSTRAINT FK_AreaRegions_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId),
CONSTRAINT [UI_AreaRegions_AreaRegionName] UNIQUE NONCLUSTERED (AreaRegionName)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.AreaRegions_Archive));

GO

CREATE INDEX FI_AreaRegions_CountryRegion ON AreaRegions (CountryRegionId);
GO


/* ============================================================ */
/* Справочник городов(населенных пунктов)                       */
/* ============================================================ */

CREATE TABLE Towns
(
    TownsId             bigint identity(1,1) NOT NULL,
    CountryId           int       NOT NULL,
    TownName            nvarchar(250)  NOT NULL,
    Prefix              nvarchar(25)      NULL,  --- например г., пос., пгт.
    CountryRegionId     int           NULL,
    AreaRegionId        int           NULL,
    Towns_guid          nvarchar(36) NULL, ----- уникальный идентификатор города (населенного пункта)
    UserIdLastEditedBy int NOT NULL,
    ValidFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
    ValidTo datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
CONSTRAINT PK_Towns PRIMARY KEY CLUSTERED (TownsId),
CONSTRAINT FK_Towns_Countries  FOREIGN KEY (CountryId) REFERENCES Countries (CountryId),
CONSTRAINT FK_Towns_CountryRegions  FOREIGN KEY (CountryRegionId) REFERENCES CountryRegions (CountryRegionId),
CONSTRAINT FK_Towns_AreaRegions FOREIGN KEY (AreaRegionId) REFERENCES AreaRegions(AreaRegionId),
CONSTRAINT FK_Towns_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Towns_Archive)
);
GO

CREATE UNIQUE INDEX UI_Townsname ON Towns (TownName, Prefix, CountryRegionId, AreaRegionId, Towns_guid);
GO

CREATE INDEX FI_Towns_CountryRegion ON Towns (CountryRegionId);
GO

CREATE INDEX FI_Towns_AreaRegion ON Towns (AreaRegionId);
GO



/* ============================================================ */
/* Справочник улиц.                                             */
/* ============================================================ */

CREATE TABLE Streets
(
    StreetsId     bigint identity(1,1) NOT NULL,
    TownsId       bigint       NOT NULL,   --- fk towns
    StreetName    nvarchar(250) NOT NULL,
    Prefix        nvarchar(15)      NULL,  --- например ул., пер., просп.
    Streets_guid  nvarchar(36)      NULL,  --- уникальный идентификатор улицы
    UserIdLastEditedBy int NOT NULL,
    ValidFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
    ValidTo datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
CONSTRAINT PK_Streets PRIMARY KEY CLUSTERED (StreetsId),
CONSTRAINT FK_Streets_Towns  FOREIGN KEY (TownsId) REFERENCES Towns (TownsId),
CONSTRAINT FK_Streets_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Streets_Archive)
);
GO

CREATE UNIQUE INDEX UI_StreetNames ON Streets (StreetName, Prefix, TownsId, Streets_guid);
GO


CREATE INDEX FI_Streets_Towns ON Streets (TownsId);
GO



/* ============================================================ */
/* Справочник адресов.                                          */
/* ============================================================ */

CREATE TABLE Address
(
   AddressId          bigint identity(1,1) NOT NULL,
   StreetsId          bigint               NOT NULL,   --- fk streets
   House              int               NOT NULL,
   Postfix            nvarchar(15)              NULL,
   Post_index         nvarchar(6)               NULL,
   Address_guid       nvarchar(36) NULL, ----- уникальный идентификатор адреса
   UserIdLastEditedBy int NOT NULL,
   ValidFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
   ValidTo datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
CONSTRAINT PK_Address PRIMARY KEY CLUSTERED (AddressId),
CONSTRAINT FK_Address_Streets  FOREIGN KEY (StreetsId) REFERENCES Streets (StreetsId),
CONSTRAINT FK_Address_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Address_Archive)
);
GO

CREATE UNIQUE INDEX UI_Address_houses ON Address (StreetsId, House, postfix, Address_guid);
GO

CREATE INDEX FI_Address_Streets ON Address (StreetsId);
GO


/*********Справочник квартир (помещений)**********/
create table Rooms
(
RoomsId         bigint identity(1,1) NOT NULL,
AddressId       bigint         NOT NULL,  --- fk address
Flat            int            NULL,  --- квартира адреса
Flat_postfix    nvarchar(50)       NULL,  --- постфикс квартиры адреса
Roomguid        nvarchar(36)        NULL,  ---   Глобальный уникальный идентификатор помещения
UserIdLastEditedBy int NOT NULL,
ValidFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
ValidTo datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
CONSTRAINT PK_Rooms PRIMARY KEY CLUSTERED (RoomsId),
CONSTRAINT FK_Rooms_Address  FOREIGN KEY (AddressId) REFERENCES Address (AddressId),
CONSTRAINT FK_Rooms_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Rooms_Archive)
);
GO

CREATE INDEX FI_Rooms_Address ON Rooms (AddressId);
GO


/*************Таблицы формирования клиента****************/

/*********Физические лица********/

CREATE TABLE Peoples
(
    PeoplesId bigint identity(1,1) NOT NULL,  --- id клиента
    Lastname nvarchar(50)    NULL,         --- ФИО
    Firstname nvarchar(50)    NULL,
    Middlename nvarchar(50)  NULL,
    Gender smallint NULL, --- пол 1 -мужчина, 2 -женщина
    BirthDate datetime2 NULL,    --- дата рождения
    Address nvarchar(500) NULL,    --- адрес произвольный текст
    AddressId bigint NULL,  --- код адреса
    RoomsId   bigint NULL,  --- код квартиры (помещения)
    comment nvarchar(500) NULL, --- произвольное описание
    UserIdLastEditedBy int NOT NULL,
    LastEditedBy datetime2  NOT NULL,
CONSTRAINT PK_Peoples PRIMARY KEY CLUSTERED (PeoplesId),
CONSTRAINT FK_Peoples_Address  FOREIGN KEY (AddressId) REFERENCES Address (AddressId),
CONSTRAINT FK_Peoples_Rooms  FOREIGN KEY (RoomsId) REFERENCES Rooms (RoomsId),
CONSTRAINT FK_Peoples_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
);
GO

ALTER TABLE Peoples 
ADD CONSTRAINT Peoples_Gender CHECK (Gender IN (1,2));
GO

CREATE INDEX FI_Peoples_Address ON Peoples (AddressId);
GO

CREATE INDEX FI_Peoples_Rooms ON Peoples (RoomsId);
GO


/***** Предприятия  ********/

CREATE TABLE Firms
(
    FirmsId bigint identity(1,1) NOT NULL,        --- id клиента
    FirmName nvarchar(255)  NOT NULL,   --- Наименование предприятия
    FirmFulln nvarchar(450)   NULL, --- Наименование полное
    AddressJur nvarchar(450) NULL,  --- адрес юридический произвольный текст
    AddressLoc nvarchar(450) NULL,  --- адрес расположения произвольный текст
    AddressDeliv varchar(450) NULL,  --- адрес доставки произвольный текст
    AddressIdJur bigint NULL,  --- код юридического адреса
    FlatJur smallint NULL,  --- квартира (офис) юридического адреса
    FlatPostfixJur nvarchar(10) NULL,  --- постфикс квартиры (офис) юридического адреса
    RoomsIdJur   bigint NULL,  --- код квартиры (помещения) юридического адреса
    AddressIdLoc bigint NULL,  --- код адреса нахождения
    Flatloc smallint NULL,  --- квартира (офис)  адреса нахождения
    flat_postfix_loc varchar(10) NULL,  --- постфикс квартиры (офис) адреса нахождения
    RoomsIdLoc bigint NULL,  --- код квартиры (помещения)  адреса нахождения
    AddressIdDeliv bigint NULL,  --- код адреса доставки
    FlatDeliv smallint NULL,  --- квартира (офис)  адреса доставки
    FlatPostfixDeliv nvarchar(10) NULL,  --- постфикс квартиры (офис) адреса доставки
    RoomsIdDeliv  bigint NULL,  --- код квартиры (помещения) адреса доставки
    FirmType smallint NULL,   --- тип предприятия : 1-государственные, 2-муниципальные, 3-частные, 4-смешанные,5-частные предприниматели
    INN    nvarchar(25)         NULL,
    KPP    nvarchar(10)         NULL,
    OKPO   nvarchar(10)         NULL,
    DirectorName nvarchar(250) NULL,  --- ФИО директора
    AccountantName nvarchar(250) NULL,--- ФИО бухгалтера
    Site nvarchar(100) NULL,    ---- сайт
    Comment varchar(500) NULL, --- произвольное описание
    UserIdLastEditedBy int NOT NULL,
    LastEditedBy datetime2  NOT NULL,
CONSTRAINT PK_Firms PRIMARY KEY CLUSTERED (FirmsId),
CONSTRAINT FK_Firms_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
);
GO

ALTER TABLE Firms ADD CONSTRAINT FK_AddressJur FOREIGN KEY (AddressIdJur)
REFERENCES Address(AddressId);
GO
ALTER TABLE Firms ADD CONSTRAINT FK_AddressLoc FOREIGN KEY (AddressIdLoc)
REFERENCES Address(AddressId);
GO
ALTER TABLE Firms ADD CONSTRAINT FK_AddressDeliv FOREIGN KEY (AddressIdDeliv)
REFERENCES Address(AddressId);
GO
ALTER TABLE Firms ADD CONSTRAINT FK_RoomsJur FOREIGN KEY (RoomsIdJur)
REFERENCES Rooms(RoomsId);
GO
ALTER TABLE Firms ADD CONSTRAINT FK_RoomsLoc FOREIGN KEY (RoomsIdLoc)
REFERENCES Rooms(RoomsId);
GO
ALTER TABLE Firms ADD CONSTRAINT FK_RoomsDeliv FOREIGN KEY (RoomsIdDeliv)
REFERENCES Rooms(RoomsId);
GO

CREATE INDEX FI_FIRMS_ADDRESSJUR ON Firms (AddressIdJur);
GO

CREATE INDEX FI_FIRMS_ADDRESSLoc ON Firms (AddressIdLoc);
GO

CREATE INDEX FI_FIRMS_ADDRESSDeliv ON Firms (AddressIdDeliv);
GO

CREATE INDEX FI_FIRMS_RoomsJur ON Firms (RoomsIdJur);
GO

CREATE INDEX FI_FIRMS_RoomsLoc ON Firms (RoomsIdLoc);
GO

CREATE INDEX FI_FIRMS_RoomsDeliv ON Firms (RoomsIdDeliv);
GO


/*********Потенциальный клиент или клиент в интересах которого выполняется маркетинговая кампания************/

CREATE TABLE Clients
(
    ClientsId bigint identity(1,1) NOT NULL,     --- id клиента
    PeoplesId bigint NULL,   --- fk peoples код физического лица
    FirmsId bigint NULL,     --- fk firms код предприятия
    LoadingId int NULL,   --- fk код загрузки
    Comment nvarchar(500) NULL, --- произвольное описание
    UserIdLastEditedBy int NOT NULL,
    LastEditedBy datetime2  NOT NULL,
CONSTRAINT PK_Clients PRIMARY KEY CLUSTERED (ClientsId),
CONSTRAINT FK_Clients_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
);
GO

CREATE INDEX FI_Clients_Peoples ON Clients (PeoplesId);
GO

ALTER TABLE Clients  ADD CONSTRAINT FK_Clients_Peoples
    FOREIGN KEY (PeoplesId)
    REFERENCES Peoples (PeoplesId);
GO

CREATE INDEX FI_Clients_Firms ON Clients (FirmsId);
GO

ALTER TABLE Clients
    ADD CONSTRAINT FK_Clients_Firms
    FOREIGN KEY (FirmsId)
    REFERENCES Firms (FirmsId);
GO


/*********Каналы воздействия - соцсети (ВК, VIBER, SIP операторы, обзвон потоком E1.
В таблице фиксируются все КАНАЛЫ ВОЗДЕЙСТВИЯ, как соцсети, так и sms, email, отправка "бумажной почты",
обзвон по IP телефонии или потоку E1, обзвон оператором call центра
*********/

CREATE TABLE ExposureChannels  ---  social_network
(
    ExposureChannelsId int identity(1,1) NOT NULL,          --- id сети
    UniqueId int NOT NULL,     --- уникальный идентификатор канала воздействия, определяет номер разработанного интерфеса
    ExposureChannelsName nvarchar(100) NOT NULL,     --- наименование канала воздействия
    ExposureChannelswebsite  nvarchar(100)  NULL,    --- сайт сети
    Color bigint NULL, --- цвет воздействия в приложении
    UserIdLastEditedBy int NOT NULL,
    ValidFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
    ValidTo datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
CONSTRAINT PK_ExposureChannels PRIMARY KEY CLUSTERED (ExposureChannelsId),
CONSTRAINT FK_ExposureChannels_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.ExposureChannels_Archive)
);
GO

CREATE UNIQUE INDEX UI_ExposureChannels_UniqueId  ON ExposureChannels(UniqueId);
GO
CREATE UNIQUE INDEX UI_ExposureChannels_Name ON ExposureChannels(ExposureChannelsName);
GO

CREATE INDEX FI_ExposureChannels_Users ON ExposureChannels (UserIdLastEditedBy);
GO


/*********Запросы/Процессы выбора.
В таблице хранится сформированный запрос. Запрос может применяться в различных кампаниях, потоках, процессах.
Кроме этого в таблице может формировать идентификатор воздействия - идентификатор dll, скрипта Python
*********/

CREATE TABLE Request
(
    RequestId bigint identity(1,1) NOT NULL,        --- id  запроса
    RequestName nvarchar(100) NOT NULL,   --- наименование запроса
    Request_text   nvarchar(max) NULL, ----  текст запроса
    UniqueId int  NULL,     --- уникальный идентификатор функции анализа/формирования, определяет номер разработанной функции
    Color bigint NULL, --- цвет
    Comment nvarchar(250)  NULL,    --- комементарий к запросу/функции
    UserIdLastEditedBy int NOT NULL,
    ValidFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
    ValidTo datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
CONSTRAINT PK_Request PRIMARY KEY CLUSTERED (RequestId),
CONSTRAINT FK_Request_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Request_Archive)
);
GO

CREATE UNIQUE INDEX UI_Request_UniqueId  ON Request(UniqueId);
GO
CREATE UNIQUE INDEX UI_Request_Name ON Request(RequestName);
GO
CREATE INDEX FI_Requests_Users ON Request (UserIdLastEditedBy);
GO


/*********Предложения. Маркетинговые предложения передаваемые в различных каналах воздействия.
Такая структура на начальном этапе. Далее добавятся возможности подключения картинок, кнопок, различные форматы (HTML)
*********/

CREATE TABLE Offers
(
    OffersId bigint identity(1,1) NOT NULL,        --- id предложения
    OffersName nvarchar(100) NOT NULL,   --- наименование предложения
    ExposureChannelsId int NOT NULL, --- fk ExposureChannels
    Heading nvarchar(250) NULL,    --- заголовок  
    File_path  nvarchar(250) NULL, --- путь к файлу  
    Offers_text nvarchar(max) NULL,  --- text NULL,  текст предложения
    File_content bit NULL,    --- загруженный файл
    Offers_type smallint NULL, --- тип (вид)  предложения 1-txt, 2-html, 3-почтовое отправление
---    packages_id int NULL, --- пакет (например пакет рекламных буклетов отправляемых по почте)  fk
    UserIdLastEditedBy int NOT NULL,
    ValidFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
    ValidTo datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
CONSTRAINT PK_Offers PRIMARY KEY CLUSTERED (OffersId),
CONSTRAINT FK_Offers_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Offers_Archive)
);
GO


CREATE UNIQUE INDEX UI_OffersName ON  Offers(OffersName);
GO
ALTER TABLE offers
    ADD CONSTRAINT FK_Offers_ExposureChannels
    FOREIGN KEY (ExposureChannelsId)
    REFERENCES ExposureChannels (ExposureChannelsId);
GO

CREATE  INDEX FI_Offers_Users ON Offers (UserIdLastEditedBy);
GO



/***
ALTER TABLE offers
    ADD CONSTRAINT fk_offers_packages
    FOREIGN KEY (packages_id)
    REFERENCES packages (id);
 ***/

/*********Маркетинговая кампания*********/

CREATE TABLE Campaign
(
    CampaignId  int identity(1,1) NOT NULL,      --- id кампании
---    organizations_id int NULL,  --- fk организация для которй проводится кампания
    CampaignName nvarchar(100) NOT NULL, --- наименование кампании
    CompanyPurpose nvarchar(500) NULL, --- цель кампании
    CampaignStatus smallint NULL, --- состояние кампании 1-ожидание, 2-выполняется, 3-выполнена, 4-остановлено выполнение  ВОЗМОЖНО ЕЩЁ КАКОЙ ТО
    DateFrom datetime2 NULL,  --- даты действия кампании
    DateTo   datetime2 NULL,
    UsersId int NULL,  --- ответственный за кампанию id пользователя 
    UserIdLastEditedBy int NOT NULL,
    ValidFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
    ValidTo datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
CONSTRAINT PK_Campaign PRIMARY KEY CLUSTERED (CampaignId),
CONSTRAINT FK_Campaign_UserIdLast FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Campaign_Archive)
);
GO

CREATE UNIQUE INDEX UI_campaign_name ON Campaign(CampaignName);
GO

ALTER TABLE Campaign  ADD CONSTRAINT FK_campaign_users
    FOREIGN KEY (UsersId) REFERENCES Users (UsersId);

CREATE INDEX FI_Campaign_Users ON Campaign (UserIdLastEditedBy);
GO

/***
ALTER TABLE Campaign ADD CONSTRAINT FK_campaign_organizations
    FOREIGN KEY (OrganizationsId)  REFERENCES Organizations (OrganizationsId);
***/
/****Справочник доступа пользователей к кампаниям*******/

CREATE TABLE UsersCampaign
(
   UsersId int NOT NULL,      --- fk users
   CampaignId int NOT NULL,   --- fk campaign
   UserIdLastEditedBy int NOT NULL,
   ValidFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
   ValidTo datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
CONSTRAINT PK_UsersCampaign PRIMARY KEY CLUSTERED (UsersId, CampaignId),
CONSTRAINT FK_UsersCampaign_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.UsersCampaign_Archive)
);
GO

ALTER TABLE UsersCampaign ADD CONSTRAINT FK_UsersCampaign_Campaign
    FOREIGN KEY (CampaignId) REFERENCES Campaign (CampaignId);
GO

CREATE INDEX FI_UCampaign_Users ON UsersCampaign (UserIdLastEditedBy);
GO

CREATE INDEX FI_UCampaign_UsersId ON UsersCampaign (UsersId);
GO

CREATE INDEX FI_UCampaign_Campaign ON UsersCampaign (CampaignId);
GO

/**********Таблица данных серверов для email отправки*****************************/

CREATE TABLE EmailServers
(
  EmailServersId int identity(1,1) NOT NULL,   ---  id сервера
  Smtpserver nvarchar(40) NOT NULL,    --- smtp.yandex.ru
  Frommail  nvarchar(40)  NOT NULL,    --- aglinka@radius-etl.ru
  Mailpass  nvarchar(40)  NOT NULL,    --- hadoop
  Portmail  int      NOT NULL,    ---  587
  Imapserver nvarchar(40)     NULL,
  Signature nvarchar(250)     NULL,
  UserIdLastEditedBy int NOT NULL,
  ValidFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
  ValidTo datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
CONSTRAINT PK_EmailServers PRIMARY KEY CLUSTERED (EmailServersId),
CONSTRAINT FK_EmailServers_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.EmailServers_Archive)
);
GO

CREATE UNIQUE INDEX UI_EmailServers_Smtpserver ON EmailServers(Smtpserver, Frommail);
GO

CREATE INDEX FI_EmailServers_Users ON UsersCampaign (UserIdLastEditedBy);
GO


/*********Поток маркетинговой кампании
Каждая кампания состоит из однго или нескольких потоков.
Потоки состоят из процессов, которые можно соединять и конфигурировать.  Для реализации кампании запускаются потоки.
Потоки можно запускать вручную, при помощи планировщика или в ответ на заданный триггер
Данные потоков могут объединяться
*********/

CREATE TABLE CampaignFlow
(
    CampaignFlowId  bigint identity(1,1) NOT NULL,      --- id потока
    CampaignId int NOT NULL,  --- fk campaign id кампании
    CampaignFlowName nvarchar(100) NOT NULL, --- наименование потока
    EmailServersId int NULL,   --- SMTP сервер для email рассылки
    Comment nvarchar(250) NULL, --- комментарий к потоку
    CampaignFlowStatus smallint NULL, --- статус потока  1-ожидание, 2-выполняется, 3-выполнена, 4-остановлено выполнение  ВОЗМОЖНО ЕЩЁ КАКОЙ ТО
    UsersId int NULL,  --- ответственный за поток кампании
    UserIdLastEditedBy int NOT NULL,
    LastEditedBy datetime2  NOT NULL,
CONSTRAINT PK_CampaignFlow PRIMARY KEY CLUSTERED (CampaignFlowId),
CONSTRAINT FK_CampaignFlow_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
);
GO

CREATE UNIQUE INDEX UI_CampaignFlow_Name ON CampaignFlow(CampaignId, CampaignFlowName);
GO

ALTER TABLE CampaignFlow ADD CONSTRAINT FK_CampaignFlow_Campaign
    FOREIGN KEY (CampaignId)  REFERENCES Campaign (CampaignId);
GO

ALTER TABLE CampaignFlow  ADD CONSTRAINT FK_CampaignFlow_EmailServers
    FOREIGN KEY (EmailServersId)  REFERENCES EmailServers (EmailServersId);
GO

ALTER TABLE CampaignFlow 
ADD CONSTRAINT CampaignFlow_Status CHECK (CampaignFlowStatus IN (1,2,3,4));
GO

CREATE INDEX FI_CampaignFlow_Users ON CampaignFlow (UserIdLastEditedBy);
GO

CREATE INDEX FI_CampaignFlow_Campaign ON CampaignFlow (CampaignId);
GO


/**********EMAIL сервера для потока кампани****************/
CREATE TABLE CampaignFlowEmail
(
    CampaignFlowId bigint NOT NULL,  --- fk CampaignFlow id потока кампании
    EmailServersId int NOT NULL,   --- SMTP сервер для email рассылки
    UserIdLastEditedBy int NOT NULL,
    ValidFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
    ValidTo datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
CONSTRAINT PK_CampaignFlowEmail PRIMARY KEY CLUSTERED (CampaignFlowId, EmailServersId),
CONSTRAINT FK_CampaignFlowEmail_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.CampaignFlowEmail_Archive)
);
GO

CREATE INDEX FI_CampaignFlowEmail_Users ON CampaignFlowEmail (UserIdLastEditedBy);
GO

ALTER TABLE CampaignFlowEmail  ADD CONSTRAINT FK_CampaignFlowEmailId_CampaignFlow
    FOREIGN KEY (CampaignFlowId)  REFERENCES CampaignFlow (CampaignFlowId);
GO

CREATE INDEX FI_CampaignFlowEmail_CampaignFlow ON CampaignFlowEmail (CampaignFlowId);
GO

ALTER TABLE CampaignFlowEmail ADD CONSTRAINT FK_CampaignFlowEmailId_EmailServers
    FOREIGN KEY (EmailServersId)  REFERENCES EmailServers (EmailServersId);
GO

CREATE INDEX FI_CampaignFlowEmail_EmailServers ON CampaignFlowEmail (EmailServersId);
GO


/*********Процессы*********/



CREATE TABLE Processes
(
    ProcessesId bigint identity(1,1) NOT NULL,       --- id процесса
    CampaignFlowId bigint NOT NULL,   --- fk CampaignFlow  id потока
    ProcessesName varchar(100) NOT NULL, --- наименование процесса
    ProcessNumber  smallint NOT NULL, --- порядок процесса в потоке
    TypeChannels smallint NOT NULL, --- тип воздействия  1 - формирование списка, 2 - воздйствие, 3 - собеседование, 4 - анализ  
    RequestId bigint NULL, ---   fk request id запроса в случае тип воздействия 1,4 - анализ/формирование списка
    ExposureChannelsId  int NULL,  --- fk ExposureChannels  каналы воздействия
    OffersId  bigint NULL,  --- fk offers id предложения
    ProcessDate  datetime2   NULL,  --- дата/время запуска процесса или сделать через сколько после предыдущнго процесса
    NumberLaunches int default 1,  --- количество запусков процесса
    LaunchFrequency int NULL, --- периодичность запуска процессов 
    comment nvarchar(250)  NULL,    --- комементарий к процессу
    Posx int NULL, --- координаты в форме
    Posy int NULL,
    ProcessStatus smallint NULL, --- состояние процесса 1-ожидание, 2-выполняется, 3-выполнен
    UserIdLastEditedBy int NOT NULL,
    LastEditedBy datetime2  NOT NULL,
CONSTRAINT PK_Processes PRIMARY KEY CLUSTERED (ProcessesId),
CONSTRAINT FK_Processes_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
);
GO

CREATE INDEX FI_Processes_Users ON Processes (UserIdLastEditedBy);
GO

ALTER TABLE Processes 
ADD CONSTRAINT Processes_Type CHECK (TypeChannels IN (1,2,3,4));
GO

ALTER TABLE Processes 
ADD CONSTRAINT Processes_Status CHECK (ProcessStatus IN (1,2,3));
GO

CREATE UNIQUE INDEX UI_ProcessesNumber
    ON Processes(CampaignFlowId, ProcessNumber);
GO

CREATE UNIQUE INDEX UI_ProcessesName
    ON Processes(CampaignFlowId, ProcessesName);
GO

ALTER TABLE Processes ADD CONSTRAINT fk_Processes_CampaignFlow
    FOREIGN KEY (CampaignFlowId)  REFERENCES CampaignFlow (CampaignFlowId);

CREATE INDEX FI_Processes_CampaignFlow ON Processes (CampaignFlowId);
GO

ALTER TABLE Processes ADD CONSTRAINT FK_Processes_Request
    FOREIGN KEY (RequestId)  REFERENCES Request (RequestId);
GO

CREATE INDEX FI_Processes_Request ON Processes (RequestId);
GO


ALTER TABLE Processes ADD CONSTRAINT FK_Processes_Offers
    FOREIGN KEY (OffersId)  REFERENCES Offers (OffersId);
GO

CREATE INDEX FI_Processes_Offers ON Processes (OffersId);
GO

ALTER TABLE Processes ADD CONSTRAINT FK_Processes_ExposureChannels
    FOREIGN KEY (ExposureChannelsId)
    REFERENCES ExposureChannels (ExposureChannelsId);
GO

CREATE INDEX FI_Processes_ExposureChannels ON Processes (ExposureChannelsId);
GO

 /*************Телефоны клиента**************************************/

CREATE TABLE ClientPhones
(
    ClientPhonesId bigint identity(1,1) NOT NULL,     --- id телефона клиента
    ClientsId bigint NOT NULL,   --- fk clients код клиента
    Phone nvarchar(40)  NULL,   ---  Телефон (с кодом города)
    Basic bit default 0,  --- признак "основной"
    Cellular bit default 1,  --- признак "сотовый"
    OrderNumber smallint  NULL, --- порядок обзвона
    UserIdLastEditedBy int NOT NULL,
    LastEditedBy datetime2  NOT NULL,
CONSTRAINT PK_ClientPhones PRIMARY KEY CLUSTERED (ClientPhonesId),
CONSTRAINT FK_ClientPhones_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
);
GO

CREATE INDEX FI_ClientPhones_Users ON ClientPhones (UserIdLastEditedBy);
GO

CREATE UNIQUE INDEX FI_ClientPhones_Phone ON ClientPhones (Phone);
GO

ALTER TABLE ClientPhones
    ADD CONSTRAINT FK_ClientPhones_Clients
    FOREIGN KEY (ClientsId)
    REFERENCES Clients (ClientsId);

CREATE UNIQUE INDEX UI_ClientPhones_Phone
    ON ClientPhones(ClientsId, Phone);

CREATE INDEX FI_ClientPhones_Clients ON ClientPhones (ClientsId);
GO


/*************email клиента**************************************/

CREATE TABLE ClientEmails
(
    ClientEmailsId bigint identity(1,1) NOT NULL,     --- id 
    ClientsId bigint NULL,   --- fk clients код клиента
    Email nvarchar(250) NULL,          ---  email
    Basic  bit default 0 NOT NULL,  --- признак "основной"
    UserIdLastEditedBy int NOT NULL,
    LastEditedBy datetime2  NOT NULL,
CONSTRAINT PK_ClientEmails PRIMARY KEY CLUSTERED (ClientEmailsId),
CONSTRAINT FK_ClientEmails_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
);

CREATE INDEX FI_ClientEmails_Users ON ClientEmails (UserIdLastEditedBy);
GO

ALTER TABLE ClientEmails
    ADD CONSTRAINT FK_ClientEmails_Clients
    FOREIGN KEY (ClientsId)
    REFERENCES Clients (ClientsId);

CREATE INDEX FI_ClientEmails_Clients ON ClientEmails (ClientsId);
GO

CREATE UNIQUE INDEX UI_ClientEmails_Email ON ClientEmails (Email);
GO


/*********Соцсети клиента*********/

CREATE TABLE ClientSocnetwork
(
    ClientSocnetworkId  bigint identity(1,1) NOT NULL,    --- id записи
    ClientsId bigint NOT NULL,          --- fk clients id клиента
    ExposureChannelsId int NOT NULL,   --- fk exposure_channels  id соцсеть  клиента
    ClientPhonesId bigint NULL,        --- fk client_phones телефон клиента идентифицирующий клиента в соц.сети
    Login  nvarchar(250) NULL,             --- логин
    UserIdLastEditedBy int NOT NULL,
    LastEditedBy datetime2  NOT NULL,
CONSTRAINT PK_ClientSocnetwork PRIMARY KEY CLUSTERED (ClientSocnetworkId),
CONSTRAINT FK_ClientSocnetwork_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
);
GO

CREATE INDEX FI_ClientSocnetwork_Users ON ClientSocnetwork (UserIdLastEditedBy);
GO

ALTER TABLE ClientSocnetwork ADD CONSTRAINT FK_ClientSocnetwork_Clients
    FOREIGN KEY (ClientsId)
    REFERENCES Clients (ClientsId);
GO 

CREATE INDEX FI_ClientSocnetwork_Clients ON  ClientSocnetwork (ClientsId);
GO

ALTER TABLE ClientSocnetwork 
    ADD CONSTRAINT FK_ClientSocnetwork_ExposureChannels
    FOREIGN KEY (ExposureChannelsId)
    REFERENCES ExposureChannels (ExposureChannelsId);
GO

CREATE INDEX FI_ClientSocnetwork_ExposureChannels ON  ClientSocnetwork (ExposureChannelsId);
GO

ALTER TABLE ClientSocnetwork ADD CONSTRAINT FK_ClientSocnetwork_ClientPhones
    FOREIGN KEY (ClientPhonesId)  REFERENCES ClientPhones (ClientPhonesId);

CREATE INDEX FI_ClientSocnetwork_ClientPhones ON  ClientSocnetwork (ClientPhonesId);
GO

CREATE UNIQUE INDEX UI_ClientSocnetwork_cs
    ON ClientSocnetwork(ClientsId, ExposureChannelsId, ClientPhonesId);
GO

/*********Типы свойств (особенности) клиента Например: Виды спорта  *********/

CREATE TABLE PropertieTypes
(
    
    PropertieTypesId int identity(1,1) NOT NULL,        --- id типа свойства
    PropertieTypesName nvarchar(100) NOT NULL,   --- наименование типа свойства
    UserIdLastEditedBy int NOT NULL,
    ValidFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
    ValidTo datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
	PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
CONSTRAINT PK_PropertieTypes PRIMARY KEY CLUSTERED (PropertieTypesId),
CONSTRAINT FK_PropertieType_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.PropertieTypes_Archive)
);

CREATE INDEX FI_PropertieTypes_Users ON PropertieTypes (UserIdLastEditedBy);
GO

CREATE UNIQUE INDEX UI_PropertieTypes_Name ON PropertieTypes(PropertieTypesName);
GO

/*********Свойства (особенности) клиента  Например: Тип:Виды спорта Свойство: Бокс*********/

CREATE TABLE Properties
(
    PropertiesId int identity(1,1) NOT NULL,        --- id свойства
    PropertieTypesId int NOT NULL, --- id propertie_types типа свойства
    PropertiesName nvarchar(100) NOT NULL,   --- наименование свойства
    UserIdLastEditedBy int NOT NULL,
    ValidFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
    ValidTo datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
CONSTRAINT PK_Properties PRIMARY KEY CLUSTERED (PropertiesId),
CONSTRAINT FK_Properties_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Properties_Archive)
);
GO

CREATE INDEX FI_Properties_Users ON Properties (UserIdLastEditedBy);
GO

CREATE UNIQUE INDEX UI_PropertiesName ON Properties(PropertiesName);
GO

ALTER TABLE Properties ADD CONSTRAINT FK_Properties_PropertieTypes
   FOREIGN KEY (PropertieTypesId) REFERENCES PropertieTypes (PropertieTypesId);
GO

CREATE INDEX FI_Properties_PropertieTypes ON Properties (PropertieTypesId);
GO


/*********Свойства у  клиента*********/

CREATE TABLE ClientProperties
(
    ClientsId bigint NOT NULL,     --- fk clients id клиента
    PropertiesId int NOT NULL,     --- fk properties id свойства клиента
    PropertiesQuantity numeric(15,4) NULL, --- количество свойств
    PropertiesComment nvarchar(250) NULL, --- текстовая характеристика свойства клиента. Это может быть например номер скидочной карточки
    UserIdLastEditedBy int NOT NULL,
    LastEditedBy datetime2  NOT NULL,
CONSTRAINT PK_ClientProperties PRIMARY KEY CLUSTERED (ClientsId, PropertiesId),
CONSTRAINT FK_ClientProperties_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
);
GO

CREATE INDEX FI_ClientProperties_Users ON ClientProperties (UserIdLastEditedBy);
GO

ALTER TABLE ClientProperties  ADD CONSTRAINT FK_ClientProperties_Clients
    FOREIGN KEY (ClientsId) REFERENCES Clients (ClientsId);
GO

CREATE INDEX FI_ClientProperties_PropertiesId ON ClientProperties (PropertiesId);
GO

CREATE INDEX FI_ClientProperties_Clients ON ClientProperties (ClientsId);
GO

ALTER TABLE ClientProperties ADD CONSTRAINT FK_ClientProperties_Properties
    FOREIGN KEY (PropertiesId)  REFERENCES Properties (PropertiesId);
GO


/*********Ячейка клиента воздействия  Определяет процесс сформировавший ячейку, процесс для которого была сформирована ячейка,
клиента, email, телефон, адрес клиента для проведения воздействия
*********/

CREATE TABLE ClientCell
(
    ClientCellId  bigint identity(1,1) NOT NULL,        --- id записи
    Processes1_id bigint NULL,   --- fk processes id процесса сформировавшего ячейку выбора processes1_id bigint NOT NULL
    ClientsId bigint NOT NULL,     --- fk id клиента
    Processes2_id bigint  NULL,      --- fk processes id целевого процесса (для выполнения которого сформирована ячейка)
    Name varchar(500) NULL,          --- наименование клиента (фио для физ лиц, наименование для предприятия)
    Gender smallint NULL,            --- пол
    Email varchar(250) NULL,         --- email
    Phone varchar(40)  NULL,         --- телефон
    Address varchar(500) NULL,       --- адрес доставки рекламной корреспонденции
    ExposureChannelsId int  NULL,   --- fk exposure_channels  id соцсеть  клиента
    PhoneSocnetId varchar(40) NULL,        --- телефон клиента идентифицирующий клиента в соц.сети
    Login  varchar(500) NULL,             --- логин клиента в соцсети
    UserIdLastEditedBy int NOT NULL,
    LastEditedBy datetime2  NOT NULL,
CONSTRAINT PK_ClientCell PRIMARY KEY CLUSTERED (ClientCellId),
CONSTRAINT FK_ClientCell_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
);
GO

CREATE INDEX FI_ClientCell_Users ON ClientCell (UserIdLastEditedBy);
GO

ALTER TABLE ClientCell  ADD CONSTRAINT FK_ClientCell_Processes1
    FOREIGN KEY (processes1_id)  REFERENCES Processes (ProcessesId);
GO

CREATE INDEX FI_ClientCell_Processes1 ON ClientCell (Processes1_id);
GO

ALTER TABLE ClientCell  ADD CONSTRAINT FK_ClientCell_Processes2
    FOREIGN KEY (processes2_id) REFERENCES Processes (ProcessesId);
GO

CREATE INDEX FI_ClientCell_Processes2 ON ClientCell (Processes2_id);
GO

ALTER TABLE ClientCell ADD CONSTRAINT FK_ClientCell_Clients
    FOREIGN KEY (ClientsId) REFERENCES Clients (ClientsId);
GO

CREATE INDEX FI_ClientCell_Clients ON ClientCell (ClientsId);
GO

ALTER TABLE ClientCell  ADD CONSTRAINT FK_ClientCell_Socnetwork
    FOREIGN KEY (ExposureChannelsId) REFERENCES ExposureChannels (ExposureChannelsId);
GO

CREATE INDEX FI_ClientCell_ExposureChannels ON ClientCell (ExposureChannelsId);
GO


/*********Типы ответа на воздействие  Например: Ответ на email c согласием *********/

CREATE TABLE ResponseTypes
(
    ResponseTypesId  int identity(1,1) NOT NULL,        --- id типа ответа на воздействие
    Name nvarchar(150) NOT NULL,   --- наименование типа ответв на воздействие
    UserIdLastEditedBy int NOT NULL,
    ValidFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
    ValidTo datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
CONSTRAINT PK_ResponseTypes PRIMARY KEY CLUSTERED (ResponseTypesId),
CONSTRAINT FK_ResponseTypes_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.ResponseTypes_Archive)
);
GO

CREATE UNIQUE INDEX UI_ResponseTypes_Name  ON ResponseTypes(Name);
GO

CREATE INDEX FI_ResponseTypes_Users ON ResponseTypes (UserIdLastEditedBy);
GO

/*********Таблица проведенных воздействий и отзывов *********/

CREATE TABLE ExposurePerformed
(
    ExposurePerformedId bigint identity(1,1) NOT NULL,       --- id записи
    ClientCellId bigint NOT NULL, --- fk client_cell id ячейки
    SendDate datetime2 default getdate(),       --- дата воздействия
    PerformedImpacts bit NULL, --- признак проведенного воздействия 
    ExposureNumber nvarchar(50) NULL, --- номер (идентификатор) воздействия, например номер почтового отправления  ИЛИ EMAIL СЕРВЕР ОТПРАВКИ
    ResponseIs bit NULL,       --- признак наличия ответа
    ResponseDate datetime2 NULL,   ---  дата ответа
    ResponseText nvarchar(max) NULL,        --- текст ответа
    ResponseTypesId int NULL,  --- fk ResponseTypes id типа ответа на воздействие
    CampaignResultIs bit NULL, --- воздействие достигло результата (цели кампании) 
    CampaignResultDate datetime2 NULL,    --- дата достижения результата по кампании
    CampaignResultText nvarchar(max) NULL, --- текст при достижении результата кампании 
    ErrorMessages nvarchar(500) NULL, --- сообщение об ошибке
    UserIdLastEditedBy int NOT NULL,
    LastEditedBy datetime2  NOT NULL,
CONSTRAINT PK_ExposurePerformed PRIMARY KEY CLUSTERED (ExposurePerformedId),
CONSTRAINT FK_ExposurePerformed_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
);
GO

CREATE INDEX FI_ExposurePerformed_Users ON ExposurePerformed (UserIdLastEditedBy);
GO

ALTER TABLE ExposurePerformed ADD CONSTRAINT FK_ExposurePerformed_ClientCell
    FOREIGN KEY (ClientCellId)  REFERENCES ClientCell (ClientCellId);
GO

CREATE INDEX FI_ExposurePerformed_ClientCellId ON ExposurePerformed (ClientCellId);
GO

ALTER TABLE ExposurePerformed ADD CONSTRAINT FK_ExposurePerformed_ResponseTypesId
    FOREIGN KEY (ResponseTypesId)  REFERENCES ResponseTypes (ResponseTypesId);
GO

CREATE INDEX FI_ExposurePerformed_ResponseTypesId ON ExposurePerformed (ResponseTypesId);
GO

CREATE INDEX FI_ExposurePerformed ON ExposurePerformed(ExposureNumber);
GO


/*****Таблица загрузок*******/

CREATE TABLE Loadings
(
    LoadingsId int identity(1,1) NOT NULL,
    CampaignId int NOT NULL,
    Name varchar(250) NOT NULL,
    Comment varchar(500) NULL,
    UserIdLastEditedBy int NOT NULL,
    LastEditedBy datetime2  NOT NULL,
CONSTRAINT PK_Loadings PRIMARY KEY CLUSTERED (LoadingsId),
CONSTRAINT FK_Loadings_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
);
GO

CREATE INDEX FI_Loadings_Users ON Loadings (UserIdLastEditedBy);
GO

ALTER TABLE Loadings ADD CONSTRAINT FK_Loadings_Campaign
    FOREIGN KEY (CampaignId) REFERENCES Campaign (CampaignId);

CREATE INDEX FI_Loadings_Campaign ON Loadings (CampaignId);
GO


/**********Настроечные переменные параметры
Параметры могут быть как общие для системы, так и для отдельных кампаний **********************************/

CREATE TABLE CampaignParams
(
    ParamId                int identity(1,1) NOT NULL,        
	ParamName              nvarchar(100)       NOT NULL,  --- наименование параметра
    ParamNum               smallint default 1  NOT NULL,  --- в общем случае может быть несколько значений параметра
    ParamStrValue          varchar (100)          NULL,
    ParamIntValue          int                NULL,
    CampaignId             int NULL,  --- fk campaign id кампании, -1 для всех кампаний 
    ParamComment           nvarchar(255)          NULL,
    UserIdLastEditedBy int NOT NULL,
    ValidFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
    ValidTo datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
CONSTRAINT PK_CampaignParams PRIMARY KEY CLUSTERED (ParamId),
CONSTRAINT FK_CampaignParams_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.CampaignParams_Archive)
);
GO

CREATE INDEX FI_CampaignParams_Users ON CampaignParams (UserIdLastEditedBy);
GO

CREATE INDEX FI_CampaignParams_CampaignId ON CampaignParams (CampaignId);
GO

CREATE UNIQUE INDEX UI_CampaignParams_Name ON CampaignParams (ParamName, ParamNum)
GO

/******************Временная таблица для загрузки данных клиентов********************/

CREATE TABLE client_tmp
(
    id  bigint identity(1,1) NOT NULL,  --- id
    loadings_id int NOT NULL,
    lastname nvarchar(250)    NULL,  --- ФИО
    firstname nvarchar(250)   NULL,
    middlename nvarchar(250)  NULL,
    name nvarchar(500)        NULL, --- может быть как ФИО квартирщика, так и наименование предприятия
    date_birth datetime2     NULL, --- дата рождения
    gender nvarchar(20)       NULL, --- пол может быть записан по разному
    phone nvarchar(40)        NULL, ---  Телефон (с кодом города)
    email nvarchar(250)       NULL, ---  email
    site nvarchar(100)        NULL, ---- сайт
    properties nvarchar(500)  NULL,
    address nvarchar(500)     NULL,  --- адрес одной строкой
    countries_name nvarchar(250) NULL, --- наименование страны
    federal_district_name  nvarchar(250) NULL, --- наименование федерального округа
    country_regions_name   nvarchar(250) NULL, --- наименование региона (области)
    area_regions_name      nvarchar(250) NULL, --- наименование района области
    towns_name             nvarchar(250) NULL, --- наименование населенного пункта 
    town_prefix            nvarchar(25)  NULL, --- префикс города (например г., пос.)
    streets_name           nvarchar(250) NULL, --- наименование улицы
    street_prefix          nvarchar(15)  NULL, --- например ул., пер., просп.
    house                  nvarchar(50)  NULL,
    postfix                nvarchar(15)  NULL,
    post_index             nvarchar(6)   NULL,
    flat                   nvarchar(20)         NULL,  --- квартира адреса
    flat_postfix    nvarchar(50)        NULL,  --- постфикс квартиры адреса
    comment nvarchar(500) NULL --- произвольное описание
);
GO

ALTER TABLE client_tmp  ADD CONSTRAINT fk_client_tmp_loadings
FOREIGN KEY (loadings_id)  REFERENCES Loadings (LoadingsId);
GO

CREATE INDEX FI_client_tmp_loadings_id ON client_tmp (loadings_id);
GO

/*********ТАБЛИЦА В КОТОРУЮ ЗАНОСИТСЯ ИНФОРМАЦИЯ ОБ ПРОЧИТАННЫХ СООБЩЕНИЯХ************/

CREATE TABLE ReadMessages
(
   ReadMessagesId   bigint identity(1,1) NOT NULL,     ---  id записи
   IdEmail          bigint                  NOT NULL,     --- уникальный номер письма возвращаемый	почтовым сервером 
   Email            varchar(40)                 NULL,     --- email
   EmailServersId   int                 NOT NULL,     --- fk email_servers
   ReadDate         datetime2 NULL,                       --- дата прочтения
   ResponseText     nvarchar(4000) NULL,                   --- текст ответа
   UseCampaig       bit NULL,                         --- использовался в рассылках
   UserIdLastEditedBy int NOT NULL,
   LastEditedBy datetime2  NOT NULL,
CONSTRAINT PK_ReadMessages PRIMARY KEY CLUSTERED (ReadMessagesId),
CONSTRAINT FK_ReadMessages_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
);
GO

CREATE INDEX FI_ReadMessages_Users ON ReadMessages (UserIdLastEditedBy);
GO

ALTER TABLE ReadMessages  ADD CONSTRAINT FK_ReadMessages_EmailServers
FOREIGN KEY (EmailServersId) REFERENCES EmailServers (EmailServersId);
GO

CREATE INDEX FI_ReadMessages_EmailServers ON ReadMessages (EmailServersId);
GO


/****************Таблицы загрузки данных ФИАС **************************************/

/*** Исходная таблица ADDROBXX.DBF. Описывает уровни от области(республики) до улиц****/ 

create table ADDROBXX
(                                  --- поля ACTSTATUS до DIVTYPE аналогичны полям исходноq таблицы
  ID bigint identity(1,1) NOT NULL,           --- до 
  ACTSTATUS int NULL,          --- Статус последней исторической записи в жизненном цикле адресного объекта: 0 – Не последняя 1 - Последняя 1
  AOGUID varchar(36) NULL,        --- Глобальный уникальный идентификатор адресного объекта 36
  AOID varchar(36) NULL,          --- Уникальный идентификатор записи. Ключевое поле. 36
  AOLEVEL  numeric(10,0) NULL,           --- уровни адресных объектов 10
  AREACODE varchar(3) NULL,      ---  Код района 3
  AUTOCODE varchar(2) NULL,  --- Код автономии 1
  CENTSTATUS varchar(10) NULL,  --- Статус центра 10  
  CITYCODE varchar(3) NULL,      ---  Код города 3
  CODE varchar(17) NULL, ---Код адресного элемента одной строкой с признаком актуальности из классификационного кода 17
  CURRSTATUS varchar(10) NULL,  --- Статус актуальности КЛАДР 4 (последние две цифры в коде) 10
  ENDDATE datetime2 NULL,  --- Окончание действия записи
  FORMALNAME varchar(120) NULL,    --- Формализованное наименование 120
  IFNSFL varchar(4) NULL,        --- Код ИФНС ФЛ 4
  IFNSUL varchar(4) NULL,        --- Код ИФНС ЮЛ 4
  NEXTID varchar(36) NULL,  --- Идентификатор записи  связывания с последующей исторической записью 36    
  OFFNAME varchar(120) NULL, --- Официальное наименование 120
  OKATO varchar(11) NULL,   --- ОКАТО 11
  OKTMO varchar(11) NULL,   --- ОКТМО 11
  OPERSTATUS numeric(10,0) NULL,  --- Статус действия над записью – причина появления записи (см. OperationStatuses )  10
  PARENTGUID varchar(36) NULL,  --- Идентификатор объекта родительского объекта 36
  PLACECODE varchar(3) NULL,   --- Код населенного пункта  3
  PLAINCODE varchar(15) NULL,   ---Код адресного элемента одной строкой без признака актуальности (последних двух цифр)15
  POSTALCODE varchar(6) NULL, --- Почтовый индекс 6
  PREVID varchar(36) NULL,     --- Идентификатор записи связывания с предыдушей исторической записью 36
  REGIONCODE varchar(2) NULL,  --- Код региона 2
  SHORTNAME varchar(10) NULL,   --- Краткое наименование типа объекта 10
  STARTDATE datetime2 NULL, --- Начало действия записи
  STREETCODE varchar(4) NULL,  --- Код улицы 4
  TERRIFNSFL varchar(4) NULL,  --- Код территориального участка ИФНС ФЛ 4
  TERRIFNSUL varchar(4) NULL,  --- Код территориального участка ИФНС ЮЛ 4
  UPDATEDATE datetime2 NULL,   --- Дата  внесения (обновления) записи
  CTARCODE varchar(3) NULL,  --- Код внутригородского района 3  
  EXTRCODE varchar(4) NULL,  --- Код дополнительного адресообразующего элемента 4
  SEXTCODE varchar(3) NULL,  --- Код подчиненного дополнительного адресообразующего элемента 3
  LIVESTATUS int NULL, --- Статус актуальности адресного объекта ФИАС на текущую дату: 0 – Не актуальный 1 - Актуальный 1
  NORMDOC varchar(36) NULL, --- Внешний ключ на нормативный документ 36
  PLANCODE varchar(4) NULL, --- Код элемента планировочной структуры 4
  CADNUM varchar(100) NULL,  --- Кадастровый номер 100
  DIVTYPE int NULL       --- Тип деления:  0 – не определено 1 – муниципальное 2 – административное
);
GO

CREATE UNIQUE INDEX fu_addrobxx ON ADDROBXX (AOID);
GO

CREATE INDEX fi_addrobxx ON ADDROBXX (AOGUID);
GO

/****
AOLEVEL
1 – уровень региона
2 – уровень автономного округа (устаревшее)
3 – уровень района
35 – уровень городских и сельских поселений
4 – уровень города
5 – уровень внутригородской территории (устаревшее)
6 – уровень населенного пункта
65 – планировочная структура
7 – уровень улицы
75 – земельный участок
8 – здания, сооружения, объекта незавершенного строительства
9 – уровень помещения в пределах здания, сооружения
90 – уровень дополнительных территорий (устаревшее)
91 – уровень объектов на дополнительных территориях (устаревшее)
***/


/***** Исходная таблица HOUSEXX.DBF. Описывает дома********/

create table HOUSEXX
(                                --- Поля AOGUID по DIVTYPE аналогичны полям исходной таблицы
  ID bigint identity(1,1) NOT NULL, 
  AOGUID  varchar(36) NULL,   --- Guid записи родительского объекта (улицы, города, населенного пункта и т.п.) 36  
  BUILDNUM  varchar(10) NULL,  --- Номер корпуса  10
  ENDDATE datetime2 NULL, --- Окончание действия записи
  ESTSTATUS int NULL,    --- Признак владения 
  HOUSEGUID  varchar(36) NULL,  --- Глобальный уникальный идентификатор дома 36
  HOUSEID  varchar(36) NULL,  --- Уникальный идентификатор записи дома 36
  HOUSENUM  varchar(20) NULL, --- Номер дома  поле разделяется на HOUSE и HOUSE_POSTFIX 20
  STATSTATUS int NULL,  --- Состояние дома
  IFNSFL  varchar(4) NULL, --- Код ИФНС ФЛ 4
  IFNSUL  varchar(4) NULL, --- Код ИФНС ЮЛ 4 
  OKATO  varchar(11) NULL, --- ОКАТО 11
  OKTMO  varchar(11) NULL, --- ОКТМО 11 
  POSTALCODE  varchar(6) NULL,  --- Почтовый индекс 6
  STARTDATE datetime2 NULL,  --- Начало действия записи
  STRUCNUM  varchar(10) NULL, --- Номер строения 10 
  STRSTATUS numeric(10,0) NULL, --- Признак строения 10
  TERRIFNSFL  varchar(4) NULL, --- Код территориального участка ИФНС ФЛ  4
  TERRIFNSUL  varchar(4) NULL, --- Код территориального участка ИФНС ЮЛ  4
  UPDATEDATE datetime2 NULL,     --- Дата время внесения (обновления) записи
  NORMDOC  varchar(36) NULL,  --- Внешний ключ на нормативный документ 36
  COUNTER int NULL,  --- Счетчик записей зданий, сооружений для формирования классификационного кода
  CADNUM  varchar(100) NULL, --- Кадастровый номер 100
  DIVTYPE int NULL, --- Тип деления: 0 – не определено 1 – муниципальное 2 – административное
  HOUSE int NULL,  ---- НОМЕР ДОМА            
  HOUSE_POSTFIX varchar(15) NULL --- ПОСТФИКС НОМЕРА ДОМА
);
GO

CREATE UNIQUE INDEX fu_housexx ON HOUSEXX (HOUSEID);
GO

CREATE INDEX fi_housexx ON HOUSEXX (HOUSEGUID);
GO

/************Исходная таблица ROOMXX   Описывает  Сведения по помещениям**************************/
create table ROOMXX
(
ID bigint identity(1,1) NOT NULL, 
ROOMID          varchar(36)  NULL,    ---	Уникальный идентификатор записи помещения
ROOMGUID	varchar(36)  NULL,    ---	Глобальный уникальный идентификатор помещения
HOUSEGUID	varchar(36)  NULL,    ---       Глобальный уникальный идентификатор родительского объекта (дома)
REGIONCODE	varchar(2)   NULL,    ---	Код региона
FLATNUMBER	varchar(50)  NULL,    ---	Номер квартиры, офиса и прочего
FLATTYPE	int      NULL,    ---	Тип квартиры
ROOMNUMBER	varchar(50)  NULL,    ---	Номер комнаты или помещения
ROOMTYPE	int      NULL,    ---       Тип комнаты
POSTALCODE	varchar(6)   NULL,    ---	Почтовый индекс
UPDATEDATE	datetime2    NULL,    ---       Дата время внесения (обновления) записи
PREVID	        varchar(36)  NULL,    ---	Идентификатор записи связывания с предыдущей исторической записью
NEXTID	        varchar(36)  NULL,    ---       Идентификатор записи  связывания с последующей исторической записью
STARTDATE	datetime2    NULL,    ---       Начало действия записи
ENDDATE	        datetime2    NULL,    ---       Окончание действия записи
LIVESTATUS	int      NULL,    ---	Статус актуальности адресного объекта ФИАС на текущую дату: 0 – Не актуальный 1 - Актуальный
NORMDOC	        varchar(36)  NULL,    ---	Внешний ключ на нормативный документ
CADNUM	        varchar(100) NULL,    ---	Кадастровый номер помещения
ROOMCADNUM	varchar(100) NULL,    ---	Кадастровый номер комнаты внутри помещения
OPERSTATUS	int	     NULL,    ---       Статус действия над записью – причина появления записи (см. OperationStatuses )
FLAT            int     NULL,    ---       квартира адреса
FLAT_POSTFIX    varchar(50)  NULL     ---       постфикс квартиры адреса

);
GO

CREATE UNIQUE INDEX fu_roomxx ON ROOMXX (ROOMID);
GO

CREATE INDEX fi_roomxx ON ROOMXX (ROOMGUID);
GO


/*******Таблица типов результатов маркетинговой кампании для потенциальных клиентов**************/

CREATE TABLE CampaignResultTypes
(
  CampaignResultTypesId int identity(1,1) NOT NULL,
  Name   nvarchar(150)  NOT NULL,
  Comment nvarchar(500) NULL,
  UserIdLastEditedBy int NOT NULL,
  ValidFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
  ValidTo datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
CONSTRAINT PK_CampaignResultTypes PRIMARY KEY CLUSTERED (CampaignResultTypesId)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.CampaignResultTypes_Archive)
);
GO

CREATE INDEX FI_CampaignResultTypes_Users ON CampaignResultTypes (UserIdLastEditedBy);
GO

CREATE UNIQUE INDEX UI_CampaignResultTypes_Name ON CampaignResultTypes(Name);
GO

/*********Таблица результатов маркетинговой кампании для потенциальных клиентов*****************/

CREATE TABLE CampaignResults
(
  CampaignId int NOT NULL,       ---- fk campaign.id id кампании
  ClientsId bigint NOT NULL,        ---- fk clients.id  id клиента
  CampaignResultTypesId int,     ---- fk campaign_result_types.id  id типа результататов кампании
  ResultDate datetime2 NULL,         ---- дата результата при установке может быть и не текущая
  Comment nvarchar(500) NULL,         ---- комментарий
  UserIdLastEditedBy int NOT NULL,
  LastEditedBy datetime2  NOT NULL,
CONSTRAINT PK_CampaignResults PRIMARY KEY CLUSTERED (CampaignId, ClientsId, CampaignResultTypesId)
);


CREATE INDEX FI_CampaignResults_Users ON CampaignResults (UserIdLastEditedBy);
GO

ALTER TABLE CampaignResults  ADD CONSTRAINT FK_CampaignResults_Campaign
    FOREIGN KEY (CampaignId) REFERENCES Campaign (CampaignId);
GO

CREATE INDEX FI_CampaignResults_Campaign ON CampaignResults (CampaignId);
GO

ALTER TABLE CampaignResults ADD CONSTRAINT FK_CampaignResults_Clients
    FOREIGN KEY (ClientsId) REFERENCES Clients (ClientsId);
GO

CREATE INDEX FI_CampaignResults_Clients ON CampaignResults (ClientsId);
GO

ALTER TABLE CampaignResults ADD CONSTRAINT FK_CampaignResults_CampaignResultTypes
    FOREIGN KEY (CampaignResultTypesId)  REFERENCES CampaignResultTypes (CampaignResultTypesId);

CREATE INDEX FI_CampaignResults_CampaignResultTypes ON CampaignResults (CampaignResultTypesId);
GO

CREATE UNIQUE INDEX ui_campaign_result_
ON CampaignResults(CampaignId, ClientsId, CampaignResultTypesId);

/*********Таблица лог проводимых воздействий*********/

CREATE TABLE ExposurePerformedLog
(
    ExposurePerformedLogId bigint identity(1,1) NOT NULL,       --- id записи
    ClientCellId bigint NOT NULL, --- fk client_cell id ячейки
    SendDate datetime2 NOT NULL,       --- дата воздействия
    SendJson nvarchar(max) NULL, --- json отправки
    ReceivedJson  nvarchar(max) NULL, --- json принятый
    UserIdLastEditedBy int NOT NULL,
    LastEditedBy datetime2  NOT NULL,
CONSTRAINT PK_ExposurePerformedLog PRIMARY KEY CLUSTERED (ExposurePerformedLogId),
CONSTRAINT FK_ExposurePerformedLog_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
);
GO

CREATE INDEX FI_ExposurePerformedLogId_Users ON CampaignResults (UserIdLastEditedBy);
GO

ALTER TABLE ExposurePerformedLog ADD CONSTRAINT FK_ExposurePerformedLog_ClientCellId
    FOREIGN KEY (ClientCellId) REFERENCES ClientCell (ClientCellId);
GO

CREATE INDEX FI_ExposurePerformedLog_ClientCell ON ExposurePerformedLog (ClientCellId);
GO


ALTER TABLE ExposurePerformedLog ADD CONSTRAINT DF_SendDate
  DEFAULT (sysdatetime()) FOR SendDate;
GO

/*******************Таблица статистики по кампаниям*********************************/
/****Статистические данные по кампании включают в себя в разрезе потока (CampaignFlowId),
процесса воздействия (ProcessesId), каналы воздействия (exposure_channels), предложения(offers)
следубщие параметры
 количество ячеек воздействия (quantity_impacts)  - количесво выбранных запросом клиентов с устройствами воздействия
 количество выполненных воздействий (actions_impacts) - 
 количество успешных воздействия (зафиксирована реакция) (quantity_successful)
 количество воздействий достигнувших результата (цели кампании) (campaign_result_achieved)  
 
****/
create table CampaignStatistics
(
   CampaignId int NOT NULL,  --- fk campaign
   CampaignFlowId bigint NOT NULL, --- fk campaign_flow
   ProcessesId bigint NOT NULL,  --- fk processes типа 2,3  - воздействие, собеседование
   ExposureChannelsId  int NOT NULL,  --- fk exposure_channels -  каналы воздействия
   OffersId  bigint NOT NULL,  --- fk offers id предложения
   QuantityImpacts int NULL,  --- количество ячеек воздействия
   ActionsImpacts int NULL,   --- количество выполненных воздействий
   QuantitySuccessful int NULL,  --- количество успешных воздействия (зафиксирована реакция)
   CampaignResultAchieved int NULL, --- количество воздействий достигнувших результата (цели кампании)
   UserIdLastEditedBy int NOT NULL,
   LastEditedBy datetime2  NOT NULL,
CONSTRAINT PK_CampaignStatistics PRIMARY KEY CLUSTERED (CampaignId, CampaignFlowId, ProcessesId, ExposureChannelsId, OffersId),
CONSTRAINT FK_CampaignStatistics_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
);
GO

CREATE INDEX FI_CampaignStatistics_Users ON CampaignStatistics (UserIdLastEditedBy);
GO

ALTER TABLE CampaignStatistics ADD CONSTRAINT FK_CampaignStatistics_Campaign
    FOREIGN KEY (CampaignId) REFERENCES Campaign (CampaignId);
GO

CREATE INDEX FI_CampaignStatistics_Campaign ON CampaignStatistics (CampaignId);
GO

ALTER TABLE CampaignStatistics ADD CONSTRAINT FK_CampaignStatistics_CampaignFlow
    FOREIGN KEY (CampaignFlowId)  REFERENCES CampaignFlow (CampaignFlowId);
GO

CREATE INDEX FI_CampaignStatistics_CampaignFlow ON CampaignStatistics (CampaignFlowId);
GO

ALTER TABLE CampaignStatistics ADD CONSTRAINT FK_Processes_CampaignStatistic
    FOREIGN KEY (ProcessesId)  REFERENCES Processes (ProcessesId);
GO

CREATE INDEX FI_CampaignStatistics_Processes ON CampaignStatistics (ProcessesId);
GO

ALTER TABLE CampaignStatistics ADD CONSTRAINT FK_CampaignStatistics_ExposureChannels
    FOREIGN KEY (ExposureChannelsId)  REFERENCES ExposureChannels (ExposureChannelsId);
GO

CREATE INDEX FI_CampaignStatistics_ExposureChannels ON CampaignStatistics (ExposureChannelsId);
GO

ALTER TABLE CampaignStatistics ADD CONSTRAINT FK_CampaignStatistics_Offers
    FOREIGN KEY (OffersId)
    REFERENCES Offers (OffersId); 
GO

CREATE INDEX FI_CampaignStatistics_Offers ON CampaignStatistics (OffersId);
GO


/*****************************************************************************************/
/************Таблицы обеспечивающие расписание  кампании (оповещения, обзвоны)***********/
/*****************************************************************************************/

/********Таблица расписания времени воздействия процесса*************************************/
/******Определяется для процесса воздействия для дня недели и времени возднйствия - позиция
в строке опреджеляет время воздействия 0 - нет воздействия, 1 - есть воздействие
*********/

create table AlertSchedule
(
  AlertScheduleId bigint identity(1,1) NOT NULL,
  CampaignId int NOT NULL,         --- fk campaign
  CampaignFlowId bigint NOT NULL,    --- fk campaign_flow
  ProcessesId bigint NOT NULL,         --- fk processes
  Monday nchar(24) default '000000001111111100000000', 
  Tuesday nchar(24) default '000000001111111100000000', 
  Wednesday nchar(24) default '000000001111111100000000',
  Thursday nchar(24) default '000000001111111100000000', 
  Friday nchar(24) default '000000001111111100000000',  
  Saturday nchar(24) default '000000000000000000000000',
  Sunday nchar(24) default '000000000000000000000000',  
  UserIdLastEditedBy int NOT NULL,
  LastEditedBy datetime2  NOT NULL,
CONSTRAINT PK_AlertSchedule PRIMARY KEY CLUSTERED (AlertScheduleId),
CONSTRAINT FK_AlertSchedule_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
);
GO

CREATE INDEX FI_AlertSchedule_Users ON CampaignStatistics (UserIdLastEditedBy);
GO

ALTER TABLE AlertSchedule  ADD CONSTRAINT FK_AlertSchedule_Campaign
  FOREIGN KEY (CampaignId) REFERENCES Campaign (CampaignId);
GO

CREATE INDEX FI_AlertSchedule_Campaign ON AlertSchedule (CampaignId);
GO

ALTER TABLE AlertSchedule  ADD CONSTRAINT FK_AlertSchedule_CampaignFlow
 FOREIGN KEY (CampaignFlowId) REFERENCES CampaignFlow (CampaignFlowId);
GO

CREATE INDEX FI_AlertSchedule_CampaignFlow ON AlertSchedule (CampaignFlowId);
GO

ALTER TABLE AlertSchedule ADD CONSTRAINT FK_AlertSchedule_processes
      FOREIGN KEY (ProcessesId) REFERENCES Processes (ProcessesId);
GO

CREATE INDEX FI_AlertSchedule_Processes ON AlertSchedule (ProcessesId);
GO

/****************Справочник выходных дней*******************/

CREATE TABLE Holidays
(   HolidaysId bigint identity(1,1) NOT NULL,
    DateCampaign datetime2 NOT NULL,
    Saturday bit NULL,
    Sunday bit NULL,
    Holiday bit NULL,
    UserIdLastEditedBy int NOT NULL,
    ValidFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
    ValidTo datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
CONSTRAINT PK_Holidays PRIMARY KEY CLUSTERED (HolidaysId),
CONSTRAINT FK_Holidays_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Holidays_Archive)
);
GO

CREATE INDEX FI_Holidays_Users ON CampaignStatistics (UserIdLastEditedBy);
GO


/****************Календарь выполнения процессов *******************/

create table ScheduleProcesses
(
  ScheduleProcessesId bigint identity(1,1) NOT NULL,
  ProcessesId bigint NOT NULL,   --- fk processes
  DateProcesses datetime2 NULL,
  Schedule nchar(24) default '000000001111111100000000',
  UserIdLastEditedBy int NOT NULL,
  LastEditedBy datetime2  NOT NULL,
CONSTRAINT PK_ScheduleProcesses PRIMARY KEY CLUSTERED (ScheduleProcessesId),
CONSTRAINT FK_ScheduleProcesses_Users FOREIGN KEY (UserIdLastEditedBy) REFERENCES Users (UsersId)
);
GO

CREATE INDEX FI_ScheduleProcesses_Users ON ScheduleProcesses (UserIdLastEditedBy);
GO

ALTER TABLE ScheduleProcesses  ADD CONSTRAINT FK_ScheduleProcesses
      FOREIGN KEY (ProcessesId)  REFERENCES Processes (ProcessesId);
GO

CREATE INDEX FI_ScheduleProcesses_Processes ON ScheduleProcesses (ProcessesId);
GO


/********************************************************************/



