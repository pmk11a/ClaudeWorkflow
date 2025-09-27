-- =====================================================
-- EXISTING DATABASE FUNCTIONS FROM DATABASE
-- Extracted from: dbdapenka2
-- Date: 2025-08-21 12:12:05
-- Total Functions: 31
-- =====================================================

-- Function: ArusKasSDBank
-- Type: SQL_SCALAR_FUNCTION
-- Created: 2025-08-10 15:10:49.437 | Modified: 2025-08-10 15:10:49.437
-- =====================================================


CREATE FUNCTION [dbo].[ArusKasSDBank] ( @Bulan int, @Tahun int)
RETURNS Float
AS
BEGIN
  Declare @SaldoQnt Float
    	  --  select --'H1'Tanda,
	    --'AK01','SAK05-',b.Bulan,b.Tahun,Devisi,0,sum(b.Nilai) Nilai 
        Select @SaldoQnt=sum(b.Nilai)     
	    from DBPERKIRAAN a
 	    left outer join 
 	    ( 	    
         select (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) 
                    then  a.Lawan
	                when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) then 
	          a.Perkiraan
		end) Perkiraan,month(t.tanggal) Bulan, year(t.tanggal) Tahun,
		    (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then debet*a.kurs
		          when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and kredit<>0 then 0
		          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and debet<>0 then 0
		          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and kredit<>0 then kredit*a.kurs end
	        	) -
	    (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then 0
		            when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and kredit<>0 then Kredit*a.kurs
		            when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then Debet*a.kurs
		            when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and kredit<>0 then 0 end) as Nilai,
		t.Devisi ,t.TipeTransHd
		     from dbTrans t 
		     left outer join dbtransaksi a on t.NoBukti=a.NoBukti
		     left outer join DBPERKIRAAN b on b.Perkiraan=a.Perkiraan
		     left outer join DBPERKIRAAN c on c.Perkiraan=a.Lawan	
		     where  (month(t.tanggal)=@bulan and year(t.tanggal)=@tahun)  and
		    (  (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) )
		and tipetranshd <>'BMM' and a.JnsTransInvestasi=1
		) B on b.Perkiraan=a.Perkiraan
 	    where b.Bulan is not null and  (a.GroupPerkiraan  like '1101000' ) --and b.Perkiraan =@perkiraan
 	    group by Bulan ,Tahun ,Devisi 
  Return isnull(@SaldoQnt,0)
END


GO

-- Function: DataBP
-- Type: SQL_SCALAR_FUNCTION
-- Created: 2014-09-30 10:36:45.023 | Modified: 2014-09-30 10:36:45.023
-- =====================================================



-- =============================================
-- Author:		Noviyanto
-- Create date: 02 agustus 2012
-- Description:	Get String NoBP
-- =============================================
Create FUNCTION [dbo].[DataBP] (@NoTT Varchar(30))
RETURNS Varchar(8000)
with Schemabinding
AS
BEGIN
  Declare @noBP varchar(30), @The_BP varchar(8000), @Counter int, @i int
  Select @Counter=COUNT(NoBeli) from DBO.dbInvoiceDet where NoBukti=@NoTT 
  Set @i=1
  Set @The_BP='' 
  Declare Mydata Cursor For
  Select NoBeli
  From DBO.dbInvoiceDet
  where NoBukti=@NoTT
  open Mydata 
  Fetch next from mydata Into @NoBP
  While @@FETCH_STATUS=0
  begin
    if @Counter=@i 
       Set @The_BP=@The_BP+@noBP
    else 
       Set @The_BP=@The_BP+@noBP+', '

    --Set @i=@i+1
    Fetch next from mydata Into @NoBP
    Set @i=@i+1
  end
  Close Mydata
  Deallocate mydata 	
  Return @The_BP
END


GO

-- Function: DataPostHutPiut
-- Type: SQL_SCALAR_FUNCTION
-- Created: 2013-06-24 17:18:55.313 | Modified: 2013-06-24 17:18:55.313
-- =====================================================


-- =============================================
-- Author:		Noviyanto
-- Create date: 02 agustus 2012
-- Description:	Get String NoBP
-- =============================================
CREATE FUNCTION [dbo].[DataPostHutPiut] (@KodeCustSupp Varchar(30), @TipeTrans varchar(50))
RETURNS Varchar(8000)
with Schemabinding
AS
BEGIN
  Declare @noBP varchar(30), @The_BP varchar(8000), @Counter int, @i int
  Select @Counter=COUNT(KodeCustSupp) 
from dbo.dbPerkCustSupp  a
     left outer join dbo.dbPosthutPiut b on b.Perkiraan=a.Perkiraan
     left Outer Join dbo.dbPerkiraan c on c.Perkiraan=b.Perkiraan
where a.KodeCustsupp=@KodeCustSupp and B.Kode=@TipeTrans

  Set @i=1
  Set @The_BP='' 
  Declare Mydata Cursor For
  select c.Keterangan+' ('+c.Perkiraan+')' NamaPerkiraan
  from dbo.dbPerkCustSupp  a
     left outer join dbo.dbPosthutPiut b on b.Perkiraan=a.Perkiraan
     left Outer Join dbo.dbPerkiraan c on c.Perkiraan=b.Perkiraan
  where a.KodeCustsupp=@KodeCustSupp and b.Kode=@TipeTrans

  open Mydata 
  Fetch next from mydata Into @NoBP
  While @@FETCH_STATUS=0
  begin
    if @Counter=@i 
       Set @The_BP=@The_BP+@noBP
    else 
       Set @The_BP=@The_BP+@noBP+CHAR(13)

    --Set @i=@i+1
    Fetch next from mydata Into @NoBP
    Set @i=@i+1
  end
  Close Mydata
  Deallocate mydata 	
  Return @The_BP
END



GO

-- Function: InvestasiSelesai
-- Type: SQL_SCALAR_FUNCTION
-- Created: 2025-07-10 17:59:14.813 | Modified: 2025-08-11 13:35:56.470
-- =====================================================



CREATE FUNCTION [dbo].[InvestasiSelesai] (@perkiraan varchar (100)) 
RETURNS datetime AS
BEGIN

declare @the_word varchar (100)
SELECT 
@the_word=    CONVERT(DATE, CAST(a.Tahun AS VARCHAR(4)) + '-' + RIGHT('0' + CAST(a.Bulan AS VARCHAR(2)), 2) + '-01') 
FROM DBINVESTASIDET a
left outer join DBINVESTASI b on b.Perkiraan =a.Perkiraan 
where Akhir =0 and (a.Perkiraan not like '1101000.%' or a.Perkiraan not like '1103010.%'  ) 
and a.Perkiraan =@perkiraan 
RETURN @the_word
END
   
GO

-- Function: JumlahPPIN
-- Type: SQL_SCALAR_FUNCTION
-- Created: 2024-02-05 22:10:10.907 | Modified: 2024-02-05 22:10:10.907
-- =====================================================
Create FUNCTION [dbo].[JumlahPPIN] (@bln int, @tahun int) 
RETURNS float AS
BEGIN
declare @the_word float
select @the_word=sum(spi) from DBINVESTASIDET where Bulan =@bln and Tahun =@tahun
RETURN @the_word
END

GO

-- Function: JumlahPPINSD
-- Type: SQL_SCALAR_FUNCTION
-- Created: 2025-05-21 11:53:30.620 | Modified: 2025-05-21 13:49:53.837
-- =====================================================
CREATE FUNCTION [dbo].[JumlahPPINSD] (@bln int, @awl int,@tahun int) 
RETURNS float AS
BEGIN
declare @the_word float
select @the_word=sum(spi) from DBINVESTASIDET where Bulan between 1  and @bln-1 and Tahun =@tahun
RETURN @the_word
END

GO

-- Function: NamaPerkiraanInduk
-- Type: SQL_SCALAR_FUNCTION
-- Created: 2016-05-21 09:36:03.897 | Modified: 2016-05-24 12:32:26.457
-- =====================================================


CREATE FUNCTION [dbo].[NamaPerkiraanInduk] (@perkiraan varchar(20)) 
RETURNS varchar(100) AS
BEGIN
--declare @the_word varchar (100), @perkiraaninduk varchar (100)
declare @the_word varchar (100), @perkiraaninduk varchar (100),@digit varchar (4)
select @digit = count (len(LEFT (@perkiraan,4 ))) from DBPERKIRAAN
where len (Perkiraan )=4 and Perkiraan like LEFT (@Perkiraan,4 )
/*set @perkiraaninduk=case when LEN (@perkiraan )	=10 then LEFT (@perkiraan,8) 
							  when LEN (@perkiraan )	=8 then LEFT (@perkiraan,6)
							  when LEN (@perkiraan )	=6 then
							  case when  @digit=0--count (len (left(@perkiraan,4)) )=1
							   THEN LEFT (@perkiraan ,2) +' .'
							  else LEFT (@perkiraan,4)  end 
							  -- LEFT (@perkiraan,4)
							  else @perkiraan end */
select @perkiraaninduk=case when LEN (@perkiraan )	=10 then LEFT (@perkiraan,8) 
							  when LEN (@perkiraan )	=8 then LEFT (@perkiraan,6)
							  when LEN (@perkiraan )	=6 then
							  case when  @digit=0--count (len (left(@perkiraan,4)) )=1
							   THEN null--LEFT (@perkiraan ,2) +' .'
							  else case when Tipe =1 and IsSubPerkiraan =0  then  null --perkiraan 
							  else  LEFT (@perkiraan,4) end
							   end 
							  -- LEFT (@perkiraan,4)
							  else @perkiraan end 
							  from DBPERKIRAAN where Perkiraan =@perkiraan							  
