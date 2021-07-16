/*********
Реализуемая в домашнем задании очередь предназначена для синхронизации (загрузки/изменении) данных
в таблице CampaignStatisticsDW из таблицы CampaignStatistics для указанной CampaignId.
Близко по логике LTE.
**********/


USE [Campaign]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


USE master
GO

ALTER DATABASE Campaign SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

ALTER DATABASE Campaign SET ENABLE_BROKER;	
GO

ALTER DATABASE Campaign SET TRUSTWORTHY ON;
GO

select DATABASEPROPERTYEX ('Campaign','UserAccess');
GO

SELECT is_broker_enabled FROM sys.databases WHERE name = 'Campaign';
GO

ALTER AUTHORIZATION    
   ON DATABASE::Campaign TO [sa]; 

ALTER DATABASE Campaign SET MULTI_USER WITH ROLLBACK IMMEDIATE;
GO

use Campaign;
GO


CREATE MESSAGE TYPE
[//Camp/SB/RequestMessage]
VALIDATION=WELL_FORMED_XML;
GO

CREATE MESSAGE TYPE
[//Camp/SB/ReplyMessage]
VALIDATION=WELL_FORMED_XML; 
GO

CREATE CONTRACT [//Camp/SB/Contract]
      ([//Camp/SB/RequestMessage]
         SENT BY INITIATOR,
       [//Camp/SB/ReplyMessage]
         SENT BY TARGET
      );
GO


CREATE QUEUE TargetQueueCamp;
GO

CREATE SERVICE [//Camp/SB/TargetService]
       ON QUEUE TargetQueueCamp
       ([//Camp/SB/Contract]);
GO


CREATE QUEUE InitiatorQueueCamp;
GO

CREATE SERVICE [//Camp/SB/InitiatorService]
       ON QUEUE InitiatorQueueCamp
       ([//Camp/SB/Contract]);
GO


/*****************************************************/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.SendNewCampStat
	@CampaignId INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RequestMessage NVARCHAR(4000);
	
	BEGIN TRAN

	SELECT @RequestMessage = (SELECT CampaignId
							  FROM dbo.CampaignStatistics AS CS
							  WHERE CampaignId = @CampaignId
							  FOR XML AUTO, root('RequestMessage')); 
	
	BEGIN DIALOG @InitDlgHandle
	FROM SERVICE
	[//Camp/SB/InitiatorService]
	TO SERVICE
	'//Camp/SB/TargetService'
	ON CONTRACT
	[//Camp/SB/Contract]
	WITH ENCRYPTION=OFF; 

	SEND ON CONVERSATION @InitDlgHandle 
	MESSAGE TYPE
	[//Camp/SB/RequestMessage]
	(@RequestMessage);

	COMMIT TRAN 
END
GO
 		 

/************************************************************************/

DROP PROCEDURE IF EXISTS GetNewCampStat;
GO

CREATE PROCEDURE GetNewCampStat
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER,
			@Message NVARCHAR(4000),
			@MessageType Sysname,
			@ReplyMessage NVARCHAR(4000),
            @CampaignId INT,
			@xml XML; 
	
	BEGIN TRAN; 

	RECEIVE TOP(1)
		@TargetDlgHandle = Conversation_Handle,
		@Message = Message_Body,
		@MessageType = Message_Type_Name
	FROM dbo.TargetQueueCamp; 

	SELECT @Message; 

	SET @xml = CAST(@Message AS XML); 

	SELECT @CampaignId = R.Cs.value('@CampaignId','INT')
	FROM @xml.nodes('/RequestMessage/CS') as R(Cs);

	SELECT '@CampaignId='+CAST(@CampaignId AS nchar(10));

MERGE dbo.CampaignStatisticsDW AS target
   USING (SELECT CampaignId, ExposureChannelsId, OffersId, QuantityImpacts, ActionsImpacts, QuantitySuccessful,
    CampaignResultAchieved FROM dbo.CampaignStatistics WHERE CampaignId = @CampaignId)  AS source 
	(CampaignId, ExposureChannelsId, OffersId, QuantityImpacts, ActionsImpacts, QuantitySuccessful, CampaignResultAchieved) ON
	(target.CampaignId = source.CampaignId AND target.ExposureChannelsId = source.ExposureChannelsId AND 
	 target.OffersId = source.OffersId)
	WHEN MATCHED
	     THEN UPDATE SET QuantityImpacts = source.QuantityImpacts,
		                 ActionsImpacts = source.ActionsImpacts,
					     QuantitySuccessful = source.QuantitySuccessful,
						 CampaignResultAchieved = source.CampaignResultAchieved
    WHEN NOT MATCHED
	     THEN INSERT (CampaignId, ExposureChannelsId, OffersId, QuantityImpacts, ActionsImpacts, QuantitySuccessful,
    CampaignResultAchieved)
	          VALUES(source.CampaignId, source.ExposureChannelsId, source.OffersId, source.QuantityImpacts, source.ActionsImpacts,
			   source.QuantitySuccessful, source.CampaignResultAchieved);


	SELECT @Message AS ReceivedRequestMessage, @MessageType;
	
	IF @MessageType=N'//Camp/SB/RequestMessage'
	BEGIN
		SET @ReplyMessage =N'<ReplyMessage> Message received </ReplyMessage>'; 
	
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//Camp/SB/ReplyMessage]
		(@ReplyMessage);
		END CONVERSATION @TargetDlgHandle;
	END 
	
	SELECT @ReplyMessage AS SentReplyMessage; 

	COMMIT TRAN;
END

/******************************************************************/

DROP PROC IF EXISTS ConfirmCampStat;
GO

CREATE PROCEDURE dbo.ConfirmCampStat
AS
BEGIN

	DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER, 
			@ReplyReceivedMessage NVARCHAR(1000) 
	
	BEGIN TRAN; 

		RECEIVE TOP(1)
			@InitiatorReplyDlgHandle=Conversation_Handle,
			@ReplyReceivedMessage=Message_Body
		FROM dbo.InitiatorQueueCamp; 
		
		END CONVERSATION @InitiatorReplyDlgHandle; 
		
		SELECT @ReplyReceivedMessage AS ReceivedRepliedMessage; 

	COMMIT TRAN; 
END

GO

/*********************************************************************/
/*********************************************************************/

use Campaign;
GO


SELECT *
FROM dbo.CampaignStatistics
WHERE CampaignId = 1;

/****
CampaignId  CampaignFlowId       ProcessesId          ExposureChannelsId OffersId             QuantityImpacts ActionsImpacts QuantitySuccessful CampaignResultAchieved UserIdLastEditedBy LastEditedBy
----------- -------------------- -------------------- ------------------ -------------------- --------------- -------------- ------------------ ---------------------- ------------------ ---------------------------
1           1                    2                    1                  1                    1200            1200           700                300                    1                  2021-07-08 20:09:04.4500000
****/

SELECT *
FROM dbo.CampaignStatisticsDW
WHERE CampaignId = 1;

/***
CampaignId  ExposureChannelsId OffersId             QuantityImpacts ActionsImpacts QuantitySuccessful CampaignResultAchieved
----------- ------------------ -------------------- --------------- -------------- ------------------ ----------------------
1           1                  1                    1200            1200           700                300
***/

UPDATE CampaignStatistics SET  QuantitySuccessful = 710,
						       CampaignResultAchieved = 310
WHERE CampaignId = 1;
GO

SELECT *
FROM dbo.CampaignStatistics
WHERE CampaignId = 1;

/****
CampaignId  CampaignFlowId       ProcessesId          ExposureChannelsId OffersId             QuantityImpacts ActionsImpacts QuantitySuccessful CampaignResultAchieved UserIdLastEditedBy LastEditedBy
----------- -------------------- -------------------- ------------------ -------------------- --------------- -------------- ------------------ ---------------------- ------------------ ---------------------------
1           1                    2                    1                  1                    1200            1200           710                310                    1                  2021-07-08 20:09:04.4500000

(1 row affected)

****/

EXEC dbo.SendNewCampStat @CampaignId = 1;
GO


EXEC dbo.GetNewCampStat;
GO

SELECT conversation_handle, is_initiator, s.name as 'local service', 
far_service, sc.name 'contract', ce.state_desc
FROM sys.conversation_endpoints ce
LEFT JOIN sys.services s
ON ce.service_id = s.service_id
LEFT JOIN sys.service_contracts sc
ON ce.service_contract_id = sc.service_contract_id
ORDER BY conversation_handle;

/****
conversation_handle                  is_initiator local service                                                                                                                    far_service                                                                                                                                                                                                                                                      contract                                                                                                                         state_desc
------------------------------------ ------------ -------------------------------------------------------------------------------------------------------------------------------- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -------------------------------------------------------------------------------------------------------------------------------- ------------------------------------------------------------
3DB7436F-1BE6-EB11-9005-C8D9D20C2E2C 0            //Camp/SB/TargetService                                                                                                          //Camp/SB/InitiatorService                                                                                                                                                                                                                                       //Camp/SB/Contract                                                                                                               CLOSED
044D2CFF-1DE6-EB11-9005-C8D9D20C2E2C 1            //Camp/SB/InitiatorService                                                                                                       //Camp/SB/TargetService                                                                                                                                                                                                                                          //Camp/SB/Contract                                                                                                               DISCONNECTED_INBOUND
074D2CFF-1DE6-EB11-9005-C8D9D20C2E2C 0            //Camp/SB/TargetService                                                                                                          //Camp/SB/InitiatorService                                                                                                                                                                                                                                       //Camp/SB/Contract                                                                                                               CLOSED
*****/

EXEC dbo.ConfirmCampStat;
GO


-- Проверим синхронизацию данных

SELECT *
FROM dbo.CampaignStatistics
WHERE CampaignId = 1;


SELECT *
FROM dbo.CampaignStatisticsDW
WHERE CampaignId = 1;

/*****
CampaignId  CampaignFlowId       ProcessesId          ExposureChannelsId OffersId             QuantityImpacts ActionsImpacts QuantitySuccessful CampaignResultAchieved UserIdLastEditedBy LastEditedBy
----------- -------------------- -------------------- ------------------ -------------------- --------------- -------------- ------------------ ---------------------- ------------------ ---------------------------
1           1                    2                    1                  1                    1200            1200           710                310                    1                  2021-07-08 20:09:04.4500000

CampaignId  ExposureChannelsId OffersId             QuantityImpacts ActionsImpacts QuantitySuccessful CampaignResultAchieved
----------- ------------------ -------------------- --------------- -------------- ------------------ ----------------------
1           1                  1                    1200            1200           710                310

ДАННЫЕ СИНХРОНИЗИРОВАНЫ
*****/



/*****Автоматизируем процесс*******************/


USE Campaign;
GO


ALTER QUEUE [dbo].[InitiatorQueueCamp] WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF) 
	, ACTIVATION (   STATUS = ON ,
        PROCEDURE_NAME = dbo.ConfirmCampStat, MAX_QUEUE_READERS = 100, EXECUTE AS OWNER) ; 

GO

ALTER QUEUE [dbo].[TargetQueueCamp] WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF)
	, ACTIVATION (  STATUS = ON ,
        PROCEDURE_NAME = dbo.GetNewCampStat, MAX_QUEUE_READERS = 100, EXECUTE AS OWNER) ; 

GO


/***********************/

-- Выполним для другого CampaignId

use Campaign;
GO

SELECT *
FROM dbo.CampaignStatisticsDW
WHERE CampaignId = 3;

/***
CampaignId  ExposureChannelsId OffersId             QuantityImpacts ActionsImpacts QuantitySuccessful CampaignResultAchieved
----------- ------------------ -------------------- --------------- -------------- ------------------ ----------------------
3           1                  2                    1500            400            300                70

(1 row affected)
*****/

SELECT *
FROM dbo.CampaignStatistics
WHERE CampaignId = 3;

/***
CampaignId  CampaignFlowId       ProcessesId          ExposureChannelsId OffersId             QuantityImpacts ActionsImpacts QuantitySuccessful CampaignResultAchieved UserIdLastEditedBy LastEditedBy
----------- -------------------- -------------------- ------------------ -------------------- --------------- -------------- ------------------ ---------------------- ------------------ ---------------------------
3           2                    7                    1                  2                    1500            400            300                70                     1                  2021-07-08 20:17:43.2433333

(1 row affected)
****/


UPDATE CampaignStatistics SET  QuantitySuccessful = 310,
						       CampaignResultAchieved = 80
WHERE CampaignId = 3;
GO


EXEC dbo.SendNewCampStat @CampaignId = 3;
GO

SELECT *
FROM dbo.CampaignStatistics
WHERE CampaignId = 3;


SELECT *
FROM dbo.CampaignStatisticsDW
WHERE CampaignId = 3;


/*****

CampaignId  CampaignFlowId       ProcessesId          ExposureChannelsId OffersId             QuantityImpacts ActionsImpacts QuantitySuccessful CampaignResultAchieved UserIdLastEditedBy LastEditedBy
----------- -------------------- -------------------- ------------------ -------------------- --------------- -------------- ------------------ ---------------------- ------------------ ---------------------------
3           2                    7                    1                  2                    1500            400            310                80                     1                  2021-07-08 20:17:43.2433333

CampaignId  ExposureChannelsId OffersId             QuantityImpacts ActionsImpacts QuantitySuccessful CampaignResultAchieved
----------- ------------------ -------------------- --------------- -------------- ------------------ ----------------------
3           1                  2                    1500            400            310                80

 ДАННЫЕ СИНХРОНИЗИРОВАНЫ
 *****/



/*******************************/

SET NOCOUNT ON;

DECLARE @Conversation uniqueidentifier;

WHILE EXISTS(SELECT 1 FROM sys.transmission_queue)
BEGIN
  SET @Conversation = 
                (SELECT TOP(1) conversation_handle 
                                FROM sys.transmission_queue);
  END CONVERSATION @Conversation WITH CLEANUP;
END;

GO
