USE Campaign;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*********Хранимая процедура создания пользователя***********/

IF OBJECT_ID ( 'Dbo.spUserInst', 'P' ) IS NOT NULL   
    DROP PROCEDURE Dbo.spUserInst;  
GO

CREATE PROC spUserInst(@pUserName nvarchar(120), @pUsersIdGroup int, @pGroupSign char(1), @pFromDate datetime2,
                       @pToDate datetime2, @pLastname nvarchar(40), @pFirstname nvarchar(40), @pmiddlename nvarchar(40),  
                       @pUserPassword nvarchar(16), @pPhone nvarchar(40), @pOffice  nchar(10), @pE_mail nchar(254), 
                       @pUserIdLastEditedBy int, @pUserId int OUT)
WITH EXECUTE AS CALLER
AS
BEGIN
  INSERT INTO Users(UserName, UsersIdGroup, GroupSign, FromDate,
                       ToDate, UserIdLastEditedBy)
  VALUES(@pUserName, @pUsersIdGroup, @pGroupSign, @pFromDate, @pToDate, @pUserIdLastEditedBy); 
  
  SET @pUserId = @@IDENTITY;

INSERT INTO UsersPerson(UsersId, Lastname, Firstname, middlename, UserPassword, Phone, Office, E_mail, UserIdLastEditedBy)
VALUES( @pUserId, @pLastname, @pFirstname, @pmiddlename,  @pUserPassword, @pPhone, @pOffice, @pE_mail, @pUserIdLastEditedBy);

END

GO

/*************************************************************/

IF OBJECT_ID ( 'Dbo.spCountriesInst', 'P' ) IS NOT NULL   
    DROP PROCEDURE Dbo.spCountriesInst;  
GO

CREATE PROC spCountriesInst(@pCountryName nvarchar(250), @pContinent nvarchar(30), @pUserIdLastEditedBy int, @pCountryId int OUT)
WITH EXECUTE AS CALLER
AS
BEGIN

 INSERT INTO Countries(CountryName, Continent, UserIdLastEditedBy)
 VALUES(@pCountryName, @pContinent, @pUserIdLastEditedBy);

 SET @pCountryId = @@IDENTITY;

END

GO

/***********************************************************/

IF OBJECT_ID ( 'Dbo.spCountryRegionsInst', 'P' ) IS NOT NULL   
    DROP PROCEDURE Dbo.spCountryRegionsInst;  
GO

CREATE PROC spCountryRegionsInst(@pContryId int, @pFederalDistrictId int,  @pCountryRegion_id  varchar(2),
@pCountryRegionName  nvarchar(250), @pCountregGuid nvarchar(36),  @pUserIdLastEditedBy int , @pCountryRegionId int OUT)
WITH EXECUTE AS CALLER
AS
BEGIN

INSERT INTO CountryRegions(ContryId, FederalDistrictId, CountryRegion_id, CountryRegionName, CountregGuid, UserIdLastEditedBy)
VALUES(@pContryId, @pFederalDistrictId, @pCountryRegion_id, @pCountryRegionName, @pCountregGuid, @pUserIdLastEditedBy)

SET @pCountryRegionId = @@IDENTITY;

END

GO


/************************************/

IF OBJECT_ID ( 'Dbo.spTownsInst', 'P' ) IS NOT NULL   
    DROP PROCEDURE Dbo.spTownsInst;  
GO

CREATE PROC spTownsInst(@pCountryId int, @pTownName nvarchar(250), @pPrefix nvarchar(25), @pCountryRegionId int, @pAreaRegionId int,
    @pTowns_guid nvarchar(36), @pUserIdLastEditedBy int, @pTownsId bigint OUT)
WITH EXECUTE AS CALLER
AS
BEGIN

INSERT INTO Towns(CountryId, TownName, Prefix, CountryRegionId, AreaRegionId, Towns_guid, UserIdLastEditedBy)
VALUES(@pCountryId, @pTownName, @pPrefix, @pCountryRegionId, @pAreaRegionId, @pTowns_guid, @pUserIdLastEditedBy)