select @the_word=Keterangan    from DBPERKIRAAN where Perkiraan =@perkiraaninduk
RETURN @the_word
END


GO

-- Function: PANJumlahAsetNeto
-- Type: SQL_SCALAR_FUNCTION
-- Created: 2024-02-14 23:32:30.077 | Modified: 2024-03-31 15:48:33.923
-- =====================================================
CREATE FUNCTION [dbo].[PANJumlahAsetNeto] (@bln int, @tahun int,@devisi varchar (10)) 
RETURNS float AS
BEGIN
declare @the_word float
select @the_word =sum(AwalDRp) 
 from dbNeraca a
    left outer join DBPERKIRAAN b on b.Perkiraan=a.Perkiraan
    where Bulan=Case when @bln=1 then 12 else @bln-1 end 
    and 
    Tahun=Case when @bln=1 then @tahun-1 else @tahun end--a.Bulan=@bln and a.Tahun=@Tahun 
    and b.Perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('ASN')) and (devisi like @Devisi)
RETURN @the_word
END


GO

-- Function: PerkiraanInduk
-- Type: SQL_SCALAR_FUNCTION
-- Created: 2016-05-21 08:24:43.357 | Modified: 2016-05-24 12:28:11.250
-- =====================================================

CREATE FUNCTION [dbo].[PerkiraanInduk] (@perkiraan varchar(20)) 
RETURNS varchar(100) AS
BEGIN
declare @the_word varchar (100), @perkiraaninduk varchar (100),@digit varchar (4)
select @digit = count (len(LEFT (@perkiraan,4 ))) from DBPERKIRAAN
where len (Perkiraan )=4 and Perkiraan like LEFT (@Perkiraan,4 )
/*set @perkiraaninduk=case when LEN (@perkiraan )	=10 then LEFT (@perkiraan,8) 
							  when LEN (@perkiraan )	=8 then LEFT (@perkiraan,6)
							  when LEN (@perkiraan )	=6 then
							  case when  @digit=0--count (len (left(@perkiraan,4)) )=1
							   THEN null--LEFT (@perkiraan ,2) +' .'
							  else LEFT (@perkiraan,4)  end 
							  -- LEFT (@perkiraan,4)
							  else @perkiraan end   */
select @perkiraaninduk=case when LEN (@perkiraan )	=10 then LEFT (@perkiraan,8) 
							  when LEN (@perkiraan )	=8 then LEFT (@perkiraan,6)
							  when LEN (@perkiraan )	=6 then
							  case when  @digit=0--count (len (left(@perkiraan,4)) )=1
							   THEN null--LEFT (@perkiraan ,2) +' .'
							  else case when Tipe =1 and IsSubPerkiraan =0  then  null --perkiraan 
							  else  LEFT (@perkiraan,4) end
							   end 
							  -- LEFT (@perkiraan,4)
							  else @perkiraan end 
							  from DBPERKIRAAN where Perkiraan =@perkiraan
							  
select @the_word=Perkiraan   from DBPERKIRAAN where Perkiraan =@perkiraaninduk
RETURN @the_word
END

GO

-- Function: Qnt2Awal
-- Type: SQL_SCALAR_FUNCTION
-- Created: 2013-01-22 10:45:01.487 | Modified: 2013-01-26 10:03:54.890
-- =====================================================

CREATE FUNCTION [dbo].[Qnt2Awal] (@Kodebrg Varchar(30), @Kodegdg Varchar(15), @Bulan int, @Tahun int)
RETURNS Float
AS
BEGIN
  Declare @SaldoQnt Float
  Select @SaldoQnt=SUM(isnull(Saldo2Qnt,0)) 
  From dbStockAV
  where KODEBRG=@Kodebrg and BULAN=Case when @Bulan=1 then 12 else @Bulan-1 end  and TAHUN=Case when @bulan=1 then @Tahun-1 else @Tahun end and
        Kodegdg=@kodegdg
  Return isnull(@SaldoQnt,0)
END

GO

-- Function: Qnt2SPP
-- Type: SQL_SCALAR_FUNCTION
-- Created: 2013-01-22 10:41:13.927 | Modified: 2013-01-26 10:05:14.703
-- =====================================================

CREATE FUNCTION [dbo].[Qnt2SPP] (@Kodebrg Varchar(30), @Kodegdg Varchar(15),@Bulan int, @Tahun int)
RETURNS Float
AS
BEGIN
  Declare @SaldoQnt Float
  Select @SaldoQnt=SUM(isnull(QNT2,0)) 
  From dbSPP a
       left Outer join dbSPPDet b on b.NoBukti=a.NoBukti
  where month(a.tanggal)=@Bulan and YEAR(a.Tanggal)=@Tahun and b.KodeBrg=@Kodebrg and b.kodegdg=@Kodegdg 
  Return @SaldoQnt
END

GO

-- Function: QntAwal
-- Type: SQL_SCALAR_FUNCTION
-- Created: 2013-01-22 10:45:01.433 | Modified: 2013-01-26 10:04:36.123
-- =====================================================

CREATE FUNCTION [dbo].[QntAwal] (@Kodebrg Varchar(30), @Kodegdg Varchar(15), @Bulan int, @Tahun int)
RETURNS Float
AS
BEGIN
  Declare @SaldoQnt Float
  Select @SaldoQnt=SUM(isnull(SaldoQnt,0)) 
  From dbStockAV
  where KODEBRG=@Kodebrg and BULAN=Case when @Bulan=1 then 12 else @Bulan-1 end  and TAHUN=Case when @bulan=1 then @Tahun-1 else @Tahun end and
        Kodegdg=@Kodegdg
  Return isnull(@SaldoQnt,0)
END

GO

-- Function: QntSPP
-- Type: SQL_SCALAR_FUNCTION
-- Created: 2013-01-22 10:41:13.877 | Modified: 2013-01-26 10:05:04.650
-- =====================================================


CREATE FUNCTION [dbo].[QntSPP] (@Kodebrg Varchar(30), @Kodegdg Varchar(15), @Bulan int, @Tahun int)
RETURNS Float
AS
BEGIN
  Declare @SaldoQnt Float
  Select @SaldoQnt=SUM(isnull(Qnt,0)) 
  From dbSPP a
       left Outer join dbSPPDet b on b.NoBukti=a.NoBukti
  where month(a.tanggal)=@Bulan and YEAR(a.Tanggal)=@Tahun and b.KodeBrg=@Kodebrg and 
        b.kodegdg=@Kodegdg
  Return @SaldoQnt
END

GO

-- Function: Saldo2IN
-- Type: SQL_SCALAR_FUNCTION
-- Created: 2013-01-22 10:09:47.463 | Modified: 2013-01-26 10:05:39.370
-- =====================================================

-- =============================================
-- Author:		Noviyanto
-- Create date: 22 Januari 2013
-- Description:	Get Saldo Qnt In 2
-- =============================================
CREATE FUNCTION [dbo].[Saldo2IN] (@Kodebrg Varchar(30), @Kodegdg Varchar(15), @Bulan int, @Tahun int)
RETURNS Float
AS
BEGIN
  Declare @SaldoQnt Float
  Select @SaldoQnt=SUM(Isnull(Qnt2in,0)) From DBSTOCKBRG where KODEBRG=@Kodebrg and BULAN=@Bulan and TAHUN=@Tahun and
         KODEGDG=@Kodegdg
  Return @SaldoQnt
END

GO

-- Function: Saldo2Out
-- Type: SQL_SCALAR_FUNCTION
-- Created: 2013-01-22 10:09:47.467 | Modified: 2013-01-26 10:05:58.217
-- =====================================================


-- =============================================
-- Author:		Noviyanto
-- Create date: 22 Januari 2013
-- Description:	Get Saldo Qnt In 2
-- =============================================
CREATE FUNCTION [dbo].[Saldo2Out] (@Kodebrg Varchar(30), @Kodegdg Varchar(15), @Bulan int, @Tahun int)
RETURNS Float
AS
BEGIN
  Declare @SaldoQnt Float
  Select @SaldoQnt=SUM(isnull(Qnt2Out,0)-isnull(QNT2PNJ,0)) From DBSTOCKBRG where KODEBRG=@Kodebrg and BULAN=@Bulan and TAHUN=@Tahun and
         KODEGDG=@Kodegdg
  Return @SaldoQnt
END

GO

-- Function: Saldo2Qnt
-- Type: SQL_SCALAR_FUNCTION
-- Created: 2013-01-22 10:41:13.933 | Modified: 2013-01-26 10:06:19.033
-- =====================================================

CREATE FUNCTION [dbo].[Saldo2Qnt] (@Kodebrg Varchar(30), @Kodegdg Varchar(15), @Bulan int, @Tahun int)
RETURNS Float
AS
BEGIN
  Declare @SaldoQnt Float
  Select @SaldoQnt=SUM((isnull(Qnt2Awal,0)+isnull(Qnt2In,0))-(isnull(Qnt2Out,0)+isnull(Qnt2SPP,0))) 
  From dbStockAV
  where KODEBRG=@Kodebrg and BULAN=@Bulan and TAHUN=@Tahun and kodegdg=@Kodegdg
  Return @SaldoQnt
