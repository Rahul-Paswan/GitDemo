-- Replace DB Name	:	REPLACE  "[CoreAuth]" With CoreAuth DataBase Name

--IF EXISTS (SELECT name FROM sysobjects WHERE name = 'CheckPrimaryCard' AND type = 'TR')
--   DROP TRIGGER CheckPrimaryCard
--GO

ALTER TRIGGER [dbo].[CheckPrimaryCard]
ON [dbo].[EmbossingAccounts] 
FOR UPDATE
AS 
SET NOCOUNT ON
DECLARE @Acctid INT
DECLARE @Parent01aid INT
DECLARE @ManualCardStatus INT
DECLARE @ManualCardStatusOld INT
DECLARE @ECardType INT
DECLARE @CancelStatus INT
declare	@CurrentARTime datetime
declare	@ExpirationDate datetime
declare	@PreviousDate datetime

SELECT @Acctid =Acctid,@Parent01aid=Parent01aid, @ManualCardStatus=ManualCardStatus,@ECardType=ECardType, @CancelStatus=CancelStatus,@ExpirationDate = PendingCardExpDate,@PreviousDate = CardExpDate FROM INSERTED
SELECT  @ManualCardStatusOld= ManualCardStatus FROM DELETED
Select  @CurrentARTime  =  ProcDayEnd from arsystemaccounts WITH (NOLOCK)
/*IF @ECardType=0 AND (@ManualCardStatus=7 OR @ManualCardStatus=8)
BEGIN
	UPDATE EmbossingAccounts SET ManualCardStatus = @ManualCardStatus, CancelStatus=@CancelStatus, CardClosedDate =  @CurrentARTime
		WHERE (Parent01aid=@Parent01aid and CardClosedDate Is NULL and ECardType= 1)
END*/
IF (@ManualCardStatus=7 OR @ManualCardStatus=8)
BEGIN
UPDATE EmbossingAccounts SET CardClosedDate =  @CurrentARTime
		WHERE (Acctid=@Acctid and CardClosedDate Is NULL)
END
IF (@ManualCardStatus=1)
BEGIN
UPDATE EmbossingAccounts SET cardactdate =  @CurrentARTime
		WHERE (Acctid=@Acctid and cardactdate Is NULL)
	
	IF (@ManualCardStatusOld !=1 )
	BEGIN
		IF (@ManualCardStatusOld is not NULL)	
		BEGIN	
			UPDATE EmbossingAccounts SET ExpirationDate = @PreviousDate, CardExpDate =  @ExpirationDate,PendingCardExpDate = null
				 , AppTransactionCounter = '0000'
				WHERE (Acctid=@Acctid and PendingCardExpDate Is Not Null)
			UPDATE [CoreAuth]..EmbossingAccounts SET AppTransactionCounter = '0000' WHERE Acctid=@Acctid
		END
	END
END

GO