SET @pTownsId = @@IDENTITY;

END

GO


/******************************************************************/

IF OBJECT_ID ( 'Dbo.spStreetsInst', 'P' ) IS NOT NULL   
    DROP PROCEDURE Dbo.spTownsInst;  
GO

CREATE PROC spStreetsInst(@pTownsId int, @pStreetName nvarchar(250), @pPrefix nvarchar(25), @pStreets_guid nvarchar(36), @pUserIdLastEditedBy int, @pStreetsId bigint OUT)
WITH EXECUTE AS CALLER
AS
BEGIN

INSERT INTO Streets(TownsId, StreetName, Prefix, Streets_guid, UserIdLastEditedBy)
VALUES(@pTownsId, @pStreetName, @pPrefix, @pStreets_guid, @pUserIdLastEditedBy)

 SET @pStreetsId = @@IDENTITY

END

GO


/***************************************************************/

IF OBJECT_ID ( 'Dbo.spAddressInst', 'P' ) IS NOT NULL   
    DROP PROCEDURE Dbo.spAddressInst;  
GO

CREATE PROC spAddressInst(@pStreetsId bigint, @pHouse int, @pPostfix nvarchar(15), @pPost_index nvarchar(6), @pAddress_guid nvarchar(36), @pUserIdLastEditedBy int, @pAddressId bigint OUT)
WITH EXECUTE AS CALLER
AS
BEGIN

INSERT INTO Address(StreetsId, House, Postfix, Post_index, Address_guid, UserIdLastEditedBy)
VALUES(@pStreetsId, @pHouse, @pPostfix, @pPost_index, @pAddress_guid, @pUserIdLastEditedBy)

 SET @pAddressId = @@IDENTITY

END

GO


/**********************************************************************************************************/


IF OBJECT_ID ( 'Dbo.spRoomsInst', 'P' ) IS NOT NULL   
    DROP PROCEDURE Dbo.spRoomsInst;  
GO

CREATE PROC spRoomsInst(@pAddressId bigint, @pFlat int, @pFlat_postfix nvarchar(50), @pRoomguid nvarchar(36), @pUserIdLastEditedBy int, @pRoomsId bigint OUT)
WITH EXECUTE AS CALLER
AS
BEGIN

INSERT INTO Rooms(AddressId, Flat, Flat_postfix, Roomguid, UserIdLastEditedBy)
VALUES(@pAddressId, @pFlat, @pFlat_postfix, @pRoomguid, @pUserIdLastEditedBy)

SET @pRoomsId = @@IDENTITY

END

GO


/****************************************************************/


IF OBJECT_ID ( 'Dbo.spPeoplesInst', 'P' ) IS NOT NULL   
    DROP PROCEDURE Dbo.spPeoplesInst;  
GO

CREATE PROC spPeoplesInst(@pLastname nvarchar(50), @pFirstname nvarchar(50), @pMiddlename nvarchar(50), @pGender smallint, 
    @pBirthDate datetime2, @pAddress nvarchar(500), @pAddressId bigint, @pRoomsId   bigint,
    @pcomment nvarchar(500),  @pUserIdLastEditedBy int, @pPeoplesId bigint OUT)
WITH EXECUTE AS CALLER
AS
BEGIN

INSERT INTO Peoples(Lastname, Firstname, Middlename, Gender, BirthDate, Address, AddressId, RoomsId, comment, UserIdLastEditedBy, LastEditedBy)
VALUES(@pLastname, @pFirstname, @pMiddlename, @pGender, @pBirthDate, @pAddress, @pAddressId, @pRoomsId, @pcomment, @pUserIdLastEditedBy, GETDATE())

SET @pPeoplesId = @@IDENTITY

END

GO

/***************************************************************************/

IF OBJECT_ID ( 'Dbo.spClientsInst', 'P' ) IS NOT NULL   
    DROP PROCEDURE Dbo.spClientsInst;  
GO

CREATE PROC spClientsInst(@pPeoplesId bigint, @pFirmsId bigint, @pLoadingId int, @pComment nvarchar(500), @pUserIdLastEditedBy int, @pClientsId bigint OUT)
WITH EXECUTE AS CALLER
AS
BEGIN