END

GO

-- Function: SaldoIN
-- Type: SQL_SCALAR_FUNCTION
-- Created: 2013-01-22 10:09:47.393 | Modified: 2013-01-26 10:06:32.757
-- =====================================================
-- =============================================
-- Author:		Noviyanto
-- Create date: 22 Januari 2013
-- Description:	Get Saldo Qnt In
-- =============================================
CREATE FUNCTION [dbo].[SaldoIN] (@Kodebrg Varchar(30), @Kodegdg Varchar(15), @Bulan int, @Tahun int)
RETURNS Float
AS
BEGIN
  Declare @SaldoQnt Float
  Select @SaldoQnt=SUM(isnull(Qntin,0)) From DBSTOCKBRG where KODEBRG=@Kodebrg and BULAN=@Bulan and TAHUN=@Tahun and KODEGDG=@Kodegdg
  Return @SaldoQnt
END

GO

-- Function: SaldoOut
-- Type: SQL_SCALAR_FUNCTION
-- Created: 2013-01-22 10:09:47.497 | Modified: 2013-01-26 10:06:51.623
-- =====================================================


-- =============================================
-- Author:		Noviyanto
-- Create date: 22 Januari 2013
-- Description:	Get Saldo Qnt In 2
-- =============================================
CREATE FUNCTION [dbo].[SaldoOut] (@Kodebrg Varchar(30), @Kodegdg Varchar(15), @Bulan int, @Tahun int)
RETURNS Float
AS
BEGIN
  Declare @SaldoQnt Float
  Select @SaldoQnt=SUM(isnull(QntOut,0)-isnull(QNTPNJ,0)) From DBSTOCKBRG where KODEBRG=@Kodebrg and BULAN=@Bulan and TAHUN=@Tahun and
         KODEGDG=@Kodegdg
  Return @SaldoQnt
END


GO

-- Function: SaldoQnt
-- Type: SQL_SCALAR_FUNCTION
-- Created: 2013-01-22 10:41:13.930 | Modified: 2013-01-26 10:07:07.627
-- =====================================================

CREATE FUNCTION [dbo].[SaldoQnt] (@Kodebrg Varchar(30), @Kodegdg Varchar(15), @Bulan int, @Tahun int)
RETURNS Float
AS
BEGIN
  Declare @SaldoQnt Float
  Select @SaldoQnt=SUM((isnull(QntAwal,0)+isnull(QntIn,0))-(isnull(QntOut,0)+isnull(QntSPP,0))) 
  From dbStockAV
  where KODEBRG=@Kodebrg and BULAN=@Bulan and TAHUN=@Tahun and Kodegdg=@Kodegdg
  Return @SaldoQnt
END

GO

-- Function: SclHitungNilaiX
-- Type: SQL_SCALAR_FUNCTION
-- Created: 2024-02-28 22:01:18.343 | Modified: 2024-08-08 13:50:32.020
-- =====================================================


CREATE FUNCTION [dbo].[SclHitungNilaiX] (@bln int, @tahun int,@devisi varchar (10)) 
RETURNS float AS
BEGIN
declare @the_word float
		select @the_word=SUM(AwalDRp )-SUM(AwalKRp )
		from DBNERACA a
		left outer join DBPERKIRAAN b on b.Perkiraan =a.Perkiraan 
		where Bulan =@bln and Tahun =@tahun  and b.Perkiraan <>'X' and isnull(IsNonLedger,0) =0
RETURN @the_word
END



GO

-- Function: terbilang
-- Type: SQL_SCALAR_FUNCTION
-- Created: 2013-02-04 09:52:13.057 | Modified: 2013-02-04 09:52:13.057
-- =====================================================

Create FUNCTION [dbo].[terbilang] (@the_amount money) 
RETURNS varchar(250) AS
BEGIN

DECLARE @divisor	bigint,
	@large_amount	money,
	@tiny_amount	money,
	@dividen	money,
	@dummy		money,
	@the_word	varchar(250),
	@weight	varchar(100),
	@unit		varchar(30),
	@follower	varchar(50),
	@prefix	varchar(10),
	@sufix		varchar(10)


SET @the_word = ''
SET @large_amount = FLOOR(ABS(@the_amount) )
SET @tiny_amount = ROUND((ABS(@the_amount) - @large_amount ) * 100.00,0)
SET @divisor = 1000000000000.00

IF @large_amount > @divisor * 1000.00
	RETURN 'OUT OF RANGE' 

WHILE @divisor >= 1
BEGIN	
	SET @dividen = FLOOR(@large_amount / @divisor)
	
	SET @large_amount = CONVERT(bigint,@large_amount) % @divisor
	
	SET @unit = ''
	IF @dividen > 0.00
		SET @unit=(CASE @divisor
			WHEN 1000000000000.00 THEN 'Trilliyun '
			WHEN 1000000000.00 THEN 'Milyar '			
			WHEN 1000000.00 THEN 'Juta '				
			WHEN 1000.00 THEN 'Ribu '
			ELSE @unit
		END )

	SET @weight = ''	
	SET @dummy = @dividen
	IF @dummy >= 100.00
		SET @weight = (CASE FLOOR(@dummy / 100.00)
			WHEN 1 THEN 'Se'
			WHEN 2 THEN 'Dua '
			WHEN 3 THEN 'Tiga '
			WHEN 4 THEN 'Empat '
			WHEN 5 THEN 'Lima '
			WHEN 6 THEN 'Enam '
			WHEN 7 THEN 'Tujuh '
			WHEN 8 THEN 'Delapan '
			ELSE 'Sembilan ' END ) + 'Ratus '

	SET @dummy = CONVERT(bigint,@dividen) % 100

	IF @dummy < 10.00
	BEGIN
		IF @dummy = 1.00 AND @unit = 'Ribu'
		BEGIN
			IF @dividen=@dummy
				SET @weight = @weight + 'Se'
			ELSE
				SET @weight = @weight + 'Satu '
		END
		ELSE
		IF @dummy > 0.00 
			SET @weight = @weight + (CASE @dummy
				WHEN 1 THEN 'Satu '
				WHEN 2 THEN 'Dua '
				WHEN 3 THEN 'Tiga '
				WHEN 4 THEN 'Empat '
				WHEN 5 THEN 'Lima '
				WHEN 6 THEN 'Enam '
				WHEN 7 THEN 'Tujuh '
				WHEN 8 THEN 'Delapan '
				ELSE 'Sembilan ' END)
	END
	ELSE
	IF @dummy BETWEEN 11 AND 19
		SET @weight = @weight + (CASE CONVERT(bigint,@dummy) % 10 
			WHEN 1 THEN 'Se'
			WHEN 2 THEN 'Dua '
			WHEN 3 THEN 'Tiga '
			WHEN 4 THEN 'Empat '
			WHEN 5 THEN 'Lima '
			WHEN 6 THEN 'Enam '
			WHEN 7 THEN 'Tujuh '
			WHEN 8 THEN 'Delapan '
			ELSE 'Sembilan ' END ) + 'Belas '
	ELSE
	BEGIN
		SET @weight = @weight + (CASE FLOOR(@dummy / 10) 
			WHEN 1 THEN 'Se'
			WHEN 2 THEN 'Dua '
			WHEN 3 THEN 'Tiga '
			WHEN 4 THEN 'Empat '
			WHEN 5 THEN 'Lima '
			WHEN 6 THEN 'Enam '
			WHEN 7 THEN 'Tujuh '
			WHEN 8 THEN 'Delapan '
			ELSE 'Sembilan ' END ) + 'Puluh '
		IF CONVERT(bigint,@dummy) % 10 > 0 
			SET @weight = @weight + (CASE CONVERT(bigint,@dummy) % 10 
				WHEN 1 THEN 'Satu '
				WHEN 2 THEN 'Dua '
				WHEN 3 THEN 'Tiga '
				WHEN 4 THEN 'Empat '
				WHEN 5 THEN 'Lima '
				WHEN 6 THEN 'Enam '
				WHEN 7 THEN 'Tujuh '
				WHEN 8 THEN 'Delapan '
				ELSE 'Sembilan ' END )
	END
	
	SET @the_word = @the_word + @weight + @unit
	SET @divisor = @divisor / 1000.00
END

IF FLOOR(@the_amount) = 0.00 
	SET @the_word = 'Nol '

SET @follower = ''
IF @tiny_amount < 10.00
BEGIN	
	IF @tiny_amount > 0.00 
		SET @follower = 'Koma Nol ' + (CASE @tiny_amount
			WHEN 1 THEN 'Satu '
			WHEN 2 THEN 'Dua '
			WHEN 3 THEN 'Tiga '
			WHEN 4 THEN 'Empat '
			WHEN 5 THEN 'Lima '
			WHEN 6 THEN 'Enam '
			WHEN 7 THEN 'Tujuh '
			WHEN 8 THEN 'Delapan '
			ELSE 'Sembilan ' END)
END
ELSE
BEGIN
	SET @follower = 'Koma ' + (CASE FLOOR(@tiny_amount / 10.00)
			WHEN 1 THEN 'Satu '
			WHEN 2 THEN 'Dua '
			WHEN 3 THEN 'Tiga '
			WHEN 4 THEN 'Empat '
			WHEN 5 THEN 'Lima '
			WHEN 6 THEN 'Enam '
			WHEN 7 THEN 'Tujuh '
			WHEN 8 THEN 'Delapan '
			ELSE 'Sembilan ' END)
	IF CONVERT(bigint,@tiny_amount) % 10 > 0 
		SET @follower = @follower + (CASE CONVERT(bigint,@tiny_amount) % 10
			WHEN 1 THEN 'Satu '
			WHEN 2 THEN 'Dua '
			WHEN 3 THEN 'Tiga '
			WHEN 4 THEN 'Empat '
			WHEN 5 THEN 'Lima '
			WHEN 6 THEN 'Enam '
			WHEN 7 THEN 'Tujuh '
			WHEN 8 THEN 'Delapan '
			ELSE 'Sembilan ' END)
END 
	
SET @the_word = @the_word + @follower

IF @the_amount < 0.00
	SET @the_word = 'Minus ' + @the_word
	
RETURN @the_word
END

GO

-- Function: JumlahAsetNeto
-- Type: SQL_INLINE_TABLE_VALUED_FUNCTION
-- Created: 2024-02-12 19:21:56.200 | Modified: 2024-08-07 17:01:46.203
-- =====================================================
  
     
CREATE function [dbo].[JumlahAsetNeto]
(
@bulan int ,@tahun int, @divisi varchar (15)
)
returns table as return
(
/*select z.Devisi ,z.Keterangan,z.PerkiraanG,z.asetneto,z.nilaiBulanini bulanini  from 
(
select 
Keterangan ,
case when (b.GroupPerkiraan is null OR GroupPerkiraan ='') and b.IsInvestasi=0  then  b.Perkiraan   else GroupPerkiraan  end PerkiraanG,
case when (b.GroupPerkiraan is null OR GroupPerkiraan ='') and b.IsInvestasi=0  then  a.AkhirKRp-a.AkhirDRp   else 0   end nilaiBulanini,
0 asetneto,Devisi 
from DBNERACA  a
     left outer join DBPERKIRAAN  b on b.Perkiraan=a.Perkiraan 
     
     where  
     Bulan =@bulan  and Tahun=@tahun and  a.Devisi like @divisi and IsNonLedger =0 
    -- )x where PerkiraanG <>'140000001'
union all 
 select Keterangan,GroupPerkiraan  ,0,SUM(AwalDRp )nilaiNeto,a.Devisi  from DBNERACA a
     left outer join DBPERKIRAAN b on b.Perkiraan =a.Perkiraan
     where IsInvestasi =1 and Bulan =@bulan and Tahun =@tahun 
     group by b.GroupPerkiraan  ,Keterangan,Devisi  
     --) c on c.Perkiraan =a.Perkiraan  
 ) z 
 left outer join DBPERKIRAAN b on b.Perkiraan =z.PerkiraanG 
 )*/
 select PerkiraanG , Devisi ,--max (case when nilaiBulanini =0 and nilaineto =0 then nilaineto  else nilaiBulanini end)bulanini  
--max(nilaiBulanini)nilaibulanini ,max (nilaineto)neto 
max(case when nilaiBulanini=0 then nilaineto else nilaiBulanini end )nilaibulanini --,max (nilaineto)neto 
from
(
select 
Keterangan ,
case when (b.GroupPerkiraan is null OR GroupPerkiraan ='') and isnull(b.IsInvestasi,0)=0  then  b.Perkiraan   else GroupPerkiraan  end PerkiraanG,
case when (b.GroupPerkiraan is null OR GroupPerkiraan ='') and isnull(b.IsInvestasi,0)=0 and b.DK =0 then  a.AkhirDRp - a.AkhirKRp --a.AkhirKRp-a.AkhirDRp 
else -1*a.AkhirKRp-a.AkhirDRp--a.AkhirKRp -a.AkhirDRp  
end nilaiBulanini,
0 nilaineto,Devisi 
from DBNERACA  a
     left outer join DBPERKIRAAN  b on b.Perkiraan=a.Perkiraan 
     
     where  
     Bulan =@bulan  and Tahun=@tahun and  a.Devisi like @divisi and isnull(IsNonLedger,0) =0 and isnull(IsInvestasi,0) =0
    -- )x where PerkiraanG <>'140000001'
union --all 
 select Keterangan,GroupPerkiraan  ,0  nilaiBulanini,SUM(AwalDRp )nilaiNeto,a.Devisi  from DBNERACA a
     left outer join DBPERKIRAAN b on b.Perkiraan =a.Perkiraan
     where isnull(IsInvestasi,0) =1 and Bulan =@bulan and Tahun =@tahun and isnull(IsNonLedger,0) =1
     group by b.GroupPerkiraan  ,Keterangan,Devisi 
     )x
     group by x.PerkiraanG ,nilaiBulanini,Devisi 
     
)
GO

-- Function: JumlahInvestasi
-- Type: SQL_INLINE_TABLE_VALUED_FUNCTION
-- Created: 2024-02-06 07:30:07.457 | Modified: 2024-02-06 07:30:07.457
-- =====================================================


     
     
Create function [dbo].[JumlahInvestasi]
(
@bln int ,@tahun int
)
returns table as return
(
select bulan,tahun,sum(spi)ppin,SUM(AkhirPasar )spiblnini,SUM(sk)spiblnlalu,SUM(sd)pasarblnini,
SUM(AwalPasar ) pasarblnlalu,SUM(Akhir ) perolehanblnini 
from DBINVESTASIDET where Bulan =@bln and Tahun =@tahun
group by bulan,tahun
)


GO

-- Function: SaldoAkhirTabunganInvestasi
-- Type: SQL_INLINE_TABLE_VALUED_FUNCTION
-- Created: 2024-03-13 13:28:03.390 | Modified: 2024-03-13 13:28:03.390
-- =====================================================
   
Create function [dbo].[SaldoAkhirTabunganInvestasi]
(
@bln int ,@tahun int
)
returns table as return
(
select bulan,tahun, SUM(AwalDRp) awaltabungan,SUM(AkhirDRp) akhirtabungan
from DBNERACA  where Bulan =@bln and Tahun =@tahun and LEN (Perkiraan )=8
group by bulan,tahun
)



GO

-- Function: TblHitungNilaiX
-- Type: SQL_INLINE_TABLE_VALUED_FUNCTION
-- Created: 2024-02-28 21:59:48.607 | Modified: 2024-02-28 21:59:48.607
-- =====================================================

   
Create function [dbo].[TblHitungNilaiX]
(
@bln int ,@tahun int
)
returns table as return
(
select SUM(AwalDRp )awaldx,SUM(AwalKRp  )awalkx,SUM(AwalDRp )-SUM(AwalKRp )NilaiX from DBNERACA a
left outer join DBPERKIRAAN b on b.Perkiraan =a.Perkiraan 
where Bulan =@bln and Tahun =@tahun  and b.Perkiraan <>'X' and IsNonLedger =0
)


GO

-- Function: TblLapArusKas
-- Type: SQL_INLINE_TABLE_VALUED_FUNCTION
-- Created: 2024-09-10 16:22:32.683 | Modified: 2025-06-19 13:49:11.470
-- =====================================================