INSERT INTO Clients(PeoplesId, FirmsId, LoadingId, Comment, UserIdLastEditedBy, LastEditedBy)
VALUES(@pPeoplesId, @pFirmsId, @pLoadingId, @pComment, @pUserIdLastEditedBy, GETDATE())

SET @pClientsId = @@IDENTITY

END

GO


/*******************************************************************************************/

IF OBJECT_ID ( 'Dbo.spExposureChannelsInst', 'P' ) IS NOT NULL   
    DROP PROCEDURE Dbo.spExposureChannelsInst;  
GO

CREATE PROC spExposureChannelsInst(@pUniqueId int, @pExposureChannelsName nvarchar(100), @pExposureChannelswebsite  nvarchar(100), @pColor bigint, @pUserIdLastEditedBy int, @pExposureChannelsId int OUT)
WITH EXECUTE AS CALLER
AS
BEGIN

INSERT INTO ExposureChannels(UniqueId, ExposureChannelsName, ExposureChannelswebsite, Color, UserIdLastEditedBy)
VALUES(@pUniqueId, @pExposureChannelsName, @pExposureChannelswebsite, @pColor, @pUserIdLastEditedBy)

SET @pExposureChannelsId = @@IDENTITY

END

GO


/*****************************************************************************************/

IF OBJECT_ID ( 'Dbo.spRequestInst', 'P' ) IS NOT NULL   
    DROP PROCEDURE Dbo.spRequestInst;  
GO

CREATE PROC spRequestInst(@pRequestName nvarchar(100), @pRequest_text nvarchar(max), @pUniqueId int, @pColor bigint, @pComment nvarchar(250), @pUserIdLastEditedBy int,  @pRequestId bigint OUT)
WITH EXECUTE AS CALLER
AS
BEGIN

INSERT INTO Request(RequestName, Request_text, UniqueId, Color, Comment, UserIdLastEditedBy)
VALUES(@pRequestName, @pRequest_text, @pUniqueId, @pColor, @pComment, @pUserIdLastEditedBy)

SET @pRequestId = @@IDENTITY

END

GO


/**************************************************************************************/

IF OBJECT_ID ( 'Dbo.spOffersInst', 'P' ) IS NOT NULL   
    DROP PROCEDURE Dbo.spOffersInst;  
GO

CREATE PROC spOffersInst(@pOffersName nvarchar(100), @pExposureChannelsId int, @pHeading nvarchar(250), @pFile_path  nvarchar(250), 
    @pOffers_text nvarchar(max), @pFile_content bit,  @pOffers_type smallint, @pUserIdLastEditedBy int, @pOffersId bigint OUT)
WITH EXECUTE AS CALLER
AS
BEGIN

INSERT INTO Offers(OffersName, ExposureChannelsId, Heading, File_path, Offers_text, File_content,  Offers_type, UserIdLastEditedBy)
VALUES(@pOffersName, @pExposureChannelsId, @pHeading, @pFile_path, @pOffers_text, @pFile_content, @pOffers_type, @pUserIdLastEditedBy)

SET @pOffersId = @@IDENTITY

END

GO

/*****************************************************************************/


IF OBJECT_ID ( 'Dbo.spClientPhonesInst', 'P' ) IS NOT NULL   
    DROP PROCEDURE Dbo.spClientPhonesInst;  
GO

CREATE PROC spClientPhonesInst(@pClientsId bigint, @pPhone nvarchar(40), @pBasic bit, @pCellular bit,  @pOrderNumber smallint, @pUserIdLastEditedBy int,  @pClPhoneId bigint OUT)
WITH EXECUTE AS CALLER
AS
BEGIN

	INSERT INTO ClientPhones(ClientsId, Phone, Basic, Cellular,  OrderNumber, UserIdLastEditedBy, LastEditedBy)
	VALUES(@pClientsId, @pPhone, @pBasic, @pCellular,  @pOrderNumber, @pUserIdLastEditedBy, GETDATE());

SET @pClPhoneId = @@IDENTITY

END


/*************email клиента**************************************/


CREATE PROC spClientEmailsInst(@pClientsId bigint, @pEmail nvarchar(250), @pBasic bit, @pUserIdLastEditedBy int,  @pClEmailId bigint OUT)
WITH EXECUTE AS CALLER
AS
BEGIN

INSERT ClientEmails(ClientsId, Email, Basic, UserIdLastEditedBy, LastEditedBy)
VALUES(@pClientsId, @pEmail, @pBasic, @pUserIdLastEditedBy, GETDATE())

SET @pClEmailId = @@IDENTITY

END


/*********************************************/


IF OBJECT_ID ( 'Dbo.spClientPropertiesInst', 'P' ) IS NOT NULL   
    DROP PROCEDURE Dbo.spClientPropertiesInst;  
GO

CREATE PROC spClientPropertiesInst(@pClientsId bigint, @pPropertiesId int, @pPropertiesQuantity numeric(15,4), @pPropertiesComment nvarchar(250), @pUserIdLastEditedBy int)
WITH EXECUTE AS CALLER
AS
BEGIN

INSERT ClientProperties(ClientsId, PropertiesId, PropertiesQuantity, PropertiesComment, UserIdLastEditedBy, LastEditedBy)
values(@pClientsId, @pPropertiesId, @pPropertiesQuantity, @pPropertiesComment, @pUserIdLastEditedBy, GETDATE() )

END




/************************************************************/
/************************************************************/
/*********Хранимая процедура создания ячейки воздействия***********/

USE Campaign;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID ( 'Dbo.spClientCellInst', 'P' ) IS NOT NULL   
    DROP PROCEDURE Dbo.spClientCellInst;  
GO

CREATE PROC spClientCellInst(@pProcesses1_id bigint, @pProcesses2_id bigint, @pRequestId int, @pUserIdLastEditedBy int, @pClientCellId bigint)
WITH EXECUTE AS CALLER
AS
DECLARE @p_varproc1 nvarchar(20),
        @p_varproc2 nvarchar(20),
        @p_varuser nvarchar(20),
        @p_text_request nvarchar(MAX),
        @p_text_incell nvarchar(MAX),
        @p_query nvarchar(MAX);
BEGIN

SET @p_text_incell = N'INSERT ClientCell(Processes1_id, ClientsId, Processes2_id, Name, Gender, Email, Phone, Address, ExposureChannelsId, PhoneSocnetId, Login, UserIdLastEditedBy, LastEditedBy)';

    SET @p_varproc1 = CAST(@pProcesses1_id AS nvarchar(20));
    SET @p_varproc2 = CAST(@pProcesses2_id AS nvarchar(20));
    SET @p_varuser =  CAST(@pUserIdLastEditedBy AS nvarchar(20));

	SELECT @p_text_request = Request_text FROM Request WHERE RequestId = @pRequestId;

    SET @p_text_request = REPLACE(@p_text_request, 'c.ClientsId,', (@p_varproc1 + ', c.ClientsId, ' + @p_varproc2 + ', '));
    SET @p_text_request = REPLACE(@p_text_request, '@pUserId', @p_varuser);

    SET @p_query = @p_text_incell + @p_text_request;

	EXEC (@p_query);

	SET @pClientCellId = @@IDENTITY;
	
END

GO

DECLARE @vProcesses1_id bigint, @vProcesses2_id bigint, @vRequestId int, @vUserIdLastEditedBy int, @vClientCellId bigint;
SELECT @vProcesses1_id = 1, @vProcesses2_id = 2, @vRequestId = 1, @vUserIdLastEditedBy = 1;
EXEC spClientCellInst @vProcesses1_id, @vProcesses2_id, @vRequestId, @vUserIdLastEditedBy, @vClientCellId;
GO

SELECT * FROM ClientCell;
GO


/**********ФУНКЦИЯ ФОРМИРОВАНИЯ СПРАВОЧНИКОВ НА ОСНОВЕ ЗАГРУЖЕННЫХ ДАННЫХ****************/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*********Хранимая процедура загрузки физ лиц***********/