CREATE function [dbo].[TblLapArusKas]
(
@bulan int ,@tahun int,@Devisi Varchar(15)
)
returns table as return
(
 
     select KodeAK,KodeSAK,Bulan,Tahun,Devisi  ,sum(Nilai) Nilai from (    
	    select --'A' Tanda,
	    a.KodeAK,a.KodeSAK,b.Bulan,b.Tahun,Devisi,JnsTransInvestasi ,sum(b.Nilai) Nilai from DBPERKIRAAN a
       left outer join 
       (
     select (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK','IVT'))) 
        then  a.Lawan
	          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK','IVT'))) then --'2901'
	          a.Perkiraan
		end) Perkiraan,month(t.tanggal) Bulan, year(t.tanggal) Tahun,
	    (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK','IVT'))) and debet<>0 then debet*a.kurs
		          when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK','IVT')))  and kredit<>0 then 0
		          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK','IVT')))  and debet<>0 then 0
		          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK','IVT')))  and kredit<>0 then kredit*a.kurs end
	        	) -
	    (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK','IVT'))) and debet<>0 then 0
		            when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK','IVT'))) and kredit<>0 then Kredit*a.kurs
		            when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK','IVT'))) and debet<>0 then Debet*a.kurs
		            when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK','IVT'))) and kredit<>0 then 0 end) as Nilai,
		            kodecost,t.Devisi ,JnsTransInvestasi
		from dbTrans t 
               left outer join dbtransaksi a on t.NoBukti=a.NoBukti
		     left outer join DBPERKIRAAN b on b.Perkiraan=a.Perkiraan
		     left outer join DBPERKIRAAN c on c.Perkiraan=a.Lawan	
		where (month(t.tanggal)=@bulan and year(t.tanggal)=@Tahun) 
		--and (a.Devisi like @Devisi) --and isnull(ispasang,0)=0--and (a.Perkiraan ='2901' or a.Lawan  ='2901' )
		and (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK','IVT'))) or 
		(a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK','IVT')) )
	   ) B on b.Perkiraan=a.Perkiraan
	   where b.Perkiraan is not null and KodeSAK not in ('SAK05','SAK06')
	   and  devisi like @devisi and ISNULL (JnsTransInvestasi,0) <>3
	   group by a.KodeAK,a.KodeSAK,b.Bulan,b.Tahun,devisi,JnsTransInvestasi-- ,a.Perkiraan
  -- hutang piutang inves
       union all
	    select --'B' Tanda,
	    'AK01','SAK05+',b.Bulan,b.Tahun,Devisi,0  ,sum(b.Nilai) Nilai from DBPERKIRAAN a
 	    left outer join 
 	    ( 	    
select (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) 
                    then  a.Lawan
	                when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) then --'2901'
	          a.Perkiraan
		end) Perkiraan,month(t.tanggal) Bulan, year(t.tanggal) Tahun,
		    (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then debet*a.kurs
		          when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and kredit<>0 then 0
		          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and debet<>0 then 0
		          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and kredit<>0 then kredit*a.kurs end
	        	) -
	    (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then 0
		            when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and kredit<>0 then Kredit*a.kurs
		            when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then Debet*a.kurs
		            when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and kredit<>0 then 0 end) as Nilai,
		t.Devisi ,t.TipeTransHd
		     from dbTrans t 
		     left outer join dbtransaksi a on t.NoBukti=a.NoBukti
		     left outer join DBPERKIRAAN b on b.Perkiraan=a.Perkiraan
		     left outer join DBPERKIRAAN c on c.Perkiraan=a.Lawan	
		     where (month(t.tanggal)=@bulan and year(t.tanggal)=@tahun) and  
		    (  (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) or 
		(a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')) ))
		--and KODECOST <>'' 
		and tipetranshd <>'BMM' -- and a.NoBukti like '%41%'
		)
		 	    
 	    B on b.Perkiraan=a.Perkiraan
 	    where KodeSAK in ('SAK06')
 	    group by Bulan ,Tahun ,Devisi,a.Keterangan --,a.Perkiraan 		
 	    
       union all
	    select --'C'Tanda,
	    'AK01','SAK05-',b.Bulan,b.Tahun,Devisi,0,sum(b.Nilai) Nilai from DBPERKIRAAN a
 	    left outer join 
 	    ( 	    
select (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) 
                    then  a.Lawan
	                when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) then --'2901'
	          a.Perkiraan
		end) Perkiraan,month(t.tanggal) Bulan, year(t.tanggal) Tahun,
		    (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then debet*a.kurs
		          when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and kredit<>0 then 0
		          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and debet<>0 then 0
		          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and kredit<>0 then kredit*a.kurs end
	        	) -
	    (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then 0
		            when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and kredit<>0 then Kredit*a.kurs
		            when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then Debet*a.kurs
		            when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and kredit<>0 then 0 end) as Nilai,
		t.Devisi ,t.TipeTransHd
		     from dbTrans t 
		     left outer join dbtransaksi a on t.NoBukti=a.NoBukti
		     left outer join DBPERKIRAAN b on b.Perkiraan=a.Perkiraan
		     left outer join DBPERKIRAAN c on c.Perkiraan=a.Lawan	
		     where (month(t.tanggal)=@bulan and year(t.tanggal)=@tahun) and  
		    (  (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) or 
		(a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')) ))
		--and KODECOST <>'' 
		and tipetranshd <>'BMM' -- and a.NoBukti like '%41%'
		)
		 	    
 	    B on b.Perkiraan=a.Perkiraan
 	    where KodeSAK in ('SAK05') and b.Bulan is not null 
 	    and  	     (  (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode not in ('IVT'))) )
 	    group by Bulan ,Tahun ,Devisi ,a.Perkiraan,a.Keterangan  --,b.Perkiraan 	 	           

       union all
	    select --'D'Tanda,
	    'AK01','SAK05-',b.Bulan,b.Tahun,Devisi,0,sum(b.Nilai) Nilai from DBPERKIRAAN a
 	    left outer join 
 	    ( 	    
select (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) 
                    then  a.Lawan
	                when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) then --'2901'
	          a.Perkiraan
		end) Perkiraan,month(t.tanggal) Bulan, year(t.tanggal) Tahun,
		    (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then debet*a.kurs
		          when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and kredit<>0 then 0
		          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and debet<>0 then 0
		          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and kredit<>0 then kredit*a.kurs end
	        	) -
	    (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then 0
		            when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and kredit<>0 then Kredit*a.kurs
		            when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then Debet*a.kurs
		            when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and kredit<>0 then 0 end) as Nilai,
		t.Devisi ,t.TipeTransHd
		     from dbTrans t 
		     left outer join dbtransaksi a on t.NoBukti=a.NoBukti
		     left outer join DBPERKIRAAN b on b.Perkiraan=a.Perkiraan
		     left outer join DBPERKIRAAN c on c.Perkiraan=a.Lawan	
		     where (month(t.tanggal)=@bulan and year(t.tanggal)=@tahun) and  
		    (  (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) or 
		(a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')) ))
		--and KODECOST <>'' 
		and tipetranshd <>'BMM' -- and a.NoBukti like '%41%'
		)
		 	    
 	    B on b.Perkiraan=a.Perkiraan
 	    where KodeSAK in ('SAK05') and b.Bulan is not null 
 	    and  	     (  (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode  in ('IVT'))) )
 	    and a.Perkiraan not like '1103010' 
 	    group by Bulan ,Tahun ,Devisi ,a.Perkiraan,a.Keterangan  --,b.Perkiraan 	 	           

       
      union all
	    select --'D1'Tanda,
	    'AK01','SAK05-',b.Bulan,b.Tahun,Devisi,0,sum(b.Nilai) Nilai from DBPERKIRAAN a
 	    left outer join 
 	    ( 	    
select (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) 
                    then  a.Lawan
	                when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) then --'2901'
	          a.Perkiraan
		end) Perkiraan,month(t.tanggal) Bulan, year(t.tanggal) Tahun,
		    (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then debet*a.kurs
		          when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and kredit<>0 then 0
		          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and debet<>0 then 0
		          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and kredit<>0 then kredit*a.kurs end
	        	) -
	    (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then 0
		            when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and kredit<>0 then Kredit*a.kurs
		            when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then Debet*a.kurs
		            when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and kredit<>0 then 0 end) as Nilai,
		t.Devisi ,t.TipeTransHd
		     from dbTrans t 
		     left outer join dbtransaksi a on t.NoBukti=a.NoBukti
		     left outer join DBPERKIRAAN b on b.Perkiraan=a.Perkiraan
		     left outer join DBPERKIRAAN c on c.Perkiraan=a.Lawan	
		     where (month(t.tanggal)=@bulan and year(t.tanggal)=@tahun) and  
		    (  (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) 
		    --or (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')) )
		)
		--and KODECOST <>'' 
		and tipetranshd <>'BMM' -- and a.NoBukti like '%41%'
		)
		 	    
 	    B on b.Perkiraan=a.Perkiraan
 	    where KodeSAK in ('SAK05') and b.Bulan is not null 
 	    and  	     (  (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode  in ('IVT'))) )
 	    and a.Perkiraan  like '1103010' 
 	    group by Bulan ,Tahun ,Devisi ,a.Perkiraan,a.Keterangan  	 	           

       union all
	    select --'D2'Tanda,
	    'AK01','SAK05+',b.Bulan,b.Tahun,Devisi,0,sum(b.Nilai) Nilai from DBPERKIRAAN a
 	    left outer join 
 	    ( 	    
select (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) 
                    then  a.Lawan
	                when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) then --'2901'
	          a.Perkiraan
		end) Perkiraan,month(t.tanggal) Bulan, year(t.tanggal) Tahun,
		    (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then debet*a.kurs
		          when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and kredit<>0 then 0
		          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and debet<>0 then 0
		          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and kredit<>0 then kredit*a.kurs end
	        	) -
	    (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then 0
		            when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and kredit<>0 then Kredit*a.kurs
		            when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then Debet*a.kurs
		            when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and kredit<>0 then 0 end) as Nilai,
		t.Devisi ,t.TipeTransHd
		     from dbTrans t 
		     left outer join dbtransaksi a on t.NoBukti=a.NoBukti
		     left outer join DBPERKIRAAN b on b.Perkiraan=a.Perkiraan
		     left outer join DBPERKIRAAN c on c.Perkiraan=a.Lawan	
		     where (month(t.tanggal)=@bulan and year(t.tanggal)=@tahun) and  
		    ( -- (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) or 
		(a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')) ))
		--and KODECOST <>'' 
		and tipetranshd <>'BMM' -- and a.NoBukti like '%41%'
		)
		 	    
 	    B on b.Perkiraan=a.Perkiraan
 	    where KodeSAK in ('SAK05') and b.Bulan is not null 
 	    and  	     (  (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode  in ('IVT'))) )
 	    and a.Perkiraan  like '1103010' 
 	    group by Bulan ,Tahun ,Devisi ,a.Perkiraan,a.Keterangan -- ,b.Perkiraan 	 	           


--tabungan	   	   
	   union 
	   	   select --'F' Tanda,
	   	   'AK01','SAK05+',@bulan ,@Tahun ,@Devisi,0, SUM(-1*(sd-awalpasar))/* -1*SPI  */ from DBINVESTASIDET 
	   where Perkiraan like '1101000%' and Bulan=@bulan and Tahun =@Tahun 
	   --case when sum(SD)>sum(AwalPasar) then -1*sum(SD-AwalPasar ) else -1*sum(SD-AwalPasar ) end
	   having sum(SD)>sum(AwalPasar)   	     	           
	   union 
	   	   select --'F' Tanda,
	   	   'AK01','SAK05-',@bulan ,@Tahun ,@Devisi,0, SUM(-1*(sd-awalpasar))/* -1*SPI  */ from DBINVESTASIDET 
	   where Perkiraan like '1101000%' and Bulan=@bulan and Tahun =@Tahun  	     	           
       having sum(SD)<sum(AwalPasar)   

      union all
	    select --'G' Tanda,
	    'AK02',KodeSAK+'+',b.Bulan,b.Tahun,Devisi,0,sum(b.Nilai) Nilai from DBPERKIRAAN a
 	    left outer join 
 	    ( 	    
select (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) 
                    then  a.Lawan
	                when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) then --'2901'
	          a.Perkiraan
		end) Perkiraan,month(t.tanggal) Bulan, year(t.tanggal) Tahun,
		    (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then debet*a.kurs
		          when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and kredit<>0 then 0
		          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and debet<>0 then 0
		          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and kredit<>0 then kredit*a.kurs end
	        	) -
	    (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then 0
		            when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and kredit<>0 then Kredit*a.kurs
		            when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then Debet*a.kurs
		            when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and kredit<>0 then 0 end) as Nilai,
		t.Devisi ,t.TipeTransHd
		     from dbTrans t 
		     left outer join dbtransaksi a on t.NoBukti=a.NoBukti
		     left outer join DBPERKIRAAN b on b.Perkiraan=a.Perkiraan
		     left outer join DBPERKIRAAN c on c.Perkiraan=a.Lawan	
		     where (month(t.tanggal)=@bulan and year(t.tanggal)=@tahun) and  
		    (  (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) 
		    --or (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')) )
		)
		--and KODECOST <>'' 
		and tipetranshd <>'BMM' -- and a.NoBukti like '%41%'
		)
		 	    
 	    B on b.Perkiraan=a.Perkiraan
 	    where KodeSAK in ('SAK09','SAK10','SAK11','SAK12') and b.Bulan is not null 
 	    /*and  	     (  (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode  in ('IVT'))) )
 	    and a.Perkiraan  like '1103010'*/ 
 	    group by Bulan ,Tahun ,Devisi ,a.Perkiraan,a.Keterangan,a.KodeSAK  	 	           

       union all
	    select --'G1'Tanda,
	    'AK02',KodeSAK+'-',b.Bulan,b.Tahun,Devisi,0,sum(b.Nilai) Nilai from DBPERKIRAAN a
 	    left outer join 
 	    ( 	    
select (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) 
                    then  a.Lawan
	                when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) then --'2901'
	          a.Perkiraan
		end) Perkiraan,month(t.tanggal) Bulan, year(t.tanggal) Tahun,
		    (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then debet*a.kurs
		          when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and kredit<>0 then 0
		          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and debet<>0 then 0
		          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and kredit<>0 then kredit*a.kurs end
	        	) -
	    (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then 0
		            when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and kredit<>0 then Kredit*a.kurs
		            when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then Debet*a.kurs
		            when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and kredit<>0 then 0 end) as Nilai,
		t.Devisi ,t.TipeTransHd
		     from dbTrans t 
		     left outer join dbtransaksi a on t.NoBukti=a.NoBukti
		     left outer join DBPERKIRAAN b on b.Perkiraan=a.Perkiraan
		     left outer join DBPERKIRAAN c on c.Perkiraan=a.Lawan	
		     where (month(t.tanggal)=@bulan and year(t.tanggal)=@tahun) and  
		    ( -- (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) or 
		(a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')) ))
		--and KODECOST <>'' 
		and tipetranshd <>'BMM' -- and a.NoBukti like '%41%'
		)
		 	    
 	    B on b.Perkiraan=a.Perkiraan
 	    where KodeSAK in ('SAK09','SAK10','SAK11','SAK12') and b.Bulan is not null 
 	    /*and  	     (  (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode  in ('IVT'))) )
 	    and a.Perkiraan  like '1103010' */
 	    group by Bulan ,Tahun ,Devisi ,a.Perkiraan,a.Keterangan,a.KodeSAK  -- ,b.Perkiraan 	 	           
---perpindahan investasi tabungan ke tabungan biaya
      union all
	    select --'H1'Tanda,
	    'AK01','SAK05-',b.Bulan,b.Tahun,Devisi,0,sum(b.Nilai) Nilai from DBPERKIRAAN a
 	    left outer join 
 	    ( 	    
select (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) 
                    then  a.Lawan
	                when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) then --'2901'
	          a.Perkiraan
		end) Perkiraan,month(t.tanggal) Bulan, year(t.tanggal) Tahun,
		    (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then debet*a.kurs
		          when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and kredit<>0 then 0
		          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and debet<>0 then 0
		          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and kredit<>0 then kredit*a.kurs end
	        	) -
	    (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then 0
		            when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and kredit<>0 then Kredit*a.kurs
		            when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then Debet*a.kurs
		            when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and kredit<>0 then 0 end) as Nilai,
		t.Devisi ,t.TipeTransHd
		     from dbTrans t 
		     left outer join dbtransaksi a on t.NoBukti=a.NoBukti
		     left outer join DBPERKIRAAN b on b.Perkiraan=a.Perkiraan
		     left outer join DBPERKIRAAN c on c.Perkiraan=a.Lawan	
		     where (month(t.tanggal)=@bulan and year(t.tanggal)=@tahun) and  
		    (  (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) 
		    --or (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')) )
		)
		--and KODECOST <>'' 
		and tipetranshd <>'BMM' -- and a.NoBukti like '%41%'
		and a.JnsTransInvestasi=1
		)
		 	    
 	    B on b.Perkiraan=a.Perkiraan
 	    where --KodeSAK in ('SAK05') and 
 	    b.Bulan is not null 
 	    and  	    -- (  (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode  in ('IVT'))) )
 	    --and (a.Perkiraan  like '1103010' or  (a.GroupPerkiraan  like '1101000' and IsNonLedger=0 and IsInvestasi =0))
 	     (a.GroupPerkiraan  like '1101000' --and IsNonLedger=0 and IsInvestasi =0
 	    )
 	    group by Bulan ,Tahun ,Devisi ,a.Perkiraan,a.Keterangan  	 	           

       union all
	    select --'H2'Tanda,
	    'AK01','SAK05+',b.Bulan,b.Tahun,Devisi,0,sum(b.Nilai) Nilai from DBPERKIRAAN a
 	    left outer join 
 	    ( 	    
select (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) 
                    then  a.Lawan
	                when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) then --'2901'
	          a.Perkiraan
		end) Perkiraan,month(t.tanggal) Bulan, year(t.tanggal) Tahun,
		    (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then debet*a.kurs
		          when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and kredit<>0 then 0
		          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and debet<>0 then 0
		          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and kredit<>0 then kredit*a.kurs end
	        	) -
	    (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then 0
		            when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and kredit<>0 then Kredit*a.kurs
		            when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then Debet*a.kurs
		            when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and kredit<>0 then 0 end) as Nilai,
		t.Devisi ,t.TipeTransHd
		     from dbTrans t 
		     left outer join dbtransaksi a on t.NoBukti=a.NoBukti
		     left outer join DBPERKIRAAN b on b.Perkiraan=a.Perkiraan
		     left outer join DBPERKIRAAN c on c.Perkiraan=a.Lawan	
		     where (month(t.tanggal)=@bulan and year(t.tanggal)=@tahun) and  
		    ( -- (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) or 
		(a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')) ))
		--and KODECOST <>'' 
		and tipetranshd <>'BMM' -- and a.NoBukti like '%41%'
		and JnsTransInvestasi =2
		)
		 	    
 	    B on b.Perkiraan=a.Perkiraan
 	    where --KodeSAK in ('SAK05') and 
 	    b.Bulan is not null 
 	    and  	--     (  (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode  in ('IVT'))) )
 	   -- and (a.Perkiraan  like '1103010'  or (a.GroupPerkiraan  like '1101000' and IsNonLedger=0 and IsInvestasi =0))
 	    (a.GroupPerkiraan  like '1101000' --and IsNonLedger=0 and IsInvestasi =0
 	    )
 	    group by Bulan ,Tahun ,Devisi ,a.Perkiraan,a.Keterangan -- ,b.Perkiraan 	 

	) Z 
	where Bulan =@bulan and Tahun =@tahun
	group by KodeAK,KodeSAK,Bulan,Tahun  ,devisi   


)

GO

-- Function: TblLapArusKasDetail
-- Type: SQL_INLINE_TABLE_VALUED_FUNCTION
-- Created: 2024-07-03 19:57:04.993 | Modified: 2024-07-03 19:57:04.993
-- =====================================================