IF OBJECT_ID ( 'Dbo.spCreateClientTmp', 'P' ) IS NOT NULL   
    DROP PROCEDURE Dbo.spCreateClientTmp;  
GO

CREATE PROC spCreateClientTmp(@p_loadings_id integer, @p_prop_type integer,  @p_user integer)
WITH EXECUTE AS CALLER
AS
DECLARE
  @p_quantity int,
  @p_lastname nvarchar(250),
  @p_firstname nvarchar(250),
  @p_middlename nvarchar(250),
  @p_name nvarchar(255),
  @p_date_birth datetime2,
  @p_gender nvarchar(20),
  @p_phone nvarchar(40),
  @p_email nvarchar(250),
  @p_properties nvarchar(500),
  @p_people_id int,
  @p_client_id int,
  @p_gender_int smallint,
  @p_address nvarchar(500),
  @p_comment nvarchar(500),
  @p_firm integer,
  @p_clphone_id int,
  @p_clemail_id int,
  @p_basic bit,
  @p_cellular bit,
  @p_order_number smallint,
  @p_client_properties_id bigint,
  @p_address_id bigint,
  @p_rooms_id bigint;

 BEGIN
  
	SET NOCOUNT ON;
  
  DECLARE ctmp_curs CURSOR
  FOR SELECT lastname, firstname, middlename, name, date_birth, gender, phone,  email, properties,  address, comment 
      FROM client_tmp WHERE loadings_id=@p_loadings_id;

    SELECT @p_quantity=0, @p_address=null, @p_comment=null, @p_firm=null, @p_basic=1, @p_cellular=1, @p_order_number=1, @p_address_id =null, @p_rooms_id = null;


  OPEN ctmp_curs

  FETCH ctmp_curs INTO @p_lastname, @p_firstname, @p_middlename, @p_name, @p_date_birth, @p_gender, @p_phone, @p_email, @p_properties,
    @p_address, @p_comment;
   
   WHILE (@@FETCH_STATUS=0) BEGIN

    IF UPPER(@p_gender) LIKE '%М%' SET @p_gender_int=1 ELSE
    IF UPPER(@p_gender) LIKE '%Ж%' SET @p_gender_int=2 ELSE SET @p_gender_int=NULL;
    
    IF  @p_comment is null AND @p_properties is not null SET  @p_comment=@p_properties;
      EXEC spPeoplesInst @p_lastname, @p_firstname, @p_middlename, @p_gender_int, @p_date_birth, @p_address, @p_address_id, @p_rooms_id, @p_comment, @p_user, @p_people_id OUT 
	
    EXEC spClientsInst @p_people_id, @p_firm, @p_loadings_id, @p_comment, @p_user, @p_client_id OUT
	
    IF @p_phone is not null and @p_phone <> '' 
      EXEC spClientPhonesInst @p_client_id, @p_phone, @p_basic, @p_cellular, @p_order_number, @p_user, @p_clphone_id
	
	
    IF @p_email is not null and @p_email <> '' 
       EXEC spClientEmailsInst @p_client_id, @p_email, @p_basic, @p_user, @p_clemail_id OUT;

    if @p_prop_type is not null 
       EXEC spClientPropertiesInst @p_client_id, @p_prop_type, null, @p_properties, @p_user

    SELECT @p_comment=null, @p_properties=null;

    FETCH ctmp_curs INTO @p_lastname, @p_firstname, @p_middlename, @p_name, @p_date_birth, @p_gender, @p_phone, @p_email, @p_properties,
    @p_address, @p_comment;

  END 

  CLOSE ctmp_curs;
  DEALLOCATE ctmp_curs; 

  SET NOCOUNT OFF;
 
END

GO

EXEC spCreateClientTmp 1, 1, 2


SELECT * FROM Peoples;




/***********Функция формирования статистики для кампании   ***********************************************************/


IF OBJECT_ID ( 'dbo.spFormationStatistics02', 'P' ) IS NOT NULL   
    DROP PROCEDURE dbo.spFormationStatistics02;  
GO