CREATE function [dbo].[TblLapArusKasDetail]
(
@bulan int ,@tahun int,@Devisi Varchar(15)
)
returns table as return
(
--Set @Devisi=Case when @Devisi in ('-','') then '%' else @Devisi end;
select * from
(
     select a.KodeAK,a.KodeSAK,c.Keterangan ketsak,b.Bulan,b.Tahun,Devisi, a.Perkiraan,a.Keterangan,Urutan   
	    ,sum(cast (b.Nilai as numeric(18,0))) Nilai,a.Keterangan ketperkiraan 
	    from DBPERKIRAAN a
       left outer join 
       (
     select (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK','IVT'))) 
        then  a.Lawan
	          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK','IVT'))) then --'2901'
	          a.Perkiraan
		end) Perkiraan,month(t.tanggal) Bulan, year(t.tanggal) Tahun,
	    (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK','IVT'))) and debet<>0 then debet*a.kurs
		          when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK','IVT')))  and kredit<>0 then 0
		          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK','IVT')))  and debet<>0 then 0
		          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK','IVT')))  and kredit<>0 then kredit*a.kurs end
	        	) -
	    (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK','IVT'))) and debet<>0 then 0
		            when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK','IVT'))) and kredit<>0 then Kredit*a.kurs
		            when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK','IVT'))) and debet<>0 then Debet*a.kurs
		            when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK','IVT'))) and kredit<>0 then 0 end) as Nilai,
		            kodecost,t.Devisi ,JnsTransInvestasi
		from dbTrans t 
               left outer join dbtransaksi a on t.NoBukti=a.NoBukti
		     left outer join DBPERKIRAAN b on b.Perkiraan=a.Perkiraan
		     left outer join DBPERKIRAAN c on c.Perkiraan=a.Lawan	
		where (month(t.tanggal)=@bulan and year(t.tanggal)=@Tahun) 
		--and (a.Devisi like @Devisi) --and isnull(ispasang,0)=0--and (a.Perkiraan ='2901' or a.Lawan  ='2901' )
		and (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK','IVT'))) or 
		(a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK','IVT')) )
	   ) B on b.Perkiraan=a.Perkiraan
	   left outer join DBArusKasKonfig c on  c.KodeAK=a.KodeAK and c.KodeSAK=a.KodeSAK 
	   where b.Perkiraan is not null and a.KodeSAK<>'SAK05'
	   and  devisi like @devisi and Tahun =@Tahun and Bulan =@bulan and ISNULL (JnsTransInvestasi,0) <>3
	   group by a.KodeAK,a.KodeSAK,b.Bulan,b.Tahun,devisi,a.Perkiraan ,a.Keterangan ,Urutan,c.Keterangan 
	   
 	    union all
 	   select 'AK01' kodeak,'SAK05+' kodesak,c.Keterangan ketsak,b.Bulan,b.Tahun,Devisi , a.Perkiraan,a.Keterangan,Urutan ,
 	   sum(b.Nilai) Nilai ,a.Keterangan 
 	   from DBPERKIRAAN a
       left outer join 
       (
       
       select (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('IVT'))) then a.Perkiraan 
	          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('IVT'))) then a.Lawan 
		end) Perkiraan,month(t.tanggal) Bulan, year(t.tanggal) Tahun,
		(case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('IVT'))) and debet<>0 then -1*debet*a.kurs
		when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('IVT')))  and kredit<>0 then 0
		when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('IVT')))  and debet<>0 then 0--debet*a.kurs
		when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('IVT')))  and kredit<>0 then kredit*a.kurs end
	    )
		   		            as Nilai,   t.Devisi ,t.TipeTransHd
		from dbTrans t 
               left outer join dbtransaksi a on t.NoBukti=a.NoBukti
		     left outer join DBPERKIRAAN b on b.Perkiraan=a.Perkiraan
		     left outer join DBPERKIRAAN c on c.Perkiraan=a.Lawan	
		where (month(t.tanggal)=@bulan and year(t.tanggal)=@Tahun) and 
		(a.Devisi like @Devisi)
		and (a.Perkiraan in (select Perkiraan  from DBPOSTHUTPIUT where kode='IVT')  or Lawan
in  (select Perkiraan  from DBPOSTHUTPIUT where kode='IVT') )
	   ) B on b.Perkiraan=a.Perkiraan
	   left outer join DBArusKasKonfig c on  c.KodeAK=c.KodeAK and c.KodeSAK=a.KodeSAK 
	   where b.Perkiraan is not null and a.KodeSAK='SAK05' and tipetranshd <>'BMM'
	   group by b.Bulan,b.Tahun,Devisi, a.Perkiraan,a.Keterangan,Urutan,c.Keterangan   --,a.KodeAK,a.KodeSAK
	   union
	   select 'AK01' kodeak,'SAK05+' kodesak,'Tabungan' ketsak,@bulan ,@Tahun ,@Devisi  , c .Perkiraan, 
	   c.Keterangan,'1' Urutan ,SUM(-1*(sd-awalpasar) ) Nilai,''   	   

   	   from DBINVESTASIDET a 
   	   left outer join DBINVESTASI b on b.Perkiraan =a.Perkiraan  
   	   LEFT outer join DBPERKIRAAN c on c.Perkiraan =b.GroupInvestasi   
	   where a.Perkiraan like '11020000%' and Bulan=@bulan and Tahun =@Tahun 
	   group by c.Perkiraan ,c.Keterangan 

 	    union all
 	   
 	   select 'AK01' kodeak,'SAK05-' kodesak,'Saham' ketsak,b.Bulan,b.Tahun,Devisi , a.Perkiraan,a.Keterangan,Urutan ,
 	   sum(b.Nilai) Nilai ,a.Keterangan 
 	   from DBPERKIRAAN a
       left outer join 
       (
       
       select (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('IVT'))) then a.Perkiraan 
	          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('IVT'))) then a.Lawan 
		end) Perkiraan,month(t.tanggal) Bulan, year(t.tanggal) Tahun,
        (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('IVT'))) and debet<>0 then 0---1*debet*a.kurs
		when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('IVT')))  and kredit<>0 then 0
		when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('IVT')))  and debet<>0 then debet*a.kurs
		when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('IVT')))  and kredit<>0 then kredit*a.kurs end
	    )		   		            as Nilai,   t.Devisi ,t.TipeTransHd
		from dbTrans t 
               left outer join dbtransaksi a on t.NoBukti=a.NoBukti
		     left outer join DBPERKIRAAN b on b.Perkiraan=a.Perkiraan
		     left outer join DBPERKIRAAN c on c.Perkiraan=a.Lawan	
		where (month(t.tanggal)=@bulan and year(t.tanggal)=@Tahun) and 
		(a.Devisi like @Devisi)
		and (a.Perkiraan in (select Perkiraan  from DBPOSTHUTPIUT where kode='IVT')  or Lawan
in  (select Perkiraan  from DBPOSTHUTPIUT where kode='IVT') )
	   ) B on b.Perkiraan=a.Perkiraan
	   left outer join DBArusKasKonfig c on  c.KodeAK=c.KodeAK and c.KodeSAK=a.KodeSAK 
	   where b.Perkiraan is not null and a.KodeSAK='SAK05' and tipetranshd <>'BMM'
	   group by b.Bulan,b.Tahun,Devisi, a.Perkiraan,a.Keterangan,Urutan,c.Keterangan   --,a.KodeAK,a.KodeSAK
       union all
    --   'AK01' kodeak,'SAK05-' kodesak,'Saham' ketsak,b.Bulan,b.Tahun,Devisi , a.Perkiraan,a.Keterangan,Urutan ,sum(b.Nilai) Nilai 
  	    select 'AK01' kodeak,'SAK05-' kodesak,'Saham' ketsak,b.Bulan,b.Tahun,Devisi,a.Perkiraan,a.Keterangan ,'2' Urutan ,
  	    sum(b.Nilai) Nilai,a.Keterangan from DBPERKIRAAN a
 	    left outer join 
 	    (
			select (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) 
                    then  a.Lawan
	                when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) then --'2901'
	          a.Perkiraan
		end) Perkiraan,month(t.tanggal) Bulan, year(t.tanggal) Tahun,
		    (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then debet*a.kurs
		          when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and kredit<>0 then 0
		          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and debet<>0 then 0
		          when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')))  and kredit<>0 then kredit*a.kurs end
	        	) -
	    (case when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then 0
		            when (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and kredit<>0 then Kredit*a.kurs
		            when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and debet<>0 then Debet*a.kurs
		            when (a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) and kredit<>0 then 0 end) as Nilai,
		t.Devisi ,t.TipeTransHd
		     from dbTrans t 
		     left outer join dbtransaksi a on t.NoBukti=a.NoBukti
		     left outer join DBPERKIRAAN b on b.Perkiraan=a.Perkiraan
		     left outer join DBPERKIRAAN c on c.Perkiraan=a.Lawan	
		     where (month(t.tanggal)=@bulan and year(t.tanggal)=@Tahun) and  
		    (  (a.perkiraan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK'))) or 
		(a.lawan in (select Perkiraan from DBPOSTHUTPIUT where Kode in ('KAS','BANK')) ))
		and KODECOST <>'' and tipetranshd <>'BMM'
 	    )
 	    B on b.Perkiraan=a.Perkiraan
 	    
 	    	   where b.Perkiraan is not null and KodeSAK='SAK05' and tipetranshd <>'BMM'
	   group by a.KodeAK,a.KodeSAK,b.Bulan,b.Tahun,Devisi ,a.Perkiraan ,a.Keterangan
	   )A  	      
	  -- order by KodeSAK 
)





GO

-- Function: TblLapPerubahanAsetNeto
-- Type: SQL_INLINE_TABLE_VALUED_FUNCTION
-- Created: 2024-09-10 16:23:29.480 | Modified: 2024-10-16 15:40:56.023
-- =====================================================


CREATE function [dbo].[TblLapPerubahanAsetNeto]
(
@bulan int ,@tahun int,@Devisi Varchar(15)
)
returns table as return
(
--select 1
    select * from
    (
    	select x.KodePAN ,max(nilaidebet)nilaidebet ,max(nilaikredit)nilaikredit ,
	sum(case when tipe=0 then nilai else -1*nilai end) deltanetto,SUM(nilai)nilai  from 
	(
	select b.KodePAN,SUM (AkhirDRp )nilaidebet,SUM (AkhirKRp )nilaikredit ,
	
	sum (
	case when KodePAN ='PAN11' then dbo.JumlahPPIN (@bulan-1 ,@Tahun )else 
	case when isnull(AkhirDRp,0)=0 then ISNULL(MKRp-MDRp,0)+ISNULL(JPKRp-JpDRp,0)    --isnull(AkhirKRp,0)--
	else isnull(MDRp-MKRp,0) +ISNULL(JPDRp -JPKRp,0 ) end --isnull(AkhirDRp,0)
	end
	)  
	nilai
	/*Keterangan, b.Perkiraan ,AwalDRp , AkhirKRp */  from DBNERACA a
	left outer join DBPERKIRAAN b on b.Perkiraan=a.Perkiraan 
 where A.bulan=@bulan-1 and A.tahun=@tahun --Bulan =@bulan  and Tahun =@Tahun 
	 and isnull(KodePAN,'')<>''
	group by b.KodePAN 
	)x
	left outer join DBPerubahanAsetKonfig y on y.KodePAN=x.KodePAN
	group by x.kodepan,y.tipe
   ) y
)




GO

-- Function: TblLapPerubahanAsetNetoSD
-- Type: SQL_INLINE_TABLE_VALUED_FUNCTION
-- Created: 2025-05-19 15:25:53.497 | Modified: 2025-05-19 15:25:53.497
-- =====================================================


CREATE function [dbo].[TblLapPerubahanAsetNetoSD]
(
@bulan int ,@tahun int,@Devisi Varchar(15)
)
returns table as return
(
    	select x.KodePAN,SUM(akhirdebet)Akhirdebet,SUM (akhirkredit)akhirkredit  from 
	(
	select b.KodePAN,SUM (AkhirDRp )nilaidebet,SUM (AkhirKRp )nilaikredit ,
	
	sum (
	case when KodePAN ='PAN11' then dbo.JumlahPPIN (@bulan-1 ,@Tahun )else 
	case when isnull(AkhirDRp,0)=0 then ISNULL(MKRp-MDRp,0)+ISNULL(JPKRp-JpDRp,0)    --isnull(AkhirKRp,0)--
	else isnull(MDRp-MKRp,0) +ISNULL(JPDRp -JPKRp,0 ) end --isnull(AkhirDRp,0)
	end
	)  
	nilai, SUM(AkhirDRp ) akhirdebet, SUM(AkhirKRp ) akhirkredit
 from DBNERACA a
	left outer join DBPERKIRAAN b on b.Perkiraan=a.Perkiraan 
 where A.bulan between 1 and @bulan   and A.tahun=@tahun --Bulan =@bulan  and Tahun =@Tahun 
	 and isnull(KodePAN,'')<>''
	group by b.KodePAN 
	)x
	left outer join DBPerubahanAsetKonfig y on y.KodePAN=x.KodePAN
	group by x.kodepan,y.tipe
)




GO

-- Function: TblTotalAsetNeto
-- Type: SQL_INLINE_TABLE_VALUED_FUNCTION
-- Created: 2024-10-08 16:11:22.943 | Modified: 2024-10-08 16:11:22.943
-- =====================================================


CREATE function [dbo].[TblTotalAsetNeto]
(
--@bulan int ,@tahun int,@Devisi Varchar(15)
@devisi varchar(10),@bulan int,@tahun int
)
returns table as return
(
 
		  --Set @divisi=Case when @divisi in ('-','') then '%' else @divisi end
		select Grup ,SUM(bulanini )Nilai from
		(
		 select case when Jumlah ='+' then 'Aset Tersedia' else 'Pasiva' end groupneraca,Grup ,Jumlah ,Keterangan ,Tipe ,DK ,
		 max(BulanIni )bulanini, max(bulanlalu )bulanlalu,Devisi ,perkiraan 
		,max(case when jumlah ='+' then BulanIni else -1*BulanIni  end )jmlbulanini
		 from
		(
		Select Case when Left(A.Neraca,2)='A1' then 'INVESTASI'
					when Left(A.Neraca,2)='A2' then 'SELISIH NILAI KINI AKTUARIAL'
					when Left(A.Neraca,2)='A3' then 'ASET LANCAR DI LUAR INVESTASI' 
					when Left(A.Neraca,2)='A4' then 'ASET OPERASIONAL'
					when Left(A.Neraca,2)='A5' then 'ASET LAIN-LAIN'
					when Left(A.Neraca,2)='P1' then 'NILAI AKTUARIA'
					when Left(A.Neraca,2)='P2' then 'LIABILITAS DILUAR NILAI KINI AKTUARIA'
					--when Left(A.Neraca,2)='P3' then 'MODAL SENDIRI' 
					else ''
			   end Grup, 
			   Case when Left(A.Neraca,2)='A1' then '+'
					when Left(A.Neraca,2)='A2' then '+'
					when Left(A.Neraca,2)='A3' then '+' 
					when Left(A.Neraca,2)='A4' then '+'
					when Left(A.Neraca,2)='A5' then '+'
					when Left(A.Neraca,2)='P1' then '-'
					when Left(A.Neraca,2)='P2' then '-'
					--when Left(A.Neraca,2)='P3' then 'MODAL SENDIRI' 
					else ''
			   end Jumlah, b.nilaibulanini bulanini,c.nilaibulanini bulanlalu,
			   a.Keterangan, Tipe, DK,b.devisi,Perkiraan 
			   from dbPerkiraan a
			   left outer join dbo.JumlahAsetNeto(@bulan ,@tahun ,@devisi) b on b.perkiraang=a.Perkiraan
			   left outer join dbo.JumlahAsetNeto(@bulan-1 ,@tahun ,@devisi) c on c.perkiraang=a.Perkiraan 
			   where (Left(A.Neraca,2)<>'' or Left(A.Neraca,2) <>'  '  ) and Left(A.Neraca,2) <>'A2' 
			   and Left(A.Neraca,2) <>'P1'
			   )x
			   where bulanini is not null --and
			   group by Grup ,Keterangan ,Tipe ,DK,Devisi ,perkiraan,Jumlah 
		--Order by x.Perkiraan
		)x
		group by Grup 

)


GO

-- Function: TblTotalNeracaAktivaPasiva
-- Type: SQL_INLINE_TABLE_VALUED_FUNCTION
-- Created: 2024-10-08 16:29:21.740 | Modified: 2024-10-08 16:29:21.740
-- =====================================================


CREATE function [dbo].[TblTotalNeracaAktivaPasiva]
(
--@bulan int ,@tahun int,@Devisi Varchar(15)
@devisi varchar(10),@bulan int,@tahun int
)
returns table as return
(
 
select grupAP2,sum(jumlah1) Jumlah from
(
select (select P.KetNeraca from dbperkiraan P where P.perkiraan=C.perkiraan) as keterangan, substring(C.neraca,1,1) as grupAP1,
          substring(C.neraca,1,2) as grupAP2,
          isnull((select SUM((a.AwalDRp-a.AwalKRp)+(a.MDRp-a.MKRp)+(a.JPDRp-a.JPKRp)+(a.RLDRp-a.RLKRp))
          from dbneraca A,dbperkiraan B
          where A.bulan=@bulan and A.tahun=@tahun and A.perkiraan=B.perkiraan and substring(B.neraca,1,5)=substring(C.Neraca,1,5)),0) as jumlah1,
          
          isnull((select SUM((a.AwalDRp-a.AwalKRp)+(a.MDRp-a.MKRp)+(a.JPDRp-a.JPKRp)+(a.RLDRp-a.RLKRp))
          from dbneraca A,dbperkiraan B
          where A.bulan=@bulan-1 and A.tahun=@tahun and A.perkiraan=B.perkiraan and substring(B.neraca,1,5)=substring(C.Neraca,1,5)),0) as jumlah2

from dbperkiraan C
where len(C.neraca)=6 and substring(C.neraca,1,1)='A'  
union all
select (select P.KetNeraca from dbperkiraan P where P.perkiraan=C.perkiraan) as keterangan, substring(C.neraca,1,1) as grupAP1,
          substring(C.neraca,1,2) as grupAP2,
          isnull((select SUM((a.AwalKRp-A.AwalDRp)+(a.MKRp-A.MDRp)+(a.JPKRp-A.JPDRp)+(a.RLKRp-A.RLDRp))
          from dbneraca A,dbperkiraan B
          where A.bulan=@bulan and A.tahun=@tahun and A.perkiraan=B.perkiraan and substring(B.neraca,1,5)=substring(C.Neraca,1,5)),0) as jumlah1,
          
          isnull((select SUM((a.AwalKRp-A.AwalDRp)+(a.MKRp-A.MDRp)+(a.JPKRp-A.JPDRp)+(a.RLKRp-A.RLDRp))
          from dbneraca A,dbperkiraan B
          where A.bulan=@bulan-1 and A.tahun=@tahun and A.perkiraan=B.perkiraan and substring(B.neraca,1,5)=substring(C.Neraca,1,5)),0) as jumlah2

from dbperkiraan C
where len(C.neraca)=6 and substring(C.neraca,1,1)='P'  
--order by C.neraca
)x
group by grupAP2 

)


GO