CREATE PROC spFormationStatistics02(@p_campaign_id integer, @p_user_beg integer)

AS 

BEGIN

 CREATE TABLE #CampaignStatisticsTmp
 (
   ID int IDENTITY(1,1) NOT NULL, 
   CampaignId int NOT NULL,  --- fk campaign
   CampaignFlowId bigint NOT NULL, --- fk campaign_flow
   ProcessesId bigint NOT NULL,  --- fk processes типа 2,3  - воздействие, собеседование
   ExposureChannelsId  int NOT NULL,  --- fk exposure_channels -  каналы воздействия
   OffersId  bigint NOT NULL,  --- fk offers id предложения
   QuantityImpacts int NULL,  --- количество ячеек воздействия
   ActionsImpacts int NULL,   --- количество выполненных воздействий
   QuantitySuccessful int NULL,  --- количество успешных воздействия (зафиксирована реакция)
   CampaignResultAchieved int NULL, --- количество воздействий достигнувших результата (цели кампании)
 );

 DELETE FROM  CampaignStatistics WHERE CampaignId=@p_campaign_id;

 INSERT INTO CampaignStatistics(CampaignId, CampaignFlowId, ProcessesId, ExposureChannelsId, OffersId, QuantityImpacts,  UserIdLastEditedBy)
 SELECT C.CampaignId, CF.CampaignFlowId, P.ProcessesId, P.ExposureChannelsId, P.OffersId, count(*), @p_user_beg
 FROM Campaign C
 INNER JOIN CampaignFlow CF ON CF.CampaignId=C.CampaignId
 INNER JOIN Processes P ON CF.CampaignFlowId = P.CampaignFlowId and P.TypeChannels in (2,3)
 INNER JOIN ClientCell CC ON CC.Processes2_id = P.ProcessesId
 where C.CampaignId=@p_campaign_id
 group by  C.CampaignId, CF.CampaignFlowId, P.ProcessesId, P.ExposureChannelsId, P.OffersId;

 
 INSERT INTO #CampaignStatisticsTmp(CampaignId, CampaignFlowId, ProcessesId, ExposureChannelsId, OffersId, QuantitySuccessful)
 SELECT C.CampaignId, CF.CampaignFlowId, P.ProcessesId, P.ExposureChannelsId, P.OffersId, count(*)
 FROM Campaign C
 INNER JOIN CampaignFlow CF ON CF.CampaignId=C.CampaignId
 INNER JOIN Processes P ON CF.CampaignFlowId = P.CampaignFlowId and P.TypeChannels in (2,3)
 INNER JOIN ClientCell CC ON CC.Processes2_id = P.ProcessesId
 INNER JOIN ExposurePerformed EP ON EP.ClientCellId = CC.ClientCellId AND EP.ResponseIs = 1
 where C.CampaignId=@p_campaign_id
 group by  C.CampaignId, CF.CampaignFlowId, P.ProcessesId, P.ExposureChannelsId, P.OffersId;

 UPDATE CS
 SET CS.QuantitySuccessful = T.QuantitySuccessful
 FROM  CampaignStatistics CS,
       #CampaignStatisticsTmp T
 WHERE CS.CampaignId = T.CampaignId AND CS.CampaignFlowId = T.CampaignFlowId AND CS.ProcessesId = T.ProcessesId AND
       CS.ExposureChannelsId = T.ExposureChannelsId AND CS.OffersId = T.OffersId;

 DELETE FROM  #CampaignStatisticsTmp;

 INSERT INTO #CampaignStatisticsTmp(CampaignId, CampaignFlowId, ProcessesId, ExposureChannelsId, OffersId,  ActionsImpacts)
 SELECT C.CampaignId, CF.CampaignFlowId, P.ProcessesId, P.ExposureChannelsId, P.OffersId, count(*)
 FROM Campaign C
 INNER JOIN CampaignFlow CF ON CF.CampaignId=C.CampaignId
 INNER JOIN Processes P ON CF.CampaignFlowId = P.CampaignFlowId and P.TypeChannels in (2,3)
 INNER JOIN ClientCell CC ON CC.Processes2_id = P.ProcessesId
 INNER JOIN ExposurePerformed EP ON EP.ClientCellId = CC.ClientCellId AND EP.PerformedImpacts = 1
 where C.CampaignId=@p_campaign_id
 group by  C.CampaignId, CF.CampaignFlowId, P.ProcessesId, P.ExposureChannelsId, P.OffersId;

 UPDATE CS
 SET CS.ActionsImpacts = T.ActionsImpacts
 FROM  CampaignStatistics CS,
       #CampaignStatisticsTmp T
 WHERE CS.CampaignId = T.CampaignId AND CS.CampaignFlowId = T.CampaignFlowId AND CS.ProcessesId = T.ProcessesId AND
       CS.ExposureChannelsId = T.ExposureChannelsId AND CS.OffersId = T.OffersId;

--- количество воздействий достигнувших результата (цели кампании)

 DELETE FROM  #CampaignStatisticsTmp WHERE CampaignId=@p_campaign_id;

 INSERT INTO #CampaignStatisticsTmp(CampaignId, CampaignFlowId, ProcessesId, ExposureChannelsId, OffersId,  CampaignResultAchieved)
 SELECT C.CampaignId, CF.CampaignFlowId, P.ProcessesId, P.ExposureChannelsId, P.OffersId, count(*)
 FROM Campaign C
 INNER JOIN CampaignFlow CF ON CF.CampaignId=C.CampaignId
 INNER JOIN Processes P ON CF.CampaignFlowId = P.CampaignFlowId and P.TypeChannels in (2,3)
 INNER JOIN ClientCell CC ON CC.Processes2_id = P.ProcessesId
 INNER JOIN ExposurePerformed EP ON EP.ClientCellId = CC.ClientCellId AND EP.CampaignResultIs = 1
 where C.CampaignId=@p_campaign_id
 group by  C.CampaignId, CF.CampaignFlowId, P.ProcessesId, P.ExposureChannelsId, P.OffersId;

 
 UPDATE CS
 SET CS.CampaignResultAchieved = T.CampaignResultAchieved
 FROM  CampaignStatistics CS,
       #CampaignStatisticsTmp T
 WHERE CS.CampaignId = T.CampaignId AND CS.CampaignFlowId = T.CampaignFlowId AND CS.ProcessesId = T.ProcessesId AND
       CS.ExposureChannelsId = T.ExposureChannelsId AND CS.OffersId = T.OffersId;

 
 END;

/*********Пример запроса для выбора целевой аудитории. Формируется генератором запросов ****************/


SELECT C.ClientsId, (CASE WHEN P.Lastname IS NULL THEN '' ELSE P.Lastname END + ' ' +
                     CASE WHEN P.Firstname IS NULL THEN '' ELSE P.Firstname END + ' ' + 
					 CASE WHEN P.Middlename IS NULL THEN '' ELSE P.Middlename END) AS Name, 
P.Gender, PE.Email, PH.Phone, P.Address, CS.ExposureChannelsId, PH1.Phone AS PhoneSocnet, CS.Login  
FROM Clients C
INNER JOIN Peoples P ON P.PeoplesId=C.PeoplesId AND P.Gender=1 AND P.BirthDate>'19591120' AND P.BirthDate<'20011120'
INNER JOIN ClientProperties CP1 ON CP1.ClientsId=C.ClientsId AND CP1.PropertiesId=7
INNER JOIN ClientProperties CP2 ON CP2.ClientsId=C.ClientsId AND CP2.PropertiesId=3 AND CP2.PropertiesQuantity>=170
LEFT OUTER JOIN ClientPhones PH ON PH.ClientsId=C.ClientsId AND PH.Basic=1 AND PH.Cellular=1
LEFT OUTER JOIN ClientEmails PE ON PE.ClientsId=C.ClientsId
LEFT OUTER JOIN ClientSocnetwork CS ON CS.ClientsId=C.ClientsId AND CS.ExposureChannelsId=5
LEFT OUTER JOIN ClientPhones PH1 ON  PH1.ClientPhonesId = CS.ClientPhonesId

