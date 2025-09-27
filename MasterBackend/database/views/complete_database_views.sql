-- =====================================================
-- EXISTING DATABASE VIEWS FROM DATABASE
-- Extracted from: dbdapenka2
-- Date: 2025-08-21 11:43:02
-- Total Views: 194
-- =====================================================

-- =====================================================
-- KEY/PATTERN VIEWS (Most Likely Important)
-- =====================================================

-- View: vwAktiva
-- Created: 2011-11-22 16:29:11.903 | Modified: 2011-11-23 22:32:53.300
-- =====================================================


CREATE View [dbo].[vwAktiva]
as
select A.*,C.Keterangan KelAktiva,D.Keterangan NamaAkumulasi,
       E.Keterangan NamaBiaya,F.Keterangan NamaBiaya2,
       G.Keterangan NamaBiaya3,H.Keterangan NamaBiaya4,
       Case when A.Tipe='L' then 'Garis Lurus'
            when A.Tipe='M' then 'Menurun'
            when A.Tipe='P' then 'Pajak'
            else ''
       end Mytipe,
       I.NamaBag,
       C.Keterangan+Case when C.Keterangan is null then '' else ' ('+C.Perkiraan+')' end myAktiva,
       D.Keterangan+Case when D.Keterangan is null then '' else ' ('+D.Perkiraan+')' end myAkumulasi,
       E.Keterangan+Case when E.Keterangan is null then '' else ' ('+E.Perkiraan+')' end myBiaya,
       F.Keterangan+Case when F.Keterangan is null then '' else ' ('+F.Perkiraan+')' end myBiaya2,
       G.Keterangan+Case when G.Keterangan is null then '' else ' ('+G.Perkiraan+')' end myBiaya3,
       H.Keterangan+Case when H.Keterangan is null then '' else ' ('+H.Perkiraan+')' end myBiaya4,
       I.NamaBag+Case when I.NamaBag is null then '' else ' ('+I.KodeBag+')' end myBagian
from DBAKTIVA A
     left Outer join DBPOSTHUTPIUT B on B.Perkiraan=A.NoMuka
     Left Outer join DBPERKIRAAN C on C.Perkiraan=B.Perkiraan and C.Perkiraan=A.NoMuka
     left Outer join DBPERKIRAAN D on D.Perkiraan=A.Akumulasi
     left Outer join DBPERKIRAAN E on E.Perkiraan=A.Biaya
     left Outer join DBPERKIRAAN F on F.Perkiraan=A.Biaya2
     left Outer join DBPERKIRAAN G on G.Perkiraan=A.biaya3
     left Outer join DBPERKIRAAN H on H.Perkiraan=A.biaya4
     Left Outer join DBBAGIAN I on I.KodeBag=A.Kodebag


GO

-- View: vwAktivitasUser
-- Created: 2011-06-01 13:57:10.550 | Modified: 2011-06-01 13:57:10.550
-- =====================================================




CREATE  View [dbo].[vwAktivitasUser]
as

select  A.Tahun, A.Bulan, A.Tanggal, A.Pemakai, A.Aktivitas,
        cast(case when A.Aktivitas='I' then 'Tambah' when A.Aktivitas='U' then 'Koreksi'
        when A.Aktivitas='D' then 'Hapus' when A.Aktivitas='C' then 'Cetak' else '' end as varchar(50)) NamaAktivitas,
        isnull(B.NamaSumber,'') Sumber, A.NoBukti, 
	cast(case when A.Aktivitas='I' then 'Tambah --> ' 
                  when A.Aktivitas='U' then 'Koreksi --> '
                  when A.Aktivitas='D' then 'Hapus --> ' 
                  when A.Aktivitas='C' then 'Cetak' 
                  when A.Aktivitas='CI' then 'Cetak Surat Jalan' 
                  else '' 
             end+A.Keterangan as text) Keterangan
from    dbLogFile A
left outer join vwSumberAktivitasUser B on B.KodeSumber=A.Sumber












GO

-- View: vwAlamatCust
-- Created: 2011-10-19 13:42:21.707 | Modified: 2011-10-19 13:42:21.707
-- =====================================================
Create View [dbo].[vwAlamatCust]
As
select *
from 	dbAlamatCust A














GO

-- View: vwBagian
-- Created: 2011-12-08 20:19:04.703 | Modified: 2011-12-08 20:21:12.023
-- =====================================================
CREATE View vwBagian
As
Select A.*, 
       B.Keterangan+' ('+A.Perkiraan+')' NamaPerkiraan,
       C.Keterangan+' ('+A.Biaya+')' NamaBiaya
from DBBAGIAN A
     Left Outer Join DBPERKIRAAN B on B.Perkiraan=A.Perkiraan
     left Outer join DBPERKIRAAN C on C.Perkiraan=A.Biaya
     
 
GO

-- View: vwBarang
-- Created: 2014-04-14 10:19:02.520 | Modified: 2014-09-30 10:44:52.933
-- =====================================================




CREATE View [dbo].[vwBarang]
as
     
select	A.KODEBRG, A.NAMABRG, A.KODEGRP, B.NAMA NamaGrp, A.KODESUBGRP, C.NamaSubGrp, 
	A.KodeSupp,
	A.SAT1, A.ISI1, A.SAT2, A.ISI2, A.SAT3, A.ISI3,
	A.NFix, cast(case when A.NFix=0 then 'Tetap' else 'Tidak Tetap' end as varchar(30)) MyNFix,
	A.Hrg1_1, A.Hrg2_1, A.Hrg3_1, A.Hrg1_2, A.Hrg2_2, A.Hrg3_2, A.Hrg1_3, A.Hrg2_3, A.Hrg3_3,
	A.QntMin, A.QntMax, A.ISAKTIF, cast(case when A.ISAKTIF=1 then 'Aktif' else 'Non Aktif' end as varchar(50)) MyAktif,
	A.Keterangan, A.NamaBrg2,
	A.Tolerate, A.Proses, A.IsTakeIn,
	CAST(1 as int) IsBeli, CAST(1 as int) IsJual, A.IsBarang,ISNULL(IsJasa,0) Isjasa
from	DBBARANG A
left outer join DBGROUP B on B.KODEGRP=A.KODEGRP
left outer join dbSubGroup C on C.KodeSubGrp=A.KODESUBGRP and C.KodeGrp=B.KODEGRP and C.KodeGrp=A.KODEGRP




GO

-- View: vwBarangJadi
-- Created: 2011-12-08 19:44:29.550 | Modified: 2011-12-08 19:46:02.463
-- =====================================================

CREATE View [dbo].[vwBarangJadi]
as     
Select A.*, B.Keterangan NamaKelompok, C.Keterangan NamaKategori, 
       D.Keterangan NamaSubKategori, E.Keterangan NamaJenis,
       F.Keterangan NamaSubJenis,
       B.Keterangan+Case when B.Keterangan is null then '' else ' ('+B.KodeKelompok+')' end myKelompok,
       C.Keterangan+Case when C.Keterangan is null then '' else ' ('+C.KodeKategori+')' end myKategori,
       D.Keterangan+Case when D.Keterangan is null then '' else ' ('+D.KodeSubKategori+')' end mySubKategori,
       E.Keterangan+Case when E.Keterangan is null then '' else ' ('+E.KodeJnsBrg+')' end myJenis,
       F.Keterangan+Case when F.Keterangan is null then '' else ' ('+F.kodesubJnsBrg+')' end mySubJenis
from DBBARANGJADI A
     left outer join DBKELOMPOK B on B.KodeKelompok=A.KodeKelompok
     left outer join DBKATEGORIBRGJADI C on C.KodeKategori=A.KodeKategori
     left outer join DBSUBKATEGORIBRGJADI D on D.KodeSubKategori=A.KodeSubKategori
     Left Outer join DBJENISBRGJADI E on E.KodeJnsBrg=A.KodeJnsBrg
     left outer join DBSUBJENISBRGJADI F on F.kodesubJnsBrg=A.kodesubJnsBrg


GO

-- View: vwBon
-- Created: 2011-12-02 15:35:10.873 | Modified: 2011-12-08 20:16:04.513
-- =====================================================
Create View Dbo.vwbon
as
select A.*,B.Keterangan NamaPerkiraan
from DBBON A
     left Outer join DBPERKIRAAN B on B.Perkiraan=A.Perkiraan
     
GO

-- View: vwBonBelumLunas
-- Created: 2011-12-01 15:50:39.063 | Modified: 2011-12-01 15:50:39.063
-- =====================================================
Create View dbo.vwBonBelumLunas
as
Select Nobukti,SUM(Debet-Kredit) Saldo
from DBBON
Group by NoBukti
Having SUM(Debet-Kredit)>0
GO

-- View: vwBrgInspeksi
-- Created: 2011-02-11 15:18:57.623 | Modified: 2011-03-03 11:58:14.430
-- =====================================================

CREATE  View [dbo].[vwBrgInspeksi]
as
select a.KodeBrg,d.NamaBrg,a.NoBukti,a.Qnt,a.Qnt2,d.Toleransi From dbPODet a
left Outer join dbPPLdet b on a.NoPPL=b.NoBukti and a.UrutPPL=b.Urut
Left Outer join dbPermintaanBrgdet c on c.NoBukti=b.NoPermintaan and c.Urut=b.UrutPermintaan 
Left Outer Join dbBarang d on d.KodeBrg=C.KodeBrg
where c.IsInspeksi=1


GO

-- View: vwBrowsCust
-- Created: 2012-04-12 14:22:41.437 | Modified: 2014-03-05 13:33:24.170
-- =====================================================



CREATE View [dbo].[vwBrowsCust]
as

Select 	A.KODECUSTSUPP, A.NAMACUSTSUPP, A.ALAMAT1, A.ALAMAT2, 
    case when isnull(A.Alamat2,'')='' then A.Alamat1 else A.Alamat1+char(13)+A.Alamat2 end Alamat,
	A.kota kodeKota,  A.Kota, 
	A.TELPON, A.FAX, A.EMAIL, A.KODEPOS, A.NEGARA, A.NPWP, A.Tanggal, A.PLAFON, A.HARI, A.HARIHUTPIUT, 
	A.BERIKAT, A.USAHA, D.PERKIRAAN, JENIS, A.NAMAPKP, A.ALAMATPKP1, A.ALAMATPKP2, A.KOTAPKP, A.Sales, A.KodeVls, A.KodeTipe, A.IsPpn,
	A.Agent,case when isnull(A.Alamat2A,'')='' then A.Alamat1A else A.Alamat1A+char(13)+A.Alamat2A end AlamatA,
	A.KotaA, A.NegaraA, A.ContactP, B.IsBeliJual, B.IsLokalorExim,
	case when isnull(A.ALAMATPKP2,'')='' then A.ALAMATPKP1 else A.ALAMATPKP1+char(13)+A.ALAMATPKP2 end AlamatPKP,	   
	C.Keterangan NamaPerkiraan,A.IsAktif,Isnull(A.PPN,0) PPN
From 	dbo.DBCUSTSUPP A
      left Outer join DBPERKCUSTSUPP D on D.KodeCustSupp=A.KODECUSTSUPP
      Left Outer Join DBPOSTHUTPIUT B on B.Perkiraan=D.PERKIRAAN
      Left Outer Join dbo.DBPERKIRAAN C on C.Perkiraan=B.PERKIRAAN
where B.Kode='PT'



GO

-- View: vwBrowsCustomer
-- Created: 2014-02-19 10:17:43.023 | Modified: 2014-02-19 10:18:47.700
-- =====================================================


CREATE  View [dbo].[vwBrowsCustomer]
As

select	A.KODECUSTSupp kodecust, A.NAMACUSTSUPP namaCust, ltrim(A.ALAMAT1+case when ltrim(A.ALAMAT2)<>'' then char(13)+A.ALAMAT2 else '' end+
	case when ltrim(isnull(A.KOTA,''))<>'' then char(13)+isnull(A.KOTA,'')+' '+A.KodePos else '' end) ALAMAT, 
	A.Kota kodekota, a.Kota NAMAKOTA, A.TELPON, A.PLAFON, A.HARI, A.Hari HARIPIUTANG, 
	A.USAHA, A.PERKIRAAN, A.JENIS, C.KeyNik Sales, D.Nama NAMASLS, A.KODEEXP, E.NAMAEXP, A.KODETIPE, a.IsPpn,a.PPN
from	dbCustSupp A
left outer join DBSALESCUSTOMER C on c.KodeCustSupp=a.KODECUSTSUPP
Left Outer join dbKaryawan D on d.KeyNIK=C.KeyNik
left outer join dbExpedisi E on E.KodeExp=A.KodeExp



GO

-- View: vwBrowsCustSupp
-- Created: 2014-07-15 11:35:06.730 | Modified: 2014-07-15 11:35:06.730
-- =====================================================

CREATE View [dbo].[vwBrowsCustSupp]
as

--select  A.KodeCustSupp, A.Urut, A.Perkiraan, B.Kode,
--	CS.NAMACUSTSUPP, CS.ALAMAT1, CS.ALAMAT2, CS.NamaKota, CS.NEGARA,
--	CS.ALAMATKOTA, CS.HARI, CS.HARIHUTPIUT, 
--	cast(CS.IsPpn as int) IsPPN, CS.IsAktif 
--from DBPERKCUSTSUPP A
--left outer join DBPOSTHUTPIUT B on B.Perkiraan=A.Perkiraan
--left outer join vwCUSTSUPP CS on CS.KODECUSTSUPP=A.KodeCustSupp



select B.Kode, A.Perkiraan, A.Urut, Cs.*,
	CAST(case when Cs.Jenis=0 then 1 else 0 end as tinyint) IsSupplier, 
	CAST(case when Cs.Jenis=1 then 1 else 0 end as tinyint) IsCustomer,
	CAST(case when Cs.Jenis=3 then 1 else 0 end as tinyint) IsExpedisi 
from vwCUSTSUPP Cs
left outer join DBPERKCUSTSUPP A on A.KodeCustSupp=Cs.KODECUSTSUPP
left outer join DBPOSTHUTPIUT B on B.Perkiraan=A.Perkiraan






GO

-- View: vwBrowsExpedisi
-- Created: 2013-07-15 12:07:22.207 | Modified: 2013-07-15 12:07:22.207
-- =====================================================




CREATE View [dbo].[vwBrowsExpedisi]
as

Select 	A.KODECUSTSUPP, A.NAMACUSTSUPP, A.ALAMAT1, A.ALAMAT2, 
    case when isnull(A.Alamat2,'')='' then A.Alamat1 else A.Alamat1+char(13)+A.Alamat2 end Alamat,
	A.kota kodeKota,  A.Kota, 
	A.TELPON, A.FAX, A.EMAIL, A.KODEPOS, A.NEGARA, A.NPWP, A.Tanggal, A.PLAFON, A.HARI, A.HARIHUTPIUT, 
	A.BERIKAT, A.USAHA, D.PERKIRAAN, JENIS, A.NAMAPKP, A.ALAMATPKP1, A.ALAMATPKP2, A.KOTAPKP, A.Sales, A.KodeVls, A.KodeTipe, A.IsPpn,
	A.Agent,case when isnull(A.Alamat2A,'')='' then A.Alamat1A else A.Alamat1A+char(13)+A.Alamat2A end AlamatA,
	A.KotaA, A.NegaraA, A.ContactP, B.IsBeliJual, B.IsLokalorExim,
	case when isnull(A.ALAMATPKP2,'')='' then A.ALAMATPKP1 else A.ALAMATPKP1+char(13)+A.ALAMATPKP2 end AlamatPKP,	   
	C.Keterangan NamaPerkiraan,A.IsAktif
From 	dbo.DBCUSTSUPP A
      left Outer join DBPERKCUSTSUPP D on D.KodeCustSupp=A.KODECUSTSUPP
      Left Outer Join DBPOSTHUTPIUT B on B.Perkiraan=D.PERKIRAAN
      Left Outer Join dbo.DBPERKIRAAN C on C.Perkiraan=B.PERKIRAAN
where a.Jenis=3





GO

-- View: vwBrowsOutBeli
-- Created: 2014-09-30 10:50:10.880 | Modified: 2014-09-30 10:50:10.880
-- =====================================================

Create View [dbo].[vwBrowsOutBeli]
as

Select 	*
From 	vwOutBeli
where 	QntSisa>0
	and NilaiOL=MaxOL
	
GO

-- View: vwBrowsOutBP_Inspeksi
-- Created: 2011-06-09 10:49:13.820 | Modified: 2011-06-09 10:49:13.820
-- =====================================================

CREATE View [dbo].[vwBrowsOutBP_Inspeksi]
as
select	Nobukti, urut, NoPO, UrutPO, kodebrg, Sat_1, Sat_2, Isi, Qnt, Qnt2, QntBatal, Qnt2Batal, QntIns, Qnt2Ins, QntSisaIns, Qnt2SisaIns, QntSisa, Qnt2Sisa, Nosat
From 	dbo.vwOutBP_Inspeksi 
where 	QntSisa>0 and Qnt2Sisa>0

GO

-- View: vwBrowsOutInspeksi
-- Created: 2011-02-11 15:18:57.647 | Modified: 2011-06-09 10:49:36.440
-- =====================================================


CREATE View [dbo].[vwBrowsOutInspeksi]
as

Select 	NoBukti, Urut, KodeBrg, Qnt, Qnt2, QntSJ, Qnt2SJ, QntSisa, Qnt2Sisa 
From 	vwOutInspeksi 
where 	QntSisa>0 and Qnt2Sisa>0



GO

-- View: vwBrowsOutInvoicePL
-- Created: 2014-09-24 10:57:31.803 | Modified: 2023-05-21 15:46:07.900
-- =====================================================





CREATE View [dbo].[vwBrowsOutInvoicePL]
as

Select 	*
From 	vwOutInvoicePL
where 	QntSisa>0
	and NilaiOL=MaxOL
	








GO

-- View: vwBrowsOutPermintaanBrg
-- Created: 2011-04-15 09:19:43.173 | Modified: 2011-08-04 15:52:02.820
-- =====================================================

CREATE VIEW [dbo].[vwBrowsOutPermintaanBrg]
AS
SELECT     Nobukti, urut, kodebrg,Nosat, Sat_1, Sat_2, Isi, Qnt, Qnt2, TglTiba, isInspeksi, 
		QntBPB, Qnt2BPB, QntBBP, Qnt2BBP, QntPPL, Qnt2PPL,QntBPL, Qnt2BPL, 
		QntSisaBPB, Qnt2SisaBPB, QntSisa, Qnt2Sisa, Keterangan
FROM         dbo.vwOutPermintaanBrg
where (QntSisaBPB>0) or (Qnt2SisaBPB>0)




GO

-- View: vwBrowsOutPO
-- Created: 2011-05-05 15:41:59.303 | Modified: 2011-09-16 08:43:29.070
-- =====================================================
CREATE View [dbo].[vwBrowsOutPO]
as

Select 	Nobukti, urut, NoPPL, UrutPPL, kodebrg, Sat_1, Sat_2, Isi, Qnt, Qnt2, QntBatal, Qnt2Batal, 
	QntBeli, Qnt2Beli, QntSisaBeli, Qnt2SisaBeli, QntSisa, Qnt2Sisa, ISNULL(QntTukar,0) QntTukar, ISNULL(Qnt2Tukar,0) Qnt2Tukar 
From 	dbo.vwOutPO 
where 	QntSisa>0 and Qnt2Sisa>0

GO

-- View: vwBrowsOutPO_BP
-- Created: 2011-05-05 15:41:13.570 | Modified: 2011-07-08 10:15:14.470
-- =====================================================

CREATE View [dbo].[vwBrowsOutPO_BP]
as

Select 	NoBukti, Urut, NoPPL, UrutPPL, NoInspeksi, UrutInspeksi, KodeBrg, Sat_1, Sat_2, Isi, Qnt, Qnt2, QntBatal, Qnt2Batal, 
	QntBeli, Qnt2Beli, QntSisaBeli, Qnt2SisaBeli, QntSisa, Qnt2Sisa, Nosat, Catatan
From 	vwOutPO_BP 
where 	QntSisa>0 Or Qnt2Sisa>0






GO

-- View: vwBrowsOutPO_Inspeksi
-- Created: 2011-05-05 15:43:00.673 | Modified: 2011-05-05 15:43:00.673
-- =====================================================



CREATE View [dbo].[vwBrowsOutPO_Inspeksi]
as

select	Nobukti, urut, NoPPL, UrutPPL, kodebrg, Sat_1, Sat_2, Isi, Qnt, Qnt2, QntBatal, Qnt2Batal, QntIns, Qnt2Ins, QntSisaIns, Qnt2SisaIns, QntSisa, Qnt2Sisa, Nosat
From 	dbo.vwOutPO_Inspeksi 
where 	QntSisa>0 and Qnt2Sisa>0




GO

-- View: vwBrowsOutPPL
-- Created: 2011-06-04 09:49:45.283 | Modified: 2011-06-14 10:45:25.447
-- =====================================================

CREATE VIEW [dbo].[vwBrowsOutPPL]
AS
SELECT     Nobukti, urut, kodebrg, Sat_1, Sat_2, Isi, Qnt, Qnt2, TglTiba, NoPermintaan, UrutPermintaan, QntBatal, Qnt2Batal, 
			QntPO, Qnt2PO, QntBtlPO, Qnt2BtlPO, QntSisaPO, 
            Qnt2SisaPO, QntSisa, Qnt2Sisa, NamaBag,  tglbutuh, keterangan, isInspeksi, nosat, Pelaksana
FROM         dbo.vwOutPPL
WHERE     (QntSisa > 0) AND (Qnt2Sisa > 0)
GO

-- View: vwBrowsOutRJual
-- Created: 2013-02-05 11:19:05.787 | Modified: 2014-03-05 13:37:21.173
-- =====================================================

CREATE View [dbo].[vwBrowsOutRJual]
as
Select 	NoBukti, Urut, KodeBrg, Sat_1, Sat_2, NoSat, Isi, Qnt, Qnt2, 
	QntSPB, Qnt2SPB, QntSisa, Qnt2Sisa,NetW,GrossW, noinvoice,UrutInvoice, namabrg, isFlag	
From 	vwOutRjual 
where 	QntSisa>0 and Qnt2Sisa>0


GO

-- View: vwBrowsOutSC_SPP
-- Created: 2011-07-07 12:42:23.803 | Modified: 2011-09-21 17:53:17.807
-- =====================================================




CREATE View [dbo].[vwBrowsOutSC_SPP]
as

Select 	NoBukti, Urut, KodeBrg, Sat_1, Sat_2, NoSat, Isi, Qnt, Qnt2, 
	QntSPP, Qnt2SPP, QntSisa, Qnt2Sisa, NamabrgKom 
From 	vwOutSC_SPP 
where 	QntSisa>0 and Qnt2Sisa>0







GO

-- View: vwBrowsOutShip
-- Created: 2011-08-19 15:32:18.683 | Modified: 2011-08-19 15:33:47.903
-- =====================================================

CREATE View [dbo].[vwBrowsOutShip]
as

Select 	NoBukti, Urut, KodeBrg,Namabrg, Sat_1, Sat_2, NoSat, Isi, Qnt, Qnt2, 
	QntSPB, Qnt2SPB, QntSisa, Qnt2Sisa,NetW,GrossW, NoSC
From 	vwOutShip 
where 	QntSisa>0 and Qnt2Sisa>0


GO

-- View: vwBrowsOutSHIP_SPP
-- Created: 2011-08-19 08:46:40.343 | Modified: 2011-12-27 20:03:38.750
-- =====================================================


CREATE View [dbo].[vwBrowsOutSHIP_SPP]
as

Select 	NoBukti, NOSC, Urut, KodeBrg, Sat_1, Sat_2, NoSat, Isi, Qnt, Qnt2, QntSPP, Qnt2SPP, QntSisa, Qnt2Sisa, NamabrgKom,
         ShippingMark
From 	vwOutSHIP_SPP 
where 	QntSisa>0 and Qnt2Sisa>0



GO

-- View: vwBrowsOutSO_SPP
-- Created: 2014-02-13 11:53:58.173 | Modified: 2015-03-24 10:37:26.740
-- =====================================================





CREATE View [dbo].[vwBrowsOutSO_SPP]
as
Select 	NoBukti,  Urut, KodeBrg, Satuan,  NoSat, Isi, Qnt, Qnt2, QntSPP, Qnt2SPP, QntSisa, Qnt2Sisa, NamabrgKom, isLengkap, MasaBerlaku
,IsClosedet,Tanggal
From 	vwOutSO_SPP
where 	QntSisa>0 and MasaBerlaku>=GETDATE()



GO

-- View: vwBrowsOutSPB_RSPB
-- Created: 2014-02-19 10:17:53.800 | Modified: 2014-02-19 10:17:53.800
-- =====================================================


CREATE View [dbo].[vwBrowsOutSPB_RSPB]
as
Select 	NoBukti, Urut, KodeBrg,Namabrg, Sat_1, Sat_2, NoSat, Isi, Qnt, Qnt2, 
	QntRSPB, Qnt2RSPB, QntSisa, Qnt2Sisa,NetW,GrossW, Catatan, TipeSPP,
	isClose,a.isotorisasi1,A.Flagtipe
From 	vwOutSPB_RSPB a
where 	QntSisa>0 and Qnt2Sisa>0 and a.isotorisasi1=1
GO

-- View: vwBrowsOutSPBRJual
-- Created: 2014-09-24 11:37:29.743 | Modified: 2014-09-24 11:37:29.743
-- =====================================================


create View [dbo].[vwBrowsOutSPBRJual]
as

Select 	*
From 	vwOutSPBRJual
where 	QntSisa>0
	and NilaiOL=MaxOL
	









GO

-- View: vwBrowsOutSPP
-- Created: 2011-10-19 08:41:19.440 | Modified: 2013-02-19 15:14:38.413
-- =====================================================



CREATE View [dbo].[vwBrowsOutSPP]
as
Select 	NoBukti, Urut, KodeBrg,Namabrg, Sat_1, Sat_2, NoSat, Isi, Qnt, Qnt2, 
	QntSPB, Qnt2SPB, QntSisa, Qnt2Sisa,NetW,GrossW, Catatan, TipeSPP,
	isClose, NoSO, UrutSO, isCetakKitir
From 	vwOutSPP 
where 	QntSisa>0 or Qnt2Sisa>0




GO

-- View: vwBrowsOutSPRK
-- Created: 2011-03-03 11:57:52.613 | Modified: 2011-12-29 13:51:35.450
-- =====================================================

CREATE VIEW [dbo].[vwBrowsOutSPRK]
AS
SELECT     Nobukti, urut, kodebrg, Sat_1, Sat_2, Isi, Qnt, Qnt2, '' NoPermintaan,0 UrutPermintaan,
           QntBSPRK QntBatal, Qnt2BSPRK Qnt2Batal, QntPO, Qnt2PO, QntBPO, Qnt2BPO, QntSisaPO, 
           Qnt2SisaPO, QntSisa, Qnt2Sisa, NamaBag, nosat, Pelaksana, IsInspeksi, Keterangan, KodeGrp, Catatan,
           JnsPakai, Kodegdg, kodebag, kodemesin, SOP, Perk_Investasi
FROM   dbo.vwOutSPRK
WHERE (QntSisa > 0) AND (Qnt2Sisa > 0)


GO

-- View: vwBrowsSupp
-- Created: 2012-04-12 14:22:41.437 | Modified: 2012-04-12 14:22:41.437
-- =====================================================




CREATE View [dbo].[vwBrowsSupp]
as
Select A.KODECUSTSUPP, A.NAMACUSTSUPP, A.ALAMAT1, A.ALAMAT2, 
       case when isnull(A.Alamat2,'')='' then A.Alamat1 else A.Alamat1+char(13)+A.Alamat2 end Alamat,
    	 A.kota kodeKota,  A.Kota, 
	    A.TELPON, A.FAX, A.EMAIL, A.KODEPOS, A.NEGARA, A.NPWP, A.Tanggal, A.PLAFON, A.HARI, A.HARIHUTPIUT, 
	    A.BERIKAT, A.USAHA, D.PERKIRAAN, A.JENIS, A.NAMAPKP, A.ALAMATPKP1, A.ALAMATPKP2, A.KOTAPKP, A.Sales, A.KodeVls, A.KodeTipe, A.IsPpn,
	    A.Agent,case when isnull(A.Alamat2,'')='' then A.Alamat1A else A.Alamat1A+char(13)+A.Alamat2A end AlamatA,
	    A.KotaA, A.NegaraA, A.ContactP, B.IsBeliJual, B.IsLokalorExim,
	    C.Keterangan NamaPerkiraan,A.IsAktif
From 	dbo.DBCUSTSUPP A
      Left Outer join DBPERKCUSTSUPP D on D.KodeCustSupp=A.KODECUSTSUPP
      Left Outer Join dbo.DBPOSTHUTPIUT B on B.Perkiraan=D.PERKIRAAN
      Left Outer Join dbo.DBPERKIRAAN C on C.Perkiraan=B.PERKIRAAN
where  B.Kode='HT'






GO

-- View: vwCetakContractReview
-- Created: 2011-10-19 08:41:19.457 | Modified: 2011-12-08 20:17:03.990
-- =====================================================



CREATE View [dbo].[vwCetakcontractreview]
as
select a.nobukti,b.tanggal,b.KodecustSupp,a.KodeBrg,a.NAMABRG,e.Jns_Kertas,e.Ukr_Kertas,e.gsm,
case when a.Nosat=1 then c.Qnt 
     else c.Qnt2 
end jumlahkirim,
case when c.Nosat=1 then c.Sat_1
     when c.Nosat=2 then c.Sat_2 
     else ''
end Satuan,a.Nosat,c.TGLKirim,a.Sistem_Kemasan_IsKarton,
a.Sistem_Kemasan_IsPalet,a.Sistem_Kemasan_IsKarton_Palet,a.Sistem_Kemasan_IsBungkus,
a.Sistem_Kemasan_IsBungkus_Palet,a.Sticker,a.Isi_Kemasan,a.Ketentuan_Berat_IsTeori,
a.Ketentuan_Berat_IsTimbang,a.Jenis_isPlastik,a.Jenis_isKarton,a.Diameter_Inside_120mm,
a.Diameter_Inside_152mm,a.Diameter_Inside_76mm,a.Tebal_14mm_152mm,a.Tebal_14mm_76mm,
a.Tebal_15mm,a.Tebal_Lain,a.Tebal_lain2,a.Warna_YellowA,a.Warna_YellowB,a.Warna_Lain,a.Warna_Lain2,
a.Arah_Putaran_WI,a.Arah_Putaran_WO,a.Jum_Ukuran_Cont,a.Jum_Kemasan,a.Ship_Mark,
a.NamaBrg Namabrgkom, c.Keterangan, A.Urut,
Case when d.USAHA<>'' then d.USAHA+'. ' else '' end+d.NAMACUSTSUPP NamaCustsupp,
       d.Alamat+CAse when d.Kota<>'' then CHAR(13)+d.Kota else '' end+
       Case when d.NEGARA<>'' then CHAR(13)+d.NEGARA else '' end Alamat     
from dbContractReviewDet a 
left outer join dbContractReview b on a.NoBukti = b.nobukti
left outer join DBContractReviewKIRIM c on a.NoBukti = c.NoCR and c.UrutCR=a.Urut
left outer join vwBrowsCust d on b.KodecustSupp = d.KODECUSTSUPP
left outer join DBBARANGJADI e on a.KodeBrg =  e.KODEBRG

--where a.nobukti ='ENQ/0111/00002/SZZ'













GO

-- View: vwcetakenquiry
-- Created: 2011-09-28 13:31:00.000 | Modified: 2011-09-28 13:31:00.000
-- =====================================================



CREATE View [dbo].[vwcetakenquiry]
as


select a.nobukti,b.nourut,b.tanggal,
case when b.islokal=0 then 'LOKAL' else 'EXPORT' end as penjualan,
b.kodecustsupp,c.namacustsupp,a.KodeBrg,a.Namabrg,d.Jns_Kertas,d.Ukr_Kertas,d.GSM,
a.Sat_1,a.Qnt,a.Sat_2,a.Qnt2
from dbenquirydet a 
left outer join DBENQUIRY b on a.NoBukti = b.NoBukti
left outer join vwBrowsCust c on b.KodeCustSupp=c.KODECUSTSUPP
left outer join DBBARANGJADI d on a.KodeBrg = d.KODEBRG

--where a.nobukti ='ENQ/0111/00002/SZZ'




GO

-- View: vwCetakInvoicePL
-- Created: 2013-01-15 11:46:02.820 | Modified: 2013-01-15 11:46:02.820
-- =====================================================

CREATE View [dbo].[vwCetakInvoicePL]
as
Select A.NoBukti, A.NoUrut, A.Tanggal, A.PPN, A.Valas, A.Kurs, A.KodeCustSupp, A.Consignee, A.NotifyParty, A.StuffingDate, 
       A.StuffingPlace, A.ContractNo, A.PONo, A.PaymentTerm, 
       A.DocCreditNo, A.PoL, A.PoD, A.NameOfVessel, A.Feeder_Vessel, A.Connect_Vessel, A.ShipOnBoardDate, A.Packing, 
       A.Others, A.IsCetak, A.IDUser, A.IsLokal, A.NoBL, A.NoteBeneficiary1, 
       A.NoteBeneficiary2, A.NoteBeneficiary3, A.ShipmentAdvice1, A.ShipmentAdvice2, A.ETADestination, A.ToShipmentAdvice2, A.NoPajak, A.TglFPJ, 
       A.Footnote, A.IssuingBank, A.MyID, 
       A.IsOtorisasi1, A.OtoUser1, A.TglOto1,
       A.IsOtorisasi2, A.OtoUser2, A.TglOto2, 
       A.IsOtorisasi3, A.OtoUser3, A.TglOto3, 
       A.IsOtorisasi4, A.OtoUser4, A.TglOto4, 
       
       A.IsOtorisasi5, A.OtoUser5, A.TglOto5,
       B.Kodebrg,B.Namabrg NamaBrgkom,
       Sum(Case when B.NOSAT=1 then B.QNT
            when B.NOSAT=2 then B.QNT2
            else 0
       end) Qty,
      (Case when B.NOSAT=1 then B.Sat_1
            when B.NOSAT=2 then B.Sat_2
            else ''
       end) Satuan,Sum(B.Qnt) Qnt, Sum(B.Qnt2) Qnt2, B.Sat_1,B.Sat_2,B.Nosat,B.Harga,
       Sum(B.NDPP) NDPP, Sum(B.NDPPRp) NDPPRp, Sum(B.NPPN) NPPN, Sum(B.NPPNRp) NPPnRp, Sum(B.NNET) Nnet, Sum(B.NNETRp) NnetRp,
       B.ShippingMark, B.KetDetail, B.NetW, B.GrossW, B.Meas,
       E.Namabrg,       
       Case when C.USAHA<>'' then C.USAHA+'. ' else '' end+C.NAMACUST NamaCustSupp,
       C.Alamat,C.kodekota Kota,C.USAHA,'' NEGARA, C.TELPON, '' FAX, '' EMAIL,
       '' NoLC,
	   '' NoLCShip, '' Notify_PartyShip, '' PoLShip, 
	   '' PodShip, '' ConsigneeShip, 
	   '' Veeder_VesselShip, '' Voy_Veeder_VesselShip,
       '' Connect_VesselShip, '' Voy_Connect_VesselShip, 
	   '' ShipOnBoardShip, '' Stuffing_DateShip, 
	   '' Stuffing_PlaceShip,
	   '' Freight_TermShip, '' NotesShip,
	   Case when MONTH(A.tanggal)=1 then 'January'
	        when MONTH(A.tanggal)=2 then 'February'
	        when MONTH(A.tanggal)=3 then 'March'
	        when MONTH(A.tanggal)=4 then 'April'
	        when MONTH(A.tanggal)=5 then 'May'
	        when MONTH(A.tanggal)=6 then 'June'
	        when MONTH(A.tanggal)=7 then 'July'
	        when MONTH(A.tanggal)=8 then 'August'
	        when MONTH(A.tanggal)=9 then 'September'
	        when MONTH(A.tanggal)=10 then 'October'
	        when MONTH(A.tanggal)=11 then 'November'
	        when MONTH(A.tanggal)=12 then 'December'
	        else ''
	   end Bulan, '' Ukr_Kertas, '' Trade_Term,
        Case when MONTH(A.ShipOnBoardDate)=1 then 'January'
	        when MONTH(A.ShipOnBoardDate)=2 then 'February'
	        when MONTH(A.ShipOnBoardDate)=3 then 'March'
	        when MONTH(A.ShipOnBoardDate)=4 then 'April'
	        when MONTH(A.ShipOnBoardDate)=5 then 'May'
	        when MONTH(A.ShipOnBoardDate)=6 then 'June'
	        when MONTH(A.ShipOnBoardDate)=7 then 'July'
	        when MONTH(A.ShipOnBoardDate)=8 then 'August'
	        when MONTH(A.ShipOnBoardDate)=9 then 'September'
	        when MONTH(A.ShipOnBoardDate)=10 then 'October'
	        when MONTH(A.ShipOnBoardDate)=11 then 'November'
	        when MONTH(A.ShipOnBoardDate)=12 then 'December'
	        else ''
	   end BulanShipOnBoard,
        Case when MONTH(A.ETADestination)=1 then 'January'
	        when MONTH(A.ETADestination)=2 then 'February'
	        when MONTH(A.ETADestination)=3 then 'March'
	        when MONTH(A.ETADestination)=4 then 'April'
	        when MONTH(A.ETADestination)=5 then 'May'
	        when MONTH(A.ETADestination)=6 then 'June'
	        when MONTH(A.ETADestination)=7 then 'July'
	        when MONTH(A.ETADestination)=8 then 'August'
	        when MONTH(A.ETADestination)=9 then 'September'
	        when MONTH(A.ETADestination)=10 then 'October'
	        when MONTH(A.ETADestination)=11 then 'November'
	        when MONTH(A.ETADestination)=12 then 'December'
	        else ''
	   end BulanETADestination, B.Urut
from dbInvoicePL A
     left outer join dbInvoicePLDet b on b.NoBukti=A.NoBukti     
     left outer join DBBARANG E on E.KODEBRG=B.KodeBrg
     left Outer join (Select x.NoBukti, x.Urut, x.NoSPP
                      from dbSPBDet x
                      Group by x.NoBukti, x.Urut, x.NoSPP) F on F.NoBukti=B.NoSPB and F.Urut=B.UrutSPB
     left outer join (Select NoBukti, NoSO
                      from dbSPPDet x
                      Group by NoBukti, NoSO) G on G.NoBukti=f.NoSPP
     left Outer join DBSO H on H.NoBukti=G.NoSo
     left outer join vwBrowsCustomer c on c.KODECUST=A.KodeCustSupp and c.Sales=H.KODESLS
Group by A.NoBukti, A.NoUrut, A.Tanggal, A.PPN, A.Valas, A.Kurs, A.KodeCustSupp, A.Consignee, A.NotifyParty, A.StuffingDate, 
       A.StuffingPlace, A.ContractNo, A.PONo, A.PaymentTerm, 
       A.DocCreditNo, A.PoL, A.PoD, A.NameOfVessel, A.Feeder_Vessel, A.Connect_Vessel, A.ShipOnBoardDate, A.Packing, 
       A.Others, A.IsCetak, A.IDUser, A.IsLokal, A.NoBL, A.NoteBeneficiary1, 
       A.NoteBeneficiary2, A.NoteBeneficiary3, A.ShipmentAdvice1, A.ShipmentAdvice2, A.ETADestination, A.ToShipmentAdvice2, A.NoPajak, A.TglFPJ, 
       A.Footnote, A.IssuingBank, A.MyID, 
       A.IsOtorisasi1, A.OtoUser1, A.TglOto1,
       A.IsOtorisasi2, A.OtoUser2, A.TglOto2, 
       A.IsOtorisasi3, A.OtoUser3, A.TglOto3, 
       A.IsOtorisasi4, A.OtoUser4, A.TglOto4, 
       A.IsOtorisasi5, A.OtoUser5, A.TglOto5,
       B.Kodebrg,B.Namabrg,B.NOSAT, B.SAT_1, B.SAT_2, B.Harga,
       
       B.ShippingMark, B.KetDetail, B.NetW, B.GrossW, B.Meas,
       E.Namabrg,       
       Case when C.USAHA<>'' then C.USAHA+'. ' else '' end+C.NAMACUST,
       C.Alamat,C.kodeKota,C.USAHA, C.TELPON, B.Urut,
      
	   Case when MONTH(A.tanggal)=1 then 'January'
	        when MONTH(A.tanggal)=2 then 'February'
	        when MONTH(A.tanggal)=3 then 'March'
	        when MONTH(A.tanggal)=4 then 'April'
	        when MONTH(A.tanggal)=5 then 'May'
	        when MONTH(A.tanggal)=6 then 'June'
	        when MONTH(A.tanggal)=7 then 'July'
	        when MONTH(A.tanggal)=8 then 'August'
	        when MONTH(A.tanggal)=9 then 'September'
	        when MONTH(A.tanggal)=10 then 'October'
	        when MONTH(A.tanggal)=11 then 'November'
	        when MONTH(A.tanggal)=12 then 'December'
	        else ''
	   end,
	   Case when MONTH(A.ShipOnBoardDate)=1 then 'January'
	        when MONTH(A.ShipOnBoardDate)=2 then 'February'
	        when MONTH(A.ShipOnBoardDate)=3 then 'March'
	        when MONTH(A.ShipOnBoardDate)=4 then 'April'
	        when MONTH(A.ShipOnBoardDate)=5 then 'May'
	        when MONTH(A.ShipOnBoardDate)=6 then 'June'
	        when MONTH(A.ShipOnBoardDate)=7 then 'July'
	        when MONTH(A.ShipOnBoardDate)=8 then 'August'
	        when MONTH(A.ShipOnBoardDate)=9 then 'September'
	        when MONTH(A.ShipOnBoardDate)=10 then 'October'
	        when MONTH(A.ShipOnBoardDate)=11 then 'November'
	        when MONTH(A.ShipOnBoardDate)=12 then 'December'
	        else ''
	   end,
         Case when MONTH(A.ETADestination)=1 then 'January'
	        when MONTH(A.ETADestination)=2 then 'February'
	        when MONTH(A.ETADestination)=3 then 'March'
	        when MONTH(A.ETADestination)=4 then 'April'
	        when MONTH(A.ETADestination)=5 then 'May'
	        when MONTH(A.ETADestination)=6 then 'June'
	        when MONTH(A.ETADestination)=7 then 'July'
	        when MONTH(A.ETADestination)=8 then 'August'
	        when MONTH(A.ETADestination)=9 then 'September'
	        when MONTH(A.ETADestination)=10 then 'October'
	        when MONTH(A.ETADestination)=11 then 'November'
	        when MONTH(A.ETADestination)=12 then 'December'
	        else ''
	   end

GO

-- View: vwCetakInvoicePLLampiran
-- Created: 2011-12-29 00:14:08.890 | Modified: 2011-12-29 00:19:18.353
-- =====================================================
CREATE View dbo.vwCetakInvoicePLLampiran
as
Select a.Nobukti, a.Urut, a.Keterangan, a.KodeVls, a.Kurs, a.Harga, a.NNet
from DBInvoicePLLampiran a                     
GO

-- View: vwcetakquotation
-- Created: 2011-10-19 08:41:19.473 | Modified: 2011-10-19 08:41:19.473
-- =====================================================


CREATE View [dbo].[vwcetakquotation]
as

select a.nobukti,b.kodecustsupp,b.Term_of_Payment, b.Packing,b.Delivery,b.Price_Validity,
       Case when z.USAHA<>'' then z.USAHA+'. ' else '' end+ z.NAMACUSTSUPP NamaCustSupp,      
       z.contactp,a.kodebrg,x.NAMABRG,x.Ukr_Kertas,x.Jns_Kertas,
       a.Sat_1 sat1det,a.Sat_2 sat2det,a.Nosat nosatdet,a.Qnt qntdet,a.Qnt2 qnt2det,
       c.Qnt qntkirim, c.TGLKirim tglkirim,A.harga,
       case when c.Nosat = 1 then Case when c.Nosat is not null then c.qnt else a.Qnt end
            when c.Nosat = 2 then Case when c.Nosat is not null then c.Qnt2 else a.Qnt2 end
       end Unit,
       case when c.Nosat = 1 then Case when c.Nosat is not null then c.Sat_1 else a.Sat_1 end
            when c.Nosat = 2 then Case when c.Nosat is not null then c.Sat_2 else a.Sat_2 end
       end Satuan,
       case when c.Nosat = 1 then Case when c.Nosat is not null then c.qnt else a.Qnt end
            when c.Nosat = 2 then Case when c.Nosat is not null then c.Qnt2 else a.Qnt2 end
       end*a.Harga jumlah, A.Namabrg NamabrgKom,
       B.Tanggal, C.Keterangan,
       Case when z.USAHA<>'' then z.USAHA+'. ' else '' end+z.NAMACUSTSUPP NamaCustomer,
       z.Alamat+CAse when z.Kota<>'' then CHAR(13)+z.Kota else '' end+
       Case when z.NEGARA<>'' then CHAR(13)+z.NEGARA else '' end Alamat,
       B.Note_Quotation
from dbquotationdet a 
LEFT outer join dbQuotation b on a.Nobukti = b.Nobukti
left outer join vwBrowsCust z on b.KodecustSupp = z.KODECUSTSUPP
left outer join DBBARANGJADI x on a.KodeBrg = x.KODEBRG
left outer join DBQuotationKIRIM c on a.Nobukti = c.NoQuo and c.urutQuo=a.Urut

--where a.nobukti ='ENQ/0111/00002/SZZ'










GO

-- View: vwCetakRPJ
-- Created: 2013-01-15 15:04:00.153 | Modified: 2013-01-15 15:04:00.153
-- =====================================================



CREATE View [dbo].[vwCetakRPJ]
as
Select A.NOBUKTI, A.TANGGAL, B.NamaBrg,'' Ukr_Kertas,0.00 GSM, A.NoSO, A.TglSO, A.NoLKP, A.TGLLKP,
       B.NoSPB,d.Tanggal TglSPB, A.KODECUSTSUPP, C.NamaCust NAMACUSTSUPP, null TglRencanaPenarikan, null TglPengesahan,
       F.NoBukti NoSPR, F.Tanggal TglSPR, B.URUT, 
       Case when B.Nosat=1 then B.QNT
            when B.Nosat=2 then B.QNT2
            else 0
       End QntRPJ,
       Case when B.Nosat=1 then B.SAT_1
            when B.Nosat=2 then B.SAT_2
            else ''
       End SatRPJ,
       Case when F.Nosat=1 then F.QNT
            when F.Nosat=2 then F.QNT2
            else 0
       End QntSPR,
       Case when F.Nosat=1 then F.SAT_1
            when F.Nosat=2 then F.SAT_2
            else ''
       End SatSPR
From DBRInvoicePL A
     left outer join DBRInvoicePLDET B on B.NOBUKTI=A.NOBUKTI        
     left outer join (Select x0.NoBukti, x0.Urut, z.Tanggal, z.NoBukti NoSPB, x1.KODESLS, x1.KODECUST
                      from dbInvoicePLDet x0
                           left outer join dbSPBDet y on y.NoBukti=x0.Nospb and y.Urut=x0.UrutSPB
                           left outer join dbSPB z on z.NoBukti=y.NoBukti
                           left outer join dbSPPDet x on x.NoBukti=y.NoSPP and x.Urut=y.UrutSPP
                           left Outer join DBSO x1 on x1.NOBUKTI=x.NoSO
                           ) d on d.NoBukti=B.NoInvoice and d.Urut=B.UrutInvoice --and d.NoSPB=B.NoSPB
     left outer join DBBARANG E on E.KODEBRG=B.KODEBRG
     left outer join (Select x.NoBukti,x.Tanggal, y.NoRPJ, y.UrutRPJ, y.QNT, y.QNT2, y.SAT_1, y.SAT_2, y.NOSAT
                      from dbSPBRJual x
                           left outer join dbSPBRJualDet y on y.NoBukti=x.NoBukti) F on F.NoRPJ=b.NOBUKTI and F.UrutRPJ=B.URUT
     left outer join vwBrowsCustomer C on C.KODECUST=A.KODECUSTSUPP and C.Sales=d.KODESLS



GO

-- View: vwCetakRSPB
-- Created: 2013-03-09 10:54:19.740 | Modified: 2013-03-09 10:54:19.740
-- =====================================================




--select * from DBSPBreturdet
--select * from DBrSPBdet

CREATE View [dbo].[vwCetakRSPB]
as
select A.NOBUKTI, A.NOURUT, A.TANGGAL, A.KODECUSTSUPP, 
       Case when D.USAHA<>'' then D.USAHA+'. ' else '' end+D.NamaCust NamaCustSupp, 
       D.Alamat, D.NamaKota Kota, '' NEGARA,
        A0.NoSPP, A.NoPolKend,
        A.Container, A.NoContainer, A.NoSeal,
        A.ISCETAK, A.IDUser,
        B.URUT, B.KODEBRG, C.Namabrg, '' Jns_Kertas,'' Ukr_Kertas, B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.NoSat, B.ISI,
        Ax.UrutSPP, E.NoSO,E.TglSO,E.NOPO NoPesanan, A1.NamaKirim, A1.AlamatKirim,
        (Select NOSPB from DBNOMOR) NODOK, B.Namabrg NamaBrgkom,
         case when B.NOSAT = 1 then b.SAT_1 else b.SAT_2 end as satuanas,
         case when B.NOSAT = 1 then B.QNT else b.QNT2 end as QNTAS,
        A.Catatan, b.NetW, b.GrossW, A0.sopir
From DBRSPB A
left outer join dbSPB A0 on a.NoSPB = a0.NoBukti
left outer join dbSPBDet ax on a0.NoBukti = ax.NoBukti
left outer join dbSPP A1 on A1.NoBukti=A0.NoSPP
Left Outer Join (Select Nobukti, NoSO from dbSPPDet Group by NoBukti,NoSO) A2 on A2.NoBukti=A1.nobukti
Left Outer Join DBRSPBDET B on B.NoBukti=A.NoBukti
Left Outer Join dbBarang c On C.KodeBrg=B.KodeBrg
Left Outer Join vwBrowsCustomer D On D.KodeCust=A.KodeCustSupp
Left Outer join (Select y.Nobukti NoSO,y.Tanggal TglSO, y.NoPesanan Nopo
                 from DBSO y
                 group by y.Nobukti,y.Tanggal, y.NoPesanan) E on E.NoSO=A2.NoSo


GO

-- View: vwCetakRSpbLampiran
-- Created: 2013-03-09 10:54:39.357 | Modified: 2013-03-09 10:54:39.357
-- =====================================================





CREATE view [dbo].[vwCetakRSpbLampiran]
as
Select Case when A.NOROLL<>'' then A.NOROLL+' ' else '' end+
       Case when A.NOPALLET<>'' then A.NOPALLET+' ' else '' end+ 
       Case when A.NOLOT<>'' then A.NOLOT+' ' else '' end       
        NoLot, 
       B.Namabrg NamaBrgKom, C.Jns_Kertas, C.Ukr_Kertas, C.GSM,
       A.Qnt,A.Qnt2, A.Sat_1, A.Sat_2, A.NetW, A.GrossW, A.Keterangan,
       B.NoBukti,B.Tanggal, B.NoPolKend, B.NoContainer, B.NoSeal, A.Urut, A.UrutSPB,
       Case when A.Nosat=1 then a.Qnt
            when a.Nosat=2 then a.Qnt2
            else 0
       end Qty,
       Case when A.Nosat=1 then a.Sat_1
            when a.Nosat=2 then a.Sat_2
            else ''
       end Satuan,
       (Select NoSPB from dbnomor) NODok
From dbSPBLampiran A
     left Outer join (Select y.NoBukti, Y.Tanggal, y.NoContainer, y.NoPolKend, y.NoSeal,
                             x.Urut, x.KodeBrg, x.Namabrg
                      from dbRSPBDet x
                           left Outer join dbSPB y on y.NoBukti=x.NoBukti
                      ) B on B.NoBukti=A.NoSPB and B.Urut=A.UrutSPB
     left Outer join (Select kodebrg, namabrg, SAT1, Sat2, '' Jns_Kertas, '' Ukr_Kertas, 0.00 GSM from DBBARANG) C on C.KODEBRG=B.KodeBrg








GO

-- View: vwCetakSalesContract
-- Created: 2011-10-19 08:41:19.503 | Modified: 2011-12-27 19:36:12.920
-- =====================================================


CREATE View [dbo].[vwCetakSalesContract]
as
select a.nobukti,a.kodebrg,e.NAMABRG,b.Tanggal as tanggal,b.KodecustSupp,b.islokal,
       d.NAMAPKP NAMACUSTSUPP,
       a.Qnt qntdet,a.Qnt2 as qnt2det,
       b.Term_of_Payment,b.ACC_NO,b.Swift_Code,b.Shipment_Time,b.Last_Shipment_Time,b.Packing,       
       b.Consignee, b.Notify_Party, b.Port_of_Loading, b.Port_of_Discharge, b.TransShipment, b.Partial_Shipment,
       a.Ship_Mark, b.Remarks, c.Qnt qntkirim,
       c.Qnt2 qntkirim2,a.Harga HargaDet,a.Nosat,a.ppn,
       Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                          when a.Nosat=2 then a.Qnt2
                                          else 0
                                     end
            else Case when c.Nosat=1 then c.Qnt
                      when c.nosat=2 then c.qnt2
                      else 0
                 end
       end kuantitas,
       Case when c.NoSC is null then Case when a.Nosat=1 then a.Sat_1
                                          when a.Nosat=2 then a.Sat_2
                                          else ''
                                     end
            else Case when c.Nosat=1 then c.Sat_1
                      when c.nosat=2 then c.Sat_2
                      else ''
                 end
       end Satuan,
       Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                          when a.Nosat=2 then a.Qnt2
                                          else 0
                                     end
            else Case when c.Nosat=1 then c.Qnt
                      when c.nosat=2 then c.qnt2
                      else 0
                 end
       end*a.harga SubTotal,
       Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                          when a.Nosat=2 then a.Qnt2
                                          else 0
                                     end
            else Case when c.Nosat=1 then c.Qnt
                      when c.nosat=2 then c.qnt2
                      else 0
                 end
       end*a.harga*a.Kurs SubTotalRp,
       (Case when a.PPn in (1) then Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                        when a.Nosat=2 then a.Qnt2
                                                                        else 0
                                                                   end
                                          else Case when c.Nosat=1 then c.Qnt
                                                    when c.nosat=2 then c.qnt2
                                                    else 0
                                               end
                                     end*a.Harga
            when a.PPn=2 then(Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                 when a.Nosat=2 then a.Qnt2
                                                                 else 0
                                                            end
                                   else Case when c.Nosat=1 then c.Qnt
                                             when c.nosat=2 then c.qnt2
                                             else 0
                                               end
                              end*a.Harga)/1.1
            else 0
       end*0.1)*0.001 PPh,
       (Case when a.PPn in (1) then Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                        when a.Nosat=2 then a.Qnt2
                                                                        else 0
                                                                   end
                                          else Case when c.Nosat=1 then c.Qnt
                                                    when c.nosat=2 then c.qnt2
                                                    else 0
                                               end
                                     end*a.Harga
            when a.PPn=2 then(Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                 when a.Nosat=2 then a.Qnt2
                                                                 else 0
                                                            end
                                   else Case when c.Nosat=1 then c.Qnt
                                             when c.nosat=2 then c.qnt2
                                             else 0
                                               end
                              end*a.Harga)/1.1
            else 0
       end*0.1*a.Kurs)*0.001 PPhRp,
       Case when a.PPn in (0,1) then Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                        when a.Nosat=2 then a.Qnt2
                                                                        else 0
                                                                   end
                                          else Case when c.Nosat=1 then c.Qnt
                                                    when c.nosat=2 then c.qnt2
                                                    else 0
                                               end
                                     end*a.Harga
            when a.PPn=2 then(Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                 when a.Nosat=2 then a.Qnt2
                                                                 else 0
                                                            end
                                   else Case when c.Nosat=1 then c.Qnt
                                             when c.nosat=2 then c.qnt2
                                             else 0
                                               end
                              end*a.Harga)/1.1
            else 0
       end nDPP,
	    Case when a.PPn in (0,1) then Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                        when a.Nosat=2 then a.Qnt2
                                                                        else 0
                                                                   end
                                          else Case when c.Nosat=1 then c.Qnt
                                                    when c.nosat=2 then c.qnt2
                                                    else 0
                                               end
                                     end*a.Harga
            when a.PPn=2 then(Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                 when a.Nosat=2 then a.Qnt2
                                                                 else 0
                                                            end
                                   else Case when c.Nosat=1 then c.Qnt
                                             when c.nosat=2 then c.qnt2
                                             else 0
                                               end
                              end*a.Harga)/1.1
            else 0
       end*a.Kurs nDPPRp,
	    Case when a.PPn in (1) then Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                        when a.Nosat=2 then a.Qnt2
                                                                        else 0
                                                                   end
                                          else Case when c.Nosat=1 then c.Qnt
                                                    when c.nosat=2 then c.qnt2
                                                    else 0
                                               end
                                     end*a.Harga
            when a.PPn=2 then(Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                 when a.Nosat=2 then a.Qnt2
                                                                 else 0
                                                            end
                                   else Case when c.Nosat=1 then c.Qnt
                                             when c.nosat=2 then c.qnt2
                                             else 0
                                               end
                              end*a.Harga)/1.1
            else 0
       end*0.1 nPPn,
	    (Case when a.PPn in (1) then Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                        when a.Nosat=2 then a.Qnt2
                                                                        else 0
                                                                   end
                                          else Case when c.Nosat=1 then c.Qnt
                                                    when c.nosat=2 then c.qnt2
                                                    else 0
                                               end
                                     end*a.Harga
            when a.PPn=2 then(Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                 when a.Nosat=2 then a.Qnt2
                                                                 else 0
                                                            end
                                   else Case when c.Nosat=1 then c.Qnt
                                             when c.nosat=2 then c.qnt2
                                             else 0
                                               end
                              end*a.Harga)/1.1
            else 0
       end*0.1)*a.Kurs nPPnRp,
       Case when a.PPn in (0,1) then Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                        when a.Nosat=2 then a.Qnt2
                                                                        else 0
                                                                   end
                                          else Case when c.Nosat=1 then c.Qnt
                                                    when c.nosat=2 then c.qnt2
                                                    else 0
                                               end
                                     end*a.Harga
            when a.PPn=2 then(Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                 when a.Nosat=2 then a.Qnt2
                                                                 else 0
                                                            end
                                   else Case when c.Nosat=1 then c.Qnt
                                             when c.nosat=2 then c.qnt2
                                             else 0
                                               end
                              end*a.Harga)/1.1
            else 0
       end+(
       Case when a.PPn in (1) then Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                        when a.Nosat=2 then a.Qnt2
                                                                        else 0
                                                                   end
                                          else Case when c.Nosat=1 then c.Qnt
                                                    when c.nosat=2 then c.qnt2
                                                    else 0
                                               end
                                     end*a.Harga
            when a.PPn=2 then(Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                 when a.Nosat=2 then a.Qnt2
                                                                 else 0
                                                            end
                                   else Case when c.Nosat=1 then c.Qnt
                                             when c.nosat=2 then c.qnt2
                                             else 0
                                               end
                              end*a.Harga)/1.1
            else 0
       end*0.1)+((
       Case when a.PPn in (1) then Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                        when a.Nosat=2 then a.Qnt2
                                                                        else 0
                                                                   end
                                          else Case when c.Nosat=1 then c.Qnt
                                                    when c.nosat=2 then c.qnt2
                                                    else 0
                                               end
                                     end*a.Harga
            when a.PPn=2 then(Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                 when a.Nosat=2 then a.Qnt2
                                                                 else 0
                                                            end
                                   else Case when c.Nosat=1 then c.Qnt
                                             when c.nosat=2 then c.qnt2
                                             else 0
                                               end
                              end*a.Harga)/1.1
            else 0
       end*0.1)*0.001) jumlah,
	    (Case when a.PPn in (0,1) then Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                        when a.Nosat=2 then a.Qnt2
                                                                        else 0
                                                                   end
                                          else Case when c.Nosat=1 then c.Qnt
                                                    when c.nosat=2 then c.qnt2
                                                    else 0
                                               end
                                     end*a.Harga
            when a.PPn=2 then(Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                 when a.Nosat=2 then a.Qnt2
                                                                 else 0
                                                            end
                                   else Case when c.Nosat=1 then c.Qnt
                                             when c.nosat=2 then c.qnt2
                                             else 0
                                               end
                              end*a.Harga)/1.1
            else 0
       end+(
       Case when a.PPn in (1) then Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                        when a.Nosat=2 then a.Qnt2
                                                                        else 0
                                                                   end
                                          else Case when c.Nosat=1 then c.Qnt
                                                    when c.nosat=2 then c.qnt2
                                                    else 0
                                               end
                                     end*a.Harga
            when a.PPn=2 then(Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                 when a.Nosat=2 then a.Qnt2
                                                                 else 0
                                                            end
                                   else Case when c.Nosat=1 then c.Qnt
                                             when c.nosat=2 then c.qnt2
                                             else 0
                                               end
                              end*a.Harga)/1.1
            else 0
       end*0.1)+
       ((Case when a.PPn in (1) then Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                        when a.Nosat=2 then a.Qnt2
                                                                        else 0
                                                                   end
                                          else Case when c.Nosat=1 then c.Qnt
                                                    when c.nosat=2 then c.qnt2
                                                    else 0
                                               end
                                     end*a.Harga
            when a.PPn=2 then(Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                 when a.Nosat=2 then a.Qnt2
                                                                 else 0
                                                            end
                                   else Case when c.Nosat=1 then c.Qnt
                                             when c.nosat=2 then c.qnt2
                                             else 0
                                               end
                              end*a.Harga)/1.1
            else 0
       end*0.1)*0.001))*a.kurs jumlahRp,
        d.AlamatPKP+Case when d.KOTAPKP<>'' then CHAR(13)+d.KOTAPKP else '' end Alamat,
       c.Keterangan, a.NamaBrg NamabrgKom,a.Urut,
       a.Harga
from dbSalesContractdet a 
left outer join dbSalesContract b on a.Nobukti = b.Nobukti
left outer join DBSalesContractKIRIM c on a.Nobukti = c.NoSC and c.urutSC=a.Urut
left outer join vwBrowsCust d on b.KodecustSupp = d.KODECUSTSUPP
left outer join DBBARANGJADI e on a.Kodebrg = e.KODEBRG



GO

-- View: vwCetakSPB
-- Created: 2011-11-03 09:21:09.590 | Modified: 2013-01-07 12:13:39.737
-- =====================================================


CREATE View [dbo].[vwCetakSPB]
as
select A.NOBUKTI, A.NOURUT, A.TANGGAL, A.KODECUSTSUPP, 
       Case when D.USAHA<>'' then D.USAHA+'. ' else '' end+D.NamaCustSupp NamaCustSupp, 
       D.Alamat, D.Kota, D.NEGARA,
        A.NOSPP, A.NoPolKend,
        A.Container, A.NoContainer, A.NoSeal,
        A.ISCETAK, A.IDUser,
        B.URUT, B.KODEBRG, C.NamaBrg Namabrg, '' Jns_Kertas, ''Ukr_Kertas, B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.NoSat, B.ISI,
        B.UrutSPP, E.Nobukti Noso,E.TglSO,E.NOPO NoPesanan, A1.NamaKirim, A1.AlamatKirim,
        (Select NOSPB from DBNOMOR) NODOK, B.Namabrg NamaBrgkom,
        case when B.NOSAT = 1 then b.SAT_1 else b.SAT_2 end as satuanas,
        case when B.NOSAT = 1 then B.QNT else b.QNT2 end as QNTAS,
        A.Catatan
From DBSPB A
Left Outer Join DBSPBDET B on B.NoBukti=A.NoBukti
left outer join (Select  y.nobukti, y.tanggal, x.Urut, x.NoSO, x.UrutSO, y.NamaKirim, y.AlamatKirim
                 From dbSPPDet x
                      Left Outer join dbSPP y on y.nobukti=x.nobukti
                 )A1 on A1.NoBukti=B.NoSPP and A1.Urut=B.UrutSPP
Left Outer Join dbBarang c On C.KodeBrg=B.KodeBrg
Left Outer Join vwBrowsCust D On D.KodeCustSupp=A.KodeCustSupp
Left Outer join (Select x.Nobukti,y.Tanggal TglSO,'' Nopo, x.URUT
                 from DBSODET x      
                      Left Outer join DBSO y on y.NOBUKTI=x.NOBUKTI               
                 group by x.Nobukti, y.TANGGAL, x.URUT) E on E.Nobukti=A1.NoSO and E.URUT=A1.UrutSO

GO

-- View: vwCetakSpbLampiran
-- Created: 2011-11-03 09:21:09.603 | Modified: 2013-01-07 13:44:18.357
-- =====================================================

CREATE view [dbo].[vwCetakSpbLampiran]
as
Select Case when A.NOROLL<>'' then A.NOROLL+' ' else '' end+
       Case when A.NOPALLET<>'' then A.NOPALLET+' ' else '' end+ 
       Case when A.NOLOT<>'' then A.NOLOT+' ' else '' end       
        NoLot, 
       B.Namabrg NamaBrgKom, C.Jns_Kertas, C.Ukr_Kertas, C.GSM,
       A.Qnt,A.Qnt2, A.Sat_1, A.Sat_2, A.NetW, A.GrossW, A.Keterangan,
       B.NoBukti,B.Tanggal, B.NoPolKend, B.NoContainer, B.NoSeal, A.Urut, A.UrutSPB,
       Case when A.Nosat=1 then a.Qnt
            when a.Nosat=2 then a.Qnt2
            else 0
       end Qty,
       Case when A.Nosat=1 then a.Sat_1
            when a.Nosat=2 then a.Sat_2
            else ''
       end Satuan,
       (Select NoSPB from dbnomor) NODok, b.NoSPP
From dbSPBLampiran A
     left Outer join (Select y.NoBukti, Y.Tanggal, y.NoContainer, y.NoPolKend, y.NoSeal,
                             x.Urut, x.KodeBrg, x.Namabrg, x.NoSPP
                      from dbSPBDet x
                           left Outer join dbSPB y on y.NoBukti=x.NoBukti
                     ) B on B.NoBukti=A.NoSPB and B.Urut=A.UrutSPB
     left Outer join (Select kodebrg, namabrg, SAT1, Sat2, '' Jns_Kertas, '' Ukr_Kertas, 0.00 GSM from DBBARANG) C on C.KODEBRG=B.KodeBrg






GO

-- View: vwCetakSPP
-- Created: 2011-12-28 07:17:00.580 | Modified: 2013-01-04 15:35:43.570
-- =====================================================




CREATE View [dbo].[vwCetakSPP]
as


select a.NoBukti,a.NoSO NoSC,b.NoPesan,b.Tanggal,a.KodeBrg,d.NAMABRG namabrgdbbrg ,a.NamaBrg namabrgdbdet ,''Jns_Kertas,''Ukr_Kertas,
       c.NamaCust NAMACUSTSUPP,c.Alamat,'' ALAMAT1,''ALAMAT2,''ALAMATPKP1,'' ALAMATPKP2,c.kodekota Kota,
       case when a.NOSAT = 1 then a.SAT_1 else a.SAT_2 end satuan,
       case when a.NOSAT = 1 then a.QNT else a.QNT2 end QNT,
       b.TglKirim,'' ShippingMark,b.NoLC,b.Packing,b.Catatan, a.Urut
from 
dbSPPDet a 
left outer join dbSPP b on a.NoBukti = b.NoBukti
Left Outer Join vwOutSO_SPP E on E.Nobukti=a.NoSO and E.urut=a.UrutSO
Left Outer join DBSO G on G.Nobukti=A.NoSO
left outer join vwBrowsCustomer c on b.KodeCustSupp = c.KODECUST and c.Sales=G.KODESLS
left outer join DBBARANG d on a.KodeBrg = d.KODEBRG














GO

-- View: vwCost
-- Created: 2015-04-20 09:05:28.237 | Modified: 2015-04-20 09:05:28.237
-- =====================================================







CREATE VIEW [dbo].[vwCost]

AS
------ SALES
select  a.KodeCost,a.KodeSubCost,a.tanggal,C.NIK, C.Nama, A.DEBET Saldo, A.PERKIRAAN KodePerk,D.KETERANGAN 
from vwTransaksi A
left outer join DBPERKCOST B on B.Perkiraan = A.PERKIRAAN and B.KodeCost = A.KodeCost
left outer join dbKaryawan C on C.KodeCost = A.KodeCost and C.KeyNIK = A.KodeSubCost
left outer join DBPERKIRAAN D on d.Perkiraan=a.PERKIRAAN
where A.PERKIRAAN in (select PERKIRAAN from DBPERKCOST where KodeCost='SALES')
union all
select a.KodeCost,a.KodeSubCost,a.tanggal,C.NIK, C.Nama, -A.DEBET Saldo, A.LAWAN KodePerk,d.Keterangan
from vwTransaksi A
left outer join DBPERKCOST B on B.Perkiraan = A.PERKIRAAN and B.KodeCost = A.KodeCost
left outer join dbKaryawan C on C.KodeCost = A.KodeCost and C.KeyNIK = A.KodeSubCost
left outer join DBPERKIRAAN D on d.Perkiraan=a.LAWAN
where A.LAWAN in (select PERKIRAAN from DBPERKCOST where KodeCost='SALES' )
------ KENDARAAN
union all 
select  a.KodeCost,a.KodeSubCost,a.tanggal,C.KODEKEND, C.NAMAKEND, A.DEBET Saldo, A.PERKIRAAN KodePerk,D.KETERANGAN 
from vwTransaksi A
left outer join DBPERKCOST B on B.Perkiraan = A.PERKIRAAN and B.KodeCost = A.KodeCost
left outer join DBKENDARAAN C on C.KodeCost = A.KodeCost and C.KODEKEND = A.KodeSubCost
left outer join DBPERKIRAAN D on d.Perkiraan=a.PERKIRAAN
where A.PERKIRAAN in (select PERKIRAAN from DBPERKCOST where KodeCost='KEND')
union all
select a.KodeCost,a.KodeSubCost,a.tanggal,C.KODEKEND, C.NAMAKEND, -A.DEBET Saldo, A.LAWAN KodePerk,d.Keterangan
from vwTransaksi A
left outer join DBPERKCOST B on B.Perkiraan = A.PERKIRAAN and B.KodeCost = A.KodeCost
left outer join DBKENDARAAN C on C.KodeCost = A.KodeCost and C.KODEKEND = A.KodeSubCost
left outer join DBPERKIRAAN D on d.Perkiraan=a.LAWAN
where A.LAWAN in (select PERKIRAAN from DBPERKCOST where KodeCost='KEND' )









GO

-- View: vwCrossCheckBPPB
-- Created: 2011-12-16 17:07:49.720 | Modified: 2011-12-19 15:19:45.717
-- =====================================================

CREATE View [dbo].[vwCrossCheckBPPB]
as
Select *
from (Select x.Nobukti BPPB_Nobukti, x.Tanggal BPPB_Tanggal, x.Kodebag BPPB_kodebag, x.kodeBiaya BPPB_Kodebiaya, 
             x.SOP BPPB_SOP, x.KodeMesin BPPB_Kodemesin, x.KodeJnsPakai BPPB_KodejnsPakai, 
             x.JnsKertas BPPB_jnsKertas, x.IDUSER BPPB_IDUser, 
             x.JnsPakai BPPB_jnsPakai, x.Perk_Investasi BPPB_PerkInvestasi, x.Kodegdg BPPB_kodegdg,
             y.urut BPPB_Urut, y.kodebrg BPPB_kodebrg, y.Sat_1 BPPB_Sat_1 , y.Sat_2 BPPB_Sat_2 , y.Nosat BPPB_Nosat, 
             Case when y.Nosat=1 then y.Qnt 
                  when y.Nosat=2 then y.Qnt2
                  else 0
             end BPPB_Qty,
             Case when y.Nosat=1 then y.Sat_1
                  when y.Nosat=2 then y.Sat_2
                  else ''
             end BPPB_Satuan,
             y.Isi BPPB_Isi, y.Qnt BPPB_Qnt, y.Qnt2 BPPB_Qnt2, y.TglTiba BPPB_TglTiba, 
             y.TglButuh BPPB_TglButuh, y.MyID BPPB_MyID, y.isInspeksi BPPB_isInspeksi, 
             y.Keterangan BPPB_Keterangan, y.QntBtl BPPB_QntBatal, y.Qnt2Btl BPPB_Qnt2Btl, 
             y.UrutTrans BPPB_UrutTrans, y.HPP BPPB_HPP, y.Nnet BPPB_Nnet,
             Case when x.JnsPakai=0 then 'Stock'
                  when x.JnsPakai=1 then 'Investasi'
                  when x.JnsPakai=2 then 'Rep & Pem Teknik'
                  when x.JnsPakai=3 then 'Rep & Pem Komputer'
                  when x.JnsPakai=4 then 'Rep & Pem Peralatan'
             end BPPB_MyJnsPakai,
             z.*                      
      from DBPermintaanBrg x
           left Outer join DBPermintaanBrgDET y on y.Nobukti=x.Nobukti
           left Outer join (Select x.Nobukti BBPPB_Nobukti, x.Tanggal BBPPB_Tanggal,
                                   y.urut BBPPB_urut,y.kodebrg BBPPB_Kodebrg, 
											  Case when y.Nosat=1 then y.Qnt 
										    		 when y.Nosat=2 then y.Qnt2
													 else 0
											  end BBPPB_Qty,
											  Case when y.Nosat=1 then y.Sat_1
											 		 when y.Nosat=2 then y.Sat_2
													 else ''
											  end BBPPB_Satuan,
											  y.Sat_1 BBPPB_Sat_1, y.Sat_2 BBPPB_Sat_2, 
											  y.Isi BBPPB_Isi, y.Nosat BBPPB_Nosat, y.Qnt BBPPB_Qnt, Y.Qnt2 BBPPB_Qnt2, 
											  Y.NoBPPB BBPPB_NoBPPB, Y.UrutBPPB BBPPB_UrutBPPB, 
											  y.Keterangan BBPPB_Keterangan, y.MyID BBPPB_MyID, y.UrutTrans BBPPB_UrutTrans, 
											  y.HPP BBPPB_HPP,y.nnet BBPPB_nNet
                      from DBBatalMintaBrg x
                      left Outer join DBBatalMintaBrgDET y on y.Nobukti=x.Nobukti) z on z.BBPPB_NoBPPB=x.Nobukti and z.BBPPB_UrutBPPB=y.urut) a                                                          
     left Outer join (Select x. Nobukti BPB_Nobukti, x.Tanggal BPB_Tanggal, 
                             x.Kodebag BPB_kodebag, x.kodeBiaya BPB_KodeBiaya, 
                             x.SOP BPB_SOP, x.KodeMesin BPB_KodeMesin, 
                             x.KodeJnsPakai BPB_KodeJnsPakai, x.JnsKertas BPB_JnsKertas, IDUser BPB_IDUSER, 
                             x.NoBPPB BPB_NOBPPB,x.JnsPakai BPB_JnsPakai, 
                             x.Perk_Investasi BPB_Perk_Investasi, x.Kodegdg BPB_Kodegdg,
                             y.urut BPB_Urut, y.kodebrg BPB_Kodebrg, 
                             Case when y.Nosat=1 then y.Qnt 
											 when y.Nosat=2 then y.Qnt2
									 		 else 0
									  end BPB_Qty,
									  Case when y.Nosat=1 then y.Sat_1
									 		 when y.Nosat=2 then y.Sat_2
											 else ''
									  end BPB_Satuan,
                             y.Sat_1 BPB_Sat_1, y.Sat_2 BPB_Sat_2, y.Nosat BPB_Nosat, 
                             y.Isi BPB_ISI, y.Qnt BPB_Qnt, y.Qnt2 BPB_Qnt2, 
                             y.TglTiba BPB_TglTiba, y.MyID BPB_MyID, 
                             y.NoPermintaan BPB_NoPermintaan, 
                             y.UrutPermintaan BPB_UrutPermintaan, 
                             y.IsInspeksi BPB_IsInspeksi, 
                             y.UrutTrans BPB_UrutTrans, y.KetDet BPB_KetDet, y.HPP BPB_HPP, Y.NNet BPB_NNet,
                             Case when x.JnsPakai=0 then 'Stock'
											 when x.JnsPakai=1 then 'Investasi'
											 when x.JnsPakai=2 then 'Rep & Pem Teknik'
											 when x.JnsPakai=3 then 'Rep & Pem Komputer'
											 when x.JnsPakai=4 then 'Rep & Pem Peralatan'
									  end BPB_MyJnsPakai,
                             z.*
                      from DBPenyerahanBrg x
                      left Outer join DBPenyerahanBrgDET y on y.Nobukti=x.Nobukti
                      left outer join (Select x.Nobukti RBPB_Nobukti, x.Tanggal RBPB_Tanggal, x.Kodebag RBPB_KodeBag, 
															 x.kodeBiaya RBPB_Kodebiaya, x.SOP RBPB_SOP, x.KodeMesin RBPB_kodeMesin, x.KodeJnsPakai RBPB_KodeJnsPakai, 
															 x.JnsKertas RBPB_JnsKertas, x.IDUser RBPB_IDUSER,                             
															 x.JnsPakai RBPB_JnsPakai, x.Perk_Investasi RBPB_Perk_Investasi,
															 y.urut RBPB_urut, y.kodebrg RBPB_kodebrg, 
															 Case when y.Nosat=1 then y.Qnt 
																	 when y.Nosat=2 then y.Qnt2
									 								 else 0
															  end RBPB_Qty,
															  Case when y.Nosat=1 then y.Sat_1
									 								 when y.Nosat=2 then y.Sat_2
																	 else ''
															  end RBPB_Satuan,
															 y.Sat_1 RBPB_Sat_1, 
															 y.Sat_2 RBPB_Sat_2, y.Nosat RBPB_Nosat, y.Isi RBPB_isi, 
															 y.Qnt RBPB_qnt, y.Qnt2 RBPB_Qnt2, y.TglTiba RBPB_TglTiba, y.MyID RBPB_MyID, 
															 y.NoPenyerahan RBPB_NoPenyerahan, y.UrutPenyerahan RBPB_urutPenyerahan, 
															 y.IsInspeksi RBPB_IsInspeksi, y.UrutTrans RBPB_UrutTrans, y.KetDet RBPB_KetDet, 
															 y.HPP RBPB_HPP, y.NNet RBPB_NNet,
															 Case when x.JnsPakai=0 then 'Stock'
																	 when x.JnsPakai=1 then 'Investasi'
																	 when x.JnsPakai=2 then 'Rep & Pem Teknik'
																	 when x.JnsPakai=3 then 'Rep & Pem Komputer'
																	 when x.JnsPakai=4 then 'Rep & Pem Peralatan'
															  end RBPB_MyJnsPakai
													from DBRPenyerahanBrg x
														  left outer join DBRPenyerahanBrgDET y on y.Nobukti=y.Nobukti)z on z.RBPB_NoPenyerahan=x.Nobukti and z.RBPB_urutPenyerahan=y.Urut) b on b.BPB_NoPermintaan=a.BPPB_Nobukti and b.BPB_UrutPermintaan=a.BPPB_Urut    
   left outer join (select  x.Nobukti PPL_Nobukti,x.Tanggal PPL_Tanggal, x.TglKirim PPL_TglKirim, 
                            x.IDUser PPL_IDUser, x.RefNoPermintaan PPL_RefNoPermintaan, x.RefBagPermintaan PPL_RefBagPermintaan, 
                            x.RefNamaBagPermintaan PPL_RefNamaBagPermintaan, x.RefTglPermintaan PPL_RefTglPermintaan,
                            y.urut PPL_urut, y.kodebrg PPL_kodebrg, 
                            Case when y.Nosat=1 then y.Qnt 
											 when y.Nosat=2 then y.Qnt2
									 		 else 0
									  end PPL_Qty,
									  Case when y.Nosat=1 then y.Sat_1
									 		 when y.Nosat=2 then y.Sat_2
											 else ''
									  end PPL_Satuan,y.Sat_1 PPL_Sat_1, y.Sat_2 PPL_Sat_2, y.Nosat PPL_Nosat, 
                            y.Isi PPL_isi, y.Qnt PPL_Qnt, y.Qnt2 PPL_Qnt2, y.TglTiba PPL_TglTiba, y.MyID PPL_MyId, 
                            y.NoPermintaan PPL_NoPermintaan, y.UrutPermintaan PPL_UrutPermintaan, y.Keterangan PPL_Keterangan, 
                            y.QntBtl PPL_QntBtl, y.Qnt2Btl PPL_Qnt2Btl, y.UrutTrans PPL_UrutTrans, y.Pelaksana PPL_Pelaksan, 
                            y.HPP PPL_HPP, Y.NNet PPL_NNet,
                            z.*
                    from DBPPL x
                         left outer join DBPPLDET y on y.Nobukti=x.Nobukti
                         left outer join (Select x.Nobukti BPL_Nobukti, x.Tanggal BPL_Tanggal, x.IDUser BPL_IDuser, 
                                                 y.urut BPL_urut, y.kodebrg BPL_Kodebrg, 
                                                 Case when y.Nosat=1 then y.Qnt 
																		 when y.Nosat=2 then y.Qnt2
									 									 else 0
																  end BPL_Qty,
																  Case when y.Nosat=1 then y.Sat_1
									 									 when y.Nosat=2 then y.Sat_2
																		 else ''
																  end BPL_Satuan,
                                                 y.Sat_1 BPL_Sat_1, 
                                                 y.Sat_2 BPL_Sat_2, y.Isi BPL_isi, y.Nosat BPL_nosat, 
                                                 y.Qnt BPL_Qnt, y.Qnt2 BPL_Qnt2, y.TglTiba BPL_TglTiba, y.MyID BPL_MyID, 
                                                 y.NoPPL BPL_NoPPL, y.UrutPPL BPL_UrutPPL, y.Keterangan BPL_Keterangan, 
                                                 y.NoBatalMintaBrg BPL_NoBatalMintaBrg, y.UrutBatalMintaBrg BPL_UrutBatalMintaBrg, 
                                                 y.UrutTrans BPL_UrutTrans,y.HPP BPL_HPP, y.NNet BPL_NNet
                                          from DBBatalPPL x
                                               left outer join DBBatalPPLDET y on y.Nobukti=x.Nobukti) z on z.BPL_NoPPL=x.Nobukti and z.BPL_UrutPPL=y.urut) c on c.PPL_NoPermintaan=a.BPPB_Nobukti and c.PPL_UrutPermintaan=a.BPPB_Urut
   left outer join (select x.NOBUKTI PO_Nobukti, x.TANGGAL PO_Tanggal, x.TglJatuhTempo PO_TgljatuhTempo, x.KODECUSTSUPP PO_kodecustsupp, 
                           x.RefInt PO_RefInt, x.RefVen PO_RefVendor, x.KODEVLS PO_Kodevls, x.KURS PO_Kurs, 
                           x.PPN PO_PPN, x.TIPEBAYAR PO_TipeBayar, x.HARI PO_Hari, x.TIPEDISC PO_TipeDisc, x.DISC PO_DISC, x.DISCRP PO_DISCRP, 
                           x.NILAIPOT PO_NilaiPot,x.NILAIDPP PO_NilaiDPP, x.NILAIPPN PO_NilaiPPN, 
                           x.NILAINET PO_NilaiNet, x.NILAIPOTRp PO_NilaiPotRp, x.NILAIDPPRp PO_NilaiDPPRp, x.NILAIPPNRp PO_NilaiPPnRp, 
                           x.NILAINETRp PO_NilaiNetRp, x.ISCETAK PO_IsCetak, x.Tipe PO_Tipe, x.IsLengkap PO_Lengkap, 
                           x.PPH PO_PPh, x.Freight PO_Freight, x.Lain2 PO_Lain2, x.IDUser PO_IDUser, 
                           x.RevisiKe PO_RevisiKe,x.TanggalPO PO_TanggalPO,  
                           y.URUT PO_Urut, y.NoPPL PO_NOPPL, y.UrutPPL PO_UrutPPL, 
                           y.KODEBRG PO_Kodebrg,
                           Case when y.Nosat=1 then y.Qnt 
											 when y.Nosat=2 then y.Qnt2
									 		 else 0
									  end PO_Qty,
									  Case when y.Nosat=1 then y.Sat_1
									 		 when y.Nosat=2 then y.Sat_2
											 else ''
									  end PO_Satuan,
                           y.QNT PO_Qnt, y.QNT2 PO_Qnt2, y.SAT_1 PO_Sat_1, y.SAT_2 PO_Sat_2, 
                           y.Nosat PO_Nosat, y.ISI PO_Isi, y.Toleransi PO_Toleransi, y.HARGA PO_Harga, 
                           y.DiscP1 PO_DiscP1, y.DiscRp1 PO_DiscRp1, y.DiscP2 PO_DiscP2, y.DiscRp2 PO_DiscRp2, 
                           y.DiscP3 PO_Discp3, y.DiscRp3 PO_DiscRp3, y.DiscP4 PO_DiscP4, y.DiscRp4 PO_DiscRp4, 
                           y.DISCTOT PO_DiscTot, y.HRGNETTO PO_HrgNetto, y.NDISKON PO_NDiskon, y.NDISKONTOT PO_NDiskonTot, 
                           y.BRUTTO PO_Brutto, y.SUBTOTAL PO_SubTotal, y.NDPP PO_NDPP, y.NPPN PO_NPPn, y.NNET PO_NNet,
                           y.SUBTOTALRp PO_SubTotalRp, y.NDPPRp PO_NdppRp, y.NPPNRp PO_nPPnRp, y.NNETRp PO_NnetRp, 
                           y.NOPO PO_NOPO, y.MyID PO_MyID, y.Catatan PO_Catatan, y.QntBtl PO_QntBtl, 
                           y.Qnt2Btl PO_Qnt2Btl, y.UrutTrans PO_UrutTrans, y.TglKirimPO PO_TglKirimPO,
                           z.*
                    from DBPO x
                         left outer join DBPODET y on y.NOBUKTI=x.NOBUKTI
                         left outer join (select  x.Nobukti BPO_NoBukti, x.Tanggal BPO_Tanggal, x.JenisBatal BPO_JenisBatal,
                                                  y.urut BPO_Urut, y.kodebrg BPO_kodebrg, 
                                                  Case when y.Nosat=1 then y.Qnt 
																		 when y.Nosat=2 then y.Qnt2
									 									 else 0
																  end BPO_Qty,
																  Case when y.Nosat=1 then y.Sat_1
									 									 when y.Nosat=2 then y.Sat_2
																		 else ''
																  end BPO_Satuan,
                                                  y.Sat_1 BPO_Sat_1, y.Sat_2 BPO_Sat_2, 
                                                  y.Nosat BPO_Nosat, y.Isi BPO_Isi, y.Qnt BPO_Qnt, y.Qnt2 BPO_Qnt2, 
                                                  y.MyID BPO_MyID, y.NoPO BPO_NoPO, y.UrutPO BPO_UrutPO, 
                                                  y.Keterangan BPO_Keterangan, y.UrutTrans BPO_UrutTans, 
                                                  y.HPP BPO_Hpp, y.NNet BPO_Nnet
                                          from DBBatalPO x
                                               left outer join DBBatalPODET y on y.Nobukti=x.Nobukti) z on z.BPO_NoPO=x.NOBUKTI and z.BPO_UrutPO=y.URUT) d on d.PO_NOPPL=c.PPL_Nobukti and d.PO_UrutPPL=c.PPL_urut
                                               
                                               
                          
                      
     

GO

-- View: vwCUSTSUPP
-- Created: 2014-07-10 09:42:03.920 | Modified: 2014-07-10 09:42:03.920
-- =====================================================

CREATE View [dbo].[vwCUSTSUPP]
as
     
select	A.KODECUSTSUPP, A.NAMACUSTSUPP, A.ALAMAT1, A.ALAMAT2, A.Kota,  
	A.TELPON, A.FAX, A.EMAIL, A.KODEPOS, A.NEGARA, A.NPWP, 
	A.Tanggal, A.PLAFON, A.HARI, A.HARIHUTPIUT, A.BERIKAT, A.USAHA, 
	A.JENIS, A.NAMAPKP, A.ALAMATPKP1, A.ALAMATPKP2, A.KOTAPKP, 
	A.Sales, A.KodeVls, A.KodeExp, A.KodeTipe, A.IsPpn, A.IsAktif, A.Kind, 
	A.ContactP, A.Alamat1ContP, A.Alamat2ContP, A.KotaContP, A.NegaraContP, 
	A.TelpContP, A.FaxContP, A.EmailContP, A.KODEPOSContP, A.HPContP, 
	A.SyaratPenerimaan, A.SyaratPembayaran, A.Agent, A.Alamat1A, A.Alamat2A, 
	A.KotaA, A.NegaraA, A.ContactA, A.TelpA, A.FaxA, A.EmailA, A.KODEPOSA, 
	A.HPA, A.EmailContA, A.PortOfLoading, A.CountryOfOrigin, 
	A.TglInput, A.iskontrak, A.PPN, A.HargaKe,
	A.ALAMAT1+case when ltrim(A.Alamat2)='' then '' else CHAR(13)+A.ALAMAT2 end ALAMAT,
	A.ALAMAT1+case when ltrim(A.Alamat2)='' then '' else CHAR(13)+A.ALAMAT2 end+CHAR(13)+A.Kota ALAMATKOTA,
	A.Usaha+case when isnull(A.Usaha,'')='' then '' else '. ' end+A.NamaCustSupp Nama,
	A.ALAMATPKP1+case when ltrim(A.ALAMATPKP2)='' then '' else CHAR(13)+A.ALAMATPKP2 end ALAMATPKP,
	A.ALAMATPKP1+case when ltrim(A.ALAMATPKP2)='' then '' else CHAR(13)+A.ALAMATPKP2 end+CHAR(13)+A.KOTAPKP ALAMATKOTAPKP,
	case when A.iskontrak is null then 0 when A.iskontrak=0 then 0 when A.iskontrak=1 then 1 end xKontrak,
	cast(isnull(K.NamaKota,A.KOTA) as varchar(50)) NamaKota, cast(isnull(K.KodeArea,'') as varchar(20)) KodeArea, cast(isnull(Ar.NAMAAREA,'') as varchar(50)) NamaArea, 
	case when A.HargaKe=0 then 'Harga Jual 1'
		when A.HargaKe=1 then 'Harga Jual 2'
		when a.HargaKe=2 then 'Harga Jual 3'
		else ''
	end KetHarga,
	cast(case when A.PPN=0 then 'NONE' when A.PPN=1 then 'Exclude' when A.PPN=2 then 'Include' end as varchar(50)) MyPPN,
	cast(case when A.IsAktif=0 then 'Tidak Aktif' when A.IsAktif=1 then 'Aktif' end as varchar(50)) MyAktif
from	DBCUSTSUPP A
left outer join DBKOTA K on K.KodeKota=A.KOTA
left outer join DBAREA Ar on Ar.KODEAREA=K.KodeArea







GO

-- View: vwDetailKoreksi
-- Created: 2013-06-03 14:32:21.123 | Modified: 2013-06-03 14:32:21.123
-- =====================================================







CREATE View [dbo].[vwDetailKoreksi]
as
Select A.Nobukti,A.tanggal,A.note,A.ISCetak,b.kodebrg,C.namaBrg,c.KodeGrp,c.KodeSubGrp,
       b.SaldoComp,b.QntOpname,b.Selisih,
       A.Kodegdg, b.Qntdb,B.QntCr, c.Sat1 Satuan,b.nosat,B.isi,b.Harga,b.urut,d.nama NamaGDG,
       (b.qntdb-b.qntcr)*b.harga as Total,
       (b.qntdb)*b.harga  HrgAdi,
       (b.qntcr)*b.harga HrgAdo, b.HPP,
       Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi 
From dbKoreksi A 
     left outer join dbKoreksiDet B on b.nobukti=a.nobukti 
     left outer join dbBarang C on c.kodebrg=b.kodebrg 
     left outer join dbGudang D on d.kodegdg=A.kodegdg 












GO

-- View: vwDetailUbahKemasan
-- Created: 2013-01-03 09:08:44.647 | Modified: 2013-01-03 09:08:44.647
-- =====================================================


CREATE View vwDetailUbahKemasan
as
Select A.Nobukti,A.tanggal,A.note,A.ISCetak,b.kodebrg,C.namaBrg,
       b.Kodegdg,b.Qntdb,B.QntCr,b.Satuan,b.nosat,B.isi,b.Harga,b.urut,d.nama NamaGDG, 
       (b.qntdb-b.qntcr)*b.harga as Total, 
      (b.qntdb)*b.HPP2 HrgAdi,
      (b.qntcr)*b.hpp HrgADO,b.Hpp,b.HPP2
From dbubahKemasan A 
     left outer join dbUbahKemasanDet B on b.nobukti=a.nobukti 
     left outer join dbBarang C on c.kodebrg=b.kodebrg 
     left outer join dbGudang D on d.kodegdg=b.kodegdg 
    





GO

-- View: vwGroupCustSupp
-- Created: 2012-06-07 15:03:23.640 | Modified: 2012-06-07 15:03:23.640
-- =====================================================
CREATE View [dbo].[vwGroupCustSupp]
as
     
select case when isnull(Agent,'')='' then KODECUSTSUPP else ISNULL(Agent,'') end KodeCustSupp 
from DBCUSTSUPP
group by case when isnull(Agent,'')='' then KODECUSTSUPP else ISNULL(Agent,'') end



GO

-- View: vwGudang
-- Created: 2011-11-23 18:45:57.493 | Modified: 2011-11-23 18:45:57.493
-- =====================================================
Create View dbo.vwGudang
as
Select * from DBGUDANG

GO

-- View: vwHutPiut
-- Created: 2013-06-03 11:08:31.860 | Modified: 2015-04-20 11:09:40.500
-- =====================================================



CREATE VIEW [dbo].[vwHutPiut]
 
AS
SELECT    NoFaktur, NoRetur, TipeTrans, 
	upper(KodeCustSupp) KodeCustSupp, NoBukti, NoMsk, Urut, Tanggal, JatuhTempo, 
	Debet, Kredit, Saldo, Valas, Kurs, DebetD, KreditD, SaldoD, 
	KodeSales, Tipe, Perkiraan, Catatan, NOINVOICE, KodeVls_, Kurs_,FlagSimbol,KBLB
FROM dbo.DBHUTPIUT







GO

-- View: vwHutPiutBelumlunas
-- Created: 2011-01-24 10:09:24.217 | Modified: 2011-01-24 10:09:24.217
-- =====================================================
Create View dbo.vwHutPiutBelumlunas
as
SELECT DISTINCT NoFaktur, KodeCustSupp
FROM  dbo.vwHutpiut
GROUP BY NoFaktur, KodeCustSupp
HAVING (SUM(Case when Tipe='PT' then Debet-Kredit
                 when Tipe='HT' then Kredit-Debet
                 else 0
            end) <> 0)
GO

-- View: vwJabatan
-- Created: 2011-12-08 20:34:42.440 | Modified: 2011-12-08 20:34:42.440
-- =====================================================
create View vwJabatan
as
Select * from DBJABATAN
GO

-- View: vwJenis
-- Created: 2011-11-23 18:45:57.660 | Modified: 2011-11-23 18:45:57.660
-- =====================================================
Create View dbo.vwJenis
as
Select A.*
from DBJenis A     

GO

-- View: vwJenisJadi
-- Created: 2011-12-08 19:36:36.700 | Modified: 2011-12-08 19:36:36.700
-- =====================================================

Create View [dbo].[vwJenisJadi]
as
Select A.*
from DBJENISBRGJADI A     


GO

-- View: VwKartuBatch
-- Created: 2014-11-19 13:11:19.423 | Modified: 2014-11-19 13:11:19.423
-- =====================================================


Create View VwKartuBatch
as
select B.Tanggal,A.Nobukti,A.Nobatch,A.Kodebrg,C.NamaBrg,
ISnull(A.Qnt1Terima,0)-ISnull(A.Qnt1Reject,0) Qnt1,Isnull(A.Qnt2Terima,0)-ISnull(A.Qnt2Reject,0) Qnt2,
'BPBL' ID
from dbbelidet A
left outer join dbbeli B on A.nobukti=B.nobukti
left outer join dbbarang C on A.KODEBRG=C.KODEBRG
Union All
select B.Tanggal,A.Nobukti,A.Nobatch,A.Kodebrg,C.NAMABRG,
-A.Qnt Qnt,-A.Qnt2 Qnt,'BSPP' ID
from DbSPPDet A
left outer join dbSPP B on A.nobukti=B.nobukti
left outer join dbbarang C on A.KODEBRG=C.KODEBRG
Union All
select B.Tanggal,A.Nobukti,A.Nobatch,A.Kodebrg,C.NAMABRG,
-A.Qnt Qnt,-A.Qnt2 Qnt,'BRPB' ID
from DBRBELIDET A
left outer join DBRBELI B on A.nobukti=B.nobukti
left outer join dbbarang C on A.KODEBRG=C.KODEBRG
Union All
select B.Tanggal,A.Nobukti,A.Nobatch,A.Kodebrg,C.NAMABRG,
A.Qnt Qnt,A.Qnt2 Qnt,'RPNJ' ID
from dbSPBRJualDet A
left outer join dbSPBRJual B on A.nobukti=B.nobukti
left outer join dbbarang C on A.KODEBRG=C.KODEBRG

GO

-- View: vwKartuInvocePL
-- Created: 2013-05-13 12:08:51.547 | Modified: 2013-05-13 12:08:51.547
-- =====================================================



create view [dbo].[vwKartuInvocePL]
as
SELECT 'AWL' AS tipe, '00' Prioritas, '' KodeArea,'' Kodekota,'' KodeSls,b.Kodebrg, '' KodeGdg,0.00 QNT,0.00 NilaiDPP,0.00 NilaiPPN,0.00 jumlahNetto, 
       (b.qntAwal) AS QntDB, (b.Qnt2Awal) Qnt2DB, (b.HrgAwal) HrgDebet, 
       0.00 QntCr,  0.00 Qnt2Cr, 0.00 HrgKredit,
       (b.qntAwal) AS QntSaldo, (b.Qnt2Awal) Qnt2Saldo, (b.HrgAwal) HrgSaldo, 
       Dateadd(MM, 0, Cast(CASE WHEN b.Bulan < 10 THEN '0' ELSE '' END + Cast(b.Bulan AS varchar(2))+'-01-'+ 
                           Cast(b.Tahun AS varchar(4)) AS Datetime)) Tanggal, b.Bulan, b.Tahun, 'Saldo Awal' Nobukti,
      '' KodeCustSupp, '' Keterangan, '' IDUSER, B.HRGRATA HPP
FROM  DBSTOCKBRG b
where b.QNTAWAL<>0 or b.QNT2AWAL<>0
Union All
Select 	'IPL' Tipe, 'A2' Prioritas, e.KodeArea Kodearea,e.KodeKota,f.KeyNik Kodesls,B.KodeBrg, '' KodeGdg,Sum(B.QNT)Qnt,Sum(B.NDPP) NilaiDpp ,Sum(B.NPPN) NilaiPPN,Sum(b.NNET) Jumlahnetto,
   Sum(Isnull(B.Qnt,0)) QntDb, Sum(Isnull(B.Qnt2,0))-Sum(Isnull(B.Qnt2,0)) Qnt2Db, Sum(B.NDPP) HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	Sum(Isnull(B.Qnt,0)) QntSaldo, Sum(Isnull(B.Qnt2,0)) Qnt2Saldo, Sum(B.NDPP) HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	A.KodeCustSupp, '' Keterangan, ''IDUser,
	Sum(B.NDPP/Case when B.Nosat=1 then (B.Qnt)
	                       when B.Nosat=2 then (B.Qnt2)
	                  end)  HPP
from 	DBInvoicePL A
left outer join dbInvoicePLDet B on B.NoBukti=A.NoBukti
left outer join DBBARANG C on C.KODEBRG=B.KodeBrg
left outer join DBCUSTSUPP D on D.KODECUSTSUPP=a.KodeCustSupp 
left outer join DBKOTA E on E.KodeKota=D.Kota
left outer join DBSALESCUSTOMER f on f.KodeCustSupp=d.KODECUSTSUPP
Group By B.KodeBrg, A.TANGGAL,A.NOBUKTI,A.KodeCustSupp,e.KodeArea,f.KeyNik,e.KodeKota
union all
Select 	'RIPL' Tipe, 'B1' Prioritas,e.KodeArea kodearea,e.KodeKota ,f.KeyNik Kodesls,B.KodeBrg, '' KodeGdg,Sum(Isnull(B.QNT,0)),Sum(B.NDPP) NilaiDpp ,Sum(B.NPPN) NilaiPPN,Sum(b.NNET) Jumlahnetto,
   0.00 QntDb, 0.00 Qnt2Db, 0.00 HrgDebet,
	Sum(Isnull(B.Qnt,0)) QntCr, Sum(Isnull(B.Qnt2,0)) Qnt2Cr, Sum(B.NDPP) HrgKredit,
	Sum(-1*(Isnull(B.Qnt,0))) QntSaldo, SUM(-1*(Isnull(B.Qnt2,0))) Qnt2Saldo, SUM(-1*B.NDPP) HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	A.KODECUSTSUPP, '' Keterangan, ''IDUser,
   SUM( B.NDPP/Case when B.Nosat=1 then B.QNT 
	                       when B.Nosat=2 then B.QNT2 
	                  end) HPP
from 	DBRInvoicePL A
left outer join DBRInvoicePLDET B on B.NoBukti=A.NoBukti
left outer join DBBARANG C on C.KODEBRG=B.KodeBrg
left outer join DBCUSTSUPP D on D.KODECUSTSUPP=a.KodeCustSupp 
left outer join DBKOTA E on E.KodeKota=D.Kota
left outer join DBSALESCUSTOMER f on f.KodeCustSupp=d.KODECUSTSUPP
Group By B.KodeBrg,A.TANGGAL,A.NOBUKTI,A.KODECUSTSUPP,e.KodeArea,f.KeyNik,e.KodeKota

GO

-- View: vwKartuPersediaan
-- Created: 2011-10-13 13:03:16.273 | Modified: 2011-10-13 13:03:16.273
-- =====================================================


CREATE View [dbo].[vwKartuPersediaan]
as
Select 	'BPY' Tipe, 'B2' Prioritas, B.KodeBrg, 0.00 QntDb, 0.00 Qnt2Db,0 HrgDebet,
	B.Qnt QntCr, B.Qnt2 Qnt2Cr, 0.00 HrgKredit,
	-B.Qnt QntSaldo, -B.Qnt2 Qnt2Saldo, 0.00 HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	''KodeCustSupp, '' Keterangan, A.IDUser,
    0.00 HPP, A.Kodebag, '' NamaCustSupp
from DBPenyerahanBrg A
left outer join DBPenyerahanBrgDET B on B.NoBukti=A.NoBukti
union all
Select 	'RPB' Tipe, 'A3' Prioritas, B.KodeBrg,B.Qnt QntDb, B.Qnt2 Qnt2Db,0.00 HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	B.Qnt QntSaldo, B.Qnt2 Qnt2Saldo, 0.00 HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	''KodeCustSupp, '' Keterangan, A.IDUser,
    0.00 HPP, A.Kodebag,  '' NamaCustSupp
from DBRPenyerahanBrg A
left outer join DBRPenyerahanBrgDET B on B.NoBukti=A.NoBukti
union all
Select 	'BPB' Tipe, 'A2' Prioritas, B.KodeBrg, B.Qnt QntDb, B.Qnt2 Qnt2Db, B.NDPPRp HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	B.Qnt QntSaldo, B.Qnt2 Qnt2Saldo, B.NDPPRp HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	A.KodeCustSupp, '' Keterangan, A.IDUser,
	case when Case when B.Nosat=1 then B.QNT 
	               when B.Nosat=2 then B.QNT2 
	          end=0 then 0.00 
	    else B.NDPPRp/Case when B.Nosat=1 then B.QNT 
	                       when B.Nosat=2 then B.QNT2 
	                  end end HPP,
	'' Kodebag,  C.NamaCustSupp
from 	dbBeli A
left outer join dbBeliDet B on B.NoBukti=A.NoBukti
left outer join vwBrowsSupp C on C.Kodecustsupp=a.kodecustsupp
union all
Select 	'BRB' Tipe, 'B1' Prioritas, B.KodeBrg, 0.00 QntDb, 0.00 Qnt2Db, 0.00 HrgDebet,
	(B.Qnt-B.QNTTukar) QntCr, (B.Qnt2-B.QNT2Tukar) Qnt2Cr, B.NDPPRp HrgKredit,
	-(B.Qnt-B.QNTTukar) QntSaldo, -(B.QNT2-B.QNT2Tukar) Qnt2Saldo, -B.NDPPRp HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	A.KodeCustSupp, '' Keterangan, A.IDUser,
	case when Case when B.Nosat=1 then B.QNT 
	               when B.Nosat=2 then B.QNT2 
	          end=0 then 0.00 
	    else B.NDPPRp/Case when B.Nosat=1 then B.QNT 
	                       when B.Nosat=2 then B.QNT2 
	                  end end HPP,
	'' KodeBag,  C.NamaCustSupp
from 	dbRBeli A
left outer join dbRBeliDet B on B.NoBukti=A.NoBukti
left outer join vwBrowsSupp C on C.Kodecustsupp=a.kodecustsupp
union all
Select 	'ADI' Tipe, 'A2' Prioritas, B.KodeBrg, B.QntDb, B.QntDb2 Qnt2Db, B.QntDb*B.Harga HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	B.QntDb QntSaldo, B.QntDb2 Qnt2Saldo, B.QntDb*B.Harga HrgSaldo, 
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	'' KodeCustSupp, '' Keterangan, A.IDUser,
	B.Harga HPP, '' KodeBag,  '' NamaCustSupp
from 	dbKoreksi A
left outer join dbKoreksiDet B on B.NoBukti=A.NoBukti
where 	B.QntDb<>0 or B.QntDb2<>0
union all
Select 	'ADO' Tipe, 'B3' Prioritas, B.KodeBrg, 0.00 QntDb, 0.00 Qnt2Db, 0.00 HrgDebet,
	B.QntCr, B.QntCr2 Qnt2Cr, B.QntCr*B.HPP HrgKredit,
	-1*B.QntCr QntSaldo, -1*B.QntCr2 Qnt2Saldo, -1*B.QntCr*B.HPP HrgSaldo, 
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	'' KodeCustSupp, '' Keterangan, A.IDUser,
	B.HPP, '' KodeBag, '' NamaCustSupp
from 	dbKoreksi A
left outer join dbKoreksiDet B on B.NoBukti=A.NoBukti
where 	B.QntCr<>0 or B.QntCr2<>0









GO

-- View: vwKartuStock
-- Created: 2014-11-26 15:11:46.513 | Modified: 2014-11-26 15:11:46.513
-- =====================================================
CREATE view [dbo].[vwKartuStock]
as
SELECT 'AWL' AS Tipe, 'AWL' AS MyTipe, 'A00' Prioritas, b.Kodebrg, b.Kodegdg,0.00 QNT,0.00 NilaiDPP,0.00 NilaiPPN,0.00 jumlahNetto, 
       Sum(b.qntAwal) AS QntDB, Sum(b.Qnt2Awal) Qnt2DB, Sum(b.HrgAwal) HrgDebet, 
       0.00 QntCr,  0.00 Qnt2Cr, 0.00 HrgKredit,
       Sum(b.qntAwal) AS QntSaldo, Sum(b.Qnt2Awal) Qnt2Saldo, Sum(b.HrgAwal) HrgSaldo, 
       Dateadd(MM, 0, Cast(CASE WHEN b.Bulan < 10 THEN '0' ELSE '' END + Cast(b.Bulan AS varchar(2))+'-01-'+ 
                           Cast(b.Tahun AS varchar(4)) AS Datetime)) Tanggal, b.Bulan, b.Tahun, 
      'Saldo Awal' Nobukti, 0 Urut,
      '' KodeCustSupp, '' Keterangan, '' IDUSER, 
      case when Sum(b.qntAwal)=0 then 0 else Sum(B.HRGAwal)/Sum(b.qntAwal) end HPP,
      '' NoBukti1, '' NoBukti2
FROM  DBSTOCKBRG b
where b.QNTAWAL<>0 or b.QNT2AWAL<>0
Group by b.Kodebrg, b.Kodegdg, BULAN, TAHUN
union ALL

Select 	'PBL' Tipe, 'PBL' MyTipe, 'A10' Prioritas, B.KodeBrg, B.KodeGdg, B.QNT Qnt, B.NDPP NilaiDpp ,B.NPPN NilaiPPN, b.NNET Jumlahnetto,
   Isnull(B.Qnt1Terima,0)-Isnull(B.Qnt1Reject,0) QntDb, Isnull(B.Qnt2Terima,0)-Isnull(B.Qnt2Reject,0) Qnt2Db, B.NDPPRp HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	Isnull(B.Qnt1Terima,0)-Isnull(B.Qnt1Reject,0) QntSaldo, Isnull(B.Qnt2Terima,0)-Isnull(B.Qnt2Reject,0) Qnt2Saldo, B.NDPPRp HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.Urut,
	A.KodeSupp, d.NAMACUSTSUPP as  Keterangan, ''IDUser,
	B.NDPPRp/case when isnull(B.Qnt1Terima,0)-isnull(B.Qnt1Reject,0)=0 then 1 else isnull(B.Qnt1Terima,0)-isnull(B.Qnt1Reject,0) end   HPP,
	A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	dbBeli A
left outer join dbBeliDet B on B.NoBukti=A.NoBukti
left outer join DBBARANG C on C.KODEBRG=B.KodeBrg
left outer join dbcustsupp D on d.kodecustsupp=a.kodesupp

union all
Select 	'RPB' Tipe, 'RPB' MyTipe, 'B10' Prioritas, B.KodeBrg, A.KodeGdg,Isnull(B.QNT,0) QNT, B.NDPP NilaiDpp ,B.NPPN NilaiPPN, b.NNET Jumlahnetto,
   0.00 QntDb, 0.00 Qnt2Db, 0.00 HrgDebet,
	Isnull(B.Qnt1,0) QntCr, Isnull(B.Qnt2,0) Qnt2Cr, B.NDPP HrgKredit,
	-1*Isnull(B.Qnt1,0) QntSaldo, -1*Isnull(B.Qnt2,0) Qnt2Saldo, -1*B.NDPP HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.URUT,
	A.KodeSupp,d.namacustsupp as Keterangan, ''IDUser,
   B.NDPP/Case when B.Nosat=1 then B.Qnt1 
	                       when B.Nosat=2 then B.QNT2 
	                  end HPP,
	A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	dbRBeli A
left outer join dbRBeliDet B on B.NoBukti=A.NoBukti
left outer join DBBARANG C on C.KODEBRG=B.KodeBrg
left outer join dbcustsupp D on d.kodecustsupp=a.kodesupp
--Group By B.KodeBrg, A.KodeGdg,A.TANGGAL,A.NOBUKTI,A.KODESUPP, B.Urut
union all
Select 	'PMK' Tipe, 'PMK' MyTipe, 'B20' Prioritas, B.KodeBrg, A.KodeGdg,B.QNT QNt,0.00 NilaiDpp ,0.00 NilaiPPN,0.00 Jumlahnetto,
   0.00 QntDb, 0.00 Qnt2Db, 0.00 HrgDebet,
	Isnull(B.Qnt,0) QntCr, Isnull(B.Qnt2,0) Qnt2Cr, B.Qnt*isnull(B.HPP,0) HrgKredit,
	Isnull(B.Qnt,0)*-1 QntSaldo, Isnull(B.Qnt2,0)*-1 Qnt2Saldo, -1*B.Qnt*isnull(B.HPP,0) HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.Urut,
	''KodeSupp, '' Keterangan, ''IDUser,
	isnull(B.HPP,0) HPP,
	A.Nobukti NoBukti1, A.Nobukti NoBukti2
from 	DBPenyerahanBhn A
left outer join DBPenyerahanBhndet B on B.NoBukti=A.NoBukti
left outer join DBBARANG C on C.KODEBRG=B.KodeBrg
--Group By  B.KodeBrg, A.KodeGdg,A.Tanggal,A.Nobukti, B.Urut
union all
Select 	'RPK' Tipe, 'RPK' MyTipe, 'A20' Prioritas, B.KodeBrg, A.KodeGdg, B.QNT Qnt,0.00 NilaiDpp ,0.00 NilaiPPN,0.00 Jumlahnetto,
   B.Qnt QntDb, B.Qnt2 Qnt2Db, B.Qnt*isnull(B.HPP,0) HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit, 
	B.Qnt QntSaldo, B.Qnt2 Qnt2Saldo, B.Qnt*isnull(B.HPP,0) HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.Urut,
	''KodeSupp, '' Keterangan, ''IDUser,
	isnull(B.HPP,0) HPP,
	A.Nobukti NoBukti1, A.Nobukti NoBukti2
from 	DBRPenyerahanBhn A
left outer join DBRPenyerahanBhndet B on B.NoBukti=A.NoBukti
left outer join DBBARANG C on C.KODEBRG=B.KodeBrg
--Group By B.KodeBrg, A.KodeGdg,A.Tanggal,A.Nobukti, B.Urut
Union All
Select 	'TRI' Tipe, 'TRI' MyTipe, 'B05' Prioritas, B.KodeBrg, B.GdgTujuan,B.QNT Qnt,0.00 NilaiDpp ,0.00 NilaiPPN,0.00 Jumlahnetto,
   B.Qnt, B.Qnt2 Qnt2Db, B.Qnt*B.HPP HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	B.Qnt QntSaldo, B.Qnt2 Qnt2Saldo, B.Qnt*B.HPP HrgSaldo, 
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.Urut,
	'' KodeCustSupp, '' Keterangan, '' IDUSER,
	B.HPP HPP,
	A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	DBTRANSFER A
left outer join DBTRANSFERDET B on B.NoBukti=A.NoBukti
where 	B.Qnt<>0 or B.Qnt2<>0
--Group By B.KodeBrg, B.GdgTujuan,A.Tanggal, A.NoBukti, B.Urut
union all
Select 	'TRO' Tipe, 'TRO' MyTipe, 'B05' Prioritas, B.KodeBrg,B.GDGAsal,B.QNT QNT,0.00 NilaiDpp ,0.00 NilaiPPN,0.00 Jumlahnetto,
   0.00 QntDb, 0.00 Qnt2Db, 0.00 HrgDebet,
	B.Qnt, B.Qnt2 Qnt2Cr, B.Qnt*B.HPP HrgKredit,
	-1*B.Qnt QntSaldo, -1*B.Qnt2 Qnt2Saldo, -1*B.Qnt*B.HPP HrgSaldo, 
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.Urut,
	'' KodeCustSupp, '' Keterangan, ''IDUser,
	B.HPP HPP,
	A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	DBTRANSFER A
left outer join DBTRANSFERDET B on B.NoBukti=A.NoBukti
where 	B.Qnt<>0 or B.Qnt2<>0
--Group By B.KodeBrg, B.GDGASAL,A.Tanggal, A.NoBukti, B.Urut
union all
Select 	'TRI' Tipe, 'PBI' MyTipe, 'B06' Prioritas, B.KodeBrg, A.KodeGdgT, Isnull(B.QNT,0) Qnt,0.00 NilaiDpp ,0.00 NilaiPPN,0.00 Jumlahnetto,
   Isnull(B.Qnt,0) QntDb, Isnull(B.Qnt2,0) Qnt2Db, Isnull(B.Qnt,0)*ISNULL(B.HPP,0) HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	Isnull(B.Qnt,0) QntSaldo, Isnull(B.Qnt2,0) Qnt2Saldo, Isnull(B.Qnt,0)*ISNULL(B.HPP,0) HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.Urut,
	''KodeSupp, '' Keterangan, ''IDUser,
	isnull(B.HPP,0) HPP,
	A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	DBBPPBT A
left outer join DBBPPBTDET B on B.NoBukti=A.NoBukti
left outer join DBBARANG C on C.KODEBRG=B.KodeBrg
--Group By B.KodeBrg, A.KodeGdgT,A.TANGGAL,A.NOBUKTI, B.Urut
Union All
Select 	'TRO' Tipe, 'PBO' MyTipe, 'B06' Prioritas, B.KodeBrg, 'G001' KodeGdg,Isnull(B.QNT,0) Qnt,0.00 NilaiDpp ,0.00 NilaiPPN,0.00 Jumlahnetto,
    0.00 QntDb, 0.00 Qnt2Db, 0.00 HrgDebet,
	Isnull(B.Qnt,0) QntCr, Isnull(B.Qnt2,0) Qnt2Cr, Isnull(B.Qnt,0)*ISNULL(B.HPP,0) HrgKredit, 
	Isnull(B.Qnt,0)*-1 QntSaldo, Isnull(B.Qnt2,0)*-1 Qnt2Saldo, -1*Isnull(B.Qnt,0)*ISNULL(B.HPP,0) HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.Urut,
	''KodeSupp, '' Keterangan, ''IDUser,
	isnull(B.HPP,0) HPP,
	A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	DBBPPBT A
left outer join DBBPPBTdet B on B.NoBukti=A.NoBukti
left outer join DBBARANG C on C.KODEBRG=B.KodeBrg
--Group By B.KodeBrg, A.KodeGdg,A.TANGGAL,A.NOBUKTI, B.Urut
union all
Select 	'UKI' Tipe, 'UKI' MyTipe, 'A60' Prioritas, B.KodeBrg, B.KodeGdg,B.QNTDB QNT,0.00 NilaiDpp ,0.00 NilaiPPN,0.00 Jumlahnetto,
   B.QNTDB, 0.00 Qnt2Db, B.QNTDB*ISNULL(B.HPP,0) HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	B.QntDB QntSaldo,0.00 Qnt2Saldo, B.QNTDB*ISNULL(B.HPP,0) HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.Urut,
	''KodeSupp, '' Keterangan,B.UserID IDUser,
	isnull(B.HPP,0) HPP,
	A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	DBUBAHKEMASAN A
left outer join DBUBAHKEMASANDET B on B.NoBukti=A.NoBukti
left outer join DBBARANG C on C.KODEBRG=B.KodeBrg
where	b.qntdb<>0 
--Group By B.KodeBrg, B.KodeGdg,A.NOBUKTI,A.Tanggal,B.UserID, B.Urut
union all
Select 	'UKO' Tipe, 'UKO' MyTipe, 'B60' Prioritas, B.KodeBrg, B.KodeGdg,B.QNTCR QNT,0.00 NilaiDpp ,0.00 NilaiPPN,0.00 Jumlahnetto,
   0.00 QNTDB, 0.00 Qnt2Db, 0.00 HrgDebet,
	B.QNTCR, 0.00 Qnt2Cr, B.QNTCR*ISNULL(B.HPP,0) HrgKredit,
	-B.QntCR QntSaldo, 0.00 Qnt2Saldo, -B.QNTCR*ISNULL(B.HPP,0) HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,B.Urut,
	''KodeSupp, '' Keterangan,B.UserID IDUser,
	isnull(B.HPP,0) HPP,
	A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	DBUBAHKEMASAN A
left outer join DBUBAHKEMASANDET B on B.NoBukti=A.NoBukti
left outer join DBBARANG C on C.KODEBRG=B.KodeBrg
where	b.qntcr<>0 
--Group By B.KodeBrg, B.KodeGdg,A.NOBUKTI,A.Tanggal,B.UserID, B.URUT
union all
Select 	'ADI' Tipe, 'ADI' MyTipe, 'A70' Prioritas, B.KodeBrg, A.kodegdg, B.QNTDB Qnt,0.00 NilaiDpp ,0.00 NilaiPPN,0.00 Jumlahnetto,
   B.QntDb, B.Qnt2DB Qnt2Db, B.QntDb*isnull(B.HPP,0) HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	B.QntDb QntSaldo, B.Qnt2DB Qnt2Saldo, B.QntDb*isnull(B.Hpp,0) HrgSaldo, 
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.Urut,
	'' KodeCustSupp, '' Keterangan, '' IDUSER,
	isnull(B.HPP,0) HPP,
	A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	dbKoreksi A
left outer join dbKoreksiDet B on B.NoBukti=A.NoBukti
where 	B.QntDb<>0 or B.Qnt2DB<>0
--Group By B.KodeBrg, A.kodegdg,A.Tanggal, A.NoBukti, B.URUT
union all
Select 	'ADO' Tipe, 'ADO' MyTipe, 'B70' Prioritas, B.KodeBrg,A.KodeGdg, B.QNTCR QNT,0.00 NilaiDpp ,0.00 NilaiPPN,0.00 Jumlahnetto,
   0.00 QntDb, 0.00 Qnt2Db, 0.00 HrgDebet,
	B.QntCr, B.Qnt2Cr Qnt2Cr, B.QntCr*B.HPP HrgKredit,
	-1*B.QntCr QntSaldo, -1*B.Qnt2Cr Qnt2Saldo, -1*B.QntCr*B.HPP HrgSaldo, 
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.Urut,
	'' KodeCustSupp, '' Keterangan, ''IDUser,
	B.HPP HPP,
	A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	dbKoreksi A
left outer join dbKoreksiDet B on B.NoBukti=A.NoBukti
where 	B.QntCr<>0 or B.Qnt2CR<>0
--Group By B.KodeBrg, A.kodegdg,A.Tanggal, A.NoBukti, B.URUT
Union ALL
Select 	'PNJ' Tipe, 'PNJ' MyTipe, 'B80' Prioritas, B.KodeBrg,B.KodeGdg,B.QNT QNT,0.00 NilaiDpp ,0.00 NilaiPPN,0.00 Jumlahnetto,
   0.00 QntDb, 0.00 Qnt2Db, 0.00 HrgDebet,
	B.QNT, B.QNT2 Qnt2Cr, B.QNT*B.HPP HrgKredit,
	-1*B.Qnt QntSaldo, -1*B.Qnt2 Qnt2Saldo, -1*B.Qnt*B.HPP HrgSaldo, 
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.Urut,
	'' KodeCustSupp, d.NAMACUSTSUPP as Keterangan, ''IDUser,
	B.HPP HPP,
	A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	dbSPB A
left outer join dbSPBDet B on B.NoBukti=A.NoBukti
left outer join dbcustsupp D on d.kodecustsupp=a.kodecustsupp
where 	(B.Qnt<>0 or B.Qnt2<>0)
and isnull(A.IsBatal,0)=0
--Group By B.KodeBrg, B.KodeGdg,A.Tanggal, A.NoBukti, B.Urut
Union ALL
Select 	'RSPB' Tipe, 'RSPB' MyTipe, case when A.Tanggal=A0.Tanggal then 'B81' else 'A80' end Prioritas, 
	B.KODEBRG, A.KodeGdg,B.QNT QNT,0.00 NilaiDpp ,0.00 NilaiPPN,0.00 Jumlahnetto,
   B.QNT QntDb, B.QNT2 Qnt2Db, B.QNT*B.HPP HrgDebet,
	0.00,  0.00 Qnt2Cr, 0.00 HrgKredit,
	B.Qnt QntSaldo, B.Qnt2 Qnt2Saldo, B.Qnt*B.HPP HrgSaldo, 
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.Urut,
	'' KodeCustSupp, d.NAMACUSTSUPP as Keterangan, ''IDUser,
	B.HPP HPP,
	A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	DBRSPB A
left outer join DBRSPBDet B on B.NoBukti=A.NoBukti
left outer join dbcustsupp D on d.kodecustsupp=a.kodecustsupp
left outer join dbSPB A0 on A0.NoBukti=B.NoSPB
where 	B.Qnt<>0 or B.Qnt2<>0
--Group By B.KodeBrg,B.KodeGdg, A.Tanggal, A.NoBukti, B.Urut

Union ALL
Select 	'RPJ' Tipe, 'RPJ' MyTipe, case when A.Tanggal=A0.Tanggal then 'B82' else 'A80' end Prioritas, 
	B.KODEBRG,B.KodeGdg,B.QNT QNT,0.00 NilaiDpp ,0.00 NilaiPPN,0.00 Jumlahnetto,
   B.QNT QntDb, B.QNT2 Qnt2Db, B.QNT*B.HPP HrgDebet,
	0.00,  0.00 Qnt2Cr, 0.00 HrgKredit,
	B.Qnt QntSaldo, B.Qnt2 Qnt2Saldo, B.Qnt*B.HPP HrgSaldo, 
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.Urut,
	'' KodeCustSupp, d.NAMACUSTSUPP as Keterangan, ''IDUser,
	B.HPP HPP,
	A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	DBSPBRJual A
left outer join DBSPBRJualDet B on B.NoBukti=A.NoBukti
left outer join dbcustsupp D on d.kodecustsupp=a.kodecustsupp
left outer join dbInvoicePLDet C on C.NoBukti=B.NoInv and C.Urut=B.UrutInv
left outer join dbSPB A0 on A0.NoBukti=C.NoSPB
where 	B.Qnt<>0 or B.Qnt2<>0

Union ALL
Select 	'HP' Tipe, 'HP' MyTipe, 'A90' Prioritas, A0.KODEBRG, P0.KodeGdg, 
	B.Qnt, 0.00 NilaiDpp ,0.00 NilaiPPN, 0.00 Jumlahnetto,
	B.Qnt QntDb, 0 Qnt2Db, 
	B.Qnt*ISNULL(B.HPP,0) HrgDebet,
	0.00,  0.00 Qnt2Cr, 0.00 HrgKredit,
	B.Qnt QntSaldo, 0.00 Qnt2Saldo, 
	B.Qnt*ISNULL(B.HPP,0) HrgSaldo, 
	B.TanggalMesin Tanggal, month(B.TanggalMesin) Bulan, year(B.TanggalMesin) Tahun, A.NoBukti, B.Urut,
	'' KodeCustSupp, '' Keterangan, ''IDUser,
	isnull(B.HPP,0) HPP, A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	DBHASILPRD A
left outer join DBHASILPRDMSN B on B.NoBukti=A.NoBukti
left outer join DBSPK A0 on A0.NOBUKTI=A.NoSPK
left outer join DBPRoses P0 on P0.KodePrs=A.KodePrs
left outer join (select max(KodePrs) KodePrs from dbProses) P on P.KodePrs=A.KodePrs
where 	B.Qnt<>0
and P.KodePrs is not null
--Group By B.KodeBrg,B.KodeGdg, A.Tanggal, A.NoBukti, B.URUT


--select * from DBHASILPRDMSN
--select * from DBHASILPRD
--select * from DBHASILPRDDET

--select * from DBSPK

--select * from DBPRoses





























GO

-- View: vwKartuStockWIP
-- Created: 2014-11-26 14:38:22.670 | Modified: 2014-11-26 14:38:22.670
-- =====================================================



CREATE view [dbo].[vwKartuStockWIP]
as
SELECT	'AWL' Tipe, 'AWL' MyTipe, 'A00' Prioritas, B.KODEPRS, B.KODEBRG, B.NOSPK, 
	B.QNTAWAL QntDB, B.QNT2AWAL Qnt2DB, B.HRGAWAL HrgDebet, 
	0.00 QntCr,  0.00 Qnt2Cr, 0.00 HrgKredit,
	B.QNTAWAL QntSaldo, B.Qnt2Awal Qnt2Saldo, B.HRGAWAL HrgSaldo,
	CAST(CAST(B.Tahun as varchar(4))+RIGHT('0'+CAST(B.Bulan as varchar(2)),2)+'01' as datetime) Tanggal,
	B.BULAN, B.TAHUN, 'SALDO AWAL' NoBukti, 0 Urut, 
	'' Keterangan,
	case when B.QntAwal=0 then 0 else B.HrgAwal/B.QntAwal end HPP  
FROM  dbSTOCKWIP B
where (B.QNTAWAL<>0 or B.QNT2AWAL<>0 or B.HrgAwal<>0)

union all
Select 	'PRI' Tipe, 'PRI' MyTipe, 'A20' Prioritas, B.KodePrs, C.KodeBrg, B.NoSPK, 
    A.Qnt QntDb, A.Qnt Qnt2Db, A.Qnt*isnull(A.HPP,0) HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	A.Qnt QntSaldo, A.Qnt Qnt2Saldo, A.Qnt*isnull(A.HPP,0) HrgSaldo, 
	A.TanggalMesin Tanggal, month(A.TanggalMesin) Bulan, year(A.TanggalMesin) Tahun, A.NoBukti, A.Urut,
	'' Keterangan,
	isnull(A.HPP,0) HPP
from 	DBHASILPRDMSN A
left outer join DBHASILPRD B on B.NoBukti=A.NoBukti
left outer join DBSPK C on C.NOBUKTI=B.NoSPK

union all
Select 	'PRO' Tipe, 'PRO' MyTipe, 'B20' Prioritas, A.KodePrs, C.KodeBrg, B.NoSPK, 
    0.00 QntDb, 0.00 Qnt2Db, 0.00 HrgDebet,
	A.Qnt QntCr, A.Qnt Qnt2Cr, A.Qnt*isnull(0,0) HrgKredit,
	-A.Qnt QntSaldo, -A.Qnt Qnt2Saldo, -A.Qnt*isnull(0,0) HrgSaldo, 
	B.Tanggal, month(B.Tanggal) Bulan, year(B.Tanggal) Tahun, A.NoBukti, A.Urut,
	'' Keterangan,
	isnull(0,0) HPP
from 	DBHASILPRDDET A
left outer join DBHASILPRD B on B.NoBukti=A.NoBukti
left outer join DBSPK C on C.NOBUKTI=B.NoSPK







GO

-- View: vwKategori
-- Created: 2011-11-23 18:45:57.623 | Modified: 2011-11-23 22:17:03.890
-- =====================================================

CREATE View [dbo].[vwKategori]
as
Select A.*,B.NAMA NamaGdg, C.Keterangan NamaPerkiraan,
       B.NAMA+Case when B.NAMA is null then '' else ' ('+B.KODEGDG+')' end myGudang,
       C.Keterangan+Case when C.Keterangan is null then '' else ' ('+C.Perkiraan+')' end myPerkiraan
from DBKATEGORI A
     Left Outer join DBGUDANG B on B.KODEGDG=A.Kodegdg
     left Outer join DBPERKIRAAN C on C.Perkiraan=A.Perkiraan


GO

-- View: vwKategoriJadi
-- Created: 2011-12-08 19:36:36.767 | Modified: 2011-12-08 19:36:36.767
-- =====================================================


CREATE View [dbo].[vwKategoriJadi]
as
Select A.*,B.NAMA NamaGdg, C.Keterangan NamaPerkiraan,
       B.NAMA+Case when B.NAMA is null then '' else ' ('+B.KODEGDG+')' end myGudang,
       C.Keterangan+Case when C.Keterangan is null then '' else ' ('+C.Perkiraan+')' end myPerkiraan
from DBKATEGORIBRGJADI A
     Left Outer join DBGUDANG B on B.KODEGDG=A.Kodegdg
     left Outer join DBPERKIRAAN C on C.Perkiraan=A.Perkiraan



GO

-- View: vwKelompok
-- Created: 2011-11-23 18:45:57.620 | Modified: 2011-11-23 22:18:09.923
-- =====================================================

CREATE View [dbo].[vwKelompok]
as
Select A.*,B.Keterangan NamaPerkiraan,
       B.Keterangan+Case when B.Keterangan is null then '' else ' ('+B.Perkiraan+')' end myPerkiraan
from DBKELOMPOK A
     left Outer join DBPERKIRAAN B on B.Perkiraan=A.Perkiraan


GO

-- View: vwLabaRugiHPP
-- Created: 2011-11-22 15:40:56.017 | Modified: 2011-11-22 15:40:56.017
-- =====================================================
Create View dbo.vwLabaRugiHPP
as
Select * 
from DBLRHPP
GO

-- View: vwMasterBeli
-- Created: 2012-11-20 12:06:35.753 | Modified: 2015-04-21 09:21:48.027
-- =====================================================



CREATE    View [dbo].[vwMasterBeli]
as
Select 	A.NoBukti, A.Tanggal, A.KodeSupp, C.NAMACUSTSUPP, C.Kota,NoPO,A.UserBatal,A.tglbatal,
	A.Handling, A.FakturSupp, isnull(A.IsBatal,0) IsBatal,
        sum(B.SubTotal) TotSubTotal, sum(B.NDiskon) TotDiskon, 
	sum(B.SubTotal)-sum(B.NDiskon) TotTotal, sum(B.NDPP) TotDPP, 
	sum(B.NPPN) TotPPN, sum(B.NNet) TotNet,
	sum(B.SubTotal*A.Kurs) TotSubTotalRp, sum(B.NDiskon*A.Kurs) TotDiskonRp, 
	sum(B.SubTotal*A.Kurs)-sum(B.NDiskon*A.Kurs) TotTotalRp, sum(B.NDPP*A.Kurs) TotDPPRp, 
	sum(B.NPPN*A.Kurs) TotPPNRp, sum(B.NNet*A.Kurs) TotNetRp, a.Keterangan,a.TipeBayar
	,
	A.IsOtorisasi1, A.OtoUser1, A.TglOto1, A.IsOtorisasi2, A.OtoUser2, A.TglOto2, 
	A.IsOtorisasi3, A.OtoUser3, A.TglOto3, A.IsOtorisasi4, A.OtoUser4, A.TglOto4,B.KodeGdg,
	A.IsOtorisasi5, A.OtoUser5, A.TglOto5, A.MAXOL
From dbBeli A
Left Outer Join dbBeliDet B on B.NoBukti=A.NoBukti
Left Outer Join DBCUSTSUPP C on c.KODECUSTSUPP=a.KodeSupp
Group By A.NoBukti, A.Tanggal, A.KodeSupp, C.NAMACUSTSUPP, C.Kota,
	A.Handling, A.FakturSupp, isnull(A.IsBatal,0), a.Keterangan,a.TipeBayar,NOPO,
	A.IsOtorisasi1, A.OtoUser1, A.TglOto1, A.IsOtorisasi2, A.OtoUser2, A.TglOto2, 
	A.IsOtorisasi3, A.OtoUser3, A.TglOto3, A.IsOtorisasi4, A.OtoUser4, A.TglOto4,
	A.IsOtorisasi5, A.OtoUser5, A.TglOto5, A.MAXOL,A.UserBatal,A.tglbatal,B.KodeGdg




GO

-- View: vwMasterKoreksi
-- Created: 2014-02-19 10:17:43.033 | Modified: 2014-02-19 10:18:55.800
-- =====================================================


CREATE View [dbo].[vwMasterKoreksi]
as
Select a.nobukti+' Tanggal : '+convert(varchar(10),a.tanggal,105) + '   Gudang : '+a.KodeGdg as GroupNobukti, 
       A.Nobukti,a.Tanggal,
	A.IsOtorisasi1, A.OtoUser1, A.TglOto1, A.IsOtorisasi2, A.OtoUser2, A.TglOto2, 
	A.IsOtorisasi3, A.OtoUser3, A.TglOto3, A.IsOtorisasi4, A.OtoUser4, A.TglOto4,
	A.IsOtorisasi5, A.OtoUser5, A.TglOto5,
        Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                       Case when A.IsOtorisasi2=1 then 1 else 0 end+
                       Case when A.IsOtorisasi3=1 then 1 else 0 end+
                       Case when A.IsOtorisasi4=1 then 1 else 0 end+
                       Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                  else 1
             end As Bit) NeedOtorisasi,A.NOURUT
From dbKoreksi A 



GO

-- View: vwMasterOutstandingPO
-- Created: 2012-11-20 12:07:12.353 | Modified: 2012-11-29 10:51:34.710
-- =====================================================









CREATE   View [dbo].[vwMasterOutstandingPO]
As
Select 	A.NoBukti, A.Tanggal, A.KodeSupp, C.NAMACUSTSUPP, 
	A.IsBatal,
        	sum(B.SubTotal) TotSubTotal, sum(B.NDiskon) TotDiskon, 
	sum(B.SubTotal)-sum(B.NDiskon) TotTotal, sum(B.NDPP) TotDPP, 
	sum(B.NPPN) TotPPN, sum(B.NNet) TotNet,
	sum(B.SubTotal*A.Kurs) TotSubTotalRp, sum(B.NDiskon*A.Kurs) TotDiskonRp, 
	sum(B.SubTotal*A.Kurs)-sum(B.NDiskon*A.Kurs) TotTotalRp, sum(B.NDPP*A.Kurs) TotDPPRp, 
	sum(B.NPPN*A.Kurs) TotPPNRp, sum(B.NNet*A.Kurs) TotNetRp
From dbPO A
Left Outer Join dbPODet B on B.NoBukti=A.NoBukti
Left Outer Join (select Kodebrg,NoPO,Isnull(Sum(Qnt*Isi),0)QntB from dbBelidet group by Kodebrg,NoPO)B1 On B1.NOPO=A.NoBukti and B1.Kodebrg=B.Kodebrg
Left Outer Join DBCUSTSUPP C on c.KODECUSTSUPP=a.KodeSupp
where (B.Qnt*B.Isi)<>Isnull(QntB,0)
and
Case when Isnull(A.IsClose,0)=0 Then Isnull(B.IsClose,0)else Isnull(A.IsClose,0) end=0
Group By A.NoBukti, A.Tanggal, A.KodeSupp, C.NAMACUSTSUPP, A.IsBatal









GO

-- View: vwMasterPO
-- Created: 2012-11-20 11:59:00.907 | Modified: 2013-01-02 13:56:58.393
-- =====================================================





CREATE  View [dbo].[vwMasterPO]
as

Select 	A.NoBukti, A.Tanggal, A.KodeSupp, C.NAMACUSTSUPP, C.Kota,
	A.Handling, A.FakturSupp, isnull(A.IsBatal,0) IsBatal,
        sum(B.SubTotal) TotSubTotal, sum(B.NDiskon) TotDiskon, 
	sum(B.SubTotal)-sum(B.NDiskon) TotTotal, sum(B.NDPP) TotDPP, 
	sum(B.NPPN) TotPPN, sum(B.NNet) TotNet,
	sum(B.SubTotal*A.Kurs) TotSubTotalRp, sum(B.NDiskon*A.Kurs) TotDiskonRp, 
	sum(B.SubTotal*A.Kurs)-sum(B.NDiskon*A.Kurs) TotTotalRp, sum(B.NDPP*A.Kurs) TotDPPRp, 
	sum(B.NPPN*A.Kurs) TotPPNRp, sum(B.NNet*A.Kurs) TotNetRp
From dbPO A
Left Outer Join dbPODet B on B.NoBukti=A.NoBukti
Left Outer Join  dbCustSupp C on c.KodeCustSupp=a.KodeSupp  
Group By A.NoBukti, A.Tanggal, A.KodeSupp, C.NAMACUSTSUPP, C.Kota,
	A.Handling, A.FakturSupp, isnull(A.IsBatal,0)






GO

-- View: vwMasterPOOut
-- Created: 2014-02-13 11:53:13.300 | Modified: 2014-07-18 10:11:44.057
-- =====================================================






CREATE View [dbo].[vwMasterPOOut]
as

Select 	A.NoBukti, A.Tanggal, A.KodeSupp, C.NAMACUSTSUPP, C.Kota,
b.Qnt-isnull(e.QntTerima,0) QntSisa,ISNULL(QntTerima,0)QntTerima,
	A.Handling, A.FakturSupp, --isnull(A.IsBatal,0) IsBatal,
       0.00 --sum(B.SubTotal) 
        TotSubTotal, --sum(B.NDiskon) 
     0.00   TotDiskon, 
	0.00--sum(B.SubTotal)-sum(B.NDiskon) 
	TotTotal, 0.00--sum(B.NDPP)
	 TotDPP, 
	0.00--sum(B.NPPN)
		 TotPPN, 0.00--sum(B.NNet) 
		 TotNet,
	0.00--sum(B.SubTotal*A.Kurs) 
	TotSubTotalRp, 0.00--sum(B.NDiskon*A.Kurs) 
	TotDiskonRp, 
	0.00--sum(B.SubTotal*A.Kurs)-sum(B.NDiskon*A.Kurs) 
	TotTotalRp, 0.00--sum(B.NDPP*A.Kurs) 
	TotDPPRp, 
	0.00--sum(B.NPPN*A.Kurs) 
	TotPPNRp, 0.00--sum(B.NNet*A.Kurs) 
	TotNetRp, b.KODEBRG ,B.NAMABRG, qnt, f.qntbatal, b.urut, b.IsBatal, b.UserBatal, b.TglBatal,b.SATUAN
From dbPO A
Left Outer Join dbPODet B on B.NoBukti=A.NoBukti
Left Outer Join  dbCustSupp C on c.KodeCustSupp=a.KodeSupp  
left outer join DBBARANG d on d.KODEBRG=b.KODEBRG
left outer join
	(Select NOBUKTI , Urut, KodeBrg, sum(QntBatal ) QntBatal
	 from dbPODet
	 group by NOBUKTI, Urut, KodeBrg) f on f.NOBUKTI=A.NoBukti and f.Urut=b.urut and B.KodeBrg=b.KodeBrg
left outer join
	(Select NoPO , UrutPO, KodeBrg, sum(Qnt ) QntTerima
	 from dbbelidet
	 group by NOpo, Urutpo, KodeBrg) e on e.NoPO =A.NoBukti and e.UrutPO=b.Urut and e.KodeBrg=b.KodeBrg	 
Group By A.NoBukti, A.Tanggal, A.KodeSupp, C.NAMACUSTSUPP, C.Kota,
	A.Handling, A.FakturSupp, isnull(A.IsBatal,0), b.KODEBRG , B.NamaBrg ,QNT ,f.QntBatal,e.QntTerima, b.urut, b.IsBatal, b.UserBatal, b.TglBatal, SATUAN








GO

-- View: vwMasterRBeli
-- Created: 2014-02-13 11:53:13.267 | Modified: 2014-02-13 11:53:13.267
-- =====================================================





CREATE View [dbo].[vwMasterRBeli]
as
Select 	A.NoBukti, A.Tanggal, A.KodeSupp, C.NAMACUSTSUPP, A.NoBeli, C.Kota,
	A.Handling, A.FakturSupp,
        sum(B.SubTotal) TotSubTotal, sum(B.NDiskon) TotDiskon, 
	sum(B.SubTotal)-sum(B.NDiskon) TotTotal, sum(B.NDPP) TotDPP, 
	sum(B.NPPN) TotPPN, sum(B.NNet) TotNet,Kodegdg,
	sum(B.SubTotal*A.Kurs) TotSubTotalRp, sum(B.NDiskon*A.Kurs) TotDiskonRp, 
	sum(B.SubTotal*A.Kurs)-sum(B.NDiskon*A.Kurs) TotTotalRp, sum(B.NDPP*A.Kurs) TotDPPRp, 
	sum(B.NPPN*A.Kurs) TotPPNRp, sum(B.NNet*A.Kurs) TotNetRp,
        A.IsOtorisasi1, A.OtoUser1, A.TglOto1, A.IsOtorisasi2, A.OtoUser2, A.TglOto2, 
	A.IsOtorisasi3, A.OtoUser3, A.TglOto3, A.IsOtorisasi4, A.OtoUser4, A.TglOto4,
	A.IsOtorisasi5, A.OtoUser5, A.TglOto5, A.MAXOL,        
        Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                       Case when A.IsOtorisasi2=1 then 1 else 0 end+
                       Case when A.IsOtorisasi3=1 then 1 else 0 end+
                       Case when A.IsOtorisasi4=1 then 1 else 0 end+
                       Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                  else 1
             end As Bit) NeedOtorisasi,TglFpj,NOpajak,A.IsBatal 
From dbRBeli A
Left Outer Join dbRBeliDet B on B.NoBukti=A.NoBukti
Left Outer Join dbCustSupp C on c.KODECUSTSUPP=a.KodeSupp
Group By A.NoBukti, A.Tanggal, A.KodeSupp, C.NAMACUSTSUPP, A.NoBeli, C.Kota,
	A.Handling, A.FakturSupp, A.KodeGdg, a.ISotorisasi1,OtoUser1,a.TglOto1,TglFpj,NOpajak, A.IsOtorisasi2, A.OtoUser2, A.TglOto2, 
	A.IsOtorisasi3, A.OtoUser3, A.TglOto3, A.IsOtorisasi4, A.OtoUser4, A.TglOto4,
	A.IsOtorisasi5, A.OtoUser5, A.TglOto5, A.MAXOL,A.IsBatal 













GO

-- View: vwMasterUbahKemasan
-- Created: 2013-07-11 15:16:11.343 | Modified: 2013-07-11 15:16:11.343
-- =====================================================

CREATE View [dbo].[vwMasterUbahKemasan]
as
Select a.nobukti+' Tanggal : '+convert(varchar(10),a.tanggal,105) as GroupNobukti, 
       A.Nobukti, A.NOURUT, a.Tanggal, A.NOTE, A.IsCetak, A.NilaiCetak,
       A.IsOtorisasi1, A.OtoUser1, A.TglOto1,
       A.IsOtorisasi2, A.OtoUser2, A.TglOto2,
       A.IsOtorisasi3, A.OtoUser3, A.TglOto3,
       A.IsOtorisasi4, A.OtoUser4, A.TglOto4,
       A.IsOtorisasi5, A.OtoUser5, A.TglOto5
From  DBUBAHKEMASAN A 






GO

-- View: vwMesin
-- Created: 2011-11-23 18:45:57.590 | Modified: 2011-11-23 18:45:57.590
-- =====================================================
Create View dbo.vwMesin
as
Select * from DBMESIN

GO

-- View: vwOSBarang
-- Created: 2012-12-05 11:18:32.517 | Modified: 2012-12-05 11:18:32.517
-- =====================================================



CREATE View [dbo].[vwOSBarang]
as     
select a.Kodebrg,Isnull(SUM(a.QNT*isi),0)QntBPPB,Isnull(b.Qnt,0)QntBP,Isnull(SUM(a.QNT*isi),0)-Isnull(b.Qnt,0)OSBP,isnull(e.Sisa,0)OSPPL,Isnull(f.sisa,0)OSPO from DBBPPBDET a 
left Outer Join (select Kodebrg,SUM(Qnt*isi)Qnt from DBPenyerahanBhnDET group by kodebrg)b On b.kodebrg=a.KodeBrg 
Left Outer join (select a.kodebrg,SUM(a.Qnt*isi)QntPPL,Isnull(b.Qnt,0) QntPO,SUM(a.Qnt*isi)-Isnull(b.Qnt,0)sisa from DBPPLDET a
                 Left Outer Join (select NoPPL,Kodebrg,SUM(Qnt*isi)Qnt from DBPODET group by NoPPL,Kodebrg)b On a.Nobukti=b.NoPPL and a.kodebrg=b.KODEBRG
                 group by a.kodebrg,b.Qnt
                 having SUM(a.Qnt*isi)-Isnull(b.Qnt,0)<>0)e on e.KODEBRG=a.KODEBRG
Left Outer Join (select a.kodebrg,SUM(a.Qnt*isi)QntPO,Isnull(b.Qnt,0)QntBeli,SUM(a.Qnt*isi)-isnull(b.Qnt,0)sisa from DBPODET a
                 left Outer Join (select NoPO,Kodebrg,SUM(Qnt*isi)Qnt from DBBELIDET Group by NoPO,KODEBRG)b On a.NOBUKTI=b.NoPO and a.KODEBRG=b.KODEBRG
                 group by a.KodeBrg,b.Qnt
                 having SUM(a.Qnt*isi)-isnull(b.Qnt,0)<>0)f On f.KODEBRG=a.KODEBRG                 
group by a.KodeBrg,b.Qnt,e.Sisa,f.sisa
having (Isnull(SUM(a.QNT*isi),0)-Isnull(b.Qnt,0))-Isnull(e.Sisa,0)-Isnull(f.sisa,0)>0


GO

-- View: vwOutBeli
-- Created: 2014-09-30 10:45:02.050 | Modified: 2015-04-21 15:43:53.700
-- =====================================================


CREATE View [dbo].[vwOutBeli]
as

select X.NOBUKTI+' '+right('00000000'+cast(X.URUT as varchar(8)),8) KeyUrut,
	X.NOBUKTI, X.NOURUT, X.TANGGAL, X.KODECUSTSUPP, X.NOPO, X.KodeGdg, 
	X.Flagtipe, X.TipePPN,
	Cs.NAMACUSTSUPP,
	Cs.ALAMAT ALAMATCUSTSUPP, Cs.KOTA KOTACUSTSUPP, Cs.NamaKota NAMAKOTACUSTSUPP,  
	X.URUT, X.KODEBRG, Br.NAMABRG, max(X.KetNamaBrg) KetNamaBrg, 
	Br.NAMABRG+case when max(ISNULL(X.KetNamaBrg,''))='' then '' else CHAR(13)+max(X.KetNamaBrg) end NamaBrgPlus,
	Br.SAT1, Br.SAT2, Br.NFix,
	Br.ISI1, Br.ISI2, Br.IsJasa,
	sum(X.Qnt) Qnt, SUM(X.Qnt1) Qnt1, SUM(X.Qnt2) Qnt2, 
	max(X.NOSAT) NoSat, max(X.SATUAN) Satuan, max(X.ISI) Isi,
	case when MAX(X.NoSat)=1 then sum(X.Qnt1RBeli) else sum(X.Qnt2RBeli) end QntRBeli, 
	sum(X.Qnt1RBeli) Qnt1RBeli, sum(X.Qnt2RBeli) Qnt2RBeli, 
	SUM(X.Qnt)-case when MAX(X.NoSat)=1 then sum(X.Qnt1RBeli) else sum(X.Qnt2RBeli) end QntSisa,
	SUM(X.Qnt1)-sum(X.Qnt1RBeli) Qnt1Sisa,
	SUM(X.Qnt2)-sum(X.Qnt2RBeli) Qnt2Sisa,
	NilaiOL, MAXOL
from
	(
	select A.NOBUKTI, A.NOURUT, A.TANGGAL, A.KodeSupp KODECUSTSUPP, A.NoPOHd NOPO, B.KodeGdg, 
		A.Flagtipe, A.TipePPN, B.URUT, B.KODEBRG, isnull(B.NamaBrg,'') KetNamaBrg, 
		B.QntTerima-B.QntReject Qnt, B.Qnt1Terima-B.Qnt1Reject QNT1, B.Qnt2Terima-B.Qnt2Reject QNT2, B.NOSAT,
		case when B.NOSAT=1 then C.SAT1 when b.NOSAT=2 then C.SAT2 End Satuan, B.ISI, 
		0 Qnt1RBeli, 0 Qnt2RBeli,
		(Case when A.IsOtorisasi1=1 then 1 else 0 end+
        Case when A.IsOtorisasi2=1 then 1 else 0 end+
        Case when A.IsOtorisasi3=1 then 1 else 0 end+
        Case when A.IsOtorisasi4=1 then 1 else 0 end+
        Case when A.IsOtorisasi5=1 then 1 else 0 end) NilaiOL,
        A.MAXOL 
	from DBBELI A, DBBELIDET B,DBBARANG C
	where B.NOBUKTI=A.NOBUKTI and B.KODEBRG=C.KODEBRG
	
	--union all
	--select A.NOBUKTI, A.TANGGAL, A.KodeSupp KODECUSTSUPP,
	--	B.URUTPBL URUT, B.KODEBRG,
	--	0 Qnt, 0 Qnt1, 0 Qnt2, 0 NoSat, '' Satuan, 0 Isi,
	--	B.Qnt1 Qnt1RBeli, B.QNT2 Qnt2RBeli,
	--	(Case when A.IsOtorisasi1=1 then 1 else 0 end+
    --    Case when A.IsOtorisasi2=1 then 1 else 0 end+
    --    Case when A.IsOtorisasi3=1 then 1 else 0 end+
    --    Case when A.IsOtorisasi4=1 then 1 else 0 end+
    --    Case when A.IsOtorisasi5=1 then 1 else 0 end) NilaiOL,
    --    A.MAXOL 
	--from DBBELI A, DBRBELIDET B
	--where B.NOPBL=A.NOBUKTI

	union all
	select A.NOBUKTI, A.NOURUT, A.TANGGAL, A.KodeSupp KODECUSTSUPP, A.NoPOHd NOPO, B.KodeGdg, 
		A.Flagtipe, A.TipePPN, B.UrutBeli URUT, B.KODEBRG, '' KetNamaBrg,
		0 Qnt, 0 Qnt1, 0 Qnt2, 0 NoSat,case when B.NOSAT=1 then B.SAT_1 when b.NOSAT=2 then B.Sat_2 End SatuanSatuan, 0 Isi,
		B.Qnt1Terima Qnt1RBeli, B.Qnt2Terima Qnt2RBeli,
		(Case when A.IsOtorisasi1=1 then 1 else 0 end+
        Case when A.IsOtorisasi2=1 then 1 else 0 end+
        Case when A.IsOtorisasi3=1 then 1 else 0 end+
        Case when A.IsOtorisasi4=1 then 1 else 0 end+
        Case when A.IsOtorisasi5=1 then 1 else 0 end) NilaiOL,
        A.MAXOL 
	from DBBELI A, DBinvoiceDET B
	where B.NoBeli=A.NOBUKTI

	) X
left outer join vwCUSTSUPP Cs on Cs.KODECUSTSUPP=X.KODECUSTSUPP
left outer join vwBarang Br on Br.KODEBRG=X.KodeBrg
group by X.NOBUKTI, X.NOURUT, X.TANGGAL, X.KODECUSTSUPP, X.NOPO, X.KodeGdg, 
	X.Flagtipe, X.TipePPN, Cs.NAMACUSTSUPP, 
	Cs.ALAMAT, Cs.KOTA, Cs.NamaKota, 
	X.Urut, X.KODEBRG, Br.NAMABRG, Br.SAT1, Br.SAT2, Br.NFix,
	Br.ISI1, Br.ISI2, Br.IsJasa,
	X.NilaiOL, X.MAXOL





GO

-- View: vwOutBP_Inspeksi
-- Created: 2011-06-09 10:49:13.820 | Modified: 2011-06-09 10:49:13.820
-- =====================================================

CREATE View [dbo].[vwOutBP_Inspeksi]
as
select	A.Nobukti, A.urut, A.NOPO, A.URUTPO, A.kodebrg, A.Sat_1, A.Sat_2, A.Isi, A.Qnt, A.Qnt2, 
	0.00 QntBatal, 0.00 Qnt2Batal, isnull(C.QntIns,0) QntIns, isnull(C.Qnt2Ins,0) Qnt2Ins,
	A.Qnt-isnull(C.QntIns,0) QntSisaIns, A.Qnt2-isnull(C.Qnt2Ins,0) Qnt2SisaIns,
	A.Qnt-isnull(C.QntIns,0) QntSisa, A.Qnt2-isnull(C.Qnt2Ins,0) Qnt2Sisa, A.Nosat
from 	DBBELIDET A
left outer join (select NOBUKTI,URUT, NoPPL, UrutPPL, KodeBrg, sum(Qnt) QntPO, sum(Qnt2) Qnt2Po
	              from DBPODET
	              group by NOBUKTI,URUT, NoPPL, UrutPPL, KodeBrg ) B on B.NOBUKTI=A.NOPO and B.URUT=A.URUTPO
left outer join (select NoBP, UrutBP, KodeBrg, sum(Qnt1) QntIns, sum(Qnt2) Qnt2Ins
	              from dbInspeksiDet
	              group by NoBP, UrutBP, KodeBrg
	) C on C.NoBP=A.NoBukti and C.UrutBP=A.Urut
left outer join dbPPLDet P on P.NoBukti=B.NOPPL and P.Urut=B.UrutPPL
left outer join dbPermintaanBrgDet P2 on P2.NoBukti=P.NoPermintaan and P2.Urut=P.UrutPermintaan
where	P2.IsInspeksi=1


GO

-- View: vwOutBPPB
-- Created: 2013-06-03 12:13:04.730 | Modified: 2013-06-03 12:13:04.730
-- =====================================================

CREATE View [dbo].[vwOutBPPB]
as
Select A.NOBUKTI, A.TANGGAL, B.URUT, B.KODEBRG, A.KodeGdg, A.KodeGdgT, B.QNT, B.Qnt2, B.NOSAT, B.ISI, B.SATUAN,
       ISNULL(C.Qnt,0) QntBPPBT, ISNULL(C.Qnt2,0) Qnt2BPPBT,
       (B.QNT-ISNULL(C.Qnt,0)) QntSisa, 
       (B.QNT2-ISNULL(C.Qnt2,0)) Qnt2Sisa
From DBBPPB A
     Left Outer join DBBPPBDET B on B.NOBUKTI=A.NOBUKTI
     left Outer join (Select x.NoBPPB, x.UrutBPPB, x.NOSAT, x.ISI, SUM(x.QNT) Qnt, SUM(x.Qnt2) Qnt2
                      from DBBPPBTDET x
                      Group by x.NoBPPB, x.UrutBPPB, x.NOSAT, x.ISI) C on C.NoBPPB=A.NOBUKTI and C.UrutBPPB=B.URUT
     left Outer join dbbarang BR on BR.KODEBRG=B.KODEBRG
Where Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                       Case when A.IsOtorisasi2=1 then 1 else 0 end+
                       Case when A.IsOtorisasi3=1 then 1 else 0 end+
                       Case when A.IsOtorisasi4=1 then 1 else 0 end+
                       Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                  else 1
             end As Bit)=0 and (B.QNT-ISNULL(C.Qnt,0)>0 or B.Qnt2-ISNULL(c.Qnt2,0)>0) 


GO

-- View: vwOutInspeksi
-- Created: 2011-02-11 15:18:57.637 | Modified: 2011-03-03 12:00:28.937
-- =====================================================

CREATE View [dbo].[vwOutInspeksi]
as

select	A.Nobukti, A.urut, A.kodebrg, A.reject1 Qnt, A.reject2 Qnt2, 
	isnull(C.QntSJ,0) QntSJ, isnull(C.Qnt2SJ,0) Qnt2SJ,
	A.reject1-isnull(C.QntSJ,0) QntSisa, A.reject2-isnull(C.Qnt2SJ,0) Qnt2Sisa
from 	dbInspeksiDet A
left outer join
	(select NoInspek, UrutInspek, KodeBrg, sum(Qnt1) QntSJ, sum(Qnt2) Qnt2SJ
	from dbSPengantarDet
	group by NoInspek, UrutInspek, KodeBrg
	) C on C.NoInspek=A.NoBukti and C.UrutInspek=A.Urut and C.KodeBrg=A.KodeBrg


GO

-- View: vwOutInspeksi_RBP
-- Created: 2011-06-09 15:29:23.970 | Modified: 2011-06-14 10:21:23.603
-- =====================================================

CREATE View [dbo].[vwOutInspeksi_RBP]
as
Select A.NOBUKTI,A.urut,A.KODECUSTSUPP, A.TANGGAL,A.KODEBRG,
       A.Sat_1,a.Sat_2,a.Nosat,a.Isi,
       A.Qnt QntIns, A.Qnt2 Qnt2Ins,
       A.OK1, A.OK2, A.Reject1, A.Reject2,
       A.Pending1, A.Pending2,A.NOBP,A.urutBP,C.NOPO,c.URUTPO,
       isnull(B.NOPBL,'') NOPBL,isnull(B.URUTPBL,0) URUTPBL,
       isnull(B.noins,'') NOINS,isnull(B.Urutins,'')URUTINS ,
       isnull(B.qnt,0) QntRBP, isnull(B.qnt2,0) Qnt2RBP,
       isnull(D.qnt,0) QntKNS, 
       isnull(D.qnt2,0) Qnt2KNS,
       isnull(B.qntTukar,0) qntTukar, 
       isnull(B.Qnt2Tukar,0) Qnt2Tukar,
       A.Reject1-isnull(B.qnt,0) QntSisaIns,
       A.Reject2-isnull(B.qnt2,0) Qnt2SisaIns,
       A.Pending1-isnull(D.qnt,0) QntSisaKNS,
       A.Pending2-isnull(D.qnt2,0) Qnt2SisaKNS,
       C.HARGA,C.KODEGDG,C.KODEVLS,C.KURS,C.PPN,C.TIPEBAYAR,C.DISC,C.DISCRP
from (Select A.NOBUKTI,B.URUT, A.KODECUSTSUPP,A.TANGGAL, B.NOBP,B.URUTBP,(B.Qnt1) Qnt, (B.qnt2) Qnt2,
             (B.OK1) OK1, (B.OK2) OK2,
             (B.Reject1) Reject1, (B.Reject2) Reject2,
             (B.Pending1) Pending1, (B.Pending2) Pending2,
             B.KODEBRG,B.Sat_1,B.Sat_2,B.Nosat,B.Isi
      from DBINSPEKSI A
      left outer join DBINSPEKSIDET B on B.NOBUKTI=A.NOBUKTI) A
      Left Outer join (select NOPBL,URUTPBL,NOINS,Urutins, SUM(Qnt) Qnt ,SUM(Qnt2) qnt2, SUM(QntTukar) qntTukar, SUM(QNT2Tukar) Qnt2Tukar 
                       from DBRBELIDET
                       Group by NOPBL,URUTPBL,NOINS,UrutINS) B on B.NOPBL=A.NOBP and B.URUTPBL=A.URUTBP
      Left Outer join (Select a.NOBUKTI,a.URUT,a.NOPO,URUTPO,a.HARGA,B.KODEVLS,B.KURS,B.PPN,B.TIPEBAYAR,B.DISC,B.DISCRP,
                              B.KODEGDG
                       from DBBELIDET A
                       left outer join DBBELI B on B.NOBUKTI=A.NOBUKTI) C On C.NOBUKTI=A.NOBP and C.URUT=A.URUTBP 
      Left Outer join (select NOPBL,URUTPBL,NOINS,Urutins, SUM(Qnt) Qnt ,SUM(Qnt2) qnt2
                       from DBKonsesiDET
                       Group by NOPBL,URUTPBL,NOINS,UrutINS) D on D.NOINS=A.NOBUKTI and D.URUTINS=A.URUT      


GO

-- View: VwOutInvoicePL
-- Created: 2014-09-24 10:57:10.383 | Modified: 2023-05-21 14:40:07.013
-- =====================================================


CREATE View [dbo].[VwOutInvoicePL]
As
select X.NOBUKTI+' '+right('00000000'+cast(X.URUT as varchar(8)),8) KeyUrut,
	X.NOBUKTI, X.TANGGAL, X.KODECUSTSUPP, Cs.NAMACUSTSUPP,
	Cs.ALAMAT ALAMATCUSTSUPP, Cs.KOTA KOTACUSTSUPP, Cs.NamaKota NAMAKOTACUSTSUPP, 
	X.URUT, X.KODEBRG, Br.NAMABRG, Br.SAT1, Br.SAT2, Br.NFix,
	Br.ISI1, Br.ISI2,
	sum(X.Qnt) Qnt, SUM(X.Qnt2) Qnt2, 
	max(X.NOSAT) NoSat, max(X.SATUAN) Satuan, max(X.ISI) Isi,
	case when MAX(X.NoSat)=1 then sum(X.Qnt1SPBRJual) else sum(X.Qnt2SPBRJual) end QntSPBRJual, 
	sum(X.Qnt1SPBRJual) Qnt1SPBRJual, sum(X.Qnt2SPBRJual) Qnt2SPBRJual, 
	SUM(X.Qnt)-case when MAX(X.NoSat)=1 then sum(X.Qnt1SPBRJual) else sum(X.Qnt2SPBRJual) end QntSisa,
	SUM(X.Qnt)-sum(X.Qnt1SPBRJual) Qnt1Sisa,
	SUM(X.Qnt2)-sum(X.Qnt2SPBRJual) Qnt2Sisa,
	NilaiOL, MAXOL,x.Noso,x.nobatch,HARGA 
from
	(
	
	select A.NOBUKTI, A.TANGGAL, A.KodeCustSupp KODECUSTSUPP,  
		B.URUT, B.KODEBRG, 
		B.Qnt, B.QNT2, B.NOSAT, B.SAT_1 Satuan, B.ISI, 
		0 Qnt1SPBRJual, 0 Qnt2SPBRJual,
		(Case when A.IsOtorisasi1=1 then 1 else 0 end+
        Case when A.IsOtorisasi2=1 then 1 else 0 end+
        Case when A.IsOtorisasi3=1 then 1 else 0 end+
        Case when A.IsOtorisasi4=1 then 1 else 0 end+
        Case when A.IsOtorisasi5=1 then 1 else 0 end) NilaiOL,
        A.MAXOL,B.NoSO,B.nobatch  
	from DBInvoicePL A, dbInvoicePLDet B
	where B.NOBUKTI=A.NOBUKTI
	
	union all
	select A.NOBUKTI, A.TANGGAL, A.KodeCustSupp KODECUSTSUPP, 
		B.UrutInv URUT, B.KODEBRG,
		0 Qnt, 0 Qnt2, 0 NoSat, '' Satuan, 0 Isi,
		B.Qnt Qnt1SPBRJual, B.QNT2 Qnt2SPBRJual,
		(Case when A.IsOtorisasi1=1 then 1 else 0 end+
        Case when A.IsOtorisasi2=1 then 1 else 0 end+
        Case when A.IsOtorisasi3=1 then 1 else 0 end+
        Case when A.IsOtorisasi4=1 then 1 else 0 end+
        Case when A.IsOtorisasi5=1 then 1 else 0 end) NilaiOL,
        A.MAXOL,''NoSO,'' NObatch 
	from DBInvoicePL A, dbSPBRJualDet B
	where B.Noinv=A.NOBUKTI
	
	
	) X
left outer join vwCUSTSUPP Cs on Cs.KODECUSTSUPP=X.KODECUSTSUPP
left outer join DBBARANG Br on Br.KODEBRG=X.KodeBrg
left outer join dbInvoicePLDet d on d.NoBukti =x.NoBukti 
group by X.NOBUKTI, X.TANGGAL, X.KODECUSTSUPP, Cs.NAMACUSTSUPP, 
	Cs.ALAMAT, Cs.KOTA, Cs.NamaKota, 
	X.Urut, X.KODEBRG, Br.NAMABRG, Br.SAT1, Br.SAT2, Br.NFix,
	Br.ISI1, Br.ISI2,
	X.NilaiOL, X.MAXOL
	,X.Noso,X.Nobatch,HARGA 








GO

-- View: vwOutInvoicePL_RInvoicePL
-- Created: 2013-01-15 14:40:07.823 | Modified: 2013-01-15 14:40:07.823
-- =====================================================

CREATE View [dbo].[vwOutInvoicePL_RInvoicePL]
As
Select A.KodeBrg, A.NAMABRG, A.NamabrgKom, A.NamaProduk, A.QNT, A.QNT2, A.Qty, A.SAT_1, A.SAT_2, A.Satuan,
       A.ISI, A.NOSAT, A.NetW, A.GrossW, 
       ISNULL(b.qty,0) QtyRetur, ISNULL(b.NetW,0) NetWRetur,
       ISNULL(b.GrossW,0) GrossWRetur, ISNULL(b.Qnt1,0) QntRetur,
       ISNULL(b.Qnt2,0) Qnt2Retur,
       A.Qty-ISNULL(b.qty,0) QtySisa,
       A.QNT-ISNULL(b.Qnt1,0) QntSisa,
       A.QNT2-ISNULL(b.Qnt2,0) Qnt2Sisa,
       A.NetW-ISNULL(b.NetW,0) NetWSisa,
       A.GrossW-ISNULL(b.GrossW,0) GrossWSisa, A.NoBukti, A.Urut, A.HARGA, A.NoSPB
From (    
          Select a.KodeBrg, a.Namabrg NamabrgKom, b.namabrg,
				 'Nama Produk : '+b.Namabrg+CHAR(13)+'Nama Komersil : '+ a.namabrg NamaProduk ,
				 case when a.NOSAT=1 then a.QNT
						when a.NOSAT=2 then a.QNT2
						else 0
				 end Qty,
				 case when a.NOSAT=1 then a.SAT_1
						when a.NOSAT=2 then a.SAT_2
						else ''
				 end Satuan,
				 a.NetW, a.GrossW, a.QNT, A.QNT2, a.SAT_1, a.SAT_2, a.NOSAT, a.ISI,
				 a.NoBukti, a.Urut, A.HARGA, D.NoBukti NoSPB
		from dbInvoicePLDet a
			  left outer join DBBARANG b on b.KODEBRG=a.KodeBrg
                 left Outer join dbSPBDet D on D.NoBukti=a.NoSPB and D.UrutSPP=a.UrutSPB  
                 Left Outer join dbSPPDet C on c.NoBukti=D.NoSPP and c.Urut=D.UrutSPP
                 
		) A
Left Outer join (Select x.NoInvoice, x.UrutInvoice, SUM(x.QNT) Qnt1, SUM(x.QNT2) Qnt2,
                        SUM(x.netW) NetW, SUM(x.GrossW) GrossW,
                        Sum(case when x.NOSAT=1 then x.QNT
						               when x.NOSAT=2 then x.QNT2
						               else 0
				                end) Qty
                 from DBRInvoicePLDET x
                 Group by x.NoInvoice, x.UrutInvoice) b on b.NoInvoice=A.NoBukti and b.UrutInvoice=A.Urut 





GO

-- View: vwOutPermintaanBrg
-- Created: 2011-06-04 09:49:10.237 | Modified: 2011-12-20 15:56:20.147
-- =====================================================

CREATE VIEW [dbo].[vwOutPermintaanBrg]
AS
SELECT A.Nobukti, A.urut, A.kodebrg, A.Sat_1, A.Sat_2, A.Isi, A.Qnt, A.Qnt2, A.TglTiba, A.isInspeksi, 
       ISNULL(B.QntBPB, 0) AS QntBPB, 
       ISNULL(B.Qnt2BPB, 0) AS Qnt2BPB, 
       ISNULL(c.QntPPL, 0) AS QntPPl, 
       ISNULL(c.Qnt2PPL, 0) AS Qnt2PPL,
       ISNULL(d.QntBBP,0) QntBBP, 
       ISNULL(d.Qnt2BBP,0) Qnt2BBP,
       ISNULL(e.qntBPL,0) AS QntBPL,
       ISNULL(e.Qnt2BPL,0) AS Qnt2BPL, 
       A.Qnt - ISNULL(B.QntBPB, 0)-ISNULL(d.QntBBP, 0) AS QntSisaBPB, 
       A.Qnt2 - ISNULL(B.Qnt2BPB, 0)-ISNULL(d.Qnt2BBP, 0) AS Qnt2SisaBPB, 
       A.Qnt - ISNULL(d.QntBBP, 0) - ISNULL(C.QntPPL,0)+ISNULL(e.QntBPL,0) AS QntSisa, 
       A.Qnt2 - ISNULL(d.Qnt2BBP, 0) - ISNULL(C.Qnt2PPL, 0)+ISNULL(e.Qnt2BPL,0) AS Qnt2Sisa, 
       B.NoPermintaan, A.Nosat, A.Keterangan, F.JnsPakai,
       Case when F.JnsPakai=0 then 'Stock'
				when F.JnsPakai=1 then 'Investasi'
				when F.JnsPakai=2 then 'Rep & Pem Teknik'
				when F.JnsPakai=3 then 'Rep & Pem Komputer'
				when F.JnsPakai=4 then 'Rep & Pem Peralatan'
		 end MyJnsPakai,
		 Case when A.Nosat=1 then A.Qnt
            when A.Nosat=2 then A.Qnt2
            else 0
       end BPPB_QntBPPB,
       Case when A.Nosat=1 then isnull(d.QntBBP,0)
            when A.Nosat=2 then isnull(d.Qnt2BBP,0)
            else 0
       end BPPB_QntBBP,
       Case when A.Nosat=1 then isnull(B.QntBPB,0)
            when A.Nosat=2 then isnull(B.Qnt2BPB,0)
            else 0
       end BPPB_QntBPB,
       Case when A.Nosat=1 then isnull(C.QntPPL,0)
            when A.Nosat=2 then isnull(C.Qnt2PPL,0)
            else 0
       end BPPB_QntPPL,
       Case when A.Nosat=1 then isnull(e.QntBPL,0)
            when A.Nosat=2 then isnull(e.Qnt2BPL,0)
            else 0
       end BPPB_QntBPL,
       Case when A.Nosat=1 then A.Qnt - ISNULL(B.QntBPB, 0)-ISNULL(d.QntBBP, 0)
            when A.Nosat=2 then A.Qnt2 - ISNULL(B.Qnt2BPB, 0)-ISNULL(d.Qnt2BBP, 0)
            else 0
       end BPPB_QntSisaBPB,
       Case when A.Nosat=1 then A.Qnt - ISNULL(d.QntBBP, 0) - ISNULL(C.QntPPL,0)+ISNULL(e.QntBPL,0)
            when A.Nosat=2 then A.Qnt2 - ISNULL(d.Qnt2BBP, 0) - ISNULL(C.Qnt2PPL, 0)+ISNULL(e.Qnt2BPL,0)
            else 0
       end BPPB_QntSisa,
		 Case when A.Nosat=1 then A.Sat_1
            when A.Nosat=2 then A.Sat_2
            else ''
       end BPPB_Satuan
FROM dbo.DBPermintaanBrgDET AS A 
LEFT OUTER JOIN (SELECT x.NoPermintaan, x.UrutPermintaan, x.kodebrg, SUM(x.Qnt) AS QntBPB, SUM(x.Qnt2) AS Qnt2BPB
                 FROM dbo.DBPenyerahanBrgDET x
                 GROUP BY x.NoPermintaan, x.UrutPermintaan, x.kodebrg) AS B ON B.NoPermintaan = A.Nobukti AND B.UrutPermintaan = A.urut AND 
                 B.kodebrg = A.kodebrg 
LEFT OUTER JOIN (SELECT x.NoPermintaan, x.UrutPermintaan, x.kodebrg, 
                 SUM(x.Qnt) AS QntPPL, 
                 SUM(x.Qnt2) AS Qnt2PPL
                 FROM dbo.DBPPLDET AS x 
                 GROUP BY x.NoPermintaan, x.UrutPermintaan, x.kodebrg) AS c ON c.NoPermintaan = A.Nobukti AND c.UrutPermintaan = A.urut AND 
                      c.kodebrg = A.kodebrg
LEFT Outer join (select x.NoBPPB, x.UrutBPPB, x.kodebrg,
                        SUM(x.Qnt) QntBBP, SUM(x.Qnt2) Qnt2BBP
                 from  DBBatalMintaBrgDet x
                 group by x.NoBPPB, x.UrutBPPB, x.kodebrg) d on d.NoBPPB=A.Nobukti and d.UrutBPPB=A.urut  
LEFT OUTER JOIN (SELECT y.NoPermintaan, y.UrutPermintaan, x.kodebrg, 
                 SUM(x.Qnt) AS QntBPL, 
                 SUM(x.Qnt2) AS Qnt2BPL
                 FROM dbo.DBBatalPPLDET AS x
                      left outer join (Select y.NoPermintaan,y.UrutPermintaan,y.kodebrg, y.Nobukti,y.urut
                                       From DBPPLDET y 
                                       Group by y.NoPermintaan,y.UrutPermintaan,y.kodebrg, y.Nobukti,y.urut) y on y.Nobukti=x.NoPPL and y.urut=x.UrutPPL
                 GROUP BY y.NoPermintaan, y.UrutPermintaan, x.kodebrg) AS e ON e.NoPermintaan = A.Nobukti AND e.UrutPermintaan = A.urut AND 
                      c.kodebrg = A.kodebrg
Left Outer join DBPermintaanBrg F on F.Nobukti=A.Nobukti                      


GO

-- View: vwOutPO
-- Created: 2011-05-05 15:41:36.280 | Modified: 2011-09-16 08:43:29.037
-- =====================================================
CREATE View [dbo].[vwOutPO]
as

select	A.Nobukti, A.urut, A.NoPPL, A.UrutPPL, A.kodebrg, A.Sat_1, A.Sat_2, A.Isi, A.Qnt, A.Qnt2, 
	      isnull(B.QntBatal,0) QntBatal, isnull(B.Qnt2Batal,0) Qnt2Batal, 
	      isnull(C.QntBeli,0) QntBeli, isnull(C.Qnt2Beli,0) Qnt2Beli,
	      A.Qnt-isnull(C.QntBeli,0) QntSisaBeli, 
	      A.Qnt2-isnull(C.Qnt2Beli,0) Qnt2SisaBeli,
	      A.Qnt-isnull(B.QntBatal,0)-isnull(C.QntBeli,0)+ISNULL(C.QntTukar,0) QntSisa, 
	      A.Qnt2-isnull(B.Qnt2Batal,0)-isnull(C.Qnt2Beli,0)+ISNULL(C.Qnt2Tukar,0) Qnt2Sisa,
	      ISNULL(C.QntTukar,0) QntTukar, ISNULL(C.Qnt2Tukar,0) Qnt2Tukar
from 	dbPODet A
left outer join
	(Select NoPO, UrutPO, KodeBrg, sum(Qnt) QntBatal, sum(Qnt2) Qnt2Batal
	 from dbBatalPODet
	 group by NoPO, UrutPO, KodeBrg) B on B.NoPO=A.NoBukti and B.UrutPO=A.Urut and B.KodeBrg=A.KodeBrg
left outer join
	(select x.NoPO, x.URUTPO, x.KODEBRG, sum(Qnt) QntBeli, sum(Qnt2) Qnt2Beli, sum(y.QntTukar) QntTukar, sum(y.Qnt2Tukar) Qnt2Tukar
	 from dbBeliDet x
	      left outer join(select NOPBL, URUTPBL, KodeBrg, sum(QNTTukar) QntTukar, sum(QNT2Tukar) Qnt2Tukar
	                      from DBRBELIDET A 
	                      group by NOPBL, URUTPBL, KodeBrg) y on y.NOPBL=x.NoBukti and y.URUTPBL=x.Urut
	 group by x.NOPO, x.URUTPO, x.KODEBRG) C on C.NoPO=A.NoBukti and C.UrutPO=A.Urut and C.KodeBrg=A.KODEBRG

GO

-- View: vwOutPO_BP
-- Created: 2011-05-05 15:40:51.680 | Modified: 2011-06-09 11:17:17.323
-- =====================================================
CREATE View [dbo].[vwOutPO_BP]
as
select	A.NoBukti, A.Urut, A.NoPPL, A.UrutPPL, '' NoInspeksi, 0 UrutInspeksi, A.KodeBrg, A.Sat_1, A.Sat_2, A.Isi, A.Qnt, A.Qnt2, 
	isnull(B.QntBatal,0) QntBatal, isnull(B.Qnt2Batal,0) Qnt2Batal, 
	isnull(C.QntBeli,0) QntBeli, isnull(C.Qnt2Beli,0) Qnt2Beli,
	A.Qnt-isnull(C.QntBeli,0)+ISNULL(D.QntTukar,0) QntSisaBeli, 
	A.Qnt2-isnull(C.Qnt2Beli,0)+ISNULL(D.Qnt2Tukar,0) Qnt2SisaBeli,
	A.Qnt-isnull(B.QntBatal,0)-isnull(C.QntBeli,0)+ISNULL(D.QntTukar,0) QntSisa, 
	A.Qnt2-isnull(B.Qnt2Batal,0)-isnull(C.Qnt2Beli,0)+ISNULL(D.Qnt2Tukar,0) Qnt2Sisa,
	A.Nosat,A.Catatan
from 	dbPODet A
left outer join
	(
	select NoPO, UrutPO, KodeBrg, sum(Qnt) QntBatal, sum(Qnt2) Qnt2Batal
	from dbBatalPODet
	group by NoPO, UrutPO, KodeBrg
	) B on B.NoPO=A.NoBukti and B.UrutPO=A.Urut and B.KodeBrg=A.KodeBrg
left outer join
	(select NoPO, UrutPO, KodeBrg, sum(Qnt) QntBeli, sum(Qnt2) Qnt2Beli
	from dbBeliDet
	group by NoPO, UrutPO, KodeBrg
	) C on C.NoPO=A.NoBukti and C.UrutPO=A.Urut and C.KodeBrg=A.KodeBrg
Left outer join (Select y.NOPO,y.URUTPO,SUM(QNTTUKAR) QntTukar, SUM(Qnt2Tukar) Qnt2Tukar
                 from DBRBELIDET x
                 left Outer Join DBBELIDET y on y.NOBUKTI=x.NOPBL and y.URUT=x.URUTPBL
                 Group by y.NOPO,y.URUTPO) D on D.NOPO=C.NOPO and D.URUTPO=C.URUTPO 

GO

-- View: vwOutPO_Inspeksi
-- Created: 2011-05-05 15:42:41.480 | Modified: 2011-05-05 15:42:41.480
-- =====================================================



CREATE View [dbo].[vwOutPO_Inspeksi]
as

select	A.Nobukti, A.urut, A.NoPPL, A.UrutPPL, A.kodebrg, A.Sat_1, A.Sat_2, A.Isi, A.Qnt, A.Qnt2, 
	isnull(B.QntBatal,0) QntBatal, isnull(B.Qnt2Batal,0) Qnt2Batal, isnull(C.QntIns,0) QntIns, isnull(C.Qnt2Ins,0) Qnt2Ins,
	A.Qnt-isnull(C.QntIns,0) QntSisaIns, A.Qnt2-isnull(C.Qnt2Ins,0) Qnt2SisaIns,
	A.Qnt-isnull(B.QntBatal,0)-isnull(C.QntIns,0) QntSisa, A.Qnt2-isnull(B.Qnt2Batal,0)-isnull(C.Qnt2Ins,0) Qnt2Sisa, A.Nosat
from 	dbPODet A
left outer join
	(
	select NoPO, UrutPO, KodeBrg, sum(Qnt) QntBatal, sum(Qnt2) Qnt2Batal
	from dbBatalPODet
	group by NoPO, UrutPO, KodeBrg
	) B on B.NoPO=A.NoBukti and B.UrutPO=A.Urut and B.KodeBrg=A.KodeBrg
left outer join
	(select NoPO, UrutPO, KodeBrg, sum(Qnt1) QntIns, sum(Qnt2) Qnt2Ins
	from dbInspeksiDet
	group by NoPO, UrutPO, KodeBrg
	) C on C.NoPO=A.NoBukti and C.UrutPO=A.Urut and C.KodeBrg=A.KodeBrg
left outer join dbPPLDet P on P.NoBukti=A.NOPPL and P.Urut=A.UrutPPL
left outer join dbPermintaanBrgDet P2 on P2.NoBukti=P.NoPermintaan and P2.Urut=P.UrutPermintaan
where	P2.IsInspeksi=1





GO

-- View: vwOutPOBatal
-- Created: 2014-02-13 11:53:13.270 | Modified: 2014-07-18 10:07:35.923
-- =====================================================





CREATE View [dbo].[vwOutPOBatal]
as

select c.TANGGAL,A.Nobukti, NAMACUSTSUPP,a.urut, A.NoPPL, A.UrutPPL, A.kodebrg, A.Satuan,A.Isi, A.Qnt, 
	      isnull(B.QntBatal,0) QntBatal, A.NAMABRG,
	      A.Qnt-isnull(e.QntTerima,0) QntSisa, ISNULL(QntTerima,0)QntTerima
	 
from 	dbPODet A
left outer join DBPO c on c.NOBUKTI =a.NOBUKTI 
left outer join DBBARANG d on d.KODEBRG =a.KODEBRG 
left Outer join DBCUSTSUPP f on f.KODECUSTSUPP=c.KODESUPP

left outer join
	(Select NOBUKTI , Urut, KodeBrg, sum(QntBatal ) QntBatal
	 from dbPODet
	 group by NOBUKTI, Urut, KodeBrg) B on B.NOBUKTI=A.NoBukti and B.Urut=A.Urut and B.KodeBrg=A.KodeBrg
left outer join
	(Select NoPO , UrutPO, KodeBrg, sum(Qnt ) QntTerima
	 from dbbelidet
	 group by NOpo, Urutpo, KodeBrg) e on e.NoPO =A.NoBukti and e.UrutPO=A.Urut and e.KodeBrg=A.KodeBrg	 
where
Cast(Case when Case when c.IsOtorisasi1=1 then 1 else 0 end+
                       Case when c.IsOtorisasi2=1 then 1 else 0 end+
                       Case when c.IsOtorisasi3=1 then 1 else 0 end+
                       Case when c.IsOtorisasi4=1 then 1 else 0 end+
                       Case when c.IsOtorisasi5=1 then 1 else 0 end=c.MaxOL then 0
                  else 1
             end As Bit)=0 







GO

-- View: vwOutPPL
-- Created: 2014-02-13 11:53:13.260 | Modified: 2015-04-21 08:55:56.120
-- =====================================================





CREATE VIEW [dbo].[vwOutPPL]
AS
/*
select	A.Nobukti, A.NoUrut, A.Tanggal,c.NMDEP, 
B.urut, B.kodebrg, Br.NAMABRG, B.Sat, B.Nosat, B.Isi, B.Qnt, Isnull(B.QntPO,0)QntPO, B.Keterangan, isnull(B.Qnt,0)-Isnull(B.QntPO,0)-Isnull(B.Qntbatal,0) SisaPPL, B.IsClose,br.tolerate
,B.Qnt-isnull(e.QntTerima,0) QntSisa, QntTerima,B.QntBatal,B.Tglbatal,B.IsBatal,B.userbatal,
A.IsOtorisasi1, A.OtoUser1, A.TglOto1,
       A.IsOtorisasi2, A.OtoUser2, A.TglOto2,
       A.IsOtorisasi3, A.OtoUser3, A.TglOto3,
       A.IsOtorisasi4, A.OtoUser4, A.TglOto4,
       A.IsOtorisasi5, A.OtoUser5, A.TglOto5,
       Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi
from	DBPPL A
left outer join DBPPLDET B on B.Nobukti=A.Nobukti
left outer join DBBARANG Br on Br.KODEBRG=B.kodebrg
left outer join DBDEPART c on c.KDDEP=a.KDDep
left outer join
	(Select NoPPL , UrutPPL, KodeBrg, sum(Qnt ) QntTerima
	 from DBPODET
	 group by NoPPL, UrutPPL, KodeBrg) e on e.NoPPL =B.NoBukti and e.UrutPPL=B.Urut and e.KodeBrg=B.KodeBrg	 
where B.Qnt-Isnull(B.QntPO,0)>0 and a.IsOtorisasi1 =1
and isnull(A.IsBatal,0)=0
*/


select B.Nobukti,B.urut,S.NoPPL,S.UrutPPL,B.kodebrg,S.Kodebrg KOdebrgPO,Sum(isnull(B.Qnt,0)) Qnt,
Sum(isnull(B.Qnt,0)) QNTPR,Sum(isnull(S.QNT,0)) QNTPO,Sum(isnull(S.QNT,0)) QntTerima,
SUM(Isnull(B.Qntbatal,0)) QntBatal,SUM(Isnull(S.QntBatal,0)) QntBatalPO
,B.Isbatal BatalpR,B.IsClose ClosePR,S.IsClose ClosePO,S.Isbatal BatalPO,
B1.IsOtorisasi1, B1.OtoUser1, B1.TglOto1, B1.IsOtorisasi2, B1.OtoUser2, B1.TglOto2,
       B1.IsOtorisasi3, B1.OtoUser3, B1.TglOto3,
       B1.IsOtorisasi4, B1.OtoUser4, B1.TglOto4,
       B1.IsOtorisasi5, B1.OtoUser5, B1.TglOto5,
       Cast(Case when Case when b1.IsOtorisasi1=1 then 1 else 0 end+
                      Case when B1.IsOtorisasi2=1 then 1 else 0 end+
                      Case when B1.IsOtorisasi3=1 then 1 else 0 end+
                      Case when B1.IsOtorisasi4=1 then 1 else 0 end+
                      Case when B1.IsOtorisasi5=1 then 1 else 0 end=B1.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi
		,c.NMDEP,
Sum(isnull(B.Qnt,0)) - Sum(isnull(S.QNT,0)) QntSisa,B1.Nourut,
B1.Tanggal,B.sat,
 B.NamaBrg NamaBrg,
B.Nosat,B.Isi,S.Tolerate,B.Keterangan,B.IsClose,
Sum(isnull(B.Qnt,0))-Sum(Isnull(S.Qnt,0))-Sum(Isnull(B.Qntbatal,0)) SisaPPL
,B.Tglbatal,B.IsBatal,B.userbatal,ISnull(B.IsJasa,0) IsJasa,
MONTH(B1.Tanggal) BULAN, YEAR(B1.Tanggal) TAHUN
from DBPPLDET B 
Left Outer Join DBPODET S on B.Nobukti=S.NoPPL and B.urut=S.UrutPPL
Left Outer JOin DBPPL B1 on B.Nobukti=b1.Nobukti
left outer join DBDEPART c on c.KDDEP=B1.KDDep
LEFT Outer Join DBBARANG D on B.kodebrg=D.kodebrg
--where B.Nobukti in ('SJE/PR/0114/0013','SJE/PR/0114/0010')and S.NOBUKTI is null
Where  B1.IsOtorisasi1 =1 and isnull(b1.IsBatal,0)=0 and ISNULL(B.Isbatal,0)=0
group by B.Nobukti,B.urut,S.NoPPL,S.UrutPPL,B.Isbatal,B.IsClose,S.IsClose,S.Isbatal,
B.kodebrg,S.Kodebrg,B1.IsOtorisasi1,B1.Tanggal,
 B1.IsOtorisasi2, B1.OtoUser2, B1.TglOto2,
       B1.IsOtorisasi3, B1.OtoUser3, B1.TglOto3,
       B1.IsOtorisasi4, B1.OtoUser4, B1.TglOto4,
       B1.IsOtorisasi5, B1.OtoUser5, B1.TglOto5,B1.MaxOL
       ,c.NMDEP,B1.Nourut,B.Sat,D.NamaBrg,B.Nosat,B.Isi,S.Tolerate,B.Keterangan
,B.IsClose,B.Tglbatal,B.IsBatal,B.userbatal, B1.OtoUser1, B1.TglOto1,B.NamaBrg,B.IsJasa
having Sum(isnull(B.Qnt,0)) <>Sum(isnull(S.QNT,0))









GO

-- View: vwOutRJual
-- Created: 2013-02-05 11:18:37.143 | Modified: 2014-03-05 13:37:18.703
-- =====================================================


CREATE View [dbo].[vwOutRJual]
as

select	A.NoBukti, A.Urut, A.KodeBrg,  A.Sat_1, A.Sat_2, A.NoSat, A.Isi, A.Qnt, A.Qnt2, 
	isnull(C.QntSPB,0) QntSPB, isnull(C.Qnt2SPB,0) Qnt2SPB,
	A.Qnt-isnull(C.QntSPB,0) QntSisa, A.Qnt2-isnull(C.Qnt2SPB,0) Qnt2Sisa,
     a.NetW, A.GrossW, A.NoInvoice, A.UrutInvoice, A.NamaBrg, B.IsFLag
from 	DBRInvoicePLDET A
left outer join
	(select NoINV, UrutINV, KodeBrg, sum(Qnt) QntSPB, sum(Qnt2) Qnt2SPB
	 from dbSPBRjualDet
	 group by NoINV, UrutINV, KodeBrg) C on C.NoINV=A.NoBukti and C.UrutINV=A.Urut and C.KodeBrg=A.KodeBrg
	Left Outer Join DBRInvoicePL B on B.NoBukti=A.NoBukti

GO

-- View: vwOutSC
-- Created: 2011-08-19 09:45:37.840 | Modified: 2011-08-19 09:45:37.840
-- =====================================================

Create VIew [dbo].[vwOutSC]
as
Select a.Nobukti, b.Urut, b.Sat_1, b.Sat_2, b.Isi, b.Nosat, b.Qnt, b.Qnt2,
       b.Kodebrg, isnull(C.Qnt,0) QntSC, isnull(C.Qnt2,0) Qnt2SC,
       b.Qnt-isnull(C.Qnt,0) QntSisa,
       b.Qnt2-isnull(C.Qnt2,0) Qnt2Sisa
from dbSalesContract a
     left outer join dbSalesContractDet b on b.Nobukti=a.Nobukti
     left outer join (Select NoSC,UrutSC, SUM(Qnt) Qnt, SUM(Qnt2) Qnt2
                      from DBSHIPPINGDET 
                      group by NoSC,UrutSC) C on C.NoSC=a.Nobukti and C.UrutSC=b.Urut

GO

-- View: vwOutSC_SPP
-- Created: 2011-09-21 10:12:22.183 | Modified: 2011-09-21 17:50:20.290
-- =====================================================

CREATE View [dbo].[vwOutSC_SPP]
as

select	A.NoBukti, A.Urut, A.KodeBrg, A.Sat_1, A.Sat_2, A.NoSat, A.Isi, A.Qnt, A.Qnt2, 
	isnull(C.QntSPP,0) QntSPP, isnull(C.Qnt2SPP,0) Qnt2SPP,
	A.Qnt-isnull(C.QntSPP,0) QntSisa, A.Qnt2-isnull(C.Qnt2SPP,0) Qnt2Sisa,
	A.NamaBrg NamabrgKom
from 	dbSalesContractDet A
left Outer Join (select NoSC, UrutSC, KodeBrg, sum(Qnt) QntSPP, sum(Qnt2) Qnt2SPP
	              from dbSPPLokalDet
	              group by NoSC, UrutSC, KodeBrg) C on C.NoSC=A.NoBukti and C.UrutSC=A.Urut and C.KodeBrg=A.KodeBrg
Left Outer Join dbSalesContract B on B.Nobukti=A.Nobukti	              
where B.IsLokal=0



GO

-- View: vwOutSHIP
-- Created: 2011-08-19 15:28:49.410 | Modified: 2011-09-21 18:30:51.487
-- =====================================================

CREATE View [dbo].[vwOutSHIP]
as

select	A.NoBukti, A.Urut, A.KodeBrg, A.NamaBrg, A.Sat_1, A.Sat_2, A.NoSat, A.Isi,isnull(B.Qnt,0) Qnt, 
   isnull(B.Qnt2,0) Qnt2, 
	isnull(B.Qnt,0) QntSPB, isnull(B.Qnt2,0) Qnt2SPB,
	isnull(B.Qnt,0)-isnull(C.QntSPB,0) QntSisa, isnull(B.Qnt2,0)-isnull(C.Qnt2SPB,0) Qnt2Sisa,
	B.NetW,B.GrossW, A.NoSC
from 	DBSHIPPINGDET A
left outer join (select NoShip, UrutSHIP, KodeBrg, sum(Qnt) QntSPB, sum(Qnt2) Qnt2SPB
	              from dbInvoicePLDet
	              group by NoSHIP, UrutSHIP, KodeBrg) C on C.NoSHIP=A.NoBukti and C.UrutSHIP=A.Urut
Left Outer Join (Select x.NoSHIP,x.UrutSHIP, SUM(y.QNT) Qnt, SUM(y.qnt2) Qnt2,
                             sum(y.NetW) NetW, SUM(y.GrossW) GrossW
                 from dbSPPDet x
                      left Outer Join dbSPBDet y on y.NoSPP=x.NoBukti and y.UrutSPP=x.Urut
                 group by x.NoSHIP, x.UrutSHIP) B on B.NoSHIP=A.Nobukti and B.UrutSHIP=A.Urut   
left Outer join DBSHIPPING D on D.NoBukti=A.Nobukti
where D.isclose=1                            
	 



GO

-- View: vwOutSHIP_SPP
-- Created: 2011-08-19 08:46:40.327 | Modified: 2011-12-27 20:03:10.237
-- =====================================================




CREATE View [dbo].[vwOutSHIP_SPP]
as
select A.NoBukti, A.Urut, A.KodeBrg, A.Sat_1, A.Sat_2, A.NoSat, A.Isi, A.Qnt, A.Qnt2, 
	    isnull(C.QntSPP,0) QntSPP, isnull(C.Qnt2SPP,0) Qnt2SPP,
	    A.Qnt-isnull(C.QntSPP,0) QntSisa, A.Qnt2-isnull(C.Qnt2SPP,0) Qnt2Sisa,
	    A.NoSC, A.Namabrg NamabrgKom, A.shippingMark
from 	DBSHIPPINGDET A
left outer join(select NoSHIP, UrutSHIP, KodeBrg, sum(Qnt) QntSPP, sum(Qnt2) Qnt2SPP
	             from dbSPPDet
	             group by NoSHIP, UrutSHIP, KodeBrg) C on C.NoSHIP=A.NoBukti and C.UrutSHIP=A.Urut 
left Outer join (Select Nobukti
                 from dbSalesContract) D on D.Nobukti=A.NoSC	



GO

-- View: vwOutSO_SPP
-- Created: 2014-02-13 11:53:45.523 | Modified: 2015-03-24 10:37:19.007
-- =====================================================


CREATE View [dbo].[vwOutSO_SPP]
as
select A.NoBukti, A.Urut, A.KodeBrg, A.SATUAN, A.NoSat, A.Isi, A.Qnt, A.Qnt2, 
	    isnull(C.QntSPP,0) QntSPP, isnull(C.Qnt2SPP,0) Qnt2SPP,
	    A.Qnt-isnull(C.QntSPP,0) QntSisa, A.Qnt2-isnull(C.Qnt2SPP,0) Qnt2Sisa,
	    B.CATATAN, D.Namabrg NamabrgKom, B.IsLengkap, B.MasaBerlaku,A.IScloseDet,B.TANGGAL
from 	DBSODET A
Left Outer join DBSO B on b.NOBUKTI=A.NOBUKTI
left outer join(select NoSO, UrutSO, KodeBrg, sum(Qnt) QntSPP, sum(Qnt2) Qnt2SPP
	             from dbSPPDet
	             group by NoSO, UrutSO, KodeBrg) C on C.NoSO=A.NoBukti and C.UrutSo=A.Urut 
Left Outer join DBBARANG D on D.KODEBRG=A.KODEBRG
GO

-- View: vwOutSPB
-- Created: 2014-02-19 10:17:43.010 | Modified: 2014-02-19 10:18:40.073
-- =====================================================

CREATE view [dbo].[vwOutSPB]
as
With InvoicePL(NoInvoice, Kodecust, NoSPB, UrutSPB, Qnt, Qnt2)
AS
(Select A.NoBukti, a.KodeCustSupp, B.NoSPB, B.UrutSPB, Sum(B.QNT) Qnt, Sum(B.QNT2) Qnt2
 From dbInvoicePL A
      Left Outer join dbInvoicePLDet B on b.NoBukti=A.NoBukti
 Group by A.NoBukti, a.KodeCustSupp, B.NoSPB, B.UrutSPB)

Select A.NoBukti, B.KodeBrg, B.ISI, B.NOSAT,
       Case when B.NOSAT=1 then B.SAT_1 
            when B.NOSAT=2 then B.SAT_2
            else ''
       end Satuan, B.qnt, B.QNT2, B.NetW, B.GrossW,
       ISNULL(c.qnt,0) QntInv,
       B.QNT-ISNULL(c.qnt,0) Sisa,ISNULL(A.FlagTipe,0) FlagTipe       
From dbSPB a
     Left Outer join dbSPBDet b on b.NoBukti=a.NoBukti 
     left Outer join InvoicePL c on c.NoSPB=b.NoBukti and c.UrutSPB=b.urut
where B.QNT-ISNULL(c.qnt,0)>0


GO

-- View: vwOutSPB_RSPB
-- Created: 2014-02-19 10:17:42.977 | Modified: 2014-02-19 10:18:32.160
-- =====================================================

CREATE View [dbo].[vwOutSPB_RSPB]
as

Select A.NoBukti, A.Urut, A.KodeBrg, A.NamaBrg, A.Sat_1, A.Sat_2, A.NoSat, A.Isi, A.Qnt, A.Qnt2, 
	    isnull(C.QntRSPB,0) QntRSPB, isnull(C.Qnt2RSPB,0) Qnt2RSPB,
	    A.Qnt-isnull(C.QntRSPB,0) QntSisa, A.Qnt2-isnull(C.Qnt2RSPB,0) Qnt2Sisa,
	    A.NetW,A.GrossW, 'Ekspor' TipeSPP, B.Catatan, B.isClose, b.IsOtorisasi1,b.OtoUser1,b.TglOto1,
	    ISNULL(B.FlagTipe,0) FlagTipe
from 	DBSPBDet A
left outer join (select NoSPB, UrutSPB, KodeBrg, sum(Qnt) QntRSPB, sum(Qnt2) Qnt2RSPB
	              from DBRSPBDet
	              group by NoSPB, UrutSPB, KodeBrg) C on C.NoSPB=A.NoBukti and C.UrutSPB=A.Urut 
Left Outer Join DBSPB B on B.NoBukti=A.NoBukti
--where b.IsOtorisasi1=1


GO

-- View: vwOutSPBRJual
-- Created: 2014-09-24 11:37:06.870 | Modified: 2014-09-24 11:37:06.870
-- =====================================================
Create    View [dbo].[vwOutSPBRJual]
as

select X.NOBUKTI+' '+right('00000000'+cast(X.URUT as varchar(8)),8) KeyUrut,
	X.NOURUT, X.NOBUKTI, X.TANGGAL, X.KODECUSTSUPP, Cs.NAMACUSTSUPP,
	Cs.ALAMAT ALAMATCUSTSUPP, Cs.KOTA KOTACUSTSUPP, Cs.NamaKota NAMAKOTACUSTSUPP, 
	X.NoRPJ, X.URUT, X.KODEBRG, Br.NAMABRG, Br.SAT1, Br.SAT2, Br.NFix,
	Br.ISI1, Br.ISI2, 
	sum(X.Qnt) Qnt, SUM(X.Qnt1) Qnt1, SUM(X.Qnt2) Qnt2, 
	max(X.NOSAT) NoSat, max(X.SATUAN) Satuan, max(ISI) Isi, 
	sum(X.QntInv) QntInv, SUM(X.Qnt)-SUM(X.QntInv) QntSisa,
	SUM(X.Qnt)-SUM(X.QntInv) Qnt1Sisa, SUM(X.Qnt)-SUM(X.QntInv) Qnt2Sisa,
	X.NilaiOL, X.MaxOL
from
	(
	select A.NoUrut, A.NOBUKTI, A.TANGGAL, A.KodeCustSupp KODECUSTSUPP, 
		A.NoRPJ, B.URUT, B.KODEBRG, 
		B.Qnt, B.QNT1, B.QNT2, B.NOSAT, B.SAT_1 SATUAN, B.ISI, 
		0 QntInv,
		(Case when A.IsOtorisasi1=1 then 1 else 0 end+
        Case when A.IsOtorisasi2=1 then 1 else 0 end+
        Case when A.IsOtorisasi3=1 then 1 else 0 end+
        Case when A.IsOtorisasi4=1 then 1 else 0 end+
        Case when A.IsOtorisasi5=1 then 1 else 0 end) NilaiOL,
        A.MAXOL
	from dbSPBRJual A, dbSPBRJualDet B
	where B.NOBUKTI=A.NOBUKTI
	union all
	select A.NoUrut, A.NOBUKTI, A.TANGGAL, A.KodeCustSupp KODECUSTSUPP, 
		A.NoRPJ ,B.UrutSPR URUT, B.KODEBRG, 
		0 Qnt, 0 QNT2, 0 QNT2, 0 NoSat, '' Satuan, 0 Isi,
		B.Qnt QntInv,
		(Case when A.IsOtorisasi1=1 then 1 else 0 end+
        Case when A.IsOtorisasi2=1 then 1 else 0 end+
        Case when A.IsOtorisasi3=1 then 1 else 0 end+
        Case when A.IsOtorisasi4=1 then 1 else 0 end+
        Case when A.IsOtorisasi5=1 then 1 else 0 end) NilaiOL,
        A.MAXOL 
	from dbSPBRJual A, DBINVOICERPJDet B
	where B.NOSPR=A.NOBUKTI
	) X
left outer join vwCUSTSUPP Cs on Cs.KODECUSTSUPP=X.KODECUSTSUPP
left outer join DBBARANG Br on Br.KODEBRG=X.KodeBrg
group by X.NOURUT, X.NOBUKTI, X.TANGGAL, X.KODECUSTSUPP, Cs.NAMACUSTSUPP,
	Cs.ALAMAT, Cs.KOTA, Cs.NamaKota, 
	X.NoRPJ, X.Urut, X.KODEBRG, Br.NAMABRG, Br.SAT1, Br.SAT2, Br.NFix,
	Br.ISI1, Br.ISI2,
	X.NilaiOL, X.MaxOL



GO

-- View: vwOutSPK_HasilP
-- Created: 2014-04-14 11:01:54.660 | Modified: 2014-04-14 11:01:54.660
-- =====================================================


CREATE View [dbo].[vwOutSPK_HasilP]
AS
Select A.NoBukti,A.TANGGAL,A.KodeBrg KodeBrgJ,E.NamaBrg NamaBrgJ ,A.Qnt*A.isi QntJ,A.Nosat NosatJ,A.Isi IsiJ,A.Satuan SatJ,
       ISNULL(Case when A.Nosat=1 then Case when B.NOSAT=1 then B.QNT
                                            when B.NOSAT=2 then B.QNT*A.isi
                                            else 0
                                       end
                   when A.Nosat=2 then Case when B.NOSAT=1 then B.QNT/A.isi
                                            when B.NOSAT=2 then B.QNT
                                            else 0
                                       end
                   else 0
              end,0)*Case when A.nosat=1 then 1
                          When A.nosat=2 then A.Isi 
                     end QntH,
       (A.QNT*A.Isi)-(
       ISNULL(Case when A.Nosat=1 then Case when B.NOSAT=1 then B.QNT
                                            when B.NOSAT=2 then B.QNT*A.isi
                                            else 0
                                       end
                   when A.Nosat=2 then Case when B.NOSAT=1 then B.QNT/A.isi
                                            when B.NOSAT=2 then B.QNT
                                            else 0
                                       end
                   else 0
              end,0)*Case when A.nosat=1 then 1
                          When A.nosat=2 then A.Isi 
                     end) SisaSPK
From dbSPK A
     Left Outer join dbBarang E on E.KodeBrg=A.Kodebrg
     Left Outer join (Select y.NoSPK,y.KODEBRG, y.KodeGdg, y.QNT, y.NOSAT, y.ISI, y.SATUAN
                      from DBHASILPRD x
                           left Outer join DBHASILPRDDET y on y.NOBUKTI=x.NOBUKTI) B on B.NoSPK=A.NOBUKTI and B.KODEBRG=A.KODEBRG
where (A.QNT*A.isi)-(
       ISNULL(Case when A.Nosat=1 then Case when B.NOSAT=1 then B.QNT
                                            when B.NOSAT=2 then B.QNT*A.isi
                                            else 0
                                       end
                   when A.Nosat=2 then Case when B.NOSAT=1 then B.QNT/A.isi
                                            when B.NOSAT=2 then B.QNT
                                            else 0
                                       end
                   else 0
              end,0)*Case when A.nosat=1 then 1
                          When A.nosat=2 then A.Isi 
                     end)>0 


GO

-- View: vwOutSPK_Pakai
-- Created: 2014-04-21 13:31:36.003 | Modified: 2014-09-12 11:39:31.103
-- =====================================================




CREATE View [dbo].[vwOutSPK_Pakai]
as

select NOBUKTI, URUT, KODEBRG, NOSAT, 
sum(QNTSPK) QntSPK, sum(QntPakai) QntPakai, sum(QNTSisa) QntSisa, KodePrs
from
(
select NOBUKTI, URUT, KODEBRG, NOSAT, QNT QntSPK, 0.00 QntPakai, QNT QntSisa, KodePrs
from DBSPKDET
union all
select NoSPK NoBukti, UrutSPK Urut, kodebrg, NoSat,
0.00 QntSPK, case when NoSat=1 then Qnt else Qnt2 end QntPakai,
-1*case when NoSat=1 then Qnt else Qnt2 end QntSisa, B.KodePrs 
from DBPenyerahanBhnDET A
left outer join DBPenyerahanBhn B on A.Nobukti = B.nobukti
) X group by NOBUKTI, URUT, KODEBRG, NOSAT, KodePrs





GO

-- View: vwOutSPP
-- Created: 2011-10-19 08:41:19.427 | Modified: 2014-09-11 10:45:25.173
-- =====================================================



CREATE View [dbo].[vwOutSPP]
as

select	A.NoBukti, A.Urut, A.KodeBrg, A.NamaBrg, A.Sat_1, A.Sat_2, A.NoSat, A.Isi, A.Qnt, A.Qnt2, 
	isnull(C.QntSPB,0) QntSPB, isnull(C.Qnt2SPB,0) Qnt2SPB,
	A.Qnt-(isnull(C.QntSPB,0)-isnull(D.QNTRSPB,0)) QntSisa, A.Qnt2-(isnull(C.Qnt2SPB,0)-isnull(D.QNT2RSPB,0)) Qnt2Sisa,
	A.NetW,A.GrossW, 'Ekspor' TipeSPP, B.Catatan, B.isClose, 
     Case when A.NOSAT=1 then A.SAT_1
          when A.NOSAT=2 then A.SAT_2
          else ''
     end Satuan, A.NoSO, A.UrutSO, A.isCetakKitir,D.QNT2RSPB,D.QNTRSPB
from 	dbSPPDet A
left outer join
	(select NoSPP, UrutSPP, KodeBrg, sum(Qnt) QntSPB, sum(Qnt2) Qnt2SPB
	from dbSPBDet
	group by NoSPP, UrutSPP, KodeBrg
	) C on C.NoSPP=A.NoBukti and C.UrutSPP=A.Urut and C.KodeBrg=A.KodeBrg
	Left Outer Join dbSPP B on B.NoBukti=A.NoBukti
Left Outer join
   (Select b.NoSPP,B.UrutSPP,SUM(A.QNT) QNTRSPB,SUM(A.QNT2) QNT2RSPB
     from DBRSPBDet A
     Left OUter join dbSPBDet B on A.NoSPB =B.NoBukti and A.UrutSPB=B.Urut  
     left Outer join DBRSPB y on y.NoBukti=A.NoBukti
                                  where Cast(Case when Case when y.IsOtorisasi1=1 then 1 else 0 end+
                                                       Case when y.IsOtorisasi2=1 then 1 else 0 end+
                                                       Case when y.IsOtorisasi3=1 then 1 else 0 end+
                                                       Case when y.IsOtorisasi4=1 then 1 else 0 end+
                                                       Case when y.IsOtorisasi5=1 then 1 else 0 end=y.MaxOL then 0
                                                  else 1
                                       end As Bit)=0
     group By b.NoSPP,B.UrutSPP
   ) D on A.NoBukti=D.NoSPP And A.Urut=D.UrutSPP


GO

-- View: vwOutSPRK
-- Created: 2011-03-03 11:57:52.240 | Modified: 2011-12-29 13:36:09.397
-- =====================================================

CREATE VIEW [dbo].[vwOutSPRK]
AS
SELECT  A.Nobukti, A.urut, A.kodebrg, A.Sat_1, A.Sat_2, A.Isi, A.Qnt, A.Qnt2, 
        ISNULL(B.QntPO, 0) AS QntPO, 
        ISNULL(B.Qnt2PO, 0) AS Qnt2PO,
        ISNULL(B.QntBPO, 0) AS QntBPO, 
        ISNULL(B.Qnt2BPO, 0) AS Qnt2BPO, 
        ISNULL(D.QntBSPRK, 0) AS QntBSPRK, 
        ISNULL(D.Qnt2BSPRK, 0) AS Qnt2BSPRK, 
        A.Qnt - ISNULL(B.QntPO, 0)+ISNULL(B.QntBPO, 0)- ISNULL(D.QntBSPRK, 0) AS QntSisaPO, 
        A.Qnt2 - ISNULL(B.Qnt2PO, 0)+ISNULL(B.Qnt2BPO, 0)- ISNULL(D.Qnt2BSPRK, 0) AS Qnt2SisaPO, 
        A.Qnt - ISNULL(B.QntPO, 0)+ISNULL(B.QntBPO, 0) - ISNULL(D.QntBSPRK, 0) AS QntSisa, 
        A.Qnt2 - ISNULL(B.Qnt2PO, 0)+ISNULL(B.Qnt2BPO, 0) - ISNULL(D.Qnt2BSPRK, 0) AS Qnt2Sisa,
        E.NamaBag, A.nosat, A.Pelaksana,
        A.IsInspeksi,A.Keterangan,A.Catatan,A.KodeGrp,
        Case when A.Nosat=1 then A.Qnt
            when A.Nosat=2 then A.Qnt2
            else 0
       end SPRK_Qty,
       Case when A.Nosat=1 then ISNULL(D.QntBSPRK,0)
            when A.Nosat=2 then ISNULL(D.Qnt2BSPRK,0)
            else 0
       end SPRK_QtyBtl,
       Case when A.Nosat=1 then ISNULL(B.QntPO,0)
            when A.Nosat=2 then ISNULL(B.Qnt2PO,0)
            else 0
       end SPRK_QtyPO,
       Case when A.Nosat=1 then ISNULL(B.QntBPO,0)
            when A.Nosat=2 then ISNULL(B.Qnt2BPO,0)
            else 0
       end SPRK_QtyBPO,
       Case when A.Nosat=1 then A.Qnt - ISNULL(B.QntPO, 0)+ISNULL(B.QntBPO, 0) - ISNULL(D.QntBSPRK, 0)
            when A.Nosat=2 then A.Qnt2 - ISNULL(B.Qnt2PO, 0)+ISNULL(B.Qnt2BPO, 0) - ISNULL(D.Qnt2BSPRK, 0)
            else 0
       end SPRK_QtySisa,
       Case when A.Nosat=1 then A.Sat_1
            when A.Nosat=2 then A.Sat_2
            else ''
       end SPRK_Satuan,
       C.JnsPakai,
       Case when C.JnsPakai=0 then 'Stock'
				when c.JnsPakai=1 then 'Investasi'
				when c.JnsPakai=2 then 'Rep & Pem Teknik'
				when c.JnsPakai=3 then 'Rep & Pem Komputer'
				when c.JnsPakai=4 then 'Rep & Pem Peralatan'
		 end MyJnsPakai, C.Perk_Investasi, c.Kodegdg, c.SOP, C.Tanggal, C.KodeBag, C.KodeMesin
FROM dbo.DBSPRKDET AS A 
LEFT OUTER JOIN (SELECT  x.NoPPL, x.UrutPPL, KODEBRG, SUM(x.QNT) AS QntPO, SUM(x.QNT2) AS Qnt2PO,
                         ISNULL(y.qnt,0) QntBPO,ISNULL(y.Qnt2,0) Qnt2BPO
                 FROM  dbo.DBPODET x
                       left Outer join (Select  NoPO, UrutPO, SUM(Qnt) Qnt, SUM(Qnt2) Qnt2
                                        from DBBatalPODET  
                                        group by NoPO, UrutPO) y on y.NoPO=x.NOBUKTI and y.UrutPO=x.URUT 
                 GROUP BY x.NoPPL, x.UrutPPL, x.KODEBRG, y.Qnt,y.Qnt2) AS B ON B.NoPPL = A.Nobukti AND B.UrutPPL = A.urut
left Outer join dbSPRK c on c.NoBukti=A.NoBukti
LEFT OUTER JOIN (SELECT  NoSPRK, UrutSPRK, KODEBRG, SUM(QNT) AS QntBSPRK, SUM(QNT2) AS Qnt2BSPRK
                 FROM  dbo.DBBatalSPRKDET
                 GROUP BY NoSPRK, UrutSPRK, KODEBRG) AS D ON D.NoSPRK = A.Nobukti AND D.UrutSPRK = A.urut                 
left outer join DBBAGIAN E on E.KodeBag=c.KodeBag





GO

-- View: vwOutstandingBeli
-- Created: 2012-11-29 14:29:46.490 | Modified: 2012-12-19 14:05:58.230
-- =====================================================







CREATE View [dbo].[vwOutstandingBeli]
as

select 	A.NoBukti, A.Urut, A.KodeBrg, isnull(B.QntSat1,0) QntRBeliSat1, isnull(B.QntSat2,0) QntRBeliSat2   
from 	dbBeliDet A
left outer join vwQntRBeliDariBeli B on B.NoBeli=A.NoBukti and B.UrutPBL=A.Urut
where	A.Qnt*A.Isi>isnull(B.QntSat1,0)














GO

-- View: vwOutstandingPO
-- Created: 2013-05-13 12:08:51.980 | Modified: 2014-11-19 10:03:40.273
-- =====================================================


CREATE    View [dbo].[vwOutstandingPO]
as

select 	A.NoBukti, A.Urut, A.KodeBrg,A.namaBrg,((A.Qnt*A.Isi)-(A.QntBatal*isi))-Isnull(B.QntSat1,0)QNTOS
,A.Qnt*a.ISI QntPO,A.Satuan,isnull(B.QntSat1,0) QntBeliSat1,
A.QNT,
(A.Qnt*A.Isi)-(A.QntBatal*isi) - isnull(B.QntSat1,0) OS  
from 	dbPODet A
left outer join  vwQntBeliDariPO B on B.NOPO=A.NoBukti and B.UrutPO=A.Urut
where	((A.Qnt*A.Isi)-(A.QntBatal*isi)) - isnull(B.QntSat1,0)>0
GO

-- View: vwOutTBJ_RBJ
-- Created: 2011-08-25 16:11:45.830 | Modified: 2011-08-25 16:11:45.830
-- =====================================================

CREATE View [dbo].[vwOutTBJ_RBJ]
as
Select A.Nobukti,A.Urut,A.Kodebrg,A.Kodegdg, A.Qnt,A.Qnt2, A.Nosat,A.Isi,A.Sat_1,A.Sat_2,
       isnull(B.Qnt,0) QntR, isnull(B.Qnt2,0) Qnt2R,
       A.Qnt-ISNULL(B.Qnt,0) qntSisa,
       A.Qnt2-ISNULL(B.Qnt2,0) Qnt2Sisa
From DbPenerimaanBrgJadiDet A
     left Outer join (Select x.NoTerima,x.UrutTerima, SUM(x.Qnt) Qnt, SUM(x.qnt2) Qnt2
                      from DbRPenerimaanBrgJadiDet x
                      Group by x.Noterima,x.UrutTerima) B on B.NoTerima=A.Nobukti and B.urutTerima=A.Urut
Where (A.Qnt-ISNULL(B.Qnt,0)<>0) Or (A.Qnt2-ISNULL(B.Qnt2,0)<>0)  

GO

-- View: vwpemakaianbrg
-- Created: 2011-09-30 13:32:15.170 | Modified: 2011-12-20 20:34:17.353
-- =====================================================

CREATE View [dbo].[vwpemakaianbrg]
as

SELECT a.Nobukti,b.Tanggal, a.kodebrg,c.NAMABRG,c.KodeJnsBrg,  b.Kodebag,d.NamaBag
,e.KodeJnsPakai,f.Keterangan,e.KodeMesin,g.NamaMesin,case when a.Nosat = 1 then a.Sat_1 else a.Sat_2 end as satuan,
case when a.Nosat = 1 then a.Qnt else a.Qnt2 end as QNT,a.hpp,
a.Qnt *ISNULL(a.HPP,0) as total,
Case when b.JnsPakai=0 then 'Stock'
	  when b.JnsPakai=1 then 'Investasi'
	  when b.JnsPakai=2 then 'Rep & Pem Teknik'
	  when b.JnsPakai=3 then 'Rep & Pem Komputer'
	  when b.JnsPakai=4 then 'Rep & Pem Peralatan'
end MyJnsPakai,b.JnsPakai
FROM DBPenyerahanBrgdet a 
left outer join DBPenyerahanBrg b on a.Nobukti = b.Nobukti
left outer join DBBARANG c on a.kodebrg = c.KODEBRG
left outer join DBBAGIAN d on b.Kodebag = d.KodeBag
left outer join DBPermintaanBrg e on b.NoBPPB=e.Nobukti
left outer join DBJNSPAKAI f on e.KodeJnsPakai = f.KodeJNSPakai
left outer join DBMESIN g on e.KodeMesin = g.KodeMesin


GO

-- View: vwPenerimaanBrg
-- Created: 2011-09-30 13:32:16.733 | Modified: 2011-12-21 08:22:01.347
-- =====================================================

CREATE View [dbo].[vwPenerimaanBrg]
as
select  a.NOBUKTI,b.TANGGAL,b.KODECUSTSUPP, d.NAMACUSTSUPP,
        a.KODEBRG,c.NAMABRG,a.Nosat,a.QNT,a.QNT2,a.SAT_1,a.SAT_2,f.NOPPL,c.ISJASA,c.KodeJnsBrg,
        f.tipe,
        case when a.nosat =1 then a.sat_1 
             else a.sat_2 
        end as satuan,
        case when a.Nosat = 1 then a.QNT 
             else a.QNT2 
        end as quantity,
        a.HARGA,b.KODEVLS,b.KURS,
        a.SUBTOTAL,a.SUBTOTALRp,
        a.NDPP,a.NDPPRp, a.NPPN, a.NPPNRp, a.NNET, a.NNETRp,        
        c.KodeKategori,g.Keterangan NamaKategori,g.Perkiraan PerkPersediaan, h.Keterangan NamaPerkPersediaan, 
        d.PERKIRAAN PerkHutang, d.NamaPerkiraan NamaPerkHutang
from DBBELIDET a 
left outer join DBBELI b on a.NOBUKTI = b.NOBUKTI
left outer join DBBARANG c on a.KODEBRG = c.KODEBRG
left outer join vwBrowsSupp d on b.KODECUSTSUPP = d.KODECUSTSUPP
left outer join (Select x.NOBUKTI NOPO, x.URUT URutPO, y.Tipe, x.NoPPL
                 from DBPODET x
                      left outer join DBPO y on y.NOBUKTI=x.NOBUKTI 
                 Group by x.NOBUKTI, x.URUT, x.NoPPL, y.Tipe) f on f.NOPO=a.NOPO and f.URutPO=a.URUTPO
left outer join DBKATEGORI g on g.KodeKategori=c.KodeKategori
left outer join DBPERKIRAAN h on h.Perkiraan=g.Perkiraan

GO

-- View: vwPerkiraan
-- Created: 2011-11-22 14:44:27.420 | Modified: 2011-11-22 14:44:27.420
-- =====================================================
Create View dbo.vwPerkiraan
as
select a.*,
                 Case when a.Tipe=0 then 'General'
                      when a.Tipe=1 then 'Detail'
                      else '''' 
                 end mytipe, 
                 Case when a.DK=0 then 'Debet'
                      when a.DK=1 then 'Kredit'
                      else '''' 
                 end myDK ,
                 Case when a.Kelompok=0 then 'Aktiva'
                      when a.Kelompok=1 then 'Kewajiban'
                      when a.Kelompok=2 then 'Modal'
                      when a.Kelompok=3 then 'Kelompok'
                      when a.Kelompok=4 then 'Pendapatan'
                      when a.Kelompok=5 then 'Biaya'
                      else '' 
                 end myKelompok from dbPerkiraan a 
GO

-- View: vwPerusahaan
-- Created: 2012-10-25 13:21:44.743 | Modified: 2012-10-25 13:21:44.743
-- =====================================================

CREATE VIEW [dbo].[vwPerusahaan]
AS
SELECT KODEUSAHA, NAMA, ALAMAT1 + CHAR(13) + ALAMAT2 + CHAR(13) + 'Telp ' + Telpon + ', ' + 'Fax ' + Fax + CHAR(13)+
       'E-mail : '+Email AS Alamat, ALAMAT1 AlamatReport, LOGO, 
       Direksi, Jabatan, KOTA, email,
       NPWP, NAMAPKP, ALAMATPKP1+CHAR(13)+ALAMATPKP2+CHAR(13)+KOTAPKP AlamatPKP1, TGLPENGUKUHAN,
       NPWP1, NAMAPKP1, ALAMATPKP21+CHAR(13)+ALAMATPKP22+CHAR(13)+KOTAPKP1 AlamatPKP2, TGLPENGUKUHAN1
FROM dbo.DBPERUSAHAAN

GO

-- View: vwPostBiaya
-- Created: 2011-11-23 18:45:57.607 | Modified: 2011-11-23 22:13:33.877
-- =====================================================

CREATE View [dbo].[vwPostBiaya]
as
Select A.KODEBAG, B.NamaBag, A.KodeMesin, C.NamaMesin, A.PERKIRAAN, D.Keterangan NamaPerkiraan,
       B.NamaBag+Case when B.NamaBag is null then '' else ' ('+B.KodeBag+')' end myBagian,
       C.NamaMesin+Case when C.NamaMesin is null then '' else ' ('+C.KodeMesin+')' end myMesin, 
       D.Keterangan+Case when D.Keterangan is null then '' else ' ('+D.Perkiraan+')' end myPerkiraan
from DBPOSTBIAYA A
     left outer join DBBAGIAN B on B.KodeBag=A.KODEBAG
     left outer join DBMESIN C on C.KodeMesin=A.KodeMesin
     left outer join DBPERKIRAAN D on D.Perkiraan=A.PERKIRAAN


GO

-- View: vwPostHutPiut
-- Created: 2013-12-17 12:18:07.163 | Modified: 2023-04-15 19:47:28.040
-- =====================================================








CREATE View [dbo].[vwPostHutPiut]
as
SELECT A.NOBUKTI NoFaktur, '' NoRetur, 'T' TipeTrans, A.KodeSupp KODECUSTSUPP, 
	'' NoBukti, 1 NoMsk, 1 Urut, A.TANGGAL, A.TANGGAL+A.HARI JatuhTempo, 
	0 Debet, sum(B.NNETRp) Kredit, Sum(B.NNETRp) Saldo, 
	A.KodeVls Valas, A.KURS, 
	0 DebetD, case when A.KODEVLS='IDR' then 0 else sum(B.NNet) end KreditD, 
	case when A.KODEVLS='IDR' then 0 else sum(B.NNet) end SaldoD, 
    '' KodeSales, 'HT' Tipe, J.Perkiraan PERKIRAAN, '' Catatan, 
    'PBL' NoInvoice, A.NOBUKTI NoPajak, A.KodeVls KodeVls_, A.Kurs Kurs_,
    A.IsOtorisasi1 IsOtorisasi, A.NoJurnal
FROM   DBBELI A      
LEft Outer join DBBELIDET B on B.NOBUKTI=A.NOBUKTI
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='HT'AND X.Urut=2) J on 1=1
Group by A.NoBukti, A.KodeSupp, A.TANGGAL, A.HARI,
	A.KodeVls, A.Kurs, A.IsOtorisasi1, A.NoJurnal,J.Perkiraan

-- Retur Pembelian
union all
SELECT A.NOBELI NoFaktur, A.NOBUKTI NoRetur, 'T' TipeTrans, A.KodeSupp KODECUSTSUPP, 
	'' NoBukti, 1 NoMsk, 1 Urut, A.TANGGAL, A.TANGGAL JatuhTempo, 
	sum(B.NNETRp) Debet, 0 Kredit, -1*Sum(B.NNETRp) Saldo, 
	A.KodeVls Valas, A.KURS, 
	case when A.KODEVLS='IDR' then 0 else sum(B.NNet) end DebetD, 0 KreditD, 
	-1*case when A.KODEVLS='IDR' then 0 else sum(B.NNet) end SaldoD, 
    '' KodeSales, 'HT' Tipe, J.Perkiraan PERKIRAAN, '' Catatan, 
    'RPB' NoInvoice, A.NOBUKTI NoPajak, ISNULL(Bl.KodeVls,A.KodeVls) KodeVls_, isnull(Bl.Kurs,A.Kurs) Kurs_,
    A.IsOtorisasi1 IsOtorisasi, A.NoJurnal
FROM   DBRBELI A      
LEft Outer join DBRBELIDET B on B.NOBUKTI=A.NOBUKTI
left outer join DBBELI Bl on Bl.NOBUKTI=A.NOBELI
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='HT'AND X.Urut=2) J on 1=1
Group by A.NoBukti, A.NOBELI, A.KodeSupp, A.TANGGAL, A.HARI,
	A.KodeVls, A.Kurs, Bl.KODEVLS, Bl.KURS, A.IsOtorisasi1, A.NoJurnal,J.PERKIRAAN

-- Debet Note
union all
select B.NoInv NoFaktur, A.NOBUKTI NoRetur, 'T' Tipetrans, A.KodeSupp KODECUSTSUPP, 
       '' NoBukti, 1 NoMsk, 1 Urut, A.TANGGAL, A.TANGGAL JatuhTempo, 
       sum(B.NilaiRp) Debet, 0.00 Kredit, -sum(B.NilaiRp) Saldo, 
       B.KodeVls Valas, B.Kurs KURS, 
       case when B.KodeVLS='IDR' then 0 else sum(B.Nilai) end DebetD, 0.00 KreditD, 
       case when B.KodeVLS='IDR' then 0 else -sum(B.Nilai) end SaldoD, 
       '' KodeSales, 'HT' Tipe, 
       J.Perkiraan PERKIRAAN, '' Catatan, 'DN' NoInvoice, A.NOBUKTI NoPajak,
       isnull(Bl.KodeVls,B.KodeVls) KodeVls_, isnull(Bl.Kurs,B.Kurs) Kurs_,
       A.IsOtorisasi1 IsOtorisasi, A.NoJurnal
FROM   DBDebetNote A      
LEft Outer join DBDebetNoteDET B on B.NOBUKTI=A.NOBUKTI
left outer join DBBELI Bl on Bl.NOBUKTI=B.NoInv
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='HT'AND X.Urut=2) J on 1=1
Group by A.NoBukti, A.KodeSupp, A.Tanggal,
	B.KodeVls, B.Kurs, A.NoJurnal, B.NoInv,
	Bl.KODEVLS, Bl.Kurs, A.IsOtorisasi1, A.NoJurnal,J.PERKIRAAN
		
-- Invoice Penjualan

union all
SELECT A.NoBukti NoFaktur, '' NoRetur, 'T' TipeTrans, A.KodeCustSupp KODECUSTSUPP, 
	a.NoJurnal  NoBukti, 1 NoMsk, 1 Urut, A.TANGGAL, A.TANGGAL+D.HARI JatuhTempo, 
	sum(B.NNET) Debet, 0 Kredit, Sum(B.NNETRp) Saldo, 
	A.Valas, A.KURS, 
	case when A.Valas='IDR' then 0 else sum(B.NNet) end DebetD, 0 KreditD, 
	case when A.Valas='IDR' then 0 else sum(B.NNet) end SaldoD, 
    '' KodeSales, 'PT' Tipe, j.PERKIRAAN PERKIRAAN, '' Catatan, 
    'INVC' NoInvoice, A.NoBukti NoPajak, A.Valas KodeVls_, A.Kurs Kurs_,
    A.IsOtorisasi1 IsOtorisasi, A.NoJurnal
FROM   dbInvoicePL A      
LEft Outer join dbInvoicePLDet B on B.NOBUKTI=A.NOBUKTI
left outer join dbSPP C on c.NoBukti=a.NoSPP
left outer join DBSO D on D.NOBUKTI=c.NoSHIP
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='PT'AND X.Urut=2) J on 1=1 
Group by A.NoBukti, A.KodeCustSupp, A.TANGGAL, D.HARI,
	A.Valas, A.Kurs, A.IsOtorisasi1, A.NoJurnal,J.Perkiraan

-- Retur Penjualan
union all
SELECT A.NoInvoice NoFaktur, A.NOBUKTI NoRetur, 'T' TipeTrans, A.KODECUSTSUPP, 
	'' NoBukti, 1 NoMsk, 1 Urut, A.TANGGAL, A.TANGGAL JatuhTempo, 
	0 Debet, sum(B.NNETRp) Kredit, -1*Sum(B.NNETRp) Saldo, 
	A.KodeVls Valas, A.KURS, 
	0 DebetD, case when A.KODEVLS='IDR' then 0 else sum(B.NNet) end KreditD, 
	-1*case when A.KODEVLS='IDR' then 0 else sum(B.NNet) end SaldoD, 
    '' KodeSales, 'PT' Tipe, J.PERKIRAAN PERKIRAAN, '' Catatan, 
    'RPJ' NoInvoice, A.NOBUKTI NoPajak, ISNULL(Bl.Valas,A.KodeVls) KodeVls_, isnull(Bl.Kurs,A.Kurs) Kurs_,
    A.IsOtorisasi1 IsOtorisasi, A.NoJurnal
FROM   DBINVOICERPJ A      
LEft Outer join DBINVOICERPJDet B on B.NOBUKTI=A.NOBUKTI
left outer join dbInvoicePL Bl on Bl.NOBUKTI=A.NoInvoice
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='PT'AND X.Urut=2) J on 1=1
Group by A.NoBukti, A.NoInvoice, A.KODECUSTSUPP, A.TANGGAL, A.HARI,
	A.KodeVls, A.Kurs, Bl.Valas, Bl.KURS, A.IsOtorisasi1, A.NoJurnal,J.PERKIRAAN

-- Kredit Note
union all
select B.NoInv NoFaktur, A.NOBUKTI NoRetur, 'T' Tipetrans, A.KodeSupp KODECUSTSUPP, 
       '' NoBukti, 1 NoMsk, 1 Urut, A.TANGGAL, A.TANGGAL JatuhTempo, 
       0.00 Debet, sum(B.NilaiRp) Kredit, -sum(B.NilaiRp) Saldo, 
       B.KodeVls Valas, B.Kurs KURS, 
       case when B.KodeVLS='IDR' then 0 else sum(B.Nilai) end DebetD, 0.00 KreditD, 
       case when B.KodeVLS='IDR' then 0 else -sum(B.Nilai) end SaldoD, 
       '' KodeSales, 'PT' Tipe, 
       J.Perkiraan PERKIRAAN, '' Catatan, 'KN' NoInvoice, A.NOBUKTI NoPajak,
       isnull(Bl.Valas,B.KodeVls) KodeVls_, isnull(Bl.Kurs,B.Kurs) Kurs_,
       A.IsOtorisasi1 IsOtorisasi, A.NoJurnal
FROM   DBKreditNote A      
LEft Outer join DBKreditNoteDET B on B.NOBUKTI=A.NOBUKTI
left outer join dbInvoicePL Bl on Bl.NOBUKTI=B.NoInv
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='PT'AND X.Urut=2) J on 1=1
Group by A.NoBukti, A.KodeSupp, A.Tanggal,
	B.KodeVls, B.Kurs, A.NoJurnal, B.NoInv,
	Bl.Valas, Bl.Kurs, A.IsOtorisasi1, A.NoJurnal,J.PERKIRAAN




GO

-- View: vwPostJurnalOto
-- Created: 2014-10-01 11:27:01.077 | Modified: 2023-04-15 19:12:30.670
-- =====================================================






CREATE  View [dbo].[vwPostJurnalOto]  
as  
SELECT A.NoJurnal NOBUKTI, A.NOURUT, A.TANGGAL TANGGAL,'01' DEVISI, 
	'Pembelian '+isnull(Cs.NamaCustSupp,'')  NOTE,0 LAMPIRAN, 
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
	min(B.Urut) URUT, 
	isnull(F.PerkPers,'') PERKIRAAN, J.Perkiraan LAWAN,
	A.NOBUKTI+' '+isnull(Cs.NamaCustSupp,'') KETERANGAN, 
	'' KETERANGAN2, 
	SUM(B.NDPP) DEBET, 0 KREDIT, A.KODEVLS Valas, A.KURS, 
	SUM(B.NDPPRP) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, 
	'' CUSTSUPPP,'' CUSTSUPPL, '' KODEP, 
	'' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '' KODEBAG, '' STATUSGIRO, 
	'BPL' JENIS, A.NOBUKTI NOBUKTITRANS
FROM DBO.DBBELI A 
LEFT OUTER JOIN DBO.DBbeliDET B ON B.NOBUKTI=A.NOBUKTI 
LEFT OUTER JOIN DBO.DBCUSTSUPP Cs ON Cs .KODECUSTSUPP=A.KODESUPP
Left Outer Join dbo.DBBARANG Br on Br.KODEBRG=B.KODEBRG
Left Outer join dbo.dbSubGroup F on f.KodeGrp=Br.KODEGRP and F.KodeSubGrp=Br.KODESUBGRP
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='HT'AND X.Urut=2) J on 1=1
--where A.NoJurnal<>''
GROUP BY A.NOBUKTI, A.NOURUT, A.TANGGAL, Cs.NAMACUSTSUPP, A.KODESUPP,J.Perkiraan,
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL,
	F.PerkPers, A.KODEVLS, A.KURS, A.NOURUT,
	A.NoJurnal, F.PerkH

Union ALL
SELECT A.NoJurnal NOBUKTI, A.NOURUT, A.TANGGAL TANGGAL,'01' DEVISI, 
	'PPN Masukan '+isnull(Cs.NAMACUSTSUPP,'') NOTE,0 LAMPIRAN, 
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
	min(B.Urut)+100 URUT, 
	isnull(J.Perkiraan,'') PERKIRAAN, K.Perkiraan LAWAN,
	'PPN '+isnull(A.NOBUKTI,'')+' '+isnull(Cs.NAMACUSTSUPP,'') KETERANGAN, 
	'' KETERANGAN2, 
	SUM(B.NPPN) DEBET, 0 KREDIT, A.KODEVLS Valas, A.KURS, 
	SUM(B.NPPNRp) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, 
	'' CUSTSUPPP,'' CUSTSUPPL, '' KODEP, 
	'' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '' KODEBAG, '' STATUSGIRO,
	'BPL' JENIS, A.NOBUKTI NOBUKTITRANS
FROM DBO.DBbeli A 
LEFT OUTER JOIN DBO.DBBELIDET B ON B.NOBUKTI=A.NOBUKTI 
LEFT OUTER JOIN DBO.DBCUSTSUPP Cs ON Cs.KODECUSTSUPP=A.KODESUPP
Left Outer join dbo.DBPOSTHUTPIUT J on J.Kode='PPM'
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='HT'AND X.Urut=2) K on 1=1
--where A.NoJurnal<>''
GROUP BY A.NOBUKTI, A.NOURUT, A.TANGGAL, Cs.NAMACUSTSUPP, A.KODESUPP,K.Perkiraan,
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL,
	A.KODEVLS, A.KURS, A.NOURUT,
	A.NoJurnal, J.Perkiraan
having SUM(B.NPPNRp)<>0
union all
--Rbeli
SELECT A.NoJurnal NOBUKTI, A.NOURUT, A.TANGGAL TANGGAL,'01' DEVISI, 
	'Retur Beli '+isnull(Cs.NamaCustSupp,'') NOTE,0 LAMPIRAN, 
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
	MIN(B.URUT) URUT, 
	K.PERKIRAAN PERKIRAAN, isnull(F.PerkPers,'') LAWAN,
	'RB '+A.NOBUKTI+' '+isnull(Cs.NamaCustSupp,'') KETERANGAN, 
	'' KETERANGAN2, 
	SUM(B.NDPP) DEBET, 0 KREDIT, A.KODEVLS Valas, A.KURS, 
	SUM(B.NDPPRP) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, 
	'' CUSTSUPPP,'' CUSTSUPPL, '' KODEP, 
	'' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '' KODEBAG, '' STATUSGIRO, 
	'RPB' JENIS, A.NOBUKTI NOBUKTITRANS
FROM DBO.DBRBELI A 
LEFT OUTER JOIN DBO.DBRBELIDET B ON B.NOBUKTI=A.NOBUKTI 
LEFT OUTER JOIN DBO.DBCUSTSUPP Cs ON Cs.KODECUSTSUPP=A.KODESUPP
Left Outer Join dbo.DBBARANG Br on Br.KODEBRG=B.KODEBRG
Left Outer join dbo.dbSubGroup F on F.KodeGrp=Br.KODEGRP and F.KodeSubGrp=Br.KODESUBGRP
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='HT'AND X.Urut=2) K on 1=1
--where A.NoJurnal<>''
GROUP BY A.NOBUKTI, A.NOURUT, A.TANGGAL, Cs.NAMACUSTSUPP, A.KODESUPP,K.Perkiraan,
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL,
	F.PerkPers, A.KODEVLS, A.KURS, A.NOURUT,
	A.NoJurnal, F.PerkH

union All
SELECT A.NoJurnal NOBUKTI, A.NOURUT, A.TANGGAL TANGGAL,'01' DEVISI, 
	'PPN '+A.NOBUKTI+' '+isnull(Cs.NAMACUSTSUPP,'') NOTE,0 LAMPIRAN, 
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
	MIN(B.URUT)+100 URUT, 
	K.PERKIRAAN PERKIRAAN, isnull(J.Perkiraan,'') LAWAN,
	'PPN '+A.NOBUKTI+' '+isnull(Cs.NAMACUSTSUPP,'') KETERANGAN, 
	'' KETERANGAN2, 
	SUM(B.NPPN) DEBET, 0 KREDIT, A.KODEVLS Valas, A.KURS, 
	SUM(B.NPPNRP) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, 
	'' CUSTSUPPP,'' CUSTSUPPL, '' KODEP, 
	'' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '' KODEBAG, '' STATUSGIRO, 
	'RPB' JENIS, A.NOBUKTI NOBUKTITRANS
FROM DBO.DBRBELI A 
LEFT OUTER JOIN DBO.DBRBELIDET B ON B.NOBUKTI = A.NOBUKTI 
LEFT OUTER JOIN DBO.DBCUSTSUPP Cs ON Cs.KODECUSTSUPP = A.KODESUPP
Left Outer join dbo.DBPOSTHUTPIUT J on J.Kode='PPM'
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='HT'AND X.Urut=2) K on 1=1
--where A.NoJurnal<>''
GROUP BY A.NOBUKTI, A.NOURUT, A.TANGGAL, Cs.NAMACUSTSUPP, A.KODESUPP,K.Perkiraan,
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL,
	A.KODEVLS, A.KURS, A.NOURUT,
	A.NoJurnal, J.Perkiraan
having SUM(B.NPPNRp)<>0


-- Debet Note
union all
SELECT A.NoJurnal NOBUKTI, A.NoUrut, A.TANGGAL,'01' DEVISI, 
      'Debet Note : ' + A.NOBUKTI +' TANGGAL : '+ Convert(Varchar(15),A.Tanggal, 105) NOTE,0 LAMPIRAN, 
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
       CAST(ROW_NUMBER() Over(PARTITION BY A.NoJurnal Order by A.Nojurnal) As int) URUT,  
       K.Perkiraan PERKIRAAN, 
       J.PERKIRAAN  LAWAN, 
       'Debet Note : ' + isnull(I.NAMACUSTSUPP,'') + ' (' + Isnull(I.KODECUSTSUPP,'') + ')'+CHAR(13)+ 
       'No. Invoice : '+B.NoInv KETERANGAN, '' KETERANGAN2, 
       Sum(B.Nilai) DEBET, 0 KREDIT, B.KodeVLS VALAS, B.Kurs, 
       Sum(B.NilaiRp) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, '' CUSTSUPPP, '' CUSTSUPPL, '' KODEP, 
       '' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '01' KODEBAG, '' STATUSGIRO, 
       'DN' JENIS, A.NOBUKTI NOBUKTITRANS
FROM  DBO.DBDebetNote A 
LEFT OUTER JOIN DBO.DBDebetNoteDET B ON B.NOBUKTI = A.NOBUKTI 
Left Outer join (Select x.NoFaktur, Min(x.Tanggal) Tanggal
                 From dbo.vwHutPiut x
                 where TipeTrans='T'
                 Group by x.NoFaktur) C on C.NoFaktur=B.NoInv
Left outer join dbo.vwCUSTSUPP I on I.KODECUSTSUPP=A.KodeSupp 
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='BD') J on 1=1
 Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='HT'AND X.Urut=2) K on 1=1               
--Where A.NoJurnal<>''
Group by A.NoJurnal, A.TglJurnal, A.TANGGAL, B.kodevls, B.Kurs,B.NoInv, C.Tanggal, 
      A.NOBUKTI, A.NoUrut, i.NAMACUSTSUPP, I.KODECUSTSUPP,A.TANGGAL,A.KodeSupp,K.Perkiraan,
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
       J.Perkiraan,A.NoUrutJurnal
       
       
-- Surat Jalan
UNION ALL
SELECT A.NoJurnal NOBUKTI, A.NoUrut, A.Tanggal,'01' DEVISI, 
	'Surat Jalan '+A.NoBukti+' '+isnull(Cs.NAMACUSTSUPP,'') NOTE, 0 LAMPIRAN, 
	A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
	CAST(ROW_NUMBER() Over(PARTITION BY A.NoJurnal Order by A.Nojurnal) As int) URUT,  
	isnull(J.Perkiraan,'') PERKIRAAN, 
	isnull(Sg.PerkPers,'') LAWAN, 
	'Surat Jalan '+A.NoBukti+' '+isnull(Cs.NAMACUSTSUPP,'') KETERANGAN, '' KETERANGAN2, 
	Sum(B.Qnt * B.HPP) DEBET, 0 KREDIT, 'IDR' VALAS, 1 KURS, 
	Sum(B.Qnt * B.HPP) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, '' CUSTCUPPP, '' CUSTSUPPL, '' KODEP, 
	'' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '01' KODEBAG, '' STATUSGIRO, 
	'SPB' JENIS, A.NoBukti NOBUKTITRANS
FROM  DBO.DBSPB A 
LEFT OUTER JOIN DBO.dbSPBDet B ON B.NOBUKTI=A.NOBUKTI
LEFT OUTER JOIN DBO.DBCUSTSUPP Cs ON Cs.KODECUSTSUPP=A.KodeCustSupp
Left Outer Join dbo.DBBARANG Br on Br.KODEBRG=B.KODEBRG
Left Outer join dbo.dbSubGroup Sg on Sg.KodeGrp=Br.KODEGRP and Sg.KodeSubGrp=Br.KODESUBGRP 
Left Outer Join dbo.DBPOSTHUTPIUT J on J.Kode='HPP'
--Where A.NoJurnal<>''
Group by A.NoJurnal, A.TglJurnal,A.KodeCustSupp, Cs.NAMACUSTSUPP, 
      A.NOBUKTI, A.NoUrut, A.TANGGAL,
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
       Sg.PerkPers, J.Perkiraan, A.NoUrutJurnal


-- Retur Surat Jalan
UNION ALL
SELECT A.NoJurnal NOBUKTI, A.NoUrut, A.Tanggal,'01' DEVISI, 
	'Retur Surat Jalan : ' + A.NOBUKTI +' TANGGAL : '+ Convert(Varchar(15),A.Tanggal, 105) NOTE,0 LAMPIRAN, 
	A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
	CAST(ROW_NUMBER() Over(PARTITION BY A.NoJurnal Order by A.Nojurnal) As int) URUT,  
	isnull(Sg.PerkPers,'') PERKIRAAN, 
	isnull(J.Perkiraan,'') LAWAN, 
	'Retur Surat Jalan : ' + isnull(Cs.NAMACUSTSUPP,'') + ' (' + Isnull(A.KodeCustSupp,'') + ')'+CHAR(13)+ 
	'No. Retur Surat Jalan : '+A.Nobukti+' TANGGAL : '+ Convert(Varchar(15),A.Tanggal, 105) KETERANGAN, '' KETERANGAN2, 
	Sum(B.Qnt * B.HPP) DEBET, 0 KREDIT, 'IDR' VALAS, 1 KURS, 
	Sum(B.Qnt * B.HPP) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, '' CUSTCUPPP, '' CUSTSUPPL, '' KODEP, 
	'' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '01' KODEBAG, '' STATUSGIRO,
	'RSPB' JENIS, A.NoBukti NOBUKTITRANS
FROM  DBO.DBRSPB A 
LEFT OUTER JOIN DBO.DBRSPBDet B ON B.NOBUKTI = A.NOBUKTI 
LEFT OUTER JOIN DBO.DBCUSTSUPP Cs ON Cs.KODECUSTSUPP=A.KodeCustSupp
Left Outer Join dbo.DBBARANG Br on Br.KODEBRG=B.KODEBRG
Left Outer join dbo.dbSubGroup Sg on Sg.KodeGrp=Br.KODEGRP and Sg.KodeSubGrp=Br.KODESUBGRP 
Left Outer Join dbo.DBPOSTHUTPIUT J on J.Kode='HPP'
--Where A.NoJurnal<>''
Group by A.NoJurnal, A.TglJurnal,A.KodeCustSupp, Cs.NAMACUSTSUPP, 
	A.NOBUKTI, A.NoUrut, A.TANGGAL,
	A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
	Sg.PerkPers, J.Perkiraan, A.NoUrutJurnal


-- Invoice Penjualan      
Union ALL
SELECT A.NoJurnal NOBUKTI, A.NOURUT, A.Tanggal TANGGAL,'01' DEVISI, 
	'Penjualan '+isnull(Cs.NAMACUSTSUPP,'') NOTE, 0 LAMPIRAN, 
	A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
	MIN(B.Urut) URUT,  
	j.Perkiraan PERKIRAAN, BS.PerkPers 
	LAWAN, 
	A.NoBukti+' '+isnull(Cs.NAMACUSTSUPP,'') KETERANGAN,'' KETERANGAN2, 
	Sum(B.NDPP) DEBET, 0 KREDIT, A.VALAS, A.Kurs, 
	Sum(B.NDPPRp) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, 
	A.KodeCustSupp CUSTSUPPP, '' CUSTSUPPL, '' KODEP, 
	'' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '01' KODEBAG, '' STATUSGIRO, 
	'INVC' JENIS, A.NoBukti NOBUKTITRANS
FROM  DBO.DBInvoicePL A 
LEFT OUTER JOIN DBO.dbInvoicePLDet B ON B.NOBUKTI=A.NOBUKTI 
LEFT OUTER JOIN DBO.DBBARANG Br ON Br.KODEBRG=B.KODEBRG 
LEFT OUTER JOIN dbo.DBSUBGROUP bS on Bs.KodeSubGrp=BR.KODESUBGRP
Left outer join dbo.DBCUSTSUPP Cs on Cs.KODECUSTSUPP=A.KodeCustSupp
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='PT'AND X.Urut=2) J on 1=1 
--Where A.noJurnal<>''
Group by A.NoJurnal, A.NOURUT, A.Valas, A.Kurs, 
	A.NOBUKTI, Cs.NAMACUSTSUPP, A.KODECUSTSUPP, A.TANGGAL,A.KodeCustSupp,J.Perkiraan,BS.PerkPers ,
	A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL 

Union All
SELECT A.NoJurnal NOBUKTI, A.NOURUT, A.Tanggal TANGGAL,'01' DEVISI, 
	'Faktur Pajak '+' '+isnull(Cs.NAMACUSTSUPP,'') NOTE,0 LAMPIRAN, 
	A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
	MIN(B.Urut)+1000 URUT,  
	K.Perkiraan PERKIRAAN, J.Perkiraan  LAWAN, 
	A.NoBukti+' '+isnull(Cs.NAMACUSTSUPP,'') KETERANGAN,'' KETERANGAN2, 
	Sum(B.NPPN) DEBET, 0 KREDIT, A.VALAS, A.Kurs, 
	Sum(B.NPPNRp) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, 
	A.KodeCustSupp CUSTSUPPP, '' CUSTSUPPL, '' KODEP, 
	'' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '01' KODEBAG, '' STATUSGIRO, 
	'INVC' JENIS, A.NoBukti NOBUKTITRANS
FROM  DBO.DBInvoicePL A 
LEFT OUTER JOIN DBO.dbInvoicePLDet B ON B.NOBUKTI = A.NOBUKTI
Left outer join dbo.DBCUSTSUPP Cs on Cs.KODECUSTSUPP=A.KodeCustSupp
Left Outer join dbo.DBPOSTHUTPIUT J on J.Kode='PPM'
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='PT' AND X.Urut=2) K on 1=1 
--Where A.noJurnal<>''
Group by A.NoJurnal, A.NOURUT, A.Valas, A.Kurs,
	A.NOBUKTI, Cs.NAMACUSTSUPP, A.KODECUSTSUPP, A.TANGGAL,K.Perkiraan,
	A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
	J.Perkiraan
Having SUM(B.NPPNRp)<>0


-- Penerimaan Retur Jual
Union All
SELECT A.NoJurnal NOBUKTI, A.NoUrut, A.Tanggal,'01' DEVISI, 
      'Penerimaan Retur Penjualan : ' + A.NOBUKTI +' TANGGAL : '+ Convert(Varchar(15),A.Tanggal, 105) NOTE,0 LAMPIRAN, 
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
       CAST(ROW_NUMBER() Over(PARTITION BY A.NoJurnal Order by A.Nojurnal) As int) URUT,  
       isnull(Sg.PerkPers,'') PERKIRAAN, 
       isnull(J.Perkiraan,'') LAWAN, 
       isnull(Cs.NAMACUSTSUPP,'') + ' (' + Isnull(A.KodeCustSupp,'') + ')' KETERANGAN, '' KETERANGAN2, 
       Sum(B.Qnt * B.HPP) DEBET, 0 KREDIT, 'IDR' VALAS, 1 KURS, 
       Sum(B.Qnt * B.HPP) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, '' CUSTCUPPP, '' CUSTSUPPL, '' KODEP, 
       '' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '01' KODEBAG, '' STATUSGIRO, 
       'SPR' JENIS, A.NoBukti NOBUKTITRANS
FROM  DBO.dbSPBRJual A 
LEFT OUTER JOIN DBO.dbSPBRJualDet B ON B.NOBUKTI = A.NOBUKTI 
LEFT OUTER JOIN DBO.DBCUSTSUPP Cs ON Cs.KODECUSTSUPP=A.KodeCustSupp
Left Outer Join dbo.DBBARANG Br on Br.KODEBRG=B.KODEBRG
Left Outer join dbo.dbSubGroup Sg on Sg.KodeGrp=Br.KODEGRP and Sg.KodeSubGrp=Br.KODESUBGRP 
Left Outer Join dbo.DBPOSTHUTPIUT J on J.Kode='HPP'
--Where A.noJurnal<>''
Group by A.NoJurnal, A.TglJurnal,A.KodeCustSupp, Cs.NAMACUSTSUPP, 
      A.NOBUKTI, A.NoUrut, A.TANGGAL,
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
       Sg.PerkPers, J.Perkiraan, A.NoUrutJurnal


-- Invoice Retur Jual
union all
SELECT A.NoJurnal NOBUKTI, A.NoUrut, A.TANGGAL,'01' DEVISI, 
      'Retur Invoice Penjualan : ' + isnull(I.NAMACUSTSUPP,'') + ' (' + Isnull(I.KODECUSTSUPP,'') + ')' NOTE,0 LAMPIRAN, 
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL,
       min(B.Urut) URUT,  
       BS.PerkH PERKIRAAN, 
       j.PERKIRAAN  LAWAN, 
       A.NoBukti+' '+isnull(I.NAMACUSTSUPP,'') KETERANGAN,'' KETERANGAN2,
       Sum(B.NDPP) DEBET, 0 KREDIT, A.Kodevls VALAS, A.Kurs, 
       Sum(B.NDPPRp) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, '' CUSTSUPPP, A.KODECUSTSUPP CUSTSUPPL, '' KODEP, 
       '' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '01' KODEBAG, '' STATUSGIRO, 
       'RPJ' JENIS, A.NoBukti NOBUKTITRANS
FROM  DBO.DBINVOICERPJ A 
LEFT OUTER JOIN DBO.DBINVOICERPJDet B ON B.NOBUKTI = A.NOBUKTI 
LEFT OUTER JOIN DBO.DBBARANG F ON F.KODEBRG = B.KODEBRG 
Left outer join dbo.vwCUSTSUPP I on I.KODECUSTSUPP=A.KodeCustSupp
LEFT OUTER JOIN dbo.DBSUBGROUP bS on Bs.KodeSubGrp=f.KODESUBGRP AND BS.KodeGrp=F.KODEGRP
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='PT'AND X.Urut=2) J on 1=1 
--Where A.NoJurnal<>''
Group by A.NoJurnal, A.TglJurnal, A.Tanggal, A.KODEVLS, A.Kurs, 
      A.NOBUKTI, A.NoUrut, i.NAMACUSTSUPP, I.KODECUSTSUPP,A.TANGGAL,A.KODECUSTSUPP,BS.PerkH,
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1,    
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL,
       J.Perkiraan,A.NoUrutJurnal
Union All
SELECT A.NoJurnal NOBUKTI, A.NoUrut, A.TANGGAL,'01' DEVISI, 
      'Retur Invoice Penjualan : ' + isnull(I.NAMACUSTSUPP,'') + ' (' + Isnull(I.KODECUSTSUPP,'') + ')' NOTE,0 LAMPIRAN, 
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL,
       min(B.Urut)+1000 URUT,  
       K.Perkiraan PERKIRAAN, 
       j.PERKIRAAN  LAWAN, 
       A.NoBukti+' '+isnull(I.NAMACUSTSUPP,'') KETERANGAN,'' KETERANGAN2,
       Sum(B.nPPN) DEBET, 0 KREDIT, A.Kodevls VALAS, A.Kurs, 
       Sum(B.NPPNRp) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, '' CUSTSUPPP, A.KODECUSTSUPP CUSTSUPPL, '' KODEP, 
       '' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '01' KODEBAG, '' STATUSGIRO, 
       'RPJ' JENIS, A.NoBukti NOBUKTITRANS
FROM  DBO.DBINVOICERPJ A 
LEFT OUTER JOIN DBO.DBINVOICERPJDet B ON B.NOBUKTI = A.NOBUKTI 
LEFT OUTER JOIN DBO.DBBARANG F ON F.KODEBRG = B.KODEBRG 
Left outer join dbo.vwCUSTSUPP I on I.KODECUSTSUPP=A.KodeCustSupp
Left Outer join dbo.DBPOSTHUTPIUT K on k.Kode='PPM'
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='PT'AND X.Urut=2) J on 1=1 
--Where A.NoJurnal<>''
Group by A.NoJurnal, A.TglJurnal, A.Tanggal, A.KODEVLS, A.Kurs, 
      A.NOBUKTI, A.NoUrut, i.NAMACUSTSUPP, I.KODECUSTSUPP,A.TANGGAL,A.KODECUSTSUPP,K.Perkiraan,
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1,    
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL,
       J.Perkiraan,A.NoUrutJurnal


-- Kredit Note       
union all
SELECT A.NoJurnal NOBUKTI, A.NoUrut, A.TANGGAL,'01' DEVISI, 
      'Kredit Note : ' + A.NOBUKTI +' TANGGAL : '+ Convert(Varchar(15),A.Tanggal, 105) NOTE,0 LAMPIRAN, 
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
       CAST(ROW_NUMBER() Over(PARTITION BY A.NoJurnal Order by A.Nojurnal) As int) URUT,  
       J.Perkiraan PERKIRAAN, 
       isnull(B.PerkHP,'')  LAWAN, 
       'Kredit Note : ' + isnull(I.NAMACUSTSUPP,'') + ' (' + Isnull(I.KODECUSTSUPP,'') + ')'+CHAR(13)+ 
       'No. Invoice : '+B.NoInv KETERANGAN, '' KETERANGAN2, 
       Sum(B.Nilai) DEBET, 0 KREDIT, B.KodeVLS VALAS, B.Kurs, 
       Sum(B.NilaiRp) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, '' CUSTSUPPP, '' CUSTSUPPL, '' KODEP, 
       '' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '01' KODEBAG, '' STATUSGIRO, 
       'KN' JENIS, A.NOBUKTI NOBUKTITRANS
FROM  DBO.DBKreditNote A 
LEFT OUTER JOIN DBO.DBKreditNoteDET B ON B.NOBUKTI = A.NOBUKTI 
Left outer join dbo.vwCUSTSUPP I on I.KODECUSTSUPP=A.KodeSupp
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='BK') J on 1=1
--Where A.noJurnal<>''
Group by A.NoJurnal, A.TglJurnal, A.TANGGAL, B.kodevls, B.Kurs, B.NoInv, B.PerkHP, 
      A.NOBUKTI, A.NoUrut, i.NAMACUSTSUPP, I.KODECUSTSUPP, A.TANGGAL,
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
       J.Perkiraan,A.NoUrutJurnal

-- Penyerahan Bahan       
union All
SELECT A.NoJurnal NOBUKTI, A.NoUrut, A.Tanggal,'01' DEVISI, 
      'Penyerahan Bahan : ' + A.NOBUKTI + ' Untuk SPK : ' + A.NoBPPB NOTE,0 LAMPIRAN, 
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
       CAST(ROW_NUMBER() Over(PARTITION BY A.NoJurnal Order by A.Nojurnal) As int) URUT,  
       ISNULL(J.Perkiraan,'') PERKIRAAN, 
        H.PerkPers Lawan, 
       'Penyerahan Bahan : ' + + H.NamaSubGrp + ' (' + H.KodeSubGrp + ')'+CHAR(13)+ 
       'No. Penyerahan Bahan : '+A.Nobukti+' TANGGAL : '+ Convert(Varchar(15),A.Tanggal, 105)KETERANGAN, '' KETERANGAN2, 
       Sum(B.QNT*B.HPP) DEBET, 0 KREDIT, 'IDR' VALAS, 1 KURS, 
       Sum(B.QNT*B.HPP) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, '' CUSTCUPPP, '' CUSTSUPPL, '' KODEP, 
       '' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '01' KODEBAG, '' STATUSGIRO, 
      'BP' JENIS, A.Nobukti NOBUKTITRANS
FROM  DBO.DBPenyerahanBhn A 
LEFT OUTER JOIN DBO.DBPenyerahanBhnDET B ON B.NOBUKTI = A.NOBUKTI 
LEFT OUTER JOIN DBO.DBBARANG F ON F.KODEBRG = B.KODEBRG LEFT OUTER JOIN DBO.DBGROUP G ON G.KODEGRP = F.KODEGRP
LEFT OUTER JOIN DBO.dbSubGroup H ON H.KodeGrp = F.KODEGRP and H.KodeSubGrp=F.KODESUBGRP
Left Outer Join (Select Perkiraan 
                 from dbo.DBPOSTHUTPIUT 
                 where Kode='WIP') J on 1=1
--Where A.noJurnal<>''
Group by A.NoJurnal, A.TglJurnal, H.KodeSubGrp,A.NoBPPB,
      A.NOBUKTI, A.Nourut, H.NamaSubGrp, H.KodeSubGrp,A.TANGGAL,
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
       A.NoUrutJurnal,H.PerkPers, J.Perkiraan

-- Retur Penyerahan Bahan
union All
SELECT A.NoJurnal NOBUKTI, A.Nourut, A.Tanggal,'01' DEVISI, 
      'Retur Penyerahan Bahan : ' + A.NOBUKTI + ' untuk Penyerahan : ' + A.NoPenyerahanBhn NOTE,0 LAMPIRAN, 
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL,
       CAST(ROW_NUMBER() Over(PARTITION BY A.NoJurnal Order by A.Nojurnal) As int) URUT,  
       H.PerkPers PERKIRAAN, 
       ISNULL(J.Perkiraan,'') Lawan, 
       'Retur Penyerahan Bahan : ' + + H.NamaSubGrp + ' (' + H.KodeSubGrp + ')'+CHAR(13)+ 
       'No. Penyerahan Bahan : '+A.Nobukti+' TANGGAL : '+ Convert(Varchar(15),A.Tanggal, 105)KETERANGAN, '' KETERANGAN2, 
       Sum(B.QNT*B.HPP) DEBET, 0 KREDIT, 'IDR' VALAS, 1 KURS, 
       Sum(B.QNT*B.HPP) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, '' CUSTCUPPP, '' CUSTSUPPL, '' KODEP, 
       '' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '01' KODEBAG, '' STATUSGIRO, 
      'RBP' JENIS, A.Nobukti NOBUKTITRANS
FROM  DBO.DBRPenyerahanBhn A 
LEFT OUTER JOIN DBO.DBRPenyerahanBhnDET B ON B.NOBUKTI = A.NOBUKTI 
LEFT OUTER JOIN DBO.DBBARANG F ON F.KODEBRG = B.KODEBRG LEFT OUTER JOIN DBO.DBGROUP G ON G.KODEGRP = F.KODEGRP
LEFT OUTER JOIN DBO.dbSubGroup H ON H.KodeGrp = F.KODEGRP and H.KodeSubGrp=F.KODESUBGRP
Left Outer Join (Select Perkiraan 
                 from dbo.DBPOSTHUTPIUT 
                 where Kode='WIP') J on 1=1
--Where A.noJurnal<>''
Group by A.NoJurnal, A.TglJurnal, H.KodeSubGrp,A.NoPenyerahanBhn,
      A.NOBUKTI, A.Nourut, H.NamaSubGrp, H.KodeSubGrp,A.TANGGAL,
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
       A.NoUrutJurnal,H.PerkPers, J.Perkiraan


-- Ubah Kemasan
Union ALL
SELECT A.NoJurnal NOBUKTI, A.NOURUT, A.Tanggal,'01' DEVISI, 
      'Ubah Kemasan : ' + A.NOBUKTI + ' ' + H.NamaSubGrp + ' (' + H.KodeSubGrp + ')' NOTE,0 LAMPIRAN, 
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
       CAST(ROW_NUMBER() Over(PARTITION BY A.NoJurnal Order by A.Nojurnal) As int) URUT,  
       --Case when Sum(B.QNTDB)<>0 then J.Perkiraan
       --     when Sum(B.QNTCR)<>0 then H.PerkPers
       --     else ''
       --end  PERKIRAAN, 
       '' PERKIRAAN,
       Case when Sum(B.QNTDB)<>0 then H.PerkPers
            when Sum(B.QNTCR)<>0 then J.Perkiraan
            else ''
       end LAWAN, 
       'Ubah Kemasan : ' + + H.NamaSubGrp + ' (' + H.KodeSubGrp + ')'+CHAR(13)+ 
       'No. Ubah Kemasan : '+A.Nobukti+' TANGGAL : '+ Convert(Varchar(15),A.Tanggal, 105)KETERANGAN, '' KETERANGAN2, 
       Sum(Case when B.QNTDB<>0 then B.QNTDB 
                when B.QNTCR<>0 then B.QNTCR
                else 0
           end * B.HPP) DEBET, 0 KREDIT, 'IDR' VALAS, 1 KURS, 
       Sum(Case when B.QNTDB<>0 then B.QNTDB 
                when B.QNTCR<>0 then B.QNTCR
                else 0
           end * B.HPP) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, '' CUSTCUPPP, '' CUSTSUPPL, '' KODEP, 
       '' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '01' KODEBAG, '' STATUSGIRO, 
      'KMS' JENIS, A.NOBUKTI NOBUKTITRANS
FROM  DBO.DBUBAHKEMASAN A 
LEFT OUTER JOIN DBO.DBUBAHKEMASANDET B ON B.NOBUKTI = A.NOBUKTI 
LEFT OUTER JOIN DBO.DBBARANG F ON F.KODEBRG = B.KODEBRG LEFT OUTER JOIN DBO.DBGROUP G ON G.KODEGRP = F.KODEGRP
LEFT OUTER JOIN DBO.dbSubGroup H ON H.KodeGrp = F.KODEGRP and H.KodeSubGrp=F.KODESUBGRP
Left Outer Join (Select Perkiraan 
                 from dbo.DBPOSTHUTPIUT 
                 where Kode='BYO') J on 1=1
--Where A.noJurnal<>''
Group by A.NoJurnal, A.TglJurnal, H.KodeSubGrp,
      A.NOBUKTI, A.NOURUT, H.NamaSubGrp, H.KodeSubGrp,A.TANGGAL,
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
       A.NoUrutJurnal,H.PerkPers, J.Perkiraan

--- Hasil Produksi
union all
SELECT A.NoJurnal NOBUKTI, A.NOURUT, A.TANGGAL TANGGAL,'01' DEVISI, 
	'Hasil Produksi SPK : '+A.NoSPK  NOTE,0 LAMPIRAN, 
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
	min(B.Urut) URUT, 
	'' PERKIRAAN, '' LAWAN,
	A.NOBUKTI KETERANGAN, 
	'' KETERANGAN2, 
	0 DEBET, 0 KREDIT, '' Valas, 1 KURS, 
	0 DEBETRP, 0 KREDITRP, '' TIPETRANS, 'C' TPHC, 
	'' CUSTSUPPP,'' CUSTSUPPL, '' KODEP, 
	'' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '' KODEBAG, '' STATUSGIRO, 
	'PRD' JENIS, A.NOBUKTI NOBUKTITRANS
FROM DBO.DBHASILPRD A 
LEFT OUTER JOIN DBO.DBhasilprdDET B ON B.NOBUKTI=A.NOBUKTI 
--LEFT OUTER JOIN DBO.DBCUSTSUPP Cs ON Cs .KODECUSTSUPP=A.KODESUPP
--Left Outer Join dbo.DBBARANG Br on Br.KODEBRG=B.KODEBRG
--Left Outer join dbo.dbSubGroup F on f.KodeGrp=Br.KODEGRP and F.KodeSubGrp=Br.KODESUBGRP
--Left Outer join (Select x.Perkiraan
--                 from dbo.DBPOSTHUTPIUT x
--                 where x.Kode='HT'AND X.Urut=2) J on 1=1
--where A.NoJurnal<>''
GROUP BY A.NOBUKTI, A.NOURUT, A.TANGGAL, ---J.Perkiraan,
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL,
	A.NOURUT, A.NoJurnal, A.NoSPK

--- Transfer Gudang
union all
SELECT A.NoJurnal NOBUKTI, A.NOURUT, A.TANGGAL TANGGAL,'01' DEVISI, 
	'Transfer Gudang '  NOTE,0 LAMPIRAN, 
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
	min(B.Urut) URUT, 
	'' PERKIRAAN, '' LAWAN,
	A.NOBUKTI KETERANGAN, 
	'' KETERANGAN2, 
	0 DEBET, 0 KREDIT, '' Valas, 1 KURS, 
	0 DEBETRP, 0 KREDITRP, '' TIPETRANS, 'C' TPHC, 
	'' CUSTSUPPP,'' CUSTSUPPL, '' KODEP, 
	'' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '' KODEBAG, '' STATUSGIRO, 
	'TRF' JENIS, A.NOBUKTI NOBUKTITRANS
FROM DBO.DBTRANSFER A 
LEFT OUTER JOIN DBO.DBTRANSFERDET B ON B.NOBUKTI=A.NOBUKTI 
--LEFT OUTER JOIN DBO.DBCUSTSUPP Cs ON Cs .KODECUSTSUPP=A.KODESUPP
--Left Outer Join dbo.DBBARANG Br on Br.KODEBRG=B.KODEBRG
--Left Outer join dbo.dbSubGroup F on f.KodeGrp=Br.KODEGRP and F.KodeSubGrp=Br.KODESUBGRP
--Left Outer join (Select x.Perkiraan
--                 from dbo.DBPOSTHUTPIUT x
--                 where x.Kode='HT'AND X.Urut=2) J on 1=1
--where A.NoJurnal<>''
GROUP BY A.NOBUKTI, A.NOURUT, A.TANGGAL, ---J.Perkiraan,
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL,
	A.NOURUT, A.NoJurnal


--- Opname
union all
SELECT A.NoJurnal NOBUKTI, A.NOURUT, A.TANGGAL TANGGAL,'01' DEVISI, 
	'Opname Bahan '  NOTE,0 LAMPIRAN, 
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
	min(B.Urut) URUT, 
	'' PERKIRAAN, '' LAWAN,
	A.NOBUKTI KETERANGAN, 
	'' KETERANGAN2, 
	0 DEBET, 0 KREDIT, '' Valas, 1 KURS, 
	0 DEBETRP, 0 KREDITRP, '' TIPETRANS, 'C' TPHC, 
	'' CUSTSUPPP,'' CUSTSUPPL, '' KODEP, 
	'' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '' KODEBAG, '' STATUSGIRO, 
	'OPNBHN' JENIS, A.NOBUKTI NOBUKTITRANS
FROM DBO.DBKOREKSI A 
LEFT OUTER JOIN DBO.DBKOREKSIDET B ON B.NOBUKTI=A.NOBUKTI 
--LEFT OUTER JOIN DBO.DBCUSTSUPP Cs ON Cs .KODECUSTSUPP=A.KODESUPP
--Left Outer Join dbo.DBBARANG Br on Br.KODEBRG=B.KODEBRG
--Left Outer join dbo.dbSubGroup F on f.KodeGrp=Br.KODEGRP and F.KodeSubGrp=Br.KODESUBGRP
--Left Outer join (Select x.Perkiraan
--                 from dbo.DBPOSTHUTPIUT x
--                 where x.Kode='HT'AND X.Urut=2) J on 1=1
--where A.NoJurnal<>''
GROUP BY A.NOBUKTI, A.NOURUT, A.TANGGAL, ---J.Perkiraan,
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL,
	A.NOURUT, A.NoJurnal






GO

-- View: vwQntBeliDariPO
-- Created: 2012-11-20 12:08:22.637 | Modified: 2012-11-20 12:08:22.637
-- =====================================================





CREATE View vwQntBeliDariPO
as

select NOPO, UrutPO, KodeBrg, sum(Qnt*Isi) QntSat1 from dbBeliDet
where NOPO<>'-' group by NOPO, UrutPO, KodeBrg















GO

-- View: vwQntRBeliDariBeli
-- Created: 2012-11-29 14:29:32.227 | Modified: 2012-12-19 14:05:28.943
-- =====================================================






CREATE View [dbo].[vwQntRBeliDariBeli]
as

select B.NoBeli, A.UrutPBL, A.KodeBrg, sum(A.Qnt) QntSat1, sum(A.Qnt2) QntSat2 from dbRBeliDet A, dbRBeli B
where A.NoBukti=B.NoBukti and B.NoBeli<>'-' group by B.NoBeli, A.UrutPBL, A.KodeBrg
















GO

-- View: vwRegStock
-- Created: 2011-02-11 15:18:57.600 | Modified: 2011-02-11 15:18:57.600
-- =====================================================
CREATE View dbo.vwRegStock
as

Select 	Tipe, Prioritas, KodeBrg, QntDb, Qnt2Db, HrgDebet, QntCr, Qnt2Cr, HrgKredit, 
	QntSaldo, Qnt2Saldo, HrgSaldo, Tanggal, Bulan, Tahun, NoBukti, 
	KodeCustSupp, Keterangan, IDUser, HPP
From 	dbo.vwKartuStock


GO

-- View: VwReportBeliGudang
-- Created: 2013-06-03 12:53:21.013 | Modified: 2015-03-09 15:28:01.013
-- =====================================================





CREATE  View [dbo].[VwReportBeliGudang]
as
Select 	A.NoBukti,A.TANGGAL, B.NoPO, B.UrutPO,A.KODESUPP KodeCustSupp,I.NAMACUSTSUPP,
	    B.Urut, B.KodeBrg, H.NamaBrg,b.QNT as qntbeli,b.SATUAN as satbeli,
	    isnull(B.Qnt1Terima,0) as qnt, h.SAT1 as satuan,
        isnull(b.Qnt2Terima,0) as Qnt2,h.SAT2 As satuan2,
        B.Qnt1Reject as qntreject,
        B.Qnt2Reject as qnt2reject,
        B.Harga, B.HrgNetto,B.DiscP,B.DiscTot,
        case when a.kodevls<>'IDR' then B.NDPP else 0 end as NDPP
        ,B.NDPPRp,b.NPPNRp,b.NNETRp,
        B.KodeGdg,A.KODEVLS,A.KURS,A.FAKTURSUPP,
        Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi,J.NAMA NamaGdg
From dbBeliDet B 
Left Outer Join dbBeli A On A.NoBukti=b.NoBukti
Left Outer Join dbBarang H on H.KodeBrg=B.KodeBrg
Left Outer Join DBCUSTSUPP I on A.KODESUPP = I.KODECUSTSUPP
left outer join DBGUDANG J on B.KodeGdg=J.KODEGDG






GO

-- View: VwreportBeliReject
-- Created: 2013-05-13 12:08:51.920 | Modified: 2013-05-13 12:08:51.920
-- =====================================================
CREATE View [dbo].[VwreportBeliReject]
as
Select 	A.NoBukti,A.TANGGAL, B.NoPO, B.UrutPO,A.KODESUPP,I.KODECUSTSUPP,I.NAMACUSTSUPP,
	B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt, B.NoSat, B.Isi, B.Satuan,
        0.00 Qnt2, '' SatuanRoll, B.Harga, B.HrgNetto,
        B.DiscP DiscP1, B.DiscTot DiscRp1,B.DiscTot,
        B.SubTotal TotalUSD, B.SubTotal TotalIDR, B.NDPP NDPP,
        B.NPPN NPPN, B.BYAngkut Beban, B.SubTotal + B.BYAngkut Total, B.KodeGdg
From dbBeliDet B 
Left Outer Join dbBeli A On A.NoBukti=b.NoBukti
Left Outer Join dbBarang H on H.KodeBrg=B.KodeBrg
Left Outer join DBCUSTSUPP I on A.KODESUPP = I.KODECUSTSUPP


GO

-- View: VwreportBP
-- Created: 2013-06-10 11:04:36.080 | Modified: 2013-06-10 11:04:36.080
-- =====================================================



CREATE View [dbo].[VwreportBP]
as
Select 	A.NoBukti,A.NoBPPB,
	B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt, B.NoSat, B.Isi Isi, B.Sat Satuan, B.Qnt*B.HPP NilaiHPP, A.Tanggal,
	Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi 
From dbPenyerahanBhn A
Left Outer join  dbPenyerahanBhnDet B on B.NoBukti=a.NoBukti
Left Outer join dbBarang H on H.KodeBrg=b.KodeBrg





GO

-- View: VwReportBPPBKeluar
-- Created: 2013-01-21 13:28:27.293 | Modified: 2013-01-21 13:28:27.293
-- =====================================================

Create View [dbo].[VwReportBPPBKeluar]
as

Select 	A.KodeGdgT,A.NoBukti, A.Tanggal, A.KdDep, C.NmDep,Qnt QMinta,Qnt2 QKirim,B.KodeBrg,D.NamaBrg,Nosat,Satuan
From dbBPPB A
Left Outer Join dbBPPBdet B On A.NoBukti=B.NoBukti
Left Outer Join dbBarang D On B.Kodebrg=D.Kodebrg
Left Outer Join dbDEPART C on c.KdDEP=a.KdDEP
GO

-- View: vwReportDaftarHarga
-- Created: 2011-11-04 09:16:21.633 | Modified: 2011-11-04 09:16:21.633
-- =====================================================

CREATE View [dbo].[vwReportDaftarHarga]
as
Select X.KODEBRG,X.NAMABRG, MAX(X.Bln1) Bln1, MAX(X.Bln2) Bln2, MAX(X.Bln3) Bln3, MAX(X.Bln4) Bln4, MAX(X.Bln5) Bln5, MAX(X.Bln6) Bln6,
       MAX(X.Bln7) Bln7, MAX(X.Bln8) Bln8, MAX(X.Bln9) Bln9, MAX(X.Bln10) Bln10, MAX(X.Bln11) Bln11, MAX(X.Bln12) Bln12,
       X.Tahun, X.SAT_1
From (
	select b.KODEBRG, C.NAMABRG,YEAR(a.tanggal) Tahun,B.SAT_1,
			 Case when month(a.tanggal)= 1 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln1,
			 Case when month(a.tanggal)= 2 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln2,
			 Case when month(a.tanggal)= 3 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln3,
			 Case when month(a.tanggal)= 4 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln4,
			 Case when month(a.tanggal)= 5 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln5,
			 Case when month(a.tanggal)= 6 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln6,
			 Case when month(a.tanggal)= 7 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln7,
			 Case when month(a.tanggal)= 8 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln8,
			 Case when month(a.tanggal)= 9 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln9,
			 Case when month(a.tanggal)= 10 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln10,
			 Case when month(a.tanggal)= 11 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln11,
			 Case when month(a.tanggal)= 12 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln12       
	From DBPO a
		  left outer join DBPODET b on b.NOBUKTI=a.NOBUKTI
		  left outer join DBBARANG C on C.KODEBRG=b.KODEBRG    
	group by b.KODEBRG,C.NAMABRG,month(a.tanggal),YEAR(a.tanggal), B.SAT_1)X
	
	group by  X.KODEBRG,X.NAMABRG,x.Tahun,X.SAT_1
	

GO

-- View: VwreportDebetNotte
-- Created: 2013-06-03 13:57:48.763 | Modified: 2013-06-03 13:57:48.763
-- =====================================================


CREATE View [dbo].[VwreportDebetNotte]
as
Select  a.NoBukti,x.tanggal,z.kodecustsupp,z.NAMACUSTSUPP, a.NoInv,a.KodeVLS,a.Kurs,
    Isnull(a.nilai,0) NDPP,Isnull(a.nilairp,0) NDPPRP,a.Keterangan,
      Cast(Case when Case when X.IsOtorisasi1=1 then 1 else 0 end+
                      Case when X.IsOtorisasi2=1 then 1 else 0 end+
                      Case when X.IsOtorisasi3=1 then 1 else 0 end+
                      Case when X.IsOtorisasi4=1 then 1 else 0 end+
                      Case when X.IsOtorisasi5=1 then 1 else 0 end=X.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi
	From  dbDebetNoteDet a
	left Outer join DBDebetNote x on a.NOBUKTI = x.NOBUKTI
	Left Outer Join DBCUSTSUPP z on x.KodeSupp = z.KODECUSTSUPP





GO

-- View: VwreportHasilPrd
-- Created: 2013-06-10 11:35:47.127 | Modified: 2013-06-24 16:39:04.360
-- =====================================================




CREATE View [dbo].[VwreportHasilPrd]
as 
Select A.nobukti,A.tanggal,A.keterangan,B.urut,B.Kodebrg,B.Qnt,B.Satuan,B.isi,B.Nospk,B.HPP*b.QNT*B.ISI as HPP,C.NamaBrg,
       Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi 
From  dbHasilPrd A
Left Outer join DbHasilPRDDet B on a.nobukti = B.nobukti
Left Outer Join dbBarang C on C.KodeBrg=B.KodeBrg





GO

-- View: VwreportHasilPrdACC
-- Created: 2013-06-24 10:36:50.257 | Modified: 2013-06-24 16:38:39.693
-- =====================================================






CREATE View [dbo].[VwreportHasilPrdACC]
as 
Select A.nobukti,A.tanggal,A.keterangan,B.urut,B.Kodebrg,B.Qnt,B.Satuan,B.isi,B.Nospk,
       B.HPP*B.QNT*B.ISI as HPP,C.NamaBrg,
       Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi 
From  dbHasilPrd A
Left Outer join DbHasilPRDDet B on a.nobukti = B.nobukti
Left Outer Join dbBarang C on C.KodeBrg=B.KodeBrg








GO

-- View: VwreportInvoice
-- Created: 2013-06-03 13:50:49.020 | Modified: 2015-03-09 15:28:00.940
-- =====================================================


CREATE View  [dbo].[VwreportInvoice]
as


Select  a.NoBukti,c.kurs,c.kodevls,b.NoBukti NoBeli ,b.kodebrg,b.qnt,b.SATUAN,
		e.namabrg,b.harga,B.DISCTOT,case when c.kodevls<>'IDR' then NDPPVLS else 0 end as NDPPVLS,
		B.NDPP,B.NPPN,B.NNET,C.KodeSupp KodeCustSupp,D.NAMACUSTSUPP,C.TANGGAL,
		Cast(Case when Case when C.IsOtorisasi1=1 then 1 else 0 end+
                      Case when C.IsOtorisasi2=1 then 1 else 0 end+
                      Case when C.IsOtorisasi3=1 then 1 else 0 end+
                      Case when C.IsOtorisasi4=1 then 1 else 0 end+
                      Case when C.IsOtorisasi5=1 then 1 else 0 end=C.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi
From  dbInvoiceDet a
Left Outer Join (select a.NoBukti,b.kodebrg,sum(b.qnt) qnt,b.satuan,b.harga,b.disctot, sum(ndpp) ndppvls,Sum(NDPPrp)NDPP,Sum(NPPNrp)NPPN,Sum(NNETrp)NNET 
from dbBeli a Left Outer Join dbBeliDet b On a.NoBukti=b.noBukti Group by a.NoBukti,b.KODEBRG,b.SATUAN,b.HARGA,b.DISCTOT)b On a.NoBeli=b.NoBukti
Left Outer join DBInvoice C on A.NOBUKTI = C.NOBUKTI 
Left Outer Join dbCustSupp D On C.KodeSupp=D.KodeCustSupp
left Outer Join DBBARANG E on E.KODEBRG=b.KODEBRG






GO

-- View: VwReportInvoicePembelian
-- Created: 2013-01-07 10:14:35.767 | Modified: 2013-01-07 10:14:35.767
-- =====================================================

Create View [dbo].[VwReportInvoicePembelian]
as

Select  a.NoBukti,b.NoBukti NoBeli ,NDPP,NPPN,NNET
From  dbInvoiceDet a
Left Outer Join (select a.NoBukti,Sum(NDPP)NDPP,Sum(NPPN)NPPN,Sum(NNET)NNET from dbBeli a Left Outer Join dbBeliDet b On a.NoBukti=b.noBukti Group by a.NoBukti)b On a.NoBeli=b.NoBukti
GO

-- View: VwreportInvoicePenjualan
-- Created: 2013-06-03 14:13:11.053 | Modified: 2013-06-03 14:13:11.053
-- =====================================================





CREATE View [dbo].[VwreportInvoicePenjualan]
as
select 	B.NoBukti, B.Urut, B.NoSPB, B.UrutSPB, B.KodeBrg, C.NAMABRG,x.Tanggal tglSPB,B.NoSPP,
        a.KURS,a.Valas,z.kodesls,p.nama,
        case when b.NOSAT=1 then B.QNT else B.QNT2 end as qnt,
        case when b.NOSAT=1 then B.SAT_1 else B.SAT_2 end as satuan,
        B.HARGA, B.DiscP, B.DISCTOT, B.NDPP,B.NDPPRp,B.NPPNRp, B.NNETRp, B.KetDetail,
        A.Tanggal,A.KodeCustSupp,D.NAMACUSTSUPP,   
		Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
		Case when A.IsOtorisasi2=1 then 1 else 0 end+
		Case when A.IsOtorisasi3=1 then 1 else 0 end+
		Case when A.IsOtorisasi4=1 then 1 else 0 end+
		Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
		else 1
		end As Bit) Needotorisasi
from	dbInvoicePLDet B
left outer join dbBarang C on C.KodeBrg=B.KodeBrg
left outer join DBInvoicePL A on B.NoBukti = A.NoBukti
Left outer join DBCUSTSUPP D on A.KodeCustSupp = D.KODECUSTSUPP
left outer join dbSPB X on B.NoSPB = X.NoBukti
left outer join dbSPP y on y.NoBukti=x.NoSPP
left outer join DBSO z on z.NOBUKTI=y.NoSHIP
left outer join dbKaryawan p on p.KeyNIK=z.KODESLS




GO

-- View: VwReportInVoiceRPembelian
-- Created: 2013-01-07 10:14:56.083 | Modified: 2013-01-07 10:14:56.083
-- =====================================================

Create view [dbo].[VwReportInVoiceRPembelian]
as
Select 	B.NoBukti, B.UrutPBL,
	B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt, B.NoSat, B.Isi, B.Satuan,
        0.00 Qnt2, '' SatuanRoll, B.Harga,
        B.DiscP DiscP1, B.DiscTot DiscRp1, B.DiscTot,
        B.SubTotal TotalUSD, B.SubTotal TotalIDR, B.NDPP NDPP,
        B.NPPN NPPN, B.BYAngkut Beban, B.SubTotal + B.BYAngkut Total
From dbRBeliDet B
Left Outer Join dbBarang H on H.KodeBrg=B.KodeBrg 
GO

-- View: VwReportJual
-- Created: 2012-11-01 12:56:54.733 | Modified: 2012-11-01 12:56:54.733
-- =====================================================

CREATE view [dbo].[VwReportJual]
as
Select 	A.NoBukti+right('00000000'+cast(A.Urut as varchar(8)),8) KeyNoBukti,
        A.*, C.NamaCustSupp, T.Nama NamaTipe, ST.Nama NamaSubTipe,
        cast(left(A.NoBukti,2) as varchar(50)) Left2NoBukti
From dbPenjualan A
Left Outer Join DBCUSTSUPP C on C.KODECUSTSUPP=A.KodeCustSupp
Left Outer Join DBTIPETRANS T on T.KODETIPE=A.KodeTipe
Left Outer Join DBSUBTIPETRANS ST on ST.KODETIPE=A.KodeTipe and ST.KODESUBTIPE=A.KodeSubTipe


GO

-- View: VwreportOpnameBahan
-- Created: 2013-06-03 14:32:58.230 | Modified: 2013-06-03 14:32:58.230
-- =====================================================



CREATE View [dbo].[VwreportOpnameBahan]
as
Select * from vwdetailKoreksi Where noBukti Like '%OPN%'




GO

-- View: VwreportOPnamebarang
-- Created: 2013-06-03 14:33:33.750 | Modified: 2013-06-03 14:33:33.750
-- =====================================================



CREATE View [dbo].[VwreportOPnamebarang]
as
Select * from vwdetailKoreksi Where noBukti Like '%OPBJ%'--'OPN%'



GO

-- View: vwreportoutSO
-- Created: 2013-05-13 12:08:51.610 | Modified: 2013-05-13 12:08:51.610
-- =====================================================



Create View [dbo].[vwreportoutSO]
as
Select  A.NoBukti+right('00000'+cast(A.Urut as varchar(5)),5) KeyNoBukti, A.Nobukti, 
P.Tanggal, P.Kodecust KodeCustSupp, S.NamaCust NamaCustSupp,
A.urut, A.kodebrg, B.NamaBrg, A.Satuan, A.Isi,
A.Qnt, A.Qnt2, A.QntSPP, A.Qnt2SPP,
A.QntSisa, A.Qnt2Sisa,P.MasaBerlaku,P.NoPesanan,P.TglKirim,P.TGLJATUHTEMPO
From    vwBrowsOutSO_SPP A
Left Outer Join DBSO P on P.NoBukti=A.NoBukti
Left Outer Join vwBrowsCustomer S on S.KodeCust=P.KodeCust and S.Sales=P.KODESLS
Left Outer Join dbBarang B on B.KodeBrg=A.KodeBrg
where A.islengkap=0


GO

-- View: VwreportOutSPB
-- Created: 2013-05-13 12:08:51.567 | Modified: 2015-03-11 09:53:07.077
-- =====================================================





CREATE View [dbo].[VwreportOutSPB] 
as
Select A.*,B.NAMABRG NamaBarang,C.Tanggal,C.kodeCustSupp,D.NAMACUSTSUPP,
           A.Nobukti+Cast(A.Urut as varchar(5)) MyKey,Z.NOBUKTI Noso,Z.TANGGAL TanggalSO
from dbSPBDet A
     left outer join DBBARANG B on B.KODEBRG=A.Kodebrg
     Left Outer join dbSPB C on A.NoBukti = C.NoBukti
     Left Outer join DBCUSTSUPP D on c.KodeCustSupp = D.KODECUSTSUPP
     Left Outer join (Select x.NoBukti, x.NoSPP
                      from dbSPBDet x
                      group by x.NoBukti, x.NoSPP) y on y.NoBukti=C.NoBukti
     Left Outer Join (Select x.NoBukti, x.Tanggal,y.NoSO, x.TglKirim
                      from DBSPP x 
                        left outer join dbSPPDet y on y.NoBukti=x.NoBukti
                      Group by x.NoBukti, x.Tanggal,y.NoSO, x.TglKirim) v On v.NoBukti=y.NoSPP 
    left outer join DBSO Z on Z.NOBUKTI=v.NoSO
     






GO

-- View: VwreportOUtSPK
-- Created: 2013-06-03 16:32:27.753 | Modified: 2013-06-03 16:32:27.753
-- =====================================================

Create View [dbo].[VwreportOUtSPK]
as

select a.NOBUKTI ,E.TANGGAL, a.Kodebrg, d.NAMABRG, a.Qnt QntBPPB,
sum(case when a.NOSAT=1 then isnull(b.Qnt,0) else b.Qnt2 end) QntBP,
a.QNT-sum(case when a.NOSAT=1 then isnull(b.Qnt,0) else b.Qnt2 end) Sisa
from DBSPKDET a
left outer join DBPenyerahanBhnDET b on b.NoSPK=a.NOBUKTI and b.UrutSPK=a.URUT 
--left Outer Join (select Kodebrg,SUM(Qnt*isi)Qnt from DBPenyerahanBhnDET group by kodebrg)b On b.kodebrg=a.KodeBrg 
--left Outer Join (select Kodebrg,SUM(SALDOQNT)Qnt from DBSTOCKBRG group by kodebrg )c On c.kodebrg=a.KodeBrg
Left Outer Join DBBARANG d On a.KODEBRG=d.kodebrg 
Left outer Join DBSPK E on A.NOBUKTI = E.NOBUKTI
group by a.NOBUKTI, a.Urut, a.KodeBrg, a.Qnt, a.Isi, d.NAMABRG, E.TANGGAL
having a.QNT-sum(case when a.NOSAT=1 then isnull(b.Qnt,0) else b.Qnt2 end)>0


GO

-- View: VwReportOutSPP
-- Created: 2013-05-13 12:08:51.577 | Modified: 2015-03-11 09:53:07.110
-- =====================================================



CREATE View [dbo].[VwReportOutSPP] 
as
Select  A.NoBukti+right('00000'+cast(A.Urut as varchar(5)),5) KeyNoBukti, A.Nobukti, P.Tanggal, P.KodeCustSupp, S.Namacust NamaCustSupp,
        A.urut, A.kodebrg, B.NamaBrg, '' Jns_Kertas, '' Ukr_Kertas, A.Sat_1, A.Sat_2, A.Isi,
        Case when A.NoSat=1 then A.Qnt
             when A.NoSat=2 then A.Qnt2
             else 0
        end Qnt, A.Qnt2,
        Case when A.NoSat=1 then A.QntSPB
             when A.NoSat=2 then A.Qnt2SPB
             else 0
        end QntSPB, A.Qnt2SPB,
        Case when A.NoSat=1 then A.QntSisa
             when A.NoSat=2 then A.Qnt2Sisa
             else 0
        end QntSisa, A.Qnt2Sisa,
        Case when A.NOSAT=1 then A.SAT_1
             when A.NOSAT=2 then A.SAT_2
             else ''
        end Satuan, P.Tglkirim,
        P.NoPesan
From    vwBrowsOutSPP A
Left Outer Join dbSPP P on P.NoBukti=A.NoBukti
left Outer join DBSO SO on SO.NOBUKTI=A.noso
Left Outer Join vwBrowsCustomer S on S.KodeCust=P.KodeCustSupp and s.Sales=SO.KODESLS
Left Outer Join dbBarang B on B.KodeBrg=A.KodeBrg
where A.isclose=0 

GO

-- View: VwReportOutStandingBPPB
-- Created: 2013-01-21 13:25:23.927 | Modified: 2013-01-21 13:25:23.927
-- =====================================================
CREATE View [dbo].[VwReportOutStandingBPPB]
as

Select  a.NoBukti,Tanggal,b.KodeBrg,c.NamaBrg,Qnt,Qnt2,A.KodeGdg,A.KodeGdgT
From dbBPPB a Left Outer Join dbBPPBDet b On a.NoBukti=b.NoBukti
left Outer Join dbBarang c On c.KodeBrg=b.KodeBrg
where Qnt<>Qnt2

GO

-- View: VwReportOutStandingPO
-- Created: 2013-01-07 10:15:07.063 | Modified: 2013-01-07 10:15:07.063
-- =====================================================
CREATE View [dbo].[VwReportOutStandingPO]
as
Select 	A.*, H.NamaBrg,I.TANGGAL,I.KODESUPP KOdeCustSupp,J.NAMACUSTSUPP
From vwOutstandingPO A
Left Outer Join dbBarang H on H.KodeBrg=A.KodeBrg
Left Outer Join DBPO I on A.NoBukti = I.NOBUKTI
left Outer Join DBCUSTSUPP J on I.KODESUPP = J.KODECUSTSUPP
GO

-- View: VwReportOutStandingPR
-- Created: 2013-01-07 10:15:22.863 | Modified: 2013-01-07 10:15:22.863
-- =====================================================
CREATE View [dbo].[VwReportOutStandingPR]
as
select A1.Nobukti,A1.Tanggal,a.kodebrg,C.KODESUPP KOdeCustSupp,D.NAMACUSTSUPP, a.Sat,c.NAMABRG,SUM(a.Qnt*isi)QntPPL,Isnull(b.Qnt,0) QntPO,SUM(a.Qnt*isi)-Isnull(b.Qnt,0)sisa from DBPPLDET a
Left Outer Join (select NoPPL,Kodebrg,SUM(Qnt*isi)Qnt from DBPODET  group by NoPPL,Kodebrg)b On a.Nobukti=b.NoPPL and a.kodebrg=b.KODEBRG
left Outer Join DBBARANG c On c.KODEBRG=a.kodebrg
Left Outer Join dbPPL A1 On A1.NoBukti=A.NoBukti 
Left Outer Join DBCUSTSUPP D on C.KODESUPP=D.KODECUSTSUPP
where Case when Isnull(A1.IsClose,0)=0 Then Isnull(A.IsClose,0)else Isnull(A1.IsClose,0) end=0
group by a.kodebrg,a.Sat,b.Qnt,c.NAMABRG,A1.Nobukti,A1.Tanggal,C.KODESUPP,D.NAMACUSTSUPP
having SUM(a.Qnt*isi)-Isnull(b.Qnt,0)<>0
GO

-- View: VwReportOutStandingSO
-- Created: 2013-01-18 16:31:30.357 | Modified: 2015-03-11 09:53:07.133
-- =====================================================


CREATE View [dbo].[VwReportOutStandingSO]
as
select  A.NoBukti, A.Urut, A.NoBukti+right('000000'+cast(A.Urut as varchar(6)),6) KeyUrut,
        A.KODEBRG, A.NamaBrg, A.QNT, A.QNT2, A.NOSAT, A.Satuan, A.ISI, A.QntSJ, A.Qnt2SJ, A.SatuanRoll,
        A.QNT-A.QntSJ QntSisa, A.QNT2-A.QNT2SJ Qnt2Sisa,
        C.KODECUSTSUPP,C.NAMACUSTSUPP,A.Tanggal,B.MasaBerlaku,B.NoPesanan,
        A.QNT2SJ Qnt2Spp,A.QntSJ QntSpp,B.TglKirim
--select * 
from    vwSOBelumSuratJlnDet A 
Left Outer Join  DBSO B on A.NoBukti = B.NOBUKTI
Left Outer Join DBCUSTSUPP C on B.KODECUST = C.KODECUSTSUPP



GO

-- View: VwReportOutstandingSO2
-- Created: 2013-01-25 09:11:09.357 | Modified: 2013-01-25 09:11:09.357
-- =====================================================
Create view VwReportOutstandingSO2
as
Select  A.NoBukti+right('00000'+cast(A.Urut as varchar(5)),5) KeyNoBukti, A.Nobukti, P.Tanggal, P.Kodecust KodeCustSupp, S.NamaCust NamaCustSupp,
        A.urut, A.kodebrg, B.NamaBrg, A.Satuan, A.Isi,
        A.Qnt, A.Qnt2, A.QntSPP, A.Qnt2SPP,
        A.QntSisa, A.Qnt2Sisa
From    vwBrowsOutSO_SPP A
Left Outer Join DBSO P on P.NoBukti=A.NoBukti
Left Outer Join vwBrowsCustomer S on S.KodeCust=P.KodeCust and S.Sales=P.KODESLS
Left Outer Join dbBarang B on B.KodeBrg=A.KodeBrg


GO

-- View: VwReportPembelian
-- Created: 2012-11-01 12:56:54.903 | Modified: 2012-11-01 12:56:54.903
-- =====================================================


Create View [dbo].[VwReportPembelian]
as
Select 	A.NoBukti+right('00000000'+cast(A.Urut as varchar(8)),8) KeyNoBukti,
        A.*, C.NamaCustSupp, T.Nama NamaTipe, ST.Nama NamaSubTipe,
        cast(left(A.NoBukti,2) as varchar(50)) Left2NoBukti
From dbPembelian A
Left Outer Join DBCUSTSUPP C on C.KODECUSTSUPP=A.KodeCustSupp
Left Outer Join DBTIPETRANS T on T.KODETIPE=A.KodeTipe
Left Outer Join DBSUBTIPETRANS ST on ST.KODETIPE=A.KodeTipe and ST.KODESUBTIPE=A.KodeSubTipe

GO

-- View: VwReportPenerimaanACC
-- Created: 2013-05-13 12:08:51.950 | Modified: 2015-03-09 15:28:00.997
-- =====================================================


CREATE view [dbo].[VwReportPenerimaanACC]
as

Select 	B.NoBukti,B.NoPO,I.TANGGAL,I.KODESUPP KodeCustSupp,J.NAMACUSTSUPP,
	B.Urut, B.KodeBrg, H.NamaBrg, B.QntTerima qnt, B.NoSat, B.Isi, B.Satuan,
	    k.QNT qntpo,b.QNT qntgdg, b.QntReject reject,b.Qnt2Reject reject2,
        Qnt2Terima Qnt2, '' SatuanRoll, B.Harga,
        (B.NDISKON+B.DISCTOT)*i.kurs Disctotal,
        (B.NDPP+B.NPPN)*i.kurs TotalIDR, B.NDPP*i.kurs NDPP,
        B.NPPN*i.kurs NPPN, B.BYAngkut Beban, B.SubTotal + B.BYAngkut Total,
        case when i.kurs=1 then 0 else b.disctot end as disctotusd,
        case when i.kurs=1 then 0 else b.ndpp end as Ndppusd,
        case when i.kurs=1 then 0 else b.nppn end as NPPNusd,
        case when i.kurs=1 then 0 else b.subtotal end as totalusd,
        I.kurs,I.KODEVLS--,b.Qnt2 qntgdg2,
        ,Cast(Case when Case when I.IsOtorisasi1=1 then 1 else 0 end+
		Case when I.IsOtorisasi2=1 then 1 else 0 end+
		Case when I.IsOtorisasi3=1 then 1 else 0 end+
		Case when I.IsOtorisasi4=1 then 1 else 0 end+
		Case when I.IsOtorisasi5=1 then 1 else 0 end=I.MaxOL then 0
		else 1
		end As Bit) Needotorisasi
From  DBBELIDET B 
Left Outer Join dbBarang H on H.KodeBrg=B.KodeBrg
Left Outer join DBBELI I on B.NOBUKTI = I.NOBUKTI
Left Outer Join DBCUSTSUPP J on I.KODESUPP = J.KODECUSTSUPP
Left outer join DBPODET K on K.NOBUKTI=B.NOBUKTI and k.KODEBRG=b.KODEBRG 



GO

-- View: VwreportPermintaanBahan
-- Created: 2013-06-03 14:29:18.257 | Modified: 2013-06-03 14:29:18.257
-- =====================================================




CREATE View [dbo].[VwreportPermintaanBahan]
as
Select 	A.NoBukti, A.TANGGAL,A.KodeGdg,A.KodeGdgT,a.kddep,c.NMDEP,
	B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt,B.Qnt2M, B.Satuan Satuan,
	B.Qnt2,B.Qnt2P,
	Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi 
From dbBPPB A
Left Outer join dbBPPBDet B on B.NoBukti=a.NoBukti
Left Outer join dbBarang H on H.KodeBrg=b.KodeBrg
left outer join DBDEPART c on c.KDDEP=a.KDDEP




GO

-- View: VwreportPLinvoice
-- Created: 2013-01-30 16:01:49.020 | Modified: 2013-02-01 13:36:57.100
-- =====================================================

CREATE View [dbo].[VwreportPLinvoice]
as
select 	B.NoBukti, B.Urut, B.NoSPB, B.UrutSPB, B.KodeBrg, C.NAMABRG,x.Tanggal tglSPB,B.NoSPP,
        B.PPN, B.DISC, B.KURS, B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.NOSAT, B.ISI, B.NetW, B.GrossW,
        B.HARGA, B.DiscP, B.DiscRp, B.DISCTOT, B.HRGNETTO, B.NDISKON, B.SUBTOTAL, B.NDPP, B.NPPN, B.NNET,
        B.SUBTOTALRp, B.NDPPRp, B.NPPNRp, B.NNETRp, B.KetDetail,
        A.Tanggal,A.KodeCustSupp,D.NAMACUSTSUPP
from	dbInvoicePLDet B
left outer join dbBarang C on C.KodeBrg=B.KodeBrg
left outer join DBInvoicePL A on B.NoBukti = A.NoBukti
Left outer join DBCUSTSUPP D on A.KodeCustSupp = D.KODECUSTSUPP
left outer join dbSPB X on B.NoSPB = X.NoBukti



GO

-- View: VwreportPO
-- Created: 2013-06-03 13:41:53.343 | Modified: 2013-06-03 13:41:53.343
-- =====================================================



CREATE view [dbo].[VwreportPO]
as
Select 	B.NoBukti,I.TANGGAL,I.KODESUPP KodeCustSupp,J.NAMACUSTSUPP, '' NoSPP, 0 UrutSPP,
	B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt, B.NoSat, B.Isi, B.Satuan,
        0.00 Qnt2, '' SatuanRoll, B.Harga,
        (B.NDISKON+B.DISCTOT)*i.kurs Disctotal,
        (B.NDPP+B.NPPN)*i.kurs TotalIDR, B.NDPP*i.kurs NDPP,
        B.NPPN*i.kurs NPPN, B.BYAngkut Beban, B.SubTotal + B.BYAngkut Total,
        case when i.kurs=1 then 0 else b.disctot end as disctotusd,
        case when i.kurs=1 then 0 else b.ndpp end as Ndppusd,
        case when i.kurs=1 then 0 else b.nppn end as NPPNusd,
        case when i.kurs=1 then 0 else b.subtotal end as totalusd,
        I.kurs,I.KODEVLS,
        Cast(Case when Case when I.IsOtorisasi1=1 then 1 else 0 end+
                      Case when I.IsOtorisasi2=1 then 1 else 0 end+
                      Case when I.IsOtorisasi3=1 then 1 else 0 end+
                      Case when I.IsOtorisasi4=1 then 1 else 0 end+
                      Case when I.IsOtorisasi5=1 then 1 else 0 end=I.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi
From  dbPODet B 
Left Outer Join dbBarang H on H.KodeBrg=B.KodeBrg
Left Outer join DBPO I on B.NOBUKTI = I.NOBUKTI
Left Outer Join DBCUSTSUPP J on I.KODESUPP = J.KODECUSTSUPP 



GO

-- View: VwReportPurchasingReq
-- Created: 2013-06-03 13:35:04.340 | Modified: 2013-06-03 13:35:04.340
-- =====================================================


CREATE view [dbo].[VwReportPurchasingReq]
as

Select 	A.NoBukti,A.Tanggal,H.KODESUPP KodeCustSupp,I.NAMACUSTSUPP, 
	B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt, B.NoSat, B.Isi Isi, B.Sat Satuan,B.Keterangan,
	 Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi

From dbPPL A
Left Outer join dbPPLDet B on B.NoBukti=a.NoBukti
Left Outer join dbBarang H on H.KodeBrg=b.KodeBrg
Left Outer Join DBCUSTSUPP I on H.KODESUPP=i.KODECUSTSUPP


GO

-- View: VwReportRBeli
-- Created: 2012-11-01 12:56:54.920 | Modified: 2012-11-01 12:56:54.920
-- =====================================================

CREATE View [dbo].[VwReportRBeli]
as
Select 	A.NoBukti+right('00000000'+cast(A.Urut as varchar(8)),8) KeyNoBukti,
        A.*, C.NamaCustSupp, T.Nama NamaTipe, ST.Nama NamaSubTipe,
        cast(left(A.NoBukti,2) as varchar(50)) Left2NoBukti
From dbRPembelian A
Left Outer Join DBCUSTSUPP C on C.KODECUSTSUPP=A.KodeCustSupp
Left Outer Join DBTIPETRANS T on T.KODETIPE=A.KodeTipe
Left Outer Join DBSUBTIPETRANS ST on ST.KODETIPE=A.KodeTipe and ST.KODESUBTIPE=A.KodeSubTipe

GO

-- View: VwReportRevisiPO
-- Created: 2013-01-07 10:16:15.090 | Modified: 2013-01-07 10:16:15.090
-- =====================================================
CREATE View [dbo].[VwReportRevisiPO]
as
Select 	B.NoBukti,I.TANGGAL,I.KODESUPP KodeCustSupp,J.NAMACUSTSUPP, '' NoSPP, 0 UrutSPP,
	B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt, B.NoSat, B.Isi, B.Satuan,
        0.00 Qnt2, '' SatuanRoll, B.Harga,
        B.DiscP DiscP1, B.DiscTot DiscRp1, B.DiscTot,
        B.SubTotal TotalUSD, B.SubTotal TotalIDR, B.NDPP NDPP,
        B.NPPN NPPN, B.BYAngkut Beban, B.SubTotal + B.BYAngkut Total
From  dbPODet B 
Left Outer Join dbBarang H on H.KodeBrg=B.KodeBrg
Left Outer join DBPO I on B.NOBUKTI = I.NOBUKTI
Left Outer Join DBCUSTSUPP J on I.KODESUPP = J.KODECUSTSUPP 
GO

-- View: VwreportRInvoice
-- Created: 2013-01-18 14:57:59.257 | Modified: 2013-01-18 14:57:59.257
-- =====================================================

CREATE View [dbo].[VwreportRInvoice]
as
Select 	B.NoBukti, B.UrutPBL,I.KODESUPP KodeCustSupp,j.NAMACUSTSUPP,I.TANGGAL,
	B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt, B.NoSat, B.Isi, B.Satuan,
        0.00 Qnt2, '' SatuanRoll, B.Harga,
        B.DiscP DiscP1, B.DiscTot DiscRp1, B.DiscTot,
        B.SubTotal TotalUSD, B.SubTotal TotalIDR, B.NDPP NDPP,
        B.NPPN NPPN, B.BYAngkut Beban, B.SubTotal + B.BYAngkut Total
        
From dbRBeliDet B
Left Outer Join dbBarang H on H.KodeBrg=B.KodeBrg 
Left Outer Join DBRBELI I on B.NOBUKTI = I.NOBUKTI
Left Outer Join DBCUSTSUPP J on I.KODESUPP = J.KODECUSTSUPP 
GO

-- View: VwReportRInvoicePenjualan
-- Created: 2013-06-03 14:14:44.973 | Modified: 2013-06-03 14:14:44.973
-- =====================================================




CREATE View [dbo].[VwReportRInvoicePenjualan]
as
select 	B.NOBUKTI,D.TANGGAL, B.URUT, B.KODEBRG, B.PPN, B.DISC, B.KURS,D.NOSPB,D.NoSPP,E.Tanggal TglSPB,F.Tanggal TglSpp,
        B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.ISI, B.HARGA, B.DiscP1, B.DiscRp1,
        B.DiscP2, B.DiscRp2, B.DiscP3, B.DiscRp3, B.DiscP4, B.DiscRp4, B.DISCTOT,
        B.BYANGKUT, B.HRGNETTO, B.NDISKON, B.SUBTOTAL, B.NDPP, B.NPPN, B.NNET, B.SUBTOTALRp,
        B.NDPPRp, B.NPPNRp, B.NNETRp, B.NOInvoice, B.URUTInvoice, B.Keterangan,
        C.NamaBrg, B.QntTukar, B.Qnt2Tukar, B.netW, B.GrossW,
        'Nama Produk : '+c.Namabrg+' '+'Nama Komersil : '+ b.namabrg NamaProduk,
        D.KODECUSTSUPP,G.NAMACUSTSUPP,
		Cast(Case when Case when D.IsOtorisasi1=1 then 1 else 0 end+
		Case when D.IsOtorisasi2=1 then 1 else 0 end+
		Case when D.IsOtorisasi3=1 then 1 else 0 end+
		Case when D.IsOtorisasi4=1 then 1 else 0 end+
		Case when D.IsOtorisasi5=1 then 1 else 0 end=D.MaxOL then 0
		else 1
		end As Bit) Needotorisasi
        
from	dbRInvoicePLDet B
left outer join dbBarang C on C.KodeBrg=B.KodeBrg
left outer join DBRInvoicePL D on B.NOBUKTI=D.NOBUKTI
Left Outer Join dbSPB E on D.NOSPB = E.NoBukti
Left Outer join dbSPP F on D.NoSPP = F.NoBukti
Left Outer join DBCUSTSUPP G on D.KODECUSTSUPP=G.KODECUSTSUPP







GO

-- View: VwReportRjual
-- Created: 2012-11-01 12:56:54.960 | Modified: 2012-11-01 12:56:54.960
-- =====================================================


Create View [dbo].[VwReportRjual]
as
Select 	A.NoBukti+right('00000000'+cast(A.Urut as varchar(8)),8) KeyNoBukti,
        A.*, C.NamaCustSupp, T.Nama NamaTipe, ST.Nama NamaSubTipe,
        cast(left(A.NoBukti,2) as varchar(50)) Left2NoBukti
From dbRPenjualan A
Left Outer Join DBCUSTSUPP C on C.KODECUSTSUPP=A.KodeCustSupp
Left Outer Join DBTIPETRANS T on T.KODETIPE=A.KodeTipe
Left Outer Join DBSUBTIPETRANS ST on ST.KODETIPE=A.KodeTipe and ST.KODESUBTIPE=A.KodeSubTipe

GO

-- View: VwReportRPembelianGDg
-- Created: 2013-06-03 13:53:00.930 | Modified: 2013-06-03 13:53:00.930
-- =====================================================


CREATE view [dbo].[VwReportRPembelianGDg]
as
Select 	A.NoBukti,A.TANGGAL, a.Nobeli, A.KODESUPP KodeCustSupp,I.NAMACUSTSUPP,
	    B.Urut, B.KodeBrg, H.NamaBrg,b.QNT as qntretur,b.SATUAN as satrbeli,
	    isnull(B.Qnt1,0) as qnt, h.SAT1 as satuan,
        isnull(b.Qnt2,0) as Qnt2,h.SAT2 As satuan2,
        B.Harga, B.HrgNetto,B.DiscP,B.DiscTot,
        case when a.KODEVLS<>'IDR' then b.NDPP else 0 end as ndpp,B.NDPPRp,b.NPPNRp,b.NNETRp,
        A.KODEVLS,A.KURS,A.FAKTURSUPP,
        Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi
        
From dbRBeliDet B
Left Outer Join dbBarang H on H.KodeBrg=B.KodeBrg 
left Outer Join DBRBELI A on B.NOBUKTI=A.NOBUKTI
Left Outer Join DBCUSTSUPP I on A.KODESUPP = I.KODECUSTSUPP





GO

-- View: VwReportRPenyerahanBahan
-- Created: 2013-06-03 14:27:09.800 | Modified: 2013-06-03 14:27:09.800
-- =====================================================
CREATE View [dbo].[VwReportRPenyerahanBahan]
as
Select 	A.NoBukti, 
B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt, B.NoSat, B.Isi Isi, B.Sat Satuan,A.Tanggal,
Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi 
From dbRPenyerahanBhn A
Left Outer join  dbRPenyerahanBhnDet B on B.NoBukti=a.NoBukti
Left Outer join dbBarang H on H.KodeBrg=b.KodeBrg  



GO

-- View: VwReportRPLInvoice
-- Created: 2013-02-01 14:18:16.590 | Modified: 2013-02-01 14:25:05.233
-- =====================================================
CREATE View VwReportRPLInvoice
as
select 	B.NOBUKTI,D.TANGGAL, B.URUT, B.KODEBRG, B.PPN, B.DISC, B.KURS,D.NOSPB,D.NoSPP,E.Tanggal TglSPB,F.Tanggal TglSpp,
        B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.ISI, B.HARGA, B.DiscP1, B.DiscRp1,
        B.DiscP2, B.DiscRp2, B.DiscP3, B.DiscRp3, B.DiscP4, B.DiscRp4, B.DISCTOT,
        B.BYANGKUT, B.HRGNETTO, B.NDISKON, B.SUBTOTAL, B.NDPP, B.NPPN, B.NNET, B.SUBTOTALRp,
        B.NDPPRp, B.NPPNRp, B.NNETRp, B.NOInvoice, B.URUTInvoice, B.Keterangan,
        C.NamaBrg, B.QntTukar, B.Qnt2Tukar, B.netW, B.GrossW,
        'Nama Produk : '+c.Namabrg+' '+'Nama Komersil : '+ b.namabrg NamaProduk,
        D.KODECUSTSUPP,G.NAMACUSTSUPP
from	dbRInvoicePLDet B
left outer join dbBarang C on C.KodeBrg=B.KodeBrg
left outer join DBRInvoicePL D on B.NOBUKTI=D.NOBUKTI
Left Outer Join dbSPB E on D.NOSPB = E.NoBukti
Left Outer join dbSPP F on D.NoSPP = F.NoBukti
Left Outer join DBCUSTSUPP G on D.KODECUSTSUPP=G.KODECUSTSUPP



GO

-- View: VwReportSO
-- Created: 2013-06-03 13:59:19.797 | Modified: 2013-06-03 13:59:19.797
-- =====================================================
CREATE View [dbo].[VwReportSO]
as
Select 	A.NoBukti, A.NoSPB, B.UrutSPB,A.TANGGAL,I.KODECUSTSUPP,I.NAMACUSTSUPP,
	A.NoBukti+right('0000000000'+cast(B.Urut as varchar(10)),10) NoBuktiUrut,
        B.Urut, B.KodeBrg, H.NamaBrg,
        case when b.NOSAT=1 then B.Qnt else b.QNT2 end as qntjual,b.QNT, B.NoSat, B.Isi, H.Sat1 Satuan,
        B.Qnt2, H.Sat2 Satuan2, B.Harga,
        B.DiscP1,B.DiscTot,B.NDPP,a.KURS,a.KODEVLS,B.NDPPRp,B.NPPNRp,B.NNETRp,
        Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi 
From dbSO A
Left Outer join dbSODet B on B.NoBukti=a.NoBukti
Left Outer Join vwSatuanBrg H on H.KodeBrg=B.KodeBrg --and H.NoSat=B.NoSat
Left Outer join DBCUSTSUPP I on a.KODECUST = I.KODECUSTSUPP





GO

-- View: vwreportSOx
-- Created: 2013-01-18 16:28:26.957 | Modified: 2013-01-31 09:06:04.520
-- =====================================================


CREATE View [dbo].[vwreportSOx]
as
Select  A.NoBukti+right('00000'+cast(A.Urut as varchar(5)),5) KeyNoBukti, A.Nobukti, 
P.Tanggal, P.Kodecust KodeCustSupp, S.NamaCust NamaCustSupp,
A.urut, A.kodebrg, B.NamaBrg, A.Satuan, A.Isi,
A.Qnt, A.Qnt2, A.QntSPP, A.Qnt2SPP,
A.QntSisa, A.Qnt2Sisa,P.MasaBerlaku,P.NoPesanan,P.TglKirim,P.TGLJATUHTEMPO
From    vwBrowsOutSO_SPP A
Left Outer Join DBSO P on P.NoBukti=A.NoBukti
Left Outer Join vwBrowsCustomer S on S.KodeCust=P.KodeCust and S.Sales=P.KODESLS
Left Outer Join dbBarang B on B.KodeBrg=A.KodeBrg
where A.islengkap=0


GO

-- View: VwreportSPB
-- Created: 2013-06-03 14:10:02.747 | Modified: 2013-06-03 14:10:02.747
-- =====================================================


CREATE View [dbo].[VwreportSPB]
as
select 	B.NOBUKTI, B.URUT, B.NoSPP NoSC, B.UrutSPP UrutSC, B.KODEBRG, C.NAMABRG, '' Jns_Kertas, ''Ukr_Kertas,
        B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.ISI, B.NetW, B.GrossW, '' KetDetail,
        A.Tanggal,a.KodeCustSupp,D.NAMACUSTSUPP, 
		Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
		Case when A.IsOtorisasi2=1 then 1 else 0 end+
		Case when A.IsOtorisasi3=1 then 1 else 0 end+
		Case when A.IsOtorisasi4=1 then 1 else 0 end+
		Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
		else 1
		end As Bit)NeedOtorisasi
from	dbSPBDet B
left outer join dbBarang C on C.KodeBrg=B.KodeBrg
Left Outer join dbSPB A on B.NoBukti = A.NoBukti
Left Outer Join DBCUSTSUPP D on A.KodeCustSupp = D.KODECUSTSUPP



GO

-- View: VwreportSPBACC
-- Created: 2013-06-24 10:36:50.300 | Modified: 2013-06-24 14:54:37.000
-- =====================================================



CREATE View [dbo].[VwreportSPBACC]
as
select 	B.NOBUKTI, B.URUT, B.NoSPP NoSC, B.UrutSPP UrutSC, B.KODEBRG, C.NAMABRG, '' Jns_Kertas, ''Ukr_Kertas,
        B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.ISI, B.NetW, B.GrossW, '' KetDetail,
        A.Tanggal,a.KodeCustSupp,D.NAMACUSTSUPP, 
		Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
		Case when A.IsOtorisasi2=1 then 1 else 0 end+
		Case when A.IsOtorisasi3=1 then 1 else 0 end+
		Case when A.IsOtorisasi4=1 then 1 else 0 end+
		Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
		else 1
		end As Bit)NeedOtorisasi, B.HPP, B.HPP*B.QNT Total
from	dbSPBDet B
left outer join dbBarang C on C.KodeBrg=B.KodeBrg
Left Outer join dbSPB A on B.NoBukti = A.NoBukti
Left Outer Join DBCUSTSUPP D on A.KodeCustSupp = D.KODECUSTSUPP



GO

-- View: VwReportSPBRJual
-- Created: 2015-03-09 15:28:01.037 | Modified: 2015-03-11 09:53:07.033
-- =====================================================



CREATE View [dbo].[VwReportSPBRJual]
as
select 	B.NOBUKTI,D.TANGGAL, B.URUT, B.KODEBRG,D.Tanggal TglSPB,
        B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.ISI,
        'Nama Produk : '+c.Namabrg+' '+'Nama Komersil : '+ b.namabrg NamaProduk,
        D.KODECUSTSUPP,G.NAMACUSTSUPP,
		Cast(Case when Case when D.IsOtorisasi1=1 then 1 else 0 end+
		Case when D.IsOtorisasi2=1 then 1 else 0 end+
		Case when D.IsOtorisasi3=1 then 1 else 0 end+
		Case when D.IsOtorisasi4=1 then 1 else 0 end+
		Case when D.IsOtorisasi5=1 then 1 else 0 end=D.MaxOL then 0
		else 1
		end As Bit) Needotorisasi
        
from	dbSPBRJualDet B
left outer join dbBarang C on C.KodeBrg=B.KodeBrg
left outer join dbSPBRJual D on B.NOBUKTI=D.NOBUKTI
Left Outer join DBCUSTSUPP G on D.KODECUSTSUPP=G.KODECUSTSUPP


GO

-- View: VwReportSPP
-- Created: 2013-06-03 14:07:29.153 | Modified: 2013-06-03 14:07:29.153
-- =====================================================
CREATE View [dbo].[VwReportSPP]
as
select 	B.NOBUKTI, B.URUT, B.NoSO, B.UrutSO, B.KODEBRG, C.NAMABRG,D.Tanggal,D.KodeCustSupp,E.NAMACUSTSUPP,
        B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.ISI, B.NetW, B.GrossW, B.KetDetail,
        B.Nobukti+Cast(B.urut As Varchar(5)) MyKey,
        B.NamaBrg+Char(13)+'('+C.NamaBrg+')' NamaBrgKom,
        B.ShippingMark, Case when B.Nosat=1 then B.Sat_1 when B.nosat=2 then B.Sat_2 else '' end Satuan,
        D.NoPesan,D.TglKirim,B.Kodegdg,       
	Cast(Case when Case when D.IsOtorisasi1=1 then 1 else 0 end+
    Case when D.IsOtorisasi2=1 then 1 else 0 end+
    Case when D.IsOtorisasi3=1 then 1 else 0 end+
    Case when D.IsOtorisasi4=1 then 1 else 0 end+
    Case when D.IsOtorisasi5=1 then 1 else 0 end=D.MaxOL then 0
    else 1
    end As Bit) NeeDOtorisasi
from	dbSPPDet B
left outer join dbBarang C on C.KodeBrg=B.KodeBrg
Left Outer join dbSPP D on B.NoBukti = D.NoBukti
Left Outer join DBCUSTSUPP E on D.KodeCustSupp = E.KODECUSTSUPP





GO

-- View: VwreportSPPB
-- Created: 2013-01-30 15:52:51.043 | Modified: 2013-02-01 11:31:09.150
-- =====================================================

CREATE View [dbo].[VwreportSPPB]
as
Select A.*,B.NAMABRG NamaBarang,C.Tanggal,C.kodeCustSupp,D.NAMACUSTSUPP,
           A.Nobukti+Cast(A.Urut as varchar(5)) MyKey,Z.NOBUKTI Noso,Z.TANGGAL TanggalSO
from dbSPBDet A
     left outer join DBBARANG B on B.KODEBRG=A.Kodebrg
     Left Outer join dbSPB C on A.NoBukti = C.NoBukti
     Left Outer join DBCUSTSUPP D on c.KodeCustSupp = D.KODECUSTSUPP
     Left Outer join (Select x.NoBukti, x.NoSPP
                      from dbSPBDet x
                      group by x.NoBukti, x.NoSPP) y on y.NoBukti=C.NoBukti
     Left Outer Join (Select x.NoBukti, x.Tanggal,y.NoSO, x.TglKirim
                      from DBSPP x 
                        left outer join dbSPPDet y on y.NoBukti=x.NoBukti
                      Group by x.NoBukti, x.Tanggal,y.NoSO, x.TglKirim) v On v.NoBukti=y.NoSPP 
    left outer join DBSO Z on Z.NOBUKTI=v.NoSO
     


GO

-- View: VwReportSppx
-- Created: 2013-01-30 14:00:03.827 | Modified: 2013-01-31 11:09:43.957
-- =====================================================

CREATE View [dbo].[VwReportSppx]
as
Select  A.NoBukti+right('00000'+cast(A.Urut as varchar(5)),5) KeyNoBukti, A.Nobukti, P.Tanggal, P.KodeCustSupp, S.Namacust NamaCustSupp,
        A.urut, A.kodebrg, B.NamaBrg, '' Jns_Kertas, '' Ukr_Kertas, A.Sat_1, A.Sat_2, A.Isi,
        Case when A.NoSat=1 then A.Qnt
             when A.NoSat=2 then A.Qnt2
             else 0
        end Qnt, A.Qnt2,
        Case when A.NoSat=1 then A.QntSPB
             when A.NoSat=2 then A.Qnt2SPB
             else 0
        end QntSPB, A.Qnt2SPB,
        Case when A.NoSat=1 then A.QntSisa
             when A.NoSat=2 then A.Qnt2Sisa
             else 0
        end QntSisa, A.Qnt2Sisa,
        Case when A.NOSAT=1 then A.SAT_1
             when A.NOSAT=2 then A.SAT_2
             else ''
        end Satuan, P.Tglkirim,
        P.NoPesan
From    vwBrowsOutSPP A
Left Outer Join dbSPP P on P.NoBukti=A.NoBukti
left Outer join DBSO SO on SO.NOBUKTI=A.noso
Left Outer Join vwBrowsCustomer S on S.KodeCust=P.KodeCustSupp and s.Sales=SO.KODESLS
Left Outer Join dbBarang B on B.KodeBrg=A.KodeBrg
where A.isclose=0 
    


GO

-- View: VwReportSpRk
-- Created: 2013-06-03 14:17:57.390 | Modified: 2013-06-03 14:17:57.390
-- =====================================================


CREATE View [dbo].[VwReportSpRk]
as
Select 	A.Tanggal,B.NoBukti,A.KODEBRG KodeBrgJadi,i.NAMABRG NmBrgjadi,
	B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt, B.NoSat, B.Isi Isi, B.Satuan Satuan
	 ,Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi 
From dbSPKDet B 
Left Outer Join DbSPK A on  B.nobukti = A.nobukti
Left Outer join dbBarang H on H.KodeBrg=b.KodeBrg
Left Outer Join DBBARANG I on A.KODEBRG = I.KODEBRG


GO

-- View: vwReportStockBrg
-- Created: 2013-07-11 17:38:52.523 | Modified: 2013-07-11 17:38:52.523
-- =====================================================
CREATE view [dbo].[vwReportStockBrg]
as
Select  a.BULAN, a.TAHUN, a.KODEBRG, a.KODEGDG, a.QNTAWAL, a.HRGAWAL, 
	a.QNTPBL, a.QNT2PBL, a.HRGPBL, a.QNTRPB, a.QNT2RPB, a.HRGRPB, 
	a.QNTPNJ, a.QNT2PNJ, a.HRGPNJ, a.QNTRPJ, a.QNT2RPJ, a.HRGRPJ, 
	a.QNTADI, a.QNT2ADI, a.HRGADI, a.QNTADO, a.QNT2ADO, a.HRGADO, 
	a.QNTUKI, a.QNT2UKI, a.HRGUKI, a.QNTUKO, a.QNT2UKO, a.HRGUKO, 
	a.QNTTRI, a.QNT2TRI, a.HRGTRI, a.QNTTRO, a.QNT2TRO, a.HRGTRO,
	a.QNTPMK, a.QNT2PMK, a.HRGPMK, a.QNTRPK, a.QNT2RPK, a.HRGRPK,
	a.QntHPrd, a.Qnt2HPrd, a.HRGHPrd, 
	a.HRGRATA, a.QNTIN, a.QNT2IN, a.RPIN, a.QNTOUT, a.QNT2OUT, a.RPOUT, 
	a.SALDOQNT, a.SALDO2QNT, a.SALDORP, a.SaldoAV, a.Saldo2AV, 
	B.QntMin,B.QntMax,
    b.NAMABRG, c.NAMA Namagdg, b.SAT1, b.Sat2,B.ISI1,B.ISI2,B.ISI3,
    b.KODEGRP, b.KODESUBGRP
from DBSTOCKBRG a
     left outer join DBBARANG b on b.KODEBRG=a.KODEBRG --and b.Kodegdg=a.KODEGDG
     left outer join DBGUDANG c on c.KODEGDG=a.KODEGDG




GO

-- View: VwReporttransfer
-- Created: 2013-06-10 11:36:28.560 | Modified: 2013-06-10 11:36:28.560
-- =====================================================

Create View [dbo].[VwReporttransfer]
as
Select A.nobukti, a.NoUrut, a.Tanggal,  A.Note Keterangan, A.NoPenyerahan,
	 B.URUT,  B.KODEBRG, C.NAMABRG, '' Jns_Kertas, '' Ukr_Kertas,
    B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.ISI, B.GdgAsal, B.GdgTujuan, D.Nama+' ('+B.gdgAsal+')' NamagdgAsal,
    E.Nama+' ('+B.GdgTujuan+')' NamagdgTujuan,
    A.IsOtorisasi1, A.OtoUser1, A.TglOto1, A.IsOtorisasi2, A.OtoUser2, A.TglOto2,
	A.IsOtorisasi3, A.OtoUser3, A.TglOto3, A.IsOtorisasi4, A.OtoUser4, A.TglOto4,
	A.IsOtorisasi5, A.OtoUser5, A.TglOto5,
        Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                       Case when A.IsOtorisasi2=1 then 1 else 0 end+
                       Case when A.IsOtorisasi3=1 then 1 else 0 end+
                       Case when A.IsOtorisasi4=1 then 1 else 0 end+
                       Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                  else 1
             end As Bit) NeedOtorisasi
from dbTransfer a
Left Outer JOin DBTRANSFERDET B on A.NOBUKTI=B.NOBUKTI
left outer join dbBarang C on C.KodeBrg=B.KodeBrg
left outer join dbGudang D on d.Kodegdg=B.GdgAsal
left outer join dbgudang E on E.kodegdg=B.GdgTujuan






--select * from VwReporttransfer

GO

-- View: VwReportUbahKemasanBahan
-- Created: 2013-01-21 13:31:31.560 | Modified: 2013-01-21 13:31:31.560
-- =====================================================

create view [dbo].[VwReportUbahKemasanBahan]
as
Select * from vwDetailUbahKemasan where NoBukti Like '%KMS%'

GO

-- View: vwRepPO
-- Created: 2011-03-23 13:31:20.770 | Modified: 2011-11-04 09:11:15.923
-- =====================================================

CREATE View [dbo].[vwRepPO]
as
Select 	A.NOBUKTI, A.Tanggal, A.TglJatuhTempo, A.KodeCustSupp, C.NamaCustSupp, A.KodeVls, A.Kurs, 
	B.Urut, B.KODEBRG, D.NAMABRG, case when B.NoSat=1 then B.Qnt else B.Qnt2 end Qnt,
	case when B.NoSat=1 then D.SAT1 else D.Sat2 end Satuan, 
	B.HRGNETTO Harga, B.SUBTOTAL, B.NDPP, B.NPPN , B.NNET,
	E.SyaratPembayaran, E.SyaratPengiriman,
	A.Tipe, F.QntSisa, F.Qnt2Sisa, F.QntBeli, F.Qnt2Beli 
From 	DBPO A
Left Outer Join DBPODET B on B.NOBUKTI=A.NOBUKTI
Left Outer Join DBCUSTSUPP C on C.KODECUSTSUPP=A.KODECUSTSUPP 
Left Outer Join DBBARANG D on D.KODEBRG=B.KODEBRG
Left Outer Join DBNOTEPO E on E.NOBUKTI=A.NOBUKTI 
left Outer join vwOutPO F on F.Nobukti=B.NOBUKTI and F.urut=B.URUT







GO

-- View: vwRpDetBeli
-- Created: 2011-02-11 15:18:57.667 | Modified: 2011-03-03 12:04:22.160
-- =====================================================

CREATE View [dbo].[vwRpDetBeli]
as

Select 	NoBukti, Sum(SubTotal) TotSubTotal, Sum(NDiskon) TotDiskon, Sum(SubTotal)-Sum(NDiskon) TotTotal,
	Sum(NDPP) TotDPP, Sum(NPPN) TotPPN, SUm(NNet) TotNet, Sum(SubTotalRp) TotSubTotalRp, Sum(NDiskon*Kurs) TotDiskonRp,
	Sum(SubTotalRp)-Sum(NDiskon*Kurs) TotTotalRp, Sum(NDPPRp) TotDPPRp, Sum(NPPNRp) TotPPNRp, Sum(NNETRp) TotNetRp
From 	dbBeliDet
Group By NoBukti


GO

-- View: vwRpDetInvoicePL
-- Created: 2013-01-26 08:59:27.000 | Modified: 2013-01-26 08:59:27.000
-- =====================================================


CREATE View [dbo].[vwRpDetInvoicePL]
as

Select 	NoBukti, Sum(SubTotal) TotSubTotal, Sum(NDiskon) TotDiskon, Sum(SubTotal)-Sum(NDiskon) TotTotal,
	Sum(NDPP) TotDPP, Sum(NPPN) TotPPN, SUm(NNet) TotNet, Sum(SubTotalRp) TotSubTotalRp, Sum(NDiskon*Kurs) TotDiskonRp,
	Sum(SubTotalRp)-Sum(NDiskon*Kurs) TotTotalRp, Sum(NDPPRp) TotDPPRp, Sum(NPPNRp) TotPPNRp, Sum(NNETRp) TotNetRp
From 	dbInvoicePLDet
Group By NoBukti



GO

-- View: vwRpDetInvoiceRPJ
-- Created: 2013-06-03 11:07:48.253 | Modified: 2013-06-03 11:07:48.253
-- =====================================================

CREATE View [dbo].[vwRpDetInvoiceRPJ]
as
Select 	NoBukti, Sum(SubTotal) TotSubTotal, Sum(NDiskon) TotDiskon, Sum(SubTotal)-Sum(NDiskon) TotTotal,
	Sum(NDPP) TotDPP, Sum(NPPN) TotPPN, SUm(NNet) TotNet, Sum(SubTotalRp) TotSubTotalRp, Sum(NDiskon*Kurs) TotDiskonRp,
	Sum(SubTotalRp)-Sum(NDiskon*Kurs) TotTotalRp, Sum(NDPPRp) TotDPPRp, Sum(NPPNRp) TotPPNRp, Sum(NNETRp) TotNetRp
From 	DBINVOICERPJDet
Group By NoBukti


GO

-- View: vwRpDetPO
-- Created: 2011-02-11 15:18:57.603 | Modified: 2011-04-15 09:57:11.047
-- =====================================================







CREATE View [dbo].[vwRpDetPO]
as

Select 	NoBukti, Sum(Brutto) TotBrutto,Sum(SubTotal) TotSubTotal, Sum(NDISKONTOT) TotDiskon, Sum(SubTotal)-Sum(NDiskon) TotTotal,
	Sum(NDPP) TotDPP, Sum(NPPN) TotPPN, SUm(NNet) TotNet, Sum(SubTotalRp) TotSubTotalRp, Sum(NDISKONTOT*Kurs) TotDiskonRp,
	Sum(SubTotalRp)-Sum(NDISKONTOT*Kurs) TotTotalRp, Sum(NDPPRp) TotDPPRp, Sum(NPPNRp) TotPPNRp, Sum(NNETRp) TotNetRp
From 	dbo.dbPODet
Group By NoBukti







GO

-- View: vwRpDetRBeli
-- Created: 2011-02-11 15:18:57.607 | Modified: 2013-02-25 15:28:55.097
-- =====================================================

CREATE View [dbo].[vwRpDetRBeli]
as

Select 	NoBukti, Sum(SubTotal) TotSubTotal, Sum(NDiskon) TotDiskon, Sum(SubTotal)-Sum(NDiskon) TotTotal,
	Sum(NDPP) TotDPP, Sum(NPPN) TotPPN, SUm(NNet) TotNet, Sum(SubTotalRp) TotSubTotalRp, Sum(NDiskon*Kurs) TotDiskonRp,
	Sum(SubTotalRp)-Sum(NDiskon*Kurs) TotTotalRp, Sum(NDPPRp) TotDPPRp, Sum(NPPNRp) TotPPNRp, Sum(NNETRp) TotNetRp
From 	dbRBeliDet
Group By NoBukti


GO

-- View: vwRpDetRevPO
-- Created: 2011-04-15 15:32:59.090 | Modified: 2011-04-15 15:32:59.090
-- =====================================================








CREATE View [dbo].[vwRpDetRevPO]
as

Select 	NoBukti, Sum(Brutto) TotBrutto,Sum(SubTotal) TotSubTotal, Sum(NDISKONTOT) TotDiskon, Sum(SubTotal)-Sum(NDiskon) TotTotal,
	Sum(NDPP) TotDPP, Sum(NPPN) TotPPN, SUm(NNet) TotNet, Sum(SubTotalRp) TotSubTotalRp, Sum(NDISKONTOT*Kurs) TotDiskonRp,
	Sum(SubTotalRp)-Sum(NDISKONTOT*Kurs) TotTotalRp, Sum(NDPPRp) TotDPPRp, Sum(NPPNRp) TotPPNRp, Sum(NNETRp) TotNetRp
From 	dbo.dbRevPODet
Group By NoBukti








GO

-- View: vwRpDetRInvoicePL
-- Created: 2013-02-21 11:19:15.850 | Modified: 2013-02-21 11:25:32.217
-- =====================================================
CREATE VIEW dbo.vwRpDetRInvoicePL
AS
SELECT     NOBUKTI, SUM(SUBTOTAL) AS TotSubTotal, SUM(NDISKON) AS TotDiskon, SUM(SUBTOTAL) - SUM(NDISKON) AS TotTotal, SUM(NDPP) AS TotDPP, SUM(NPPN) 
                      AS TotPPN, SUM(NNET) AS TotNet, SUM(SUBTOTALRp) AS TotSubTotalRp, SUM(NDISKON * KURS) AS TotDiskonRp, SUM(SUBTOTALRp) - SUM(NDISKON * KURS) 
                      AS TotTotalRp, SUM(NDPPRp) AS TotDPPRp, SUM(NPPNRp) AS TotPPNRp, SUM(NNETRp) AS TotNetRp
FROM         dbo.DBRInvoicePLDET
GROUP BY NOBUKTI

GO

-- View: vwRpDetSO
-- Created: 2012-12-17 11:49:43.877 | Modified: 2012-12-17 11:49:43.877
-- =====================================================
CREATE View [dbo].[vwRpDetSO]
As

Select 	NoBukti, Sum(SubTotal) TotSubTotal, Sum(NDiskon) TotDiskon, Sum(SubTotal)-Sum(NDiskon) TotTotal,
	Sum(NDPP) TotDPP, Sum(NPPN) TotPPN, SUm(NNet) TotNet, Sum(SubTotalRp) TotSubTotalRp, Sum(NDiskon*Kurs) TotDiskonRp,
	Sum(SubTotalRp)-Sum(NDiskon*Kurs) TotTotalRp, Sum(NDPPRp) TotDPPRp, Sum(NPPNRp) TotPPNRp, Sum(NNETRp) TotNetRp,
	SUM(Qnt) Qnt, SUM(Qnt2) Qnt2
From 	dbSODet
Group By NoBukti






GO

-- View: vwRPemakaianBrg
-- Created: 2011-09-30 13:32:18.460 | Modified: 2011-12-20 21:12:52.710
-- =====================================================

CREATE View [dbo].[vwRPemakaianBrg]
as

SELECT a.Nobukti,b.Tanggal, a.kodebrg,c.NAMABRG,b.Kodebag,d.NamaBag,c.KodeJnsBrg,b.KodeJnsPakai,
e.Keterangan,a.Hpp,a.NNet,
Case when b.JnsPakai=0 then 'Stock'
	  when b.JnsPakai=1 then 'Investasi'
	  when b.JnsPakai=2 then 'Rep & Pem Teknik'
	  when b.JnsPakai=3 then 'Rep & Pem Komputer'
	  when b.JnsPakai=4 then 'Rep & Pem Peralatan'
end MyJnsPakai,b.JnsPakai
,case when a.Nosat = 1 then a.Sat_1 else a.Sat_2 end as satuan,
case when a.Nosat = 1 then a.Qnt else a.Qnt2 end as QNT,
case when a.Nosat = 1 then a.Qnt * a.Hpp else a.Qnt2 * a.Hpp end as total
FROM DBRPenyerahanBrgDET a 
left outer join DBRPenyerahanBrg b on a.Nobukti = b.Nobukti
left outer join DBBARANG c on a.kodebrg = c.KODEBRG
left outer join DBBAGIAN d on b.Kodebag = d.KodeBag
left outer join DBJNSPAKAI e on b.KodeJnsPakai = e.KodeJNSPakai


GO

-- View: vwRpenerimaanbrg
-- Created: 2011-11-03 17:37:08.547 | Modified: 2011-12-20 19:49:06.590
-- =====================================================
CREATE View [dbo].[vwRpenerimaanbrg]
as

select  a.NOBUKTI,b.TANGGAL,b.KODECUSTSUPP, d.NAMACUSTSUPP,a.KODEBRG,c.NAMABRG,a.Nosat,a.QNT,a.QNT2,a.SAT_1,a.SAT_2,f.NOPPL,c.ISJASA,c.KodeJnsBrg,
        isnull(z.tipe,0) Tipe,
        case when a.nosat =1 then a.sat_1 else a.sat_2 end as satuan,a.nnet,a.PPN,
        case when a.Nosat = 1 then a.QNT else a.QNT2 end as quantity,a.harga,b.KODEVLS,b.KURS,
        case when a.Nosat = 1 then a.QNT *  a.HARGA else a.QNT2 * a.HARGA end as jumlah,
        case when a.Nosat =1 then (a.QNT * a.HARGA) * a.KURS else (a.QNT2 * a.HARGA) * a.KURS end as NilaiDPp,a.NPPN,
        case when a.Nosat =1 then ((a.QNT * a.HARGA) * a.KURS) + a.nppn else ((a.QNT2 * a.HARGA) * a.KURS) + a.PPN end as total
from DBRBELIDET a 
     left outer join DBRBELI b on a.NOBUKTI = b.NOBUKTI
     left outer join DBBARANG c on a.KODEBRG = c.KODEBRG
     left outer join vwBrowsSupp d on b.KODECUSTSUPP = d.KODECUSTSUPP
     left outer join dbpo z on z.NOBUKTI=a.NOPO
     LEFT OUTER JOIN (select NoPPL, NOBUKTI NOPO, URUT URutPO
                      from DBPODET 
                      GRoup by NoPPL, NOBUKTI, URUT) f on f.NOPO=a.NOPO and f.URutPO=a.URUTPO
GO

-- View: vwSatuanBrg
-- Created: 2012-12-17 12:03:34.377 | Modified: 2012-12-17 12:03:34.377
-- =====================================================

CREATE View [dbo].[vwSatuanBrg]
As
select A.KODEBRG, A.NAMABRG ,A.SAT1, A.ISI1,A.Sat2,A.Isi2,A.KODEGRP, E.NAMA NamaGrp
from dbBarang A
     left outer join DBGROUP E on E.KODEGRP=A.KODEGRP

GO

-- View: vwSOBelumLengkap
-- Created: 2012-12-17 11:54:27.380 | Modified: 2012-12-17 11:54:27.380
-- =====================================================
CREATE View [dbo].[vwSOBelumLengkap]
As

select distinct A.NoBukti
from dbSODet A
left outer join DBSPPDET C on C.NOSO=A.NOBukti and C.UrutSO=A.Urut
group by A.NoBukti, A.Urut, A.Qnt, A.Qnt2
having	A.Qnt-sum(isnull(C.Qnt,0))>0 or A.Qnt2-sum(isnull(C.Qnt2,0))>0

GO

-- View: vwSOBelumSuratJln
-- Created: 2012-12-17 12:00:04.717 | Modified: 2013-01-28 13:16:29.067
-- =====================================================



CREATE  View [dbo].[vwSOBelumSuratJln]
As

select 	B.Kota KodeKota, B.kota NamaKota, A.NoBukti, A.Tanggal, A.KodeCust, B.NamaCustsupp, A.NoAlamatKirim, F.Alamat AlamatKirim,
	A.Catatan, A.KodeGdg, A.INSGdg, A.INSBrg, Cast(0 as Bit)IsPPN,a.Jam, A.FlagTipe, a.IsLengkap
from 	dbSO A
left outer join dbCustsupp B on B.KodeCustsupp=A.KodeCust
left outer join (select distinct NOSO from DBSPPDET) D on D.NOSO=A.NOBUKTI
left outer join vwSOBelumLengkap E on E.NoBukti=A.NOBUKTI
left outer join vwAlamatCust F on F.KodeCustSupp=A.KodeCust and F.Nomor=A.NoAlamatKirim
--where 	D.NoBukti is null or isnull(E.NOBUKTI,'')<>''
where 	A.NoUrut<>'BONUS' and (D.NoSO is null or isnull(E.NOBUKTI,'')<>'') and
      Masaberlaku>=GETDATE()
group by  B.Kota, A.NoBukti, A.Tanggal, A.KodeCust, B.NamaCustsupp, A.NoAlamatKirim, 
         F.Alamat, A.Catatan, A.KodeGdg, A.INSGdg, A.INSBrg,a.Jam, A.FlagTipe, A.IsLengkap




GO

-- View: vwSOBelumSuratJlnDet
-- Created: 2012-12-17 12:03:42.190 | Modified: 2013-01-28 13:16:38.063
-- =====================================================



CREATE View [dbo].[vwSOBelumSuratJlnDet]
As

select 	C0.Kota KodeKota, C0.Kota NamaKota, A0.KodeGdg, A.NoBukti, A0.Tanggal, A.Urut, A.KODEBRG, D.NamaBrg, 
	A.QNT, A.QNT2, A.NOSAT, D.Sat1 Satuan, A.ISI, D.Sat2 SatuanRoll,
	(isnull(C.Qnt,0)) QntSJ, (isnull(C.Qnt2,0)) Qnt2SJ, A.IsCetakKitir
from dbSODet A
left outer join dbSO A0 on A0.NoBukti=A.NoBukti
left outer join dbCustSupp C0 on C0.KodeCustsupp=A0.KodeCust
left outer join (Select x.noso,x.urutso,sum(x.Qnt) qnt,Sum(x.Qnt2) qnt2
                 from dbSPPDet x
                 group by x.noso,x.urutso) C on C.NOSO=A.NoBukti and C.UrutSO=A.Urut
left outer join vwSatuanBrg D on D.KodeBrg=A.KodeBrg
where A0.NoUrut<>'BONUS' and (not ((A.Qnt2<>0 and (A.Qnt2<=(isnull(C.Qnt2,0)))) or (A.Qnt2=0 and (A.Qnt<=(isnull(C.Qnt,0)))))) and
A0.masaberlaku>=GETDATE()



GO

-- View: vwSPB
-- Created: 2012-01-11 14:09:03.090 | Modified: 2013-04-05 09:57:54.077
-- =====================================================

CREATE view [dbo].[vwSPB]
as

Select x.NoBukti NoSPB, x.Tanggal TglSPB, y.NoSPP, y.TglSPP, '' Noship, null TglShip, w.NoSC, w.TglSC,0 IsLokal,
       x.KodeCustSupp, x.ISFlag
from (Select x.NoBukti,y.Tanggal, x.NoSPP, y.KodeCustSupp, y.ISFlag
      From DBSPBDet x           
           left Outer join DBSPB y on y.NoBukti=x.NoBukti
      Group by x.NoBukti,y.Tanggal, x.NoSPP, y.KodeCustSupp, y.ISFlag) x 
     
     left Outer Join (Select x.NoBukti NoSPP, y.Tanggal TglSPP, x.NoSO
                     from DBSPPDet x
                          left outer join DBSPP y on y.NoBukti=x.NoBukti
                     Group by x.NoBukti,y.Tanggal, x.NoSO) y on y.NoSPP=x.NoSPP
    left Outer join (Select x.Nobukti NoSC, y.Tanggal TglSC
                     From DBSODET x
                          left Outer join DBSO y on y.Nobukti=x.Nobukti
                     Group by x.Nobukti,y.Tanggal) w on w.NoSC=y.NoSO

GO

-- View: vwSPK
-- Created: 2014-04-14 11:18:42.560 | Modified: 2014-04-14 11:18:42.560
-- =====================================================

Create View [dbo].[vwSPK]
as
select NOBUKTI,NoUrut,TANGGAL,KODEBRG,NoBatch,TglExpired,Qnt,Nosat,Satuan,Isi,KodeBOM from DBSPK       
Union All
select NoBukti,Case When LEN(Urut)=1 Then '000'+CONVERT(Varchar(1),Urut)
                    When LEN(Urut)=2 Then '00'+CONVERT(Varchar(2),Urut) 
                    When LEN(Urut)=3 Then '0'+CONVERT(Varchar(3),Urut) end
      ,Null,KODEBRG,'',Null,Qnt,NOSAT,SATUAN,ISI,KodeBOMDet             from DBSPKDET  
      where Isnull(KodeBOMDet,'')<>''  


GO

-- View: vwStock
-- Created: 2013-06-03 11:09:47.540 | Modified: 2013-06-03 11:09:47.540
-- =====================================================

CREATE View [dbo].[vwStock]
as
SELECT 'AWL' AS tipe, '00' Prioritas, b.Kodebrg, b.Kodegdg, 
       (b.qntAwal) AS QntDB, (b.Qnt2Awal) Qnt2DB, (b.HrgAwal) HrgDebet, 
       0.00 QntCr,  0.00 Qnt2Cr, 0.00 HrgKredit,
       (b.qntAwal) AS QntSaldo, (b.Qnt2Awal) Qnt2Saldo, (b.HrgAwal) HrgSaldo, 
       Dateadd(MM, 0, Cast(CASE WHEN b.Bulan < 10 THEN '0' ELSE '' END + Cast(b.Bulan AS varchar(2))+'-01-'+ 
                           Cast(b.Tahun AS varchar(4)) AS Datetime)) Tanggal, b.Bulan, b.Tahun, 'Saldo Awal' Nobukti,
      '' KodeCustSupp, '' Keterangan, '' IDUSER, B.HRGRATA, '' Ket, 'BHN' xCode
FROM  DBSTOCKBRG b
where b.QNTAWAL<>0 or b.QNT2AWAL<>0
UNION all
Select 	'BP' Tipe, '01' Prioritas, B.KodeBrg, B.kodegdg,
          Case when B.NOSAT=1 then  B.Qnt 
               when B.NOSAT=2 then  B.Qnt*B.ISI
               else 0
          end  QntDb, 
          Case when B.NOSAT=1 then  B.Qnt/B.ISI 
               when B.NOSAT=2 then  B.Qnt
               else 0
          end Qnt2Db, B.NDPPRp HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	Case when B.NOSAT=1 then  B.Qnt 
               when B.NOSAT=2 then  B.Qnt*B.ISI
               else 0
          end  QntSaldo, 
          Case when B.NOSAT=1 then  B.Qnt/B.ISI 
               when B.NOSAT=2 then  B.Qnt
               else 0
          end Qnt2Saldo, B.NDPPRp HrgSaldo,
	A.TANGGAL , month(A.TANGGAL) Bulan, year(A.TANGGAL) Tahun, A.NoBukti,
	A.KODESUPP, d.NAMACUSTSUPP Keterangan, '' IDUser,
	case when Case when B.Nosat=1 then B.QNT 
	               when B.Nosat=2 then B.QNT/B.ISI
	          end=0 then 0.00 
	    else B.NDPPRp/Case when B.Nosat=1 then B.QNT 
	                       when B.Nosat=2 then B.QNT*B.ISI
	                  end end HPP,d.NAMACUSTSUPP ket, 'BHN' xCode
from 	dbBeli A
left outer join dbBeliDet B on B.NoBukti=A.NoBukti
left outer join DBBARANG C on C.KODEBRG=B.KodeBrg
left outer join vwBrowsSupp d on d.KODECUSTSUPP=A.KODESUPP
union all
Select 	'RPB' Tipe, '10' Prioritas, B.KodeBrg, A.KODEGDG,
          0.00 QntDb, 0.00 Qnt2Db, 0.00 HrgDebet,
	Case when B.NOSAT=1 then  B.Qnt 
               when B.NOSAT=2 then  B.Qnt*B.ISI
               else 0
          end QntCr, 
          Case when B.NOSAT=1 then  B.Qnt/B.ISI 
               when B.NOSAT=2 then  B.Qnt
               else 0
          end Qnt2Cr, B.NDPPRp HrgKredit,
	-Case when B.NOSAT=1 then  B.Qnt 
               when B.NOSAT=2 then  B.Qnt*B.ISI
               else 0
          end QntSaldo, 
          -Case when B.NOSAT=1 then  B.Qnt/B.ISI 
               when B.NOSAT=2 then  B.Qnt
               else 0
          end Qnt2Saldo, -B.NDPPRp HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	A.KodeSupp, d.NAMACUSTSUPP Keterangan, '' IDUser,
	case when Case when B.Nosat=1 then B.QNT 
	               when B.Nosat=2 then B.QNT/B.ISI
	          end=0 then 0.00 
	    else B.NDPPRp/Case when B.Nosat=1 then B.QNT 
	                       when B.Nosat=2 then B.QNT*B.ISI 
	                  end end HPP,d.NAMACUSTSUPP Ket, 'BHN' xCode
from 	dbRBeli A
left outer join dbRBeliDet B on B.NoBukti=A.NoBukti
left outer join DBBARANG C on C.KODEBRG=B.KodeBrg
left outer join vwBrowsSupp d on a.KODESUPP = d.KODECUSTSUPP
union all
Select 	'BPPB' Tipe, '00' Prioritas, B.KodeBrg, A.KodeGdg, 
          0.00 QntDb, 0.00 Qnt2Db, (B.Qnt*B.HPP) HrgDebet,
	B.Qnt  QntCr, B.Qnt2 Qnt2Cr, (B.Qnt*B.HPP) HrgKredit,
	-B.Qnt QntSaldo, -B.Qnt2 Qnt2Saldo, -(B.Qnt*B.HPP) HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	'' KodeCustSupp, '' Keterangan, '' IDUser,
	B.HPP,'' Ket, 'BHN' xCode
from DBBPPBT A
left outer join DBBPPBTDET B on B.NoBukti=A.NoBukti
union all
Select 	'BPPBT' Tipe, '00' Prioritas, B.KodeBrg, A.KodeGdgT, 
          B.Qnt QntDb, B.Qnt2 Qnt2Db,(B.Qnt*B.HPP) HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	B.Qnt QntSaldo, B.Qnt2 Qnt2Saldo, (B.Qnt*B.HPP) HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	'' KodeCustSupp, '' Keterangan, '' IDUser,
	B.HPP,'' Ket, 'BHN' xCode
from DBBPPBT A
left outer join DBBPPBTDET B on B.NoBukti=A.NoBukti
union all
Select 'BPB' Tipe, '02' Prioritas, B.KodeBrg, A.KODEGDG, 
       0.00 QntDb, 0.00 Qnt2Db,0 HrgDebet,
       B.Qnt QntCr, B.Qnt2 Qnt2Cr, (B.Qnt*B.HPP) HrgKredit,
       -B.Qnt QntSaldo, -B.Qnt2 Qnt2Saldo, -(B.Qnt*B.HPP) HrgSaldo,
       A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
       '' KodeCustSupp, '' Keterangan,'' IDUser,
       B.HPP,'' Ket, 'BHN' xCode
from DBPenyerahanBhn A
left outer join DBPenyerahanBhnDET B on B.NoBukti=A.NoBukti
left Outer join DBBARANG E on E.KODEBRG=B.kodebrg
union all
Select 	'RBPB' Tipe, '02' Prioritas, B.KodeBrg,A.KODEGDG,
          B.Qnt QntDb, B.Qnt2 Qnt2Db,(B.Qnt*B.HPP) HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	B.Qnt QntSaldo, B.Qnt2 Qnt2Saldo, (B.Qnt*B.HPP) HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	'' KodeCustSupp, '' Keterangan, '' IDUser,
          B.HPP,'' Ket, 'BHN' xCode
from DBRPenyerahanBhn A
left outer join DBRPenyerahanBhnDET B on B.NoBukti=A.NoBukti
left Outer join DBBARANG E on E.KODEBRG=B.kodebrg
union all
Select 	'ADI' Tipe, '03' Prioritas, B.KodeBrg, A.kodegdg,
          Case when B.NOSAT=1 then  B.QNTDB 
               when B.NOSAT=2 then  B.QNTDB*B.ISI
               else 0
          end QntDb, 
          Case when B.NOSAT=1 then  B.QNTDB/B.ISI 
               when B.NOSAT=2 then  B.QNTDB
               else 0
          end Qnt2Db, 
          Case when B.NOSAT=1 then  B.QNTDB 
               when B.NOSAT=2 then  B.QNTDB*B.ISI
               else 0
          end*B.Harga HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	Case when B.NOSAT=1 then  B.QNTDB 
               when B.NOSAT=2 then  B.QNTDB*B.ISI
               else 0
          end QntSaldo, 
          Case when B.NOSAT=1 then  B.QNTDB/B.ISI 
               when B.NOSAT=2 then  B.QNTDB
               else 0
          end Qnt2Saldo, 
          Case when B.NOSAT=1 then  B.QNTDB 
               when B.NOSAT=2 then  B.QNTDB*B.ISI
               else 0
          end*B.Harga HrgSaldo, 
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	'' KodeCustSupp, '' Keterangan, '' IDUser,
	B.Harga HPP,'' Ket, 'BHN' xCode
from 	dbKoreksi A
left outer join dbKoreksiDet B on B.NoBukti=A.NoBukti
where 	B.QntDb<>0
union all
Select 	'ADO' Tipe, '11' Prioritas, B.KodeBrg,A.KodeGdg, 
          0.00 QntDb, 0.00 Qnt2Db, 0.00 HrgDebet,
	Case when B.NOSAT=1 then  B.QNTCR 
               when B.NOSAT=2 then  B.QNTCR*B.ISI
               else 0
          end QntCr, 
          Case when B.NOSAT=1 then  B.QNTCR/B.ISI 
               when B.NOSAT=2 then  B.QNTCR
               else 0
          end Qnt2Cr, B.QntCr*B.HPP HrgKredit,
	-Case when B.NOSAT=1 then  B.QNTCR 
               when B.NOSAT=2 then  B.QNTCR*B.ISI
               else 0
          end QntSaldo, 
          -Case when B.NOSAT=1 then  B.QNTCR/B.ISI 
               when B.NOSAT=2 then  B.QNTCR
               else 0
          end Qnt2Saldo,          
          -Case when B.NOSAT=1 then  B.QNTCR/B.ISI 
               when B.NOSAT=2 then  B.QNTCR
               else 0
          end*B.HPP HrgSaldo, 
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	'' KodeCustSupp, '' Keterangan, '' IDUser,
	B.HPP,'' Ket, 'BHN' xCode
from 	dbKoreksi A
left outer join dbKoreksiDet B on B.NoBukti=A.NoBukti
where 	B.QntCr<>0
union ALL
Select 	'PRD' Tipe, '03' Prioritas, B.KodeBrg, B.kodegdg,
          Case when B.NOSAT=1 then  B.QNT 
               when B.NOSAT=2 then  B.QNT*B.ISI
               else 0
          end QntDb, 
          Case when B.NOSAT=1 then  B.QNT/B.ISI 
               when B.NOSAT=2 then  B.QNT
               else 0
          end Qnt2Db, 
          Case when B.NOSAT=1 then  B.QNT/B.ISI  
               when B.NOSAT=2 then  B.QNT
               else 0
          end*isnull(c.HPPBrg,0) HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	Case when B.NOSAT=1 then  B.QNT 
               when B.NOSAT=2 then  B.QNT*B.ISI
               else 0
          end QntSaldo, 
          Case when B.NOSAT=1 then  B.QNT/B.ISI 
               when B.NOSAT=2 then  B.QNT
               else 0
          end Qnt2Saldo, 
          Case when B.NOSAT=1 then  B.QNT/B.ISI  
               when B.NOSAT=2 then  B.QNT
               else 0
          end*isnull(C.HPPBrg,0) HrgSaldo, 
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	'' KodeCustSupp, '' Keterangan, '' IDUser,
	isnull(c.HPPBrg,0) HPP,'' Ket, 'BHN' xCode
from 	DBHASILPRD A
left outer join DBHASILPRDDET B on B.NoBukti=A.NoBukti
left Outer join dbHPPProduksi C on C.KodeBrg=B.KODEBRG and C.Bulan=month(A.Tanggal) and c.Tahun=year(A.Tanggal)
where 	B.Qnt<>0
union All
Select 	'TRI' Tipe, '05' Prioritas, B.KodeBrg, B.GDGTUJUAN,
		B.QNT QNTDB, B.QNT2 QNT2DB,(B.QNT*B.HPP) HRGDEBET,
		0.00 QNTCR, 0.00 QNT2CR, 0.00 HRGKREDIT,
		B.QNT QNTSALDO, B.QNT2 QNT2SALDO, (B.QNT*B.HPP) HRGSALDO,
		A.TANGGAL, MONTH(A.TANGGAL) BULAN, YEAR(A.TANGGAL) TAHUN, A.NOBUKTI,
		A.IDUSER KODECUSTSUPP,A.IDUSER KETERANGAN, A.IDUSER,
		B.HPP,A.IDUSER KET, 'BHN' xCode
from DBTRANSFER A
left outer join DBTRANSFERDET B on B.NoBukti=A.NoBukti
union all
Select 	'TRO' Tipe, '13' Prioritas, B.KodeBrg, B.GDGASAL,
		0.00 QntDb, 0.00 Qnt2Db,0.00 HrgDebet,
		B.Qnt  QntCr, B.Qnt2 Qnt2Cr, (B.Qnt*B.HPP) HrgKredit,
		-B.Qnt QntSaldo, -B.Qnt2 Qnt2Saldo, -(B.Qnt*B.HPP) HrgSaldo,
		A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
		A.iduser KodeCustSupp, a.IDUser Keterangan, A.IDUser,
		B.HPP,a.IDUser Ket, 'BHN' xCode
from DBTRANSFER A
left outer join DBTRANSFERDET B on B.NoBukti=A.NoBukti
union All
Select 	'SPB' Tipe, '05' Prioritas, B.KodeBrg,B.Kodegdg,
		0.00 QNTDB, 0.00 QNT2DB,0.00 HRGDEBET,
		B.QNT QNTCR, B.QNT2 QNT2CR, (B.QNT*B.HPP) HRGKREDIT,
		-B.QNT QNTSALDO, -B.QNT2 QNT2SALDO, -(B.QNT*B.HPP) HRGSALDO,
		A.TANGGAL, MONTH(A.TANGGAL) BULAN, YEAR(A.TANGGAL) TAHUN, A.NOBUKTI,
		A.IDUSER KODECUSTSUPP,A.IDUSER KETERANGAN, A.IDUSER,
		B.HPP,D.NAMACUSTSUPP KET, 'BHN' xCode
from DBSPB A
left outer join dbSPBDet B on B.NoBukti=A.NoBukti
Left Outer join vwBrowsCust D on D.KODECUSTSUPP=A.KodeCustSupp
union all
Select 	'RSPB' Tipe, '05' Prioritas, B.KodeBrg,A.Kodegdg,
		B.QNT QNTDB, B.QNT2 QNT2DB,(B.QNT*B.HPP) HRGDEBET,
		0.00 QNTCR, 0.00 QNT2CR, 0.00 HRGKREDIT,
		B.QNT QNTSALDO, B.QNT2 QNT2SALDO, (B.QNT*B.HPP) HRGSALDO,
		A.TANGGAL, MONTH(A.TANGGAL) BULAN, YEAR(A.TANGGAL) TAHUN, A.NOBUKTI,
		A.IDUSER KODECUSTSUPP,A.IDUSER KETERANGAN, A.IDUSER,
		B.HPP,A.IDUSER KET, 'BHN' xCode
from DBRSPB A
left outer join DBRSPBDet B on B.NoBukti=A.NoBukti
union all
Select 	'RSPB' Tipe, '04' Prioritas, B.KodeBrg,B.Kodegdg,
		B.QNT QNTDB, B.QNT2 QNT2DB,(B.QNT*B.HPP) HRGDEBET,
		0.00 QNTCR, 0.00 QNT2CR, 0.00 HRGKREDIT,
		B.QNT QNTSALDO, B.QNT2 QNT2SALDO, (B.QNT*B.HPP) HRGSALDO,
		A.TANGGAL, MONTH(A.TANGGAL) BULAN, YEAR(A.TANGGAL) TAHUN, A.NOBUKTI,
		A.IDUSER KODECUSTSUPP,A.IDUSER KETERANGAN, A.IDUSER,
		B.HPP,A.IDUSER KET, 'BHN' xCode
from dbSPBRJual A
left outer join dbSPBRJualDet B on B.NoBukti=A.NoBukti
union All
Select 	'INVC' Tipe, '05' Prioritas, B.KodeBrg,C.KodeGdg,
		B.QNT QNTDB, B.QNT2 QNT2DB,(B.QNT*B.HPP) HRGDEBET,
		0.00 QNTCR, 0.00 QNT2CR, 0.00 HRGKREDIT,
		B.QNT QNTSALDO, B.QNT2 QNT2SALDO, (B.QNT*B.HPP ) HRGSALDO,
		A.TANGGAL, MONTH(A.TANGGAL) BULAN, YEAR(A.TANGGAL) TAHUN, A.NOBUKTI,
		A.KODECUSTSUPP,D.NAMACUSTSUPP KETERANGAN, '' IDUSER,
		B.HPP,'' KET, 'BHN' xCode
from DBInvoicePL A
left outer join dbInvoicePLDet B on B.NoBukti=A.NoBukti
left Outer join (Select Kodegdg, NoBukti,Urut 
                 from dbSPBDet 
                 Group by Kodegdg, NoBukti,Urut) C on C.NoBukti=B.NoSPB and C.Urut=B.UrutSPB
Left Outer join vwBrowsCust D on D.KODECUSTSUPP=A.KodeCustSupp
union all
Select 	'RINVC' Tipe, '05' Prioritas, B.KodeBrg,''KodeGdg,
		B.QNT QNTDB, B.QNT2 QNT2DB,(B.QNT*B.HPP) HRGDEBET,
		0.00 QNTCR, 0.00 QNT2CR, 0.00 HRGKREDIT,
		B.QNT QNTSALDO, B.QNT2 QNT2SALDO, (B.QNT*B.HPP ) HRGSALDO,
		A.TANGGAL, MONTH(A.TANGGAL) BULAN, YEAR(A.TANGGAL) TAHUN, A.NOBUKTI,
		A.KODECUSTSUPP,D.NAMACUSTSUPP KETERANGAN, '' IDUSER,
		B.HPP,'' KET, 'BHN' xCode
from DBInvoiceRPJ A
left outer join DBINVOICERPJDet B on B.NoBukti=A.NoBukti
Left Outer join vwBrowsCust D on D.KODECUSTSUPP=A.KodeCustSupp


GO

-- View: vwSubCost
-- Created: 2014-09-11 10:45:06.320 | Modified: 2014-11-10 09:31:16.043
-- =====================================================






CREATE View [dbo].[vwSubCost]
as

Select cast('KEND' as varchar(20)) KodeCost, 
	A.KODEKEND KodeSubCost,
	A.NAMAKEND NamaSubCost
from DBKENDARAAN A     

union all

Select cast('SALES' as varchar(20)) KodeCost, 
	cast(A.KeyNIK as varchar(20)) KodeSubCost,
	A.Nama NamaSubCost
from dbKaryawan A     
where KodeCost = 'SALES'





GO

-- View: vwSubJenis
-- Created: 2011-11-23 18:45:57.690 | Modified: 2011-11-23 22:20:52.767
-- =====================================================

CREATE View [dbo].[vwSubJenis]
as
Select A.*, B.Keterangan NamaJnsBrg,
       B.Keterangan+Case when B.Keterangan is null then '' else ' ('+B.KodeJnsBrg+')' end myJenis
from DBSUBJENIS A     
     left Outer join DBJenis B on B.KodeJnsBrg=A.KodeJnsBrg


GO

-- View: vwSubJenisJadi
-- Created: 2011-12-08 19:36:36.830 | Modified: 2011-12-08 19:36:36.830
-- =====================================================


CREATE View [dbo].[vwSubJenisJadi]
as
Select A.*       
from DBSUBJENISBRGJADI A     



GO

-- View: vwSubKategori
-- Created: 2011-11-23 18:45:57.643 | Modified: 2011-11-23 22:19:45.500
-- =====================================================

CREATE View [dbo].[vwSubKategori]
as
Select A.*,B.Keterangan NamaKategori,
       B.Keterangan+Case when B.Keterangan is null then '' else ' ('+B.KodeKategori+')' end myKategori
from DBSUBKATEGORI A     
     left Outer join DBKATEGORI B on B.KodeKategori=A.KodeKategori


GO

-- View: vwSubKategoriJadi
-- Created: 2011-12-08 19:36:36.863 | Modified: 2011-12-08 19:36:36.863
-- =====================================================


CREATE View [dbo].[vwSubKategoriJadi]
as
Select A.*
from DBSUBKATEGORIBRGJADI A



GO

-- View: vwSumberAktivitasUser
-- Created: 2011-06-01 13:55:38.677 | Modified: 2011-06-01 13:55:38.677
-- =====================================================




CREATE  View [dbo].[vwSumberAktivitasUser]
as
Select 1 Urutan, 'USR' KodeSumber, 'Pemakai' NamaSumber
union all Select 5 Urutan, 'GDG' KodeSumber, 'Gudang' NamaSumber
union all Select 8 Urutan, 'GRP' KodeSumber, 'Group Brg' NamaSumber
union all Select 10 Urutan, 'BRG' KodeSumber, 'Barang' NamaSumber
union all Select 13 Urutan, 'SUP' KodeSumber, 'Supplier' NamaSumber
union all Select 15 Urutan, 'ARE' KodeSumber, 'Area' NamaSumber
union all Select 17 Urutan, 'SSA' KodeSumber, 'Sub Area' NamaSumber
union all Select 30 Urutan, 'KOT' KodeSumber, 'Kota/ Kab.' NamaSumber
union all Select 33 Urutan, 'KEC' KodeSumber, 'Kecamatan' NamaSumber
union all Select 35 Urutan, 'DES' KodeSumber, 'Desa/ Kel.' NamaSumber
union all Select 40 Urutan, 'SLS' KodeSumber, 'Salesman' NamaSumber
union all Select 46 Urutan, 'JCU' KodeSumber, 'Jenis Cust' NamaSumber
union all Select 48 Urutan, 'LCU' KodeSumber, 'Lokasi Cust' NamaSumber
union all Select 50 Urutan, 'CUS' KodeSumber, 'Customer' NamaSumber
union all Select 60 Urutan, 'PO' KodeSumber, 'P.O' NamaSumber
union all Select 63 Urutan, 'PBL' KodeSumber, 'Pembelian' NamaSumber
union all Select 70 Urutan, 'RPB' KodeSumber, 'Retur Beli' NamaSumber
union all Select 80 Urutan, 'SO' KodeSumber, 'S.O' NamaSumber
union all Select 83 Urutan, 'PNJ' KodeSumber, 'Penjualan' NamaSumber
union all Select 86 Urutan, 'RPJ' KodeSumber, 'Retur Jual' NamaSumber
union all Select 88 Urutan, 'PT' KodeSumber, 'Lunas Piutang' NamaSumber
union all Select 90 Urutan, 'OPN' KodeSumber, 'Opname' NamaSumber
union all Select 93 Urutan, 'TRS' KodeSumber, 'Transfer Brg' NamaSumber
union all Select 96 Urutan, 'KMS' KodeSumber, 'U Kemas' NamaSumber
union all Select 100 Urutan, 'LN' KodeSumber, 'Lain-lain' NamaSumber
















GO

-- View: vwSumberJurnal
-- Created: 2014-10-01 09:10:32.290 | Modified: 2014-10-01 09:10:32.290
-- =====================================================



CREATE  View [dbo].[vwSumberJurnal]
as

select '010' MyUrut, 'PBL' JenisTrans, 'Pembelian' NamaTrans, 'DBBELI' NamaTabel
union all select '015' MyUrut, 'BPL' JenisTrans, 'Invoice Pembelian' NamaTrans, 'DBINVOICE' NamaTabel
union all select '020' MyUrut, 'RPB' JenisTrans, 'Retur Pembelian' NamaTrans, 'DBRBELI' NamaTabel
union all select	'030' MyUrut, 'DN' JenisTrans, 'Debet Note' NamaTrans, 'DBDEBETNOTE' NamaTabel
union all select	'040' MyUrut, 'SPB' JenisTrans, 'Surat Jalan' NamaTrans, 'DBSPB' NamaTabel
union all select	'045' MyUrut, 'RSPB' JenisTrans, 'Retur Surat Jalan' NamaTrans, 'DBSPB' NamaTabel
union all select	'050' MyUrut, 'INVC' JenisTrans, 'Invoice Penjualan' NamaTrans, 'DBINVOICEPL' NamaTabel
union all select	'060' MyUrut, 'SPR' JenisTrans, 'Retur Penjualan' NamaTrans, 'DBINVOICERPJ' NamaTabel
union all select	'065' MyUrut, 'RPJ' JenisTrans, 'Nota Retur Penjualan' NamaTrans, 'DBINVOICERPJ' NamaTabel
union all select	'070' MyUrut, 'KN' JenisTrans, 'Kredit Note' NamaTrans, 'DBKREDITNOTE' NamaTabel
union all select	'120' MyUrut, 'HPD' JenisTrans, 'Hasil Produksi' NamaTrans, 'DBHASILPRD' NamaTabel
union all select	'080' MyUrut, 'BP' JenisTrans, 'Pemakaian' NamaTrans, 'DBPENYERAHANBHN' NamaTabel
union all select	'090' MyUrut, 'RBP' JenisTrans, 'Retur Pemakaian' NamaTrans, 'DBRPENYERAHANBHN' NamaTabel
union all select	'110' MyUrut, 'KMS' JenisTrans, 'Ubah Kemasan' NamaTrans, 'DBUBAHKEMASAN' NamaTabel
union all select	'100' MyUrut, 'OPN' JenisTrans, 'Koreksi/ Opname' NamaTrans, 'DBKOREKSI' NamaTabel








GO

-- View: vwTransaksi
-- Created: 2014-10-01 09:46:46.430 | Modified: 2015-04-20 09:05:02.913
-- =====================================================



CREATE VIEW [dbo].[vwTransaksi]
AS
SELECT A.NOBUKTI, A.NOURUT, A.TANGGAL, B.DEVISI, A.NOTE, A.LAMPIRAN, 
	A.IsOtorisasi1, A.OtoUser1, A.TglOto1, A.IsOtorisasi2, A.OtoUser2, A.TglOto2, 
	A.IsOtorisasi3, A.OtoUser3, A.TglOto3, A.IsOtorisasi4, A.OtoUser4, A.TglOto4, 
    A.IsOtorisasi5, A.OtoUser5, A.TglOto5, A.MaxOL,
	B.URUT, B.PERKIRAAN, B.LAWAN, B.KETERANGAN, B.KETERANGAN2, B.DEBET, B.KREDIT, B.VALAS, B.KURS, B.DEBETRP, B.KREDITRP, 
    B.TIPETRANS, B.TPHC, B.CUSTSUPPP, B.CUSTSUPPL, B.KODEP, B.KODEL, 
    B.NOAKTIVAP, B.NOAKTIVAL, B.STATUSAKTIVAP, B.STATUSAKTIVAL, B.NOBON, B.KODEBAG, 
    B.STATUSGIRO, A.JENIS FlagJenis, B.TipeTrans Jenis, '' NoBuktiTrans, 'T' AsalTrans, B.KODECOST, B.KODESUBCOST   
FROM DBTRANS A 
LEFT OUTER JOIN DBTRANSAKSI B ON B.NOBUKTI = A.NOBUKTI
UNION ALL
Select A.NoBukti, A.NOURUT, A.Tanggal, A.Devisi, A.Note, A.Lampiran, 
	A.IsOtorisasi1, A.OtoUser1, A.TglOto1, A.IsOtorisasi2, A.OtoUser2, A.TglOto2, 
	A.IsOtorisasi3, A.OtoUser3, A.TglOto3, A.IsOtorisasi4, A.OtoUser4, A.TglOto4, 
    A.IsOtorisasi5, A.OtoUser5, A.TglOto5, A.MaxOL,
    A.Urut, A.Perkiraan, A.Lawan, A.Keterangan, A.Keterangan2, A.Debet, A.Kredit, A.Valas, A.Kurs, A.DebetRp, A.KreditRp, 
	A.TipeTrans, A.TPHC, A.CustSuppP, A.CustSuppL, A.KodeP, A.KodeL, 
	A.NoAktivaP, A.NoAktivaL, A.StatusAktivaP, A.StatusAktivaL, A.Nobon, A.KodeBag, 
	A.StatusGiro, '1' FlagJENIS, A.Jenis, A.NoBuktiTrans, 'O' AsalTrans, '' KodeCost, '' KodeSubCost
--From vwPostJurnalOto a
from DBJurnalOto A





GO

-- View: vwTransInvoice
-- Created: 2014-09-30 10:36:57.350 | Modified: 2015-04-21 15:22:56.833
-- =====================================================


CREATE View [dbo].[vwTransInvoice]
As

select A.NOBUKTI, A.NOURUT, A.TANGGAL, A.TglJatuhTempo, A.KODESUPP KODECUSTSUPP,
	Cs.NAMACUSTSUPP,
	Cs.ALAMATKOTA Alamat, Cs.ALAMATKOTA, Cs.KOTA, Cs.NamaKota, 
	A.NoPO, B.KodeGdg KodeGdg, G.NAMA NamaGdg, A.KETERANGAN, A.NOFAKTUR, 
	A.KODEVLS, A.KURS, A.PPN, A.TIPEBAYAR, A.HARI, A.TipeDisc, A.DISC, A.DISCRP, 
	A.IsBatal, A.UserBatal, A.TglBatal, 
	A.KodeExp, Ex.NAMACUSTSUPP NamaExp, Ex.ALAMATKOTA AlamatKotaExp, 
	A.CetakKe, A.IDUser,
	A.IsOtorisasi1, A.OtoUser1, A.TglOto1, 
	A.IsOtorisasi2, A.OtoUser2, A.TglOto2, 
	A.IsOtorisasi3, A.OtoUser3, A.TglOto3, 
	A.IsOtorisasi4, A.OtoUser4, A.TglOto4, 
	A.IsOtorisasi5, A.OtoUser5, A.TglOto5,
	Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                       Case when A.IsOtorisasi2=1 then 1 else 0 end+
                       Case when A.IsOtorisasi3=1 then 1 else 0 end+
                       Case when A.IsOtorisasi4=1 then 1 else 0 end+
                       Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                  else 1
             end As Bit) NeedOtorisasi, 
	A.NoJurnal, A.NoUrutJurnal, A.TglJurnal, A.MaxOL, 
	A.Flagtipe, A.TipePPN, A.NoInvoice, A.TglInvoice, A.NoFakturPajak, A.TglFakturPajak, A.NoBuktiPotong, A.TglBuktiPotong, 
	B.URUT, B.KODEBRG, Br.NAMABRG, isnull(B.NAMABRG,'') KetNamaBrg, 
	Br.NAMABRG+case when ISNULL(B.NamaBrg,'')='' then '' else CHAR(13)+B.NAMABRG end NamaBrgPlus,
	Br.NFix, B.QNT, B.NOSAT, B.SATUAN, B.SAT_1, B.SAT_2, B.ISI,
	Br.SAT1, Br.SAT2, Br.ISI1, Br.ISI2, 
	B.HARGA, B.DISCP, B.DISCTOT, B.BYANGKUT, 
	B.UrutPO, B.HPP, B.QntTerima, B.Qnt1Terima, B.Qnt2Terima, 
	B.HRGNETTO, B.NDISKON, B.SUBTOTAL, B.NDPP, B.NPPN, B.NNET,
	case when A.KODEVLS='IDR' then 0 else B.NDISKON end NDISKOND,
	case when A.KODEVLS='IDR' then 0 else B.SUBTOTAL end SUBTOTALD,
	case when A.KODEVLS='IDR' then 0 else B.NDPP end NDPPD,
	case when A.KODEVLS='IDR' then 0 else B.NPPN end NPPND,
	case when A.KODEVLS='IDR' then 0 else B.NNET end NNETD, 
	B.NDISKONRp, 
	B.SUBTOTALRp, B.NDPPRp, B.NPPNRp, B.NNETRp, B.NoBeli, B.UrutBeli, 
	B.KetReject, B.DiscP2, B.DiscP3, B.DiscP4, B.DiscP5,
	B.Qnt2Terima Qnt2, B.Qnt1Terima Qnt1,
	B.NoSPJ
from DBINVOICE A
left outer join DBInvoiceDET B on B.NOBUKTI=A.NOBUKTI
left outer join vwCUSTSUPP Cs on Cs.KODECUSTSUPP=A.KODESUPP
left outer join vwBarang Br on Br.KODEBRG=B.KodeBrg
left outer join vwCUSTSUPP Ex on Ex.KODECUSTSUPP=A.KodeExp
left outer join DBGUDANG G on G.KODEGDG=B.KodeGdg







GO

-- View: VwTransInvoiceRPJ
-- Created: 2014-09-24 13:32:30.643 | Modified: 2014-09-24 13:32:30.643
-- =====================================================
Create view VwTransInvoiceRPJ
as
select A.NoBukti, A.NoUrut, A.Tanggal, A.TglJatuhTempo, A.KODECUSTSUPP, Cs.NAMACUSTSUPP,
	Cs.ALAMAT Alamat, Cs.ALAMATKOTA, Cs.KOTA, Cs.NamaKota,
	A.NoInvoice, A.TglInvoice, A.NORPJ, A.KODEVLS, A.KURS, A.PPN, A.TIPEBAYAR, A.HARI, A.IDUser,
	A.Catatan, 
	A.IsOtorisasi1, A.OtoUser1, A.TglOto1, 
	A.IsOtorisasi2, A.OtoUser2, A.TglOto2, 
	A.IsOtorisasi3, A.OtoUser3, A.TglOto3, 
	A.IsOtorisasi4, A.OtoUser4, A.TglOto4, 
	A.IsOtorisasi5, A.OtoUser5, A.TglOto5,
	Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                       Case when A.IsOtorisasi2=1 then 1 else 0 end+
                       Case when A.IsOtorisasi3=1 then 1 else 0 end+
                       Case when A.IsOtorisasi4=1 then 1 else 0 end+
                       Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                  else 1
             end As Bit) NeedOtorisasi,   
	A.NoJurnal, A.NoUrutJurnal, A.TglJurnal, A.IsFlag, A.MaxOL,
	A.IsCetak, A.CetakKe, A.KodeSls, K.NAMA NamaSls, 
	A.IsBatal, A.UserBatal, A.TglBatal, A.Flagtipe, A.TipePPN,
	B.Urut, B.Kodebrg, Br.NAMABRG, B.NamaBrg NamaBrgKom,  B.NOSPR, B.UrutSPR, 
	B.SAT_1 Satuan, Br.SAT1, Br.SAT2, Br.NFix, 
	B.Qnt, B.Qnt2, B.Nosat, B.Isi, Br.ISI1, Br.ISI2, 
	B.Harga, B.DiscP, B.DiscRp, B.DISCTOT, B.HRGNETTO, 
	B.NDISKON, B.SUBTOTAL, B.NDPP, B.NPPN, B.NNET,
	case when A.KODEVLS='IDR' then 0 else B.NDISKON end NDISKOND,
	case when A.KODEVLS='IDR' then 0 else B.SUBTOTAL end SUBTOTALD,
	case when A.KODEVLS='IDR' then 0 else B.NDPP end NDPPD,
	case when A.KODEVLS='IDR' then 0 else B.NPPN end NPPND,
	case when A.KODEVLS='IDR' then 0 else B.NNET end NNETD, 
	 B.SUBTOTALRp, B.NDPPRp, B.NPPNRp, B.NNETRp, 
	B.Keterangan, B.UrutTrans, B.HPP, B.DiscP2, B.DiscP3, B.DiscP4, B.DiscP5
from DBINVOICERPJ A
left outer join DBINVOICERPJDet B on B.NoBukti=A.NoBukti
left outer join vwCUSTSUPP Cs on Cs.KODECUSTSUPP=A.KodeCustSupp
left outer join vwBarang Br on Br.KODEBRG=B.KodeBrg
left outer join dbKaryawan K on K.KeyNIK=A.KODESLS






--select * from DBINVOICERPJ
--alter table DBINVOICERPJ add catatan Varchar(200)
--alter table DBINVOICERPJ add iscetak Bit
--alter table DBINVOICERPJ add CetakKe INteger
--alter table DBINVOICERPJ add TipePPN Tinyint
--alter table dbinvoicerpjdet add NamaBrg varchar(200)


GO

-- View: vwTransSPBRJual
-- Created: 2014-09-24 09:35:19.397 | Modified: 2014-11-19 15:34:40.567
-- =====================================================



CREATE View [dbo].[vwTransSPBRJual]
As

select A.NoBukti, A.NoUrut, A.Tanggal, A.NoRPJ, A.NoSO, A.KodeCustSupp, Cs.NAMACUSTSUPP,
	Cs.ALAMATKOTA Alamat, Cs.ALAMATKOTA, Cs.KOTA, Cs.NamaKota,
	A.NoPolKend, A.Container, A.NoContainer, A.NoSeal, A.Sopir, A.Catatan, 
	A.IsCetak, A.CetakKe, A.IDUser, A.IsClose, A.IsFlag, 
	A.IsOtorisasi1, A.OtoUser1, A.TglOto1, 
	A.IsOtorisasi2, A.OtoUser2, A.TglOto2, 
	A.IsOtorisasi3, A.OtoUser3, A.TglOto3, 
	A.IsOtorisasi4, A.OtoUser4, A.TglOto4, 
	A.IsOtorisasi5, A.OtoUser5, A.TglOto5,
	Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                       Case when A.IsOtorisasi2=1 then 1 else 0 end+
                       Case when A.IsOtorisasi3=1 then 1 else 0 end+
                       Case when A.IsOtorisasi4=1 then 1 else 0 end+
                       Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                  else 1
             end As Bit) NeedOtorisasi, 
	A.NoJurnal, A.NoUrutJurnal, A.TglJurnal, A.MaxOL, 
	A.IsBatal, A.UserBatal, A.TglBatal, A.FlagTipe, A.TipePPN,
	B.Urut, B.Noinv, B.UrutInv, B.KodeBrg, Br.NAMABRG, B.Namabrg NamaBrgKom, Br.NFix, 
	B.QNT, B.QNT1, B.QNT2, B.SAT_1 Satuan, B.SAT_1, B.SAT_2, Br.SAT1, Br.SAT2, B.NOSAT, B.ISI, Br.ISI1, Br.ISI2, 
	B.NetW, B.GrossW, B.HPP, B.KodeGdg, G.NAMA NamaGdg, B.HPP*B.QNT1 NilaiHPP,A.Kodegdg KodeGdgHD,H.NAMA NamaGDGHD
	,B.Nobatch
from dbSPBRJual A
left outer join dbSPBRJualDet B on B.NoBukti=A.NoBukti
left outer join vwCUSTSUPP Cs on Cs.KODECUSTSUPP=A.KodeCustSupp
left outer join vwBarang Br on Br.KODEBRG=B.KodeBrg
left outer join DBGUDANG G on G.KODEGDG=B.KodeGdg
Left Outer Join DBGUDANG H on A.KodeGdg=H.KODEGDG





GO

-- View: vwValas
-- Created: 2011-12-08 20:45:04.003 | Modified: 2011-12-08 20:45:04.003
-- =====================================================
Create View dbo.vwValas
as
Select A.KODEVLS,A.NAMAVLS,A.Simbol,B.Tanggal,B.Kurs 
from dbVALAS A
     left Outer join DBVALASDET B on B.Kodevls=A.KODEVLS
GO

-- View: VwVerifikasi
-- Created: 2011-06-16 14:40:19.047 | Modified: 2011-06-16 14:40:19.047
-- =====================================================
CREATE VIEW dbo.VwVerifikasi
AS
SELECT     NOBUKTI AS noBP, TANGGAL AS tglbp, NOSPB, TGLSPB, KODECUSTSUPP
FROM         dbo.DBBELI AS a

GO

-- View: vwAktiva
-- Created: 2011-11-22 16:29:11.903 | Modified: 2011-11-23 22:32:53.300
-- =====================================================


CREATE View [dbo].[vwAktiva]
as
select A.*,C.Keterangan KelAktiva,D.Keterangan NamaAkumulasi,
       E.Keterangan NamaBiaya,F.Keterangan NamaBiaya2,
       G.Keterangan NamaBiaya3,H.Keterangan NamaBiaya4,
       Case when A.Tipe='L' then 'Garis Lurus'
            when A.Tipe='M' then 'Menurun'
            when A.Tipe='P' then 'Pajak'
            else ''
       end Mytipe,
       I.NamaBag,
       C.Keterangan+Case when C.Keterangan is null then '' else ' ('+C.Perkiraan+')' end myAktiva,
       D.Keterangan+Case when D.Keterangan is null then '' else ' ('+D.Perkiraan+')' end myAkumulasi,
       E.Keterangan+Case when E.Keterangan is null then '' else ' ('+E.Perkiraan+')' end myBiaya,
       F.Keterangan+Case when F.Keterangan is null then '' else ' ('+F.Perkiraan+')' end myBiaya2,
       G.Keterangan+Case when G.Keterangan is null then '' else ' ('+G.Perkiraan+')' end myBiaya3,
       H.Keterangan+Case when H.Keterangan is null then '' else ' ('+H.Perkiraan+')' end myBiaya4,
       I.NamaBag+Case when I.NamaBag is null then '' else ' ('+I.KodeBag+')' end myBagian
from DBAKTIVA A
     left Outer join DBPOSTHUTPIUT B on B.Perkiraan=A.NoMuka
     Left Outer join DBPERKIRAAN C on C.Perkiraan=B.Perkiraan and C.Perkiraan=A.NoMuka
     left Outer join DBPERKIRAAN D on D.Perkiraan=A.Akumulasi
     left Outer join DBPERKIRAAN E on E.Perkiraan=A.Biaya
     left Outer join DBPERKIRAAN F on F.Perkiraan=A.Biaya2
     left Outer join DBPERKIRAAN G on G.Perkiraan=A.biaya3
     left Outer join DBPERKIRAAN H on H.Perkiraan=A.biaya4
     Left Outer join DBBAGIAN I on I.KodeBag=A.Kodebag


GO

-- View: vwAktivitasUser
-- Created: 2011-06-01 13:57:10.550 | Modified: 2011-06-01 13:57:10.550
-- =====================================================




CREATE  View [dbo].[vwAktivitasUser]
as

select  A.Tahun, A.Bulan, A.Tanggal, A.Pemakai, A.Aktivitas,
        cast(case when A.Aktivitas='I' then 'Tambah' when A.Aktivitas='U' then 'Koreksi'
        when A.Aktivitas='D' then 'Hapus' when A.Aktivitas='C' then 'Cetak' else '' end as varchar(50)) NamaAktivitas,
        isnull(B.NamaSumber,'') Sumber, A.NoBukti, 
	cast(case when A.Aktivitas='I' then 'Tambah --> ' 
                  when A.Aktivitas='U' then 'Koreksi --> '
                  when A.Aktivitas='D' then 'Hapus --> ' 
                  when A.Aktivitas='C' then 'Cetak' 
                  when A.Aktivitas='CI' then 'Cetak Surat Jalan' 
                  else '' 
             end+A.Keterangan as text) Keterangan
from    dbLogFile A
left outer join vwSumberAktivitasUser B on B.KodeSumber=A.Sumber












GO

-- View: vwAlamatCust
-- Created: 2011-10-19 13:42:21.707 | Modified: 2011-10-19 13:42:21.707
-- =====================================================
Create View [dbo].[vwAlamatCust]
As
select *
from 	dbAlamatCust A














GO

-- View: vwBagian
-- Created: 2011-12-08 20:19:04.703 | Modified: 2011-12-08 20:21:12.023
-- =====================================================
CREATE View vwBagian
As
Select A.*, 
       B.Keterangan+' ('+A.Perkiraan+')' NamaPerkiraan,
       C.Keterangan+' ('+A.Biaya+')' NamaBiaya
from DBBAGIAN A
     Left Outer Join DBPERKIRAAN B on B.Perkiraan=A.Perkiraan
     left Outer join DBPERKIRAAN C on C.Perkiraan=A.Biaya
     
 
GO

-- View: vwBarang
-- Created: 2014-04-14 10:19:02.520 | Modified: 2014-09-30 10:44:52.933
-- =====================================================




CREATE View [dbo].[vwBarang]
as
     
select	A.KODEBRG, A.NAMABRG, A.KODEGRP, B.NAMA NamaGrp, A.KODESUBGRP, C.NamaSubGrp, 
	A.KodeSupp,
	A.SAT1, A.ISI1, A.SAT2, A.ISI2, A.SAT3, A.ISI3,
	A.NFix, cast(case when A.NFix=0 then 'Tetap' else 'Tidak Tetap' end as varchar(30)) MyNFix,
	A.Hrg1_1, A.Hrg2_1, A.Hrg3_1, A.Hrg1_2, A.Hrg2_2, A.Hrg3_2, A.Hrg1_3, A.Hrg2_3, A.Hrg3_3,
	A.QntMin, A.QntMax, A.ISAKTIF, cast(case when A.ISAKTIF=1 then 'Aktif' else 'Non Aktif' end as varchar(50)) MyAktif,
	A.Keterangan, A.NamaBrg2,
	A.Tolerate, A.Proses, A.IsTakeIn,
	CAST(1 as int) IsBeli, CAST(1 as int) IsJual, A.IsBarang,ISNULL(IsJasa,0) Isjasa
from	DBBARANG A
left outer join DBGROUP B on B.KODEGRP=A.KODEGRP
left outer join dbSubGroup C on C.KodeSubGrp=A.KODESUBGRP and C.KodeGrp=B.KODEGRP and C.KodeGrp=A.KODEGRP




GO

-- View: vwBarangJadi
-- Created: 2011-12-08 19:44:29.550 | Modified: 2011-12-08 19:46:02.463
-- =====================================================

CREATE View [dbo].[vwBarangJadi]
as     
Select A.*, B.Keterangan NamaKelompok, C.Keterangan NamaKategori, 
       D.Keterangan NamaSubKategori, E.Keterangan NamaJenis,
       F.Keterangan NamaSubJenis,
       B.Keterangan+Case when B.Keterangan is null then '' else ' ('+B.KodeKelompok+')' end myKelompok,
       C.Keterangan+Case when C.Keterangan is null then '' else ' ('+C.KodeKategori+')' end myKategori,
       D.Keterangan+Case when D.Keterangan is null then '' else ' ('+D.KodeSubKategori+')' end mySubKategori,
       E.Keterangan+Case when E.Keterangan is null then '' else ' ('+E.KodeJnsBrg+')' end myJenis,
       F.Keterangan+Case when F.Keterangan is null then '' else ' ('+F.kodesubJnsBrg+')' end mySubJenis
from DBBARANGJADI A
     left outer join DBKELOMPOK B on B.KodeKelompok=A.KodeKelompok
     left outer join DBKATEGORIBRGJADI C on C.KodeKategori=A.KodeKategori
     left outer join DBSUBKATEGORIBRGJADI D on D.KodeSubKategori=A.KodeSubKategori
     Left Outer join DBJENISBRGJADI E on E.KodeJnsBrg=A.KodeJnsBrg
     left outer join DBSUBJENISBRGJADI F on F.kodesubJnsBrg=A.kodesubJnsBrg


GO

-- View: vwBon
-- Created: 2011-12-02 15:35:10.873 | Modified: 2011-12-08 20:16:04.513
-- =====================================================
Create View Dbo.vwbon
as
select A.*,B.Keterangan NamaPerkiraan
from DBBON A
     left Outer join DBPERKIRAAN B on B.Perkiraan=A.Perkiraan
     
GO

-- View: vwBonBelumLunas
-- Created: 2011-12-01 15:50:39.063 | Modified: 2011-12-01 15:50:39.063
-- =====================================================
Create View dbo.vwBonBelumLunas
as
Select Nobukti,SUM(Debet-Kredit) Saldo
from DBBON
Group by NoBukti
Having SUM(Debet-Kredit)>0
GO

-- View: vwBrgInspeksi
-- Created: 2011-02-11 15:18:57.623 | Modified: 2011-03-03 11:58:14.430
-- =====================================================

CREATE  View [dbo].[vwBrgInspeksi]
as
select a.KodeBrg,d.NamaBrg,a.NoBukti,a.Qnt,a.Qnt2,d.Toleransi From dbPODet a
left Outer join dbPPLdet b on a.NoPPL=b.NoBukti and a.UrutPPL=b.Urut
Left Outer join dbPermintaanBrgdet c on c.NoBukti=b.NoPermintaan and c.Urut=b.UrutPermintaan 
Left Outer Join dbBarang d on d.KodeBrg=C.KodeBrg
where c.IsInspeksi=1


GO

-- View: vwBrowsCust
-- Created: 2012-04-12 14:22:41.437 | Modified: 2014-03-05 13:33:24.170
-- =====================================================



CREATE View [dbo].[vwBrowsCust]
as

Select 	A.KODECUSTSUPP, A.NAMACUSTSUPP, A.ALAMAT1, A.ALAMAT2, 
    case when isnull(A.Alamat2,'')='' then A.Alamat1 else A.Alamat1+char(13)+A.Alamat2 end Alamat,
	A.kota kodeKota,  A.Kota, 
	A.TELPON, A.FAX, A.EMAIL, A.KODEPOS, A.NEGARA, A.NPWP, A.Tanggal, A.PLAFON, A.HARI, A.HARIHUTPIUT, 
	A.BERIKAT, A.USAHA, D.PERKIRAAN, JENIS, A.NAMAPKP, A.ALAMATPKP1, A.ALAMATPKP2, A.KOTAPKP, A.Sales, A.KodeVls, A.KodeTipe, A.IsPpn,
	A.Agent,case when isnull(A.Alamat2A,'')='' then A.Alamat1A else A.Alamat1A+char(13)+A.Alamat2A end AlamatA,
	A.KotaA, A.NegaraA, A.ContactP, B.IsBeliJual, B.IsLokalorExim,
	case when isnull(A.ALAMATPKP2,'')='' then A.ALAMATPKP1 else A.ALAMATPKP1+char(13)+A.ALAMATPKP2 end AlamatPKP,	   
	C.Keterangan NamaPerkiraan,A.IsAktif,Isnull(A.PPN,0) PPN
From 	dbo.DBCUSTSUPP A
      left Outer join DBPERKCUSTSUPP D on D.KodeCustSupp=A.KODECUSTSUPP
      Left Outer Join DBPOSTHUTPIUT B on B.Perkiraan=D.PERKIRAAN
      Left Outer Join dbo.DBPERKIRAAN C on C.Perkiraan=B.PERKIRAAN
where B.Kode='PT'



GO

-- View: vwBrowsCustomer
-- Created: 2014-02-19 10:17:43.023 | Modified: 2014-02-19 10:18:47.700
-- =====================================================


CREATE  View [dbo].[vwBrowsCustomer]
As

select	A.KODECUSTSupp kodecust, A.NAMACUSTSUPP namaCust, ltrim(A.ALAMAT1+case when ltrim(A.ALAMAT2)<>'' then char(13)+A.ALAMAT2 else '' end+
	case when ltrim(isnull(A.KOTA,''))<>'' then char(13)+isnull(A.KOTA,'')+' '+A.KodePos else '' end) ALAMAT, 
	A.Kota kodekota, a.Kota NAMAKOTA, A.TELPON, A.PLAFON, A.HARI, A.Hari HARIPIUTANG, 
	A.USAHA, A.PERKIRAAN, A.JENIS, C.KeyNik Sales, D.Nama NAMASLS, A.KODEEXP, E.NAMAEXP, A.KODETIPE, a.IsPpn,a.PPN
from	dbCustSupp A
left outer join DBSALESCUSTOMER C on c.KodeCustSupp=a.KODECUSTSUPP
Left Outer join dbKaryawan D on d.KeyNIK=C.KeyNik
left outer join dbExpedisi E on E.KodeExp=A.KodeExp



GO

-- View: vwBrowsCustSupp
-- Created: 2014-07-15 11:35:06.730 | Modified: 2014-07-15 11:35:06.730
-- =====================================================

CREATE View [dbo].[vwBrowsCustSupp]
as

--select  A.KodeCustSupp, A.Urut, A.Perkiraan, B.Kode,
--	CS.NAMACUSTSUPP, CS.ALAMAT1, CS.ALAMAT2, CS.NamaKota, CS.NEGARA,
--	CS.ALAMATKOTA, CS.HARI, CS.HARIHUTPIUT, 
--	cast(CS.IsPpn as int) IsPPN, CS.IsAktif 
--from DBPERKCUSTSUPP A
--left outer join DBPOSTHUTPIUT B on B.Perkiraan=A.Perkiraan
--left outer join vwCUSTSUPP CS on CS.KODECUSTSUPP=A.KodeCustSupp



select B.Kode, A.Perkiraan, A.Urut, Cs.*,
	CAST(case when Cs.Jenis=0 then 1 else 0 end as tinyint) IsSupplier, 
	CAST(case when Cs.Jenis=1 then 1 else 0 end as tinyint) IsCustomer,
	CAST(case when Cs.Jenis=3 then 1 else 0 end as tinyint) IsExpedisi 
from vwCUSTSUPP Cs
left outer join DBPERKCUSTSUPP A on A.KodeCustSupp=Cs.KODECUSTSUPP
left outer join DBPOSTHUTPIUT B on B.Perkiraan=A.Perkiraan






GO

-- View: vwBrowsExpedisi
-- Created: 2013-07-15 12:07:22.207 | Modified: 2013-07-15 12:07:22.207
-- =====================================================




CREATE View [dbo].[vwBrowsExpedisi]
as

Select 	A.KODECUSTSUPP, A.NAMACUSTSUPP, A.ALAMAT1, A.ALAMAT2, 
    case when isnull(A.Alamat2,'')='' then A.Alamat1 else A.Alamat1+char(13)+A.Alamat2 end Alamat,
	A.kota kodeKota,  A.Kota, 
	A.TELPON, A.FAX, A.EMAIL, A.KODEPOS, A.NEGARA, A.NPWP, A.Tanggal, A.PLAFON, A.HARI, A.HARIHUTPIUT, 
	A.BERIKAT, A.USAHA, D.PERKIRAAN, JENIS, A.NAMAPKP, A.ALAMATPKP1, A.ALAMATPKP2, A.KOTAPKP, A.Sales, A.KodeVls, A.KodeTipe, A.IsPpn,
	A.Agent,case when isnull(A.Alamat2A,'')='' then A.Alamat1A else A.Alamat1A+char(13)+A.Alamat2A end AlamatA,
	A.KotaA, A.NegaraA, A.ContactP, B.IsBeliJual, B.IsLokalorExim,
	case when isnull(A.ALAMATPKP2,'')='' then A.ALAMATPKP1 else A.ALAMATPKP1+char(13)+A.ALAMATPKP2 end AlamatPKP,	   
	C.Keterangan NamaPerkiraan,A.IsAktif
From 	dbo.DBCUSTSUPP A
      left Outer join DBPERKCUSTSUPP D on D.KodeCustSupp=A.KODECUSTSUPP
      Left Outer Join DBPOSTHUTPIUT B on B.Perkiraan=D.PERKIRAAN
      Left Outer Join dbo.DBPERKIRAAN C on C.Perkiraan=B.PERKIRAAN
where a.Jenis=3





GO

-- View: vwBrowsOutBeli
-- Created: 2014-09-30 10:50:10.880 | Modified: 2014-09-30 10:50:10.880
-- =====================================================

Create View [dbo].[vwBrowsOutBeli]
as

Select 	*
From 	vwOutBeli
where 	QntSisa>0
	and NilaiOL=MaxOL
	
GO

-- View: vwBrowsOutBP_Inspeksi
-- Created: 2011-06-09 10:49:13.820 | Modified: 2011-06-09 10:49:13.820
-- =====================================================

CREATE View [dbo].[vwBrowsOutBP_Inspeksi]
as
select	Nobukti, urut, NoPO, UrutPO, kodebrg, Sat_1, Sat_2, Isi, Qnt, Qnt2, QntBatal, Qnt2Batal, QntIns, Qnt2Ins, QntSisaIns, Qnt2SisaIns, QntSisa, Qnt2Sisa, Nosat
From 	dbo.vwOutBP_Inspeksi 
where 	QntSisa>0 and Qnt2Sisa>0

GO

-- View: vwBrowsOutInspeksi
-- Created: 2011-02-11 15:18:57.647 | Modified: 2011-06-09 10:49:36.440
-- =====================================================


CREATE View [dbo].[vwBrowsOutInspeksi]
as

Select 	NoBukti, Urut, KodeBrg, Qnt, Qnt2, QntSJ, Qnt2SJ, QntSisa, Qnt2Sisa 
From 	vwOutInspeksi 
where 	QntSisa>0 and Qnt2Sisa>0



GO

-- View: vwBrowsOutInvoicePL
-- Created: 2014-09-24 10:57:31.803 | Modified: 2023-05-21 15:46:07.900
-- =====================================================





CREATE View [dbo].[vwBrowsOutInvoicePL]
as

Select 	*
From 	vwOutInvoicePL
where 	QntSisa>0
	and NilaiOL=MaxOL
	








GO

-- View: vwBrowsOutPermintaanBrg
-- Created: 2011-04-15 09:19:43.173 | Modified: 2011-08-04 15:52:02.820
-- =====================================================

CREATE VIEW [dbo].[vwBrowsOutPermintaanBrg]
AS
SELECT     Nobukti, urut, kodebrg,Nosat, Sat_1, Sat_2, Isi, Qnt, Qnt2, TglTiba, isInspeksi, 
		QntBPB, Qnt2BPB, QntBBP, Qnt2BBP, QntPPL, Qnt2PPL,QntBPL, Qnt2BPL, 
		QntSisaBPB, Qnt2SisaBPB, QntSisa, Qnt2Sisa, Keterangan
FROM         dbo.vwOutPermintaanBrg
where (QntSisaBPB>0) or (Qnt2SisaBPB>0)




GO

-- View: vwBrowsOutPO
-- Created: 2011-05-05 15:41:59.303 | Modified: 2011-09-16 08:43:29.070
-- =====================================================
CREATE View [dbo].[vwBrowsOutPO]
as

Select 	Nobukti, urut, NoPPL, UrutPPL, kodebrg, Sat_1, Sat_2, Isi, Qnt, Qnt2, QntBatal, Qnt2Batal, 
	QntBeli, Qnt2Beli, QntSisaBeli, Qnt2SisaBeli, QntSisa, Qnt2Sisa, ISNULL(QntTukar,0) QntTukar, ISNULL(Qnt2Tukar,0) Qnt2Tukar 
From 	dbo.vwOutPO 
where 	QntSisa>0 and Qnt2Sisa>0

GO

-- View: vwBrowsOutPO_BP
-- Created: 2011-05-05 15:41:13.570 | Modified: 2011-07-08 10:15:14.470
-- =====================================================

CREATE View [dbo].[vwBrowsOutPO_BP]
as

Select 	NoBukti, Urut, NoPPL, UrutPPL, NoInspeksi, UrutInspeksi, KodeBrg, Sat_1, Sat_2, Isi, Qnt, Qnt2, QntBatal, Qnt2Batal, 
	QntBeli, Qnt2Beli, QntSisaBeli, Qnt2SisaBeli, QntSisa, Qnt2Sisa, Nosat, Catatan
From 	vwOutPO_BP 
where 	QntSisa>0 Or Qnt2Sisa>0






GO

-- View: vwBrowsOutPO_Inspeksi
-- Created: 2011-05-05 15:43:00.673 | Modified: 2011-05-05 15:43:00.673
-- =====================================================



CREATE View [dbo].[vwBrowsOutPO_Inspeksi]
as

select	Nobukti, urut, NoPPL, UrutPPL, kodebrg, Sat_1, Sat_2, Isi, Qnt, Qnt2, QntBatal, Qnt2Batal, QntIns, Qnt2Ins, QntSisaIns, Qnt2SisaIns, QntSisa, Qnt2Sisa, Nosat
From 	dbo.vwOutPO_Inspeksi 
where 	QntSisa>0 and Qnt2Sisa>0




GO

-- View: vwBrowsOutPPL
-- Created: 2011-06-04 09:49:45.283 | Modified: 2011-06-14 10:45:25.447
-- =====================================================

CREATE VIEW [dbo].[vwBrowsOutPPL]
AS
SELECT     Nobukti, urut, kodebrg, Sat_1, Sat_2, Isi, Qnt, Qnt2, TglTiba, NoPermintaan, UrutPermintaan, QntBatal, Qnt2Batal, 
			QntPO, Qnt2PO, QntBtlPO, Qnt2BtlPO, QntSisaPO, 
            Qnt2SisaPO, QntSisa, Qnt2Sisa, NamaBag,  tglbutuh, keterangan, isInspeksi, nosat, Pelaksana
FROM         dbo.vwOutPPL
WHERE     (QntSisa > 0) AND (Qnt2Sisa > 0)
GO

-- View: vwBrowsOutRJual
-- Created: 2013-02-05 11:19:05.787 | Modified: 2014-03-05 13:37:21.173
-- =====================================================

CREATE View [dbo].[vwBrowsOutRJual]
as
Select 	NoBukti, Urut, KodeBrg, Sat_1, Sat_2, NoSat, Isi, Qnt, Qnt2, 
	QntSPB, Qnt2SPB, QntSisa, Qnt2Sisa,NetW,GrossW, noinvoice,UrutInvoice, namabrg, isFlag	
From 	vwOutRjual 
where 	QntSisa>0 and Qnt2Sisa>0


GO

-- View: vwBrowsOutSC_SPP
-- Created: 2011-07-07 12:42:23.803 | Modified: 2011-09-21 17:53:17.807
-- =====================================================




CREATE View [dbo].[vwBrowsOutSC_SPP]
as

Select 	NoBukti, Urut, KodeBrg, Sat_1, Sat_2, NoSat, Isi, Qnt, Qnt2, 
	QntSPP, Qnt2SPP, QntSisa, Qnt2Sisa, NamabrgKom 
From 	vwOutSC_SPP 
where 	QntSisa>0 and Qnt2Sisa>0







GO

-- View: vwBrowsOutShip
-- Created: 2011-08-19 15:32:18.683 | Modified: 2011-08-19 15:33:47.903
-- =====================================================

CREATE View [dbo].[vwBrowsOutShip]
as

Select 	NoBukti, Urut, KodeBrg,Namabrg, Sat_1, Sat_2, NoSat, Isi, Qnt, Qnt2, 
	QntSPB, Qnt2SPB, QntSisa, Qnt2Sisa,NetW,GrossW, NoSC
From 	vwOutShip 
where 	QntSisa>0 and Qnt2Sisa>0


GO

-- View: vwBrowsOutSHIP_SPP
-- Created: 2011-08-19 08:46:40.343 | Modified: 2011-12-27 20:03:38.750
-- =====================================================


CREATE View [dbo].[vwBrowsOutSHIP_SPP]
as

Select 	NoBukti, NOSC, Urut, KodeBrg, Sat_1, Sat_2, NoSat, Isi, Qnt, Qnt2, QntSPP, Qnt2SPP, QntSisa, Qnt2Sisa, NamabrgKom,
         ShippingMark
From 	vwOutSHIP_SPP 
where 	QntSisa>0 and Qnt2Sisa>0



GO

-- View: vwBrowsOutSO_SPP
-- Created: 2014-02-13 11:53:58.173 | Modified: 2015-03-24 10:37:26.740
-- =====================================================





CREATE View [dbo].[vwBrowsOutSO_SPP]
as
Select 	NoBukti,  Urut, KodeBrg, Satuan,  NoSat, Isi, Qnt, Qnt2, QntSPP, Qnt2SPP, QntSisa, Qnt2Sisa, NamabrgKom, isLengkap, MasaBerlaku
,IsClosedet,Tanggal
From 	vwOutSO_SPP
where 	QntSisa>0 and MasaBerlaku>=GETDATE()



GO

-- View: vwBrowsOutSPB_RSPB
-- Created: 2014-02-19 10:17:53.800 | Modified: 2014-02-19 10:17:53.800
-- =====================================================


CREATE View [dbo].[vwBrowsOutSPB_RSPB]
as
Select 	NoBukti, Urut, KodeBrg,Namabrg, Sat_1, Sat_2, NoSat, Isi, Qnt, Qnt2, 
	QntRSPB, Qnt2RSPB, QntSisa, Qnt2Sisa,NetW,GrossW, Catatan, TipeSPP,
	isClose,a.isotorisasi1,A.Flagtipe
From 	vwOutSPB_RSPB a
where 	QntSisa>0 and Qnt2Sisa>0 and a.isotorisasi1=1
GO

-- View: vwBrowsOutSPBRJual
-- Created: 2014-09-24 11:37:29.743 | Modified: 2014-09-24 11:37:29.743
-- =====================================================


create View [dbo].[vwBrowsOutSPBRJual]
as

Select 	*
From 	vwOutSPBRJual
where 	QntSisa>0
	and NilaiOL=MaxOL
	









GO

-- View: vwBrowsOutSPP
-- Created: 2011-10-19 08:41:19.440 | Modified: 2013-02-19 15:14:38.413
-- =====================================================



CREATE View [dbo].[vwBrowsOutSPP]
as
Select 	NoBukti, Urut, KodeBrg,Namabrg, Sat_1, Sat_2, NoSat, Isi, Qnt, Qnt2, 
	QntSPB, Qnt2SPB, QntSisa, Qnt2Sisa,NetW,GrossW, Catatan, TipeSPP,
	isClose, NoSO, UrutSO, isCetakKitir
From 	vwOutSPP 
where 	QntSisa>0 or Qnt2Sisa>0




GO

-- View: vwBrowsOutSPRK
-- Created: 2011-03-03 11:57:52.613 | Modified: 2011-12-29 13:51:35.450
-- =====================================================

CREATE VIEW [dbo].[vwBrowsOutSPRK]
AS
SELECT     Nobukti, urut, kodebrg, Sat_1, Sat_2, Isi, Qnt, Qnt2, '' NoPermintaan,0 UrutPermintaan,
           QntBSPRK QntBatal, Qnt2BSPRK Qnt2Batal, QntPO, Qnt2PO, QntBPO, Qnt2BPO, QntSisaPO, 
           Qnt2SisaPO, QntSisa, Qnt2Sisa, NamaBag, nosat, Pelaksana, IsInspeksi, Keterangan, KodeGrp, Catatan,
           JnsPakai, Kodegdg, kodebag, kodemesin, SOP, Perk_Investasi
FROM   dbo.vwOutSPRK
WHERE (QntSisa > 0) AND (Qnt2Sisa > 0)


GO

-- View: vwBrowsSupp
-- Created: 2012-04-12 14:22:41.437 | Modified: 2012-04-12 14:22:41.437
-- =====================================================




CREATE View [dbo].[vwBrowsSupp]
as
Select A.KODECUSTSUPP, A.NAMACUSTSUPP, A.ALAMAT1, A.ALAMAT2, 
       case when isnull(A.Alamat2,'')='' then A.Alamat1 else A.Alamat1+char(13)+A.Alamat2 end Alamat,
    	 A.kota kodeKota,  A.Kota, 
	    A.TELPON, A.FAX, A.EMAIL, A.KODEPOS, A.NEGARA, A.NPWP, A.Tanggal, A.PLAFON, A.HARI, A.HARIHUTPIUT, 
	    A.BERIKAT, A.USAHA, D.PERKIRAAN, A.JENIS, A.NAMAPKP, A.ALAMATPKP1, A.ALAMATPKP2, A.KOTAPKP, A.Sales, A.KodeVls, A.KodeTipe, A.IsPpn,
	    A.Agent,case when isnull(A.Alamat2,'')='' then A.Alamat1A else A.Alamat1A+char(13)+A.Alamat2A end AlamatA,
	    A.KotaA, A.NegaraA, A.ContactP, B.IsBeliJual, B.IsLokalorExim,
	    C.Keterangan NamaPerkiraan,A.IsAktif
From 	dbo.DBCUSTSUPP A
      Left Outer join DBPERKCUSTSUPP D on D.KodeCustSupp=A.KODECUSTSUPP
      Left Outer Join dbo.DBPOSTHUTPIUT B on B.Perkiraan=D.PERKIRAAN
      Left Outer Join dbo.DBPERKIRAAN C on C.Perkiraan=B.PERKIRAAN
where  B.Kode='HT'






GO

-- View: vwCetakContractReview
-- Created: 2011-10-19 08:41:19.457 | Modified: 2011-12-08 20:17:03.990
-- =====================================================



CREATE View [dbo].[vwCetakcontractreview]
as
select a.nobukti,b.tanggal,b.KodecustSupp,a.KodeBrg,a.NAMABRG,e.Jns_Kertas,e.Ukr_Kertas,e.gsm,
case when a.Nosat=1 then c.Qnt 
     else c.Qnt2 
end jumlahkirim,
case when c.Nosat=1 then c.Sat_1
     when c.Nosat=2 then c.Sat_2 
     else ''
end Satuan,a.Nosat,c.TGLKirim,a.Sistem_Kemasan_IsKarton,
a.Sistem_Kemasan_IsPalet,a.Sistem_Kemasan_IsKarton_Palet,a.Sistem_Kemasan_IsBungkus,
a.Sistem_Kemasan_IsBungkus_Palet,a.Sticker,a.Isi_Kemasan,a.Ketentuan_Berat_IsTeori,
a.Ketentuan_Berat_IsTimbang,a.Jenis_isPlastik,a.Jenis_isKarton,a.Diameter_Inside_120mm,
a.Diameter_Inside_152mm,a.Diameter_Inside_76mm,a.Tebal_14mm_152mm,a.Tebal_14mm_76mm,
a.Tebal_15mm,a.Tebal_Lain,a.Tebal_lain2,a.Warna_YellowA,a.Warna_YellowB,a.Warna_Lain,a.Warna_Lain2,
a.Arah_Putaran_WI,a.Arah_Putaran_WO,a.Jum_Ukuran_Cont,a.Jum_Kemasan,a.Ship_Mark,
a.NamaBrg Namabrgkom, c.Keterangan, A.Urut,
Case when d.USAHA<>'' then d.USAHA+'. ' else '' end+d.NAMACUSTSUPP NamaCustsupp,
       d.Alamat+CAse when d.Kota<>'' then CHAR(13)+d.Kota else '' end+
       Case when d.NEGARA<>'' then CHAR(13)+d.NEGARA else '' end Alamat     
from dbContractReviewDet a 
left outer join dbContractReview b on a.NoBukti = b.nobukti
left outer join DBContractReviewKIRIM c on a.NoBukti = c.NoCR and c.UrutCR=a.Urut
left outer join vwBrowsCust d on b.KodecustSupp = d.KODECUSTSUPP
left outer join DBBARANGJADI e on a.KodeBrg =  e.KODEBRG

--where a.nobukti ='ENQ/0111/00002/SZZ'













GO

-- View: vwcetakenquiry
-- Created: 2011-09-28 13:31:00.000 | Modified: 2011-09-28 13:31:00.000
-- =====================================================



CREATE View [dbo].[vwcetakenquiry]
as


select a.nobukti,b.nourut,b.tanggal,
case when b.islokal=0 then 'LOKAL' else 'EXPORT' end as penjualan,
b.kodecustsupp,c.namacustsupp,a.KodeBrg,a.Namabrg,d.Jns_Kertas,d.Ukr_Kertas,d.GSM,
a.Sat_1,a.Qnt,a.Sat_2,a.Qnt2
from dbenquirydet a 
left outer join DBENQUIRY b on a.NoBukti = b.NoBukti
left outer join vwBrowsCust c on b.KodeCustSupp=c.KODECUSTSUPP
left outer join DBBARANGJADI d on a.KodeBrg = d.KODEBRG

--where a.nobukti ='ENQ/0111/00002/SZZ'




GO

-- View: vwCetakInvoicePL
-- Created: 2013-01-15 11:46:02.820 | Modified: 2013-01-15 11:46:02.820
-- =====================================================

CREATE View [dbo].[vwCetakInvoicePL]
as
Select A.NoBukti, A.NoUrut, A.Tanggal, A.PPN, A.Valas, A.Kurs, A.KodeCustSupp, A.Consignee, A.NotifyParty, A.StuffingDate, 
       A.StuffingPlace, A.ContractNo, A.PONo, A.PaymentTerm, 
       A.DocCreditNo, A.PoL, A.PoD, A.NameOfVessel, A.Feeder_Vessel, A.Connect_Vessel, A.ShipOnBoardDate, A.Packing, 
       A.Others, A.IsCetak, A.IDUser, A.IsLokal, A.NoBL, A.NoteBeneficiary1, 
       A.NoteBeneficiary2, A.NoteBeneficiary3, A.ShipmentAdvice1, A.ShipmentAdvice2, A.ETADestination, A.ToShipmentAdvice2, A.NoPajak, A.TglFPJ, 
       A.Footnote, A.IssuingBank, A.MyID, 
       A.IsOtorisasi1, A.OtoUser1, A.TglOto1,
       A.IsOtorisasi2, A.OtoUser2, A.TglOto2, 
       A.IsOtorisasi3, A.OtoUser3, A.TglOto3, 
       A.IsOtorisasi4, A.OtoUser4, A.TglOto4, 
       
       A.IsOtorisasi5, A.OtoUser5, A.TglOto5,
       B.Kodebrg,B.Namabrg NamaBrgkom,
       Sum(Case when B.NOSAT=1 then B.QNT
            when B.NOSAT=2 then B.QNT2
            else 0
       end) Qty,
      (Case when B.NOSAT=1 then B.Sat_1
            when B.NOSAT=2 then B.Sat_2
            else ''
       end) Satuan,Sum(B.Qnt) Qnt, Sum(B.Qnt2) Qnt2, B.Sat_1,B.Sat_2,B.Nosat,B.Harga,
       Sum(B.NDPP) NDPP, Sum(B.NDPPRp) NDPPRp, Sum(B.NPPN) NPPN, Sum(B.NPPNRp) NPPnRp, Sum(B.NNET) Nnet, Sum(B.NNETRp) NnetRp,
       B.ShippingMark, B.KetDetail, B.NetW, B.GrossW, B.Meas,
       E.Namabrg,       
       Case when C.USAHA<>'' then C.USAHA+'. ' else '' end+C.NAMACUST NamaCustSupp,
       C.Alamat,C.kodekota Kota,C.USAHA,'' NEGARA, C.TELPON, '' FAX, '' EMAIL,
       '' NoLC,
	   '' NoLCShip, '' Notify_PartyShip, '' PoLShip, 
	   '' PodShip, '' ConsigneeShip, 
	   '' Veeder_VesselShip, '' Voy_Veeder_VesselShip,
       '' Connect_VesselShip, '' Voy_Connect_VesselShip, 
	   '' ShipOnBoardShip, '' Stuffing_DateShip, 
	   '' Stuffing_PlaceShip,
	   '' Freight_TermShip, '' NotesShip,
	   Case when MONTH(A.tanggal)=1 then 'January'
	        when MONTH(A.tanggal)=2 then 'February'
	        when MONTH(A.tanggal)=3 then 'March'
	        when MONTH(A.tanggal)=4 then 'April'
	        when MONTH(A.tanggal)=5 then 'May'
	        when MONTH(A.tanggal)=6 then 'June'
	        when MONTH(A.tanggal)=7 then 'July'
	        when MONTH(A.tanggal)=8 then 'August'
	        when MONTH(A.tanggal)=9 then 'September'
	        when MONTH(A.tanggal)=10 then 'October'
	        when MONTH(A.tanggal)=11 then 'November'
	        when MONTH(A.tanggal)=12 then 'December'
	        else ''
	   end Bulan, '' Ukr_Kertas, '' Trade_Term,
        Case when MONTH(A.ShipOnBoardDate)=1 then 'January'
	        when MONTH(A.ShipOnBoardDate)=2 then 'February'
	        when MONTH(A.ShipOnBoardDate)=3 then 'March'
	        when MONTH(A.ShipOnBoardDate)=4 then 'April'
	        when MONTH(A.ShipOnBoardDate)=5 then 'May'
	        when MONTH(A.ShipOnBoardDate)=6 then 'June'
	        when MONTH(A.ShipOnBoardDate)=7 then 'July'
	        when MONTH(A.ShipOnBoardDate)=8 then 'August'
	        when MONTH(A.ShipOnBoardDate)=9 then 'September'
	        when MONTH(A.ShipOnBoardDate)=10 then 'October'
	        when MONTH(A.ShipOnBoardDate)=11 then 'November'
	        when MONTH(A.ShipOnBoardDate)=12 then 'December'
	        else ''
	   end BulanShipOnBoard,
        Case when MONTH(A.ETADestination)=1 then 'January'
	        when MONTH(A.ETADestination)=2 then 'February'
	        when MONTH(A.ETADestination)=3 then 'March'
	        when MONTH(A.ETADestination)=4 then 'April'
	        when MONTH(A.ETADestination)=5 then 'May'
	        when MONTH(A.ETADestination)=6 then 'June'
	        when MONTH(A.ETADestination)=7 then 'July'
	        when MONTH(A.ETADestination)=8 then 'August'
	        when MONTH(A.ETADestination)=9 then 'September'
	        when MONTH(A.ETADestination)=10 then 'October'
	        when MONTH(A.ETADestination)=11 then 'November'
	        when MONTH(A.ETADestination)=12 then 'December'
	        else ''
	   end BulanETADestination, B.Urut
from dbInvoicePL A
     left outer join dbInvoicePLDet b on b.NoBukti=A.NoBukti     
     left outer join DBBARANG E on E.KODEBRG=B.KodeBrg
     left Outer join (Select x.NoBukti, x.Urut, x.NoSPP
                      from dbSPBDet x
                      Group by x.NoBukti, x.Urut, x.NoSPP) F on F.NoBukti=B.NoSPB and F.Urut=B.UrutSPB
     left outer join (Select NoBukti, NoSO
                      from dbSPPDet x
                      Group by NoBukti, NoSO) G on G.NoBukti=f.NoSPP
     left Outer join DBSO H on H.NoBukti=G.NoSo
     left outer join vwBrowsCustomer c on c.KODECUST=A.KodeCustSupp and c.Sales=H.KODESLS
Group by A.NoBukti, A.NoUrut, A.Tanggal, A.PPN, A.Valas, A.Kurs, A.KodeCustSupp, A.Consignee, A.NotifyParty, A.StuffingDate, 
       A.StuffingPlace, A.ContractNo, A.PONo, A.PaymentTerm, 
       A.DocCreditNo, A.PoL, A.PoD, A.NameOfVessel, A.Feeder_Vessel, A.Connect_Vessel, A.ShipOnBoardDate, A.Packing, 
       A.Others, A.IsCetak, A.IDUser, A.IsLokal, A.NoBL, A.NoteBeneficiary1, 
       A.NoteBeneficiary2, A.NoteBeneficiary3, A.ShipmentAdvice1, A.ShipmentAdvice2, A.ETADestination, A.ToShipmentAdvice2, A.NoPajak, A.TglFPJ, 
       A.Footnote, A.IssuingBank, A.MyID, 
       A.IsOtorisasi1, A.OtoUser1, A.TglOto1,
       A.IsOtorisasi2, A.OtoUser2, A.TglOto2, 
       A.IsOtorisasi3, A.OtoUser3, A.TglOto3, 
       A.IsOtorisasi4, A.OtoUser4, A.TglOto4, 
       A.IsOtorisasi5, A.OtoUser5, A.TglOto5,
       B.Kodebrg,B.Namabrg,B.NOSAT, B.SAT_1, B.SAT_2, B.Harga,
       
       B.ShippingMark, B.KetDetail, B.NetW, B.GrossW, B.Meas,
       E.Namabrg,       
       Case when C.USAHA<>'' then C.USAHA+'. ' else '' end+C.NAMACUST,
       C.Alamat,C.kodeKota,C.USAHA, C.TELPON, B.Urut,
      
	   Case when MONTH(A.tanggal)=1 then 'January'
	        when MONTH(A.tanggal)=2 then 'February'
	        when MONTH(A.tanggal)=3 then 'March'
	        when MONTH(A.tanggal)=4 then 'April'
	        when MONTH(A.tanggal)=5 then 'May'
	        when MONTH(A.tanggal)=6 then 'June'
	        when MONTH(A.tanggal)=7 then 'July'
	        when MONTH(A.tanggal)=8 then 'August'
	        when MONTH(A.tanggal)=9 then 'September'
	        when MONTH(A.tanggal)=10 then 'October'
	        when MONTH(A.tanggal)=11 then 'November'
	        when MONTH(A.tanggal)=12 then 'December'
	        else ''
	   end,
	   Case when MONTH(A.ShipOnBoardDate)=1 then 'January'
	        when MONTH(A.ShipOnBoardDate)=2 then 'February'
	        when MONTH(A.ShipOnBoardDate)=3 then 'March'
	        when MONTH(A.ShipOnBoardDate)=4 then 'April'
	        when MONTH(A.ShipOnBoardDate)=5 then 'May'
	        when MONTH(A.ShipOnBoardDate)=6 then 'June'
	        when MONTH(A.ShipOnBoardDate)=7 then 'July'
	        when MONTH(A.ShipOnBoardDate)=8 then 'August'
	        when MONTH(A.ShipOnBoardDate)=9 then 'September'
	        when MONTH(A.ShipOnBoardDate)=10 then 'October'
	        when MONTH(A.ShipOnBoardDate)=11 then 'November'
	        when MONTH(A.ShipOnBoardDate)=12 then 'December'
	        else ''
	   end,
         Case when MONTH(A.ETADestination)=1 then 'January'
	        when MONTH(A.ETADestination)=2 then 'February'
	        when MONTH(A.ETADestination)=3 then 'March'
	        when MONTH(A.ETADestination)=4 then 'April'
	        when MONTH(A.ETADestination)=5 then 'May'
	        when MONTH(A.ETADestination)=6 then 'June'
	        when MONTH(A.ETADestination)=7 then 'July'
	        when MONTH(A.ETADestination)=8 then 'August'
	        when MONTH(A.ETADestination)=9 then 'September'
	        when MONTH(A.ETADestination)=10 then 'October'
	        when MONTH(A.ETADestination)=11 then 'November'
	        when MONTH(A.ETADestination)=12 then 'December'
	        else ''
	   end

GO

-- View: vwCetakInvoicePLLampiran
-- Created: 2011-12-29 00:14:08.890 | Modified: 2011-12-29 00:19:18.353
-- =====================================================
CREATE View dbo.vwCetakInvoicePLLampiran
as
Select a.Nobukti, a.Urut, a.Keterangan, a.KodeVls, a.Kurs, a.Harga, a.NNet
from DBInvoicePLLampiran a                     
GO

-- View: vwcetakquotation
-- Created: 2011-10-19 08:41:19.473 | Modified: 2011-10-19 08:41:19.473
-- =====================================================


CREATE View [dbo].[vwcetakquotation]
as

select a.nobukti,b.kodecustsupp,b.Term_of_Payment, b.Packing,b.Delivery,b.Price_Validity,
       Case when z.USAHA<>'' then z.USAHA+'. ' else '' end+ z.NAMACUSTSUPP NamaCustSupp,      
       z.contactp,a.kodebrg,x.NAMABRG,x.Ukr_Kertas,x.Jns_Kertas,
       a.Sat_1 sat1det,a.Sat_2 sat2det,a.Nosat nosatdet,a.Qnt qntdet,a.Qnt2 qnt2det,
       c.Qnt qntkirim, c.TGLKirim tglkirim,A.harga,
       case when c.Nosat = 1 then Case when c.Nosat is not null then c.qnt else a.Qnt end
            when c.Nosat = 2 then Case when c.Nosat is not null then c.Qnt2 else a.Qnt2 end
       end Unit,
       case when c.Nosat = 1 then Case when c.Nosat is not null then c.Sat_1 else a.Sat_1 end
            when c.Nosat = 2 then Case when c.Nosat is not null then c.Sat_2 else a.Sat_2 end
       end Satuan,
       case when c.Nosat = 1 then Case when c.Nosat is not null then c.qnt else a.Qnt end
            when c.Nosat = 2 then Case when c.Nosat is not null then c.Qnt2 else a.Qnt2 end
       end*a.Harga jumlah, A.Namabrg NamabrgKom,
       B.Tanggal, C.Keterangan,
       Case when z.USAHA<>'' then z.USAHA+'. ' else '' end+z.NAMACUSTSUPP NamaCustomer,
       z.Alamat+CAse when z.Kota<>'' then CHAR(13)+z.Kota else '' end+
       Case when z.NEGARA<>'' then CHAR(13)+z.NEGARA else '' end Alamat,
       B.Note_Quotation
from dbquotationdet a 
LEFT outer join dbQuotation b on a.Nobukti = b.Nobukti
left outer join vwBrowsCust z on b.KodecustSupp = z.KODECUSTSUPP
left outer join DBBARANGJADI x on a.KodeBrg = x.KODEBRG
left outer join DBQuotationKIRIM c on a.Nobukti = c.NoQuo and c.urutQuo=a.Urut

--where a.nobukti ='ENQ/0111/00002/SZZ'










GO

-- View: vwCetakRPJ
-- Created: 2013-01-15 15:04:00.153 | Modified: 2013-01-15 15:04:00.153
-- =====================================================



CREATE View [dbo].[vwCetakRPJ]
as
Select A.NOBUKTI, A.TANGGAL, B.NamaBrg,'' Ukr_Kertas,0.00 GSM, A.NoSO, A.TglSO, A.NoLKP, A.TGLLKP,
       B.NoSPB,d.Tanggal TglSPB, A.KODECUSTSUPP, C.NamaCust NAMACUSTSUPP, null TglRencanaPenarikan, null TglPengesahan,
       F.NoBukti NoSPR, F.Tanggal TglSPR, B.URUT, 
       Case when B.Nosat=1 then B.QNT
            when B.Nosat=2 then B.QNT2
            else 0
       End QntRPJ,
       Case when B.Nosat=1 then B.SAT_1
            when B.Nosat=2 then B.SAT_2
            else ''
       End SatRPJ,
       Case when F.Nosat=1 then F.QNT
            when F.Nosat=2 then F.QNT2
            else 0
       End QntSPR,
       Case when F.Nosat=1 then F.SAT_1
            when F.Nosat=2 then F.SAT_2
            else ''
       End SatSPR
From DBRInvoicePL A
     left outer join DBRInvoicePLDET B on B.NOBUKTI=A.NOBUKTI        
     left outer join (Select x0.NoBukti, x0.Urut, z.Tanggal, z.NoBukti NoSPB, x1.KODESLS, x1.KODECUST
                      from dbInvoicePLDet x0
                           left outer join dbSPBDet y on y.NoBukti=x0.Nospb and y.Urut=x0.UrutSPB
                           left outer join dbSPB z on z.NoBukti=y.NoBukti
                           left outer join dbSPPDet x on x.NoBukti=y.NoSPP and x.Urut=y.UrutSPP
                           left Outer join DBSO x1 on x1.NOBUKTI=x.NoSO
                           ) d on d.NoBukti=B.NoInvoice and d.Urut=B.UrutInvoice --and d.NoSPB=B.NoSPB
     left outer join DBBARANG E on E.KODEBRG=B.KODEBRG
     left outer join (Select x.NoBukti,x.Tanggal, y.NoRPJ, y.UrutRPJ, y.QNT, y.QNT2, y.SAT_1, y.SAT_2, y.NOSAT
                      from dbSPBRJual x
                           left outer join dbSPBRJualDet y on y.NoBukti=x.NoBukti) F on F.NoRPJ=b.NOBUKTI and F.UrutRPJ=B.URUT
     left outer join vwBrowsCustomer C on C.KODECUST=A.KODECUSTSUPP and C.Sales=d.KODESLS



GO

-- View: vwCetakRSPB
-- Created: 2013-03-09 10:54:19.740 | Modified: 2013-03-09 10:54:19.740
-- =====================================================




--select * from DBSPBreturdet
--select * from DBrSPBdet

CREATE View [dbo].[vwCetakRSPB]
as
select A.NOBUKTI, A.NOURUT, A.TANGGAL, A.KODECUSTSUPP, 
       Case when D.USAHA<>'' then D.USAHA+'. ' else '' end+D.NamaCust NamaCustSupp, 
       D.Alamat, D.NamaKota Kota, '' NEGARA,
        A0.NoSPP, A.NoPolKend,
        A.Container, A.NoContainer, A.NoSeal,
        A.ISCETAK, A.IDUser,
        B.URUT, B.KODEBRG, C.Namabrg, '' Jns_Kertas,'' Ukr_Kertas, B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.NoSat, B.ISI,
        Ax.UrutSPP, E.NoSO,E.TglSO,E.NOPO NoPesanan, A1.NamaKirim, A1.AlamatKirim,
        (Select NOSPB from DBNOMOR) NODOK, B.Namabrg NamaBrgkom,
         case when B.NOSAT = 1 then b.SAT_1 else b.SAT_2 end as satuanas,
         case when B.NOSAT = 1 then B.QNT else b.QNT2 end as QNTAS,
        A.Catatan, b.NetW, b.GrossW, A0.sopir
From DBRSPB A
left outer join dbSPB A0 on a.NoSPB = a0.NoBukti
left outer join dbSPBDet ax on a0.NoBukti = ax.NoBukti
left outer join dbSPP A1 on A1.NoBukti=A0.NoSPP
Left Outer Join (Select Nobukti, NoSO from dbSPPDet Group by NoBukti,NoSO) A2 on A2.NoBukti=A1.nobukti
Left Outer Join DBRSPBDET B on B.NoBukti=A.NoBukti
Left Outer Join dbBarang c On C.KodeBrg=B.KodeBrg
Left Outer Join vwBrowsCustomer D On D.KodeCust=A.KodeCustSupp
Left Outer join (Select y.Nobukti NoSO,y.Tanggal TglSO, y.NoPesanan Nopo
                 from DBSO y
                 group by y.Nobukti,y.Tanggal, y.NoPesanan) E on E.NoSO=A2.NoSo


GO

-- View: vwCetakRSpbLampiran
-- Created: 2013-03-09 10:54:39.357 | Modified: 2013-03-09 10:54:39.357
-- =====================================================





CREATE view [dbo].[vwCetakRSpbLampiran]
as
Select Case when A.NOROLL<>'' then A.NOROLL+' ' else '' end+
       Case when A.NOPALLET<>'' then A.NOPALLET+' ' else '' end+ 
       Case when A.NOLOT<>'' then A.NOLOT+' ' else '' end       
        NoLot, 
       B.Namabrg NamaBrgKom, C.Jns_Kertas, C.Ukr_Kertas, C.GSM,
       A.Qnt,A.Qnt2, A.Sat_1, A.Sat_2, A.NetW, A.GrossW, A.Keterangan,
       B.NoBukti,B.Tanggal, B.NoPolKend, B.NoContainer, B.NoSeal, A.Urut, A.UrutSPB,
       Case when A.Nosat=1 then a.Qnt
            when a.Nosat=2 then a.Qnt2
            else 0
       end Qty,
       Case when A.Nosat=1 then a.Sat_1
            when a.Nosat=2 then a.Sat_2
            else ''
       end Satuan,
       (Select NoSPB from dbnomor) NODok
From dbSPBLampiran A
     left Outer join (Select y.NoBukti, Y.Tanggal, y.NoContainer, y.NoPolKend, y.NoSeal,
                             x.Urut, x.KodeBrg, x.Namabrg
                      from dbRSPBDet x
                           left Outer join dbSPB y on y.NoBukti=x.NoBukti
                      ) B on B.NoBukti=A.NoSPB and B.Urut=A.UrutSPB
     left Outer join (Select kodebrg, namabrg, SAT1, Sat2, '' Jns_Kertas, '' Ukr_Kertas, 0.00 GSM from DBBARANG) C on C.KODEBRG=B.KodeBrg








GO

-- View: vwCetakSalesContract
-- Created: 2011-10-19 08:41:19.503 | Modified: 2011-12-27 19:36:12.920
-- =====================================================


CREATE View [dbo].[vwCetakSalesContract]
as
select a.nobukti,a.kodebrg,e.NAMABRG,b.Tanggal as tanggal,b.KodecustSupp,b.islokal,
       d.NAMAPKP NAMACUSTSUPP,
       a.Qnt qntdet,a.Qnt2 as qnt2det,
       b.Term_of_Payment,b.ACC_NO,b.Swift_Code,b.Shipment_Time,b.Last_Shipment_Time,b.Packing,       
       b.Consignee, b.Notify_Party, b.Port_of_Loading, b.Port_of_Discharge, b.TransShipment, b.Partial_Shipment,
       a.Ship_Mark, b.Remarks, c.Qnt qntkirim,
       c.Qnt2 qntkirim2,a.Harga HargaDet,a.Nosat,a.ppn,
       Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                          when a.Nosat=2 then a.Qnt2
                                          else 0
                                     end
            else Case when c.Nosat=1 then c.Qnt
                      when c.nosat=2 then c.qnt2
                      else 0
                 end
       end kuantitas,
       Case when c.NoSC is null then Case when a.Nosat=1 then a.Sat_1
                                          when a.Nosat=2 then a.Sat_2
                                          else ''
                                     end
            else Case when c.Nosat=1 then c.Sat_1
                      when c.nosat=2 then c.Sat_2
                      else ''
                 end
       end Satuan,
       Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                          when a.Nosat=2 then a.Qnt2
                                          else 0
                                     end
            else Case when c.Nosat=1 then c.Qnt
                      when c.nosat=2 then c.qnt2
                      else 0
                 end
       end*a.harga SubTotal,
       Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                          when a.Nosat=2 then a.Qnt2
                                          else 0
                                     end
            else Case when c.Nosat=1 then c.Qnt
                      when c.nosat=2 then c.qnt2
                      else 0
                 end
       end*a.harga*a.Kurs SubTotalRp,
       (Case when a.PPn in (1) then Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                        when a.Nosat=2 then a.Qnt2
                                                                        else 0
                                                                   end
                                          else Case when c.Nosat=1 then c.Qnt
                                                    when c.nosat=2 then c.qnt2
                                                    else 0
                                               end
                                     end*a.Harga
            when a.PPn=2 then(Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                 when a.Nosat=2 then a.Qnt2
                                                                 else 0
                                                            end
                                   else Case when c.Nosat=1 then c.Qnt
                                             when c.nosat=2 then c.qnt2
                                             else 0
                                               end
                              end*a.Harga)/1.1
            else 0
       end*0.1)*0.001 PPh,
       (Case when a.PPn in (1) then Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                        when a.Nosat=2 then a.Qnt2
                                                                        else 0
                                                                   end
                                          else Case when c.Nosat=1 then c.Qnt
                                                    when c.nosat=2 then c.qnt2
                                                    else 0
                                               end
                                     end*a.Harga
            when a.PPn=2 then(Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                 when a.Nosat=2 then a.Qnt2
                                                                 else 0
                                                            end
                                   else Case when c.Nosat=1 then c.Qnt
                                             when c.nosat=2 then c.qnt2
                                             else 0
                                               end
                              end*a.Harga)/1.1
            else 0
       end*0.1*a.Kurs)*0.001 PPhRp,
       Case when a.PPn in (0,1) then Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                        when a.Nosat=2 then a.Qnt2
                                                                        else 0
                                                                   end
                                          else Case when c.Nosat=1 then c.Qnt
                                                    when c.nosat=2 then c.qnt2
                                                    else 0
                                               end
                                     end*a.Harga
            when a.PPn=2 then(Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                 when a.Nosat=2 then a.Qnt2
                                                                 else 0
                                                            end
                                   else Case when c.Nosat=1 then c.Qnt
                                             when c.nosat=2 then c.qnt2
                                             else 0
                                               end
                              end*a.Harga)/1.1
            else 0
       end nDPP,
	    Case when a.PPn in (0,1) then Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                        when a.Nosat=2 then a.Qnt2
                                                                        else 0
                                                                   end
                                          else Case when c.Nosat=1 then c.Qnt
                                                    when c.nosat=2 then c.qnt2
                                                    else 0
                                               end
                                     end*a.Harga
            when a.PPn=2 then(Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                 when a.Nosat=2 then a.Qnt2
                                                                 else 0
                                                            end
                                   else Case when c.Nosat=1 then c.Qnt
                                             when c.nosat=2 then c.qnt2
                                             else 0
                                               end
                              end*a.Harga)/1.1
            else 0
       end*a.Kurs nDPPRp,
	    Case when a.PPn in (1) then Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                        when a.Nosat=2 then a.Qnt2
                                                                        else 0
                                                                   end
                                          else Case when c.Nosat=1 then c.Qnt
                                                    when c.nosat=2 then c.qnt2
                                                    else 0
                                               end
                                     end*a.Harga
            when a.PPn=2 then(Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                 when a.Nosat=2 then a.Qnt2
                                                                 else 0
                                                            end
                                   else Case when c.Nosat=1 then c.Qnt
                                             when c.nosat=2 then c.qnt2
                                             else 0
                                               end
                              end*a.Harga)/1.1
            else 0
       end*0.1 nPPn,
	    (Case when a.PPn in (1) then Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                        when a.Nosat=2 then a.Qnt2
                                                                        else 0
                                                                   end
                                          else Case when c.Nosat=1 then c.Qnt
                                                    when c.nosat=2 then c.qnt2
                                                    else 0
                                               end
                                     end*a.Harga
            when a.PPn=2 then(Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                 when a.Nosat=2 then a.Qnt2
                                                                 else 0
                                                            end
                                   else Case when c.Nosat=1 then c.Qnt
                                             when c.nosat=2 then c.qnt2
                                             else 0
                                               end
                              end*a.Harga)/1.1
            else 0
       end*0.1)*a.Kurs nPPnRp,
       Case when a.PPn in (0,1) then Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                        when a.Nosat=2 then a.Qnt2
                                                                        else 0
                                                                   end
                                          else Case when c.Nosat=1 then c.Qnt
                                                    when c.nosat=2 then c.qnt2
                                                    else 0
                                               end
                                     end*a.Harga
            when a.PPn=2 then(Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                 when a.Nosat=2 then a.Qnt2
                                                                 else 0
                                                            end
                                   else Case when c.Nosat=1 then c.Qnt
                                             when c.nosat=2 then c.qnt2
                                             else 0
                                               end
                              end*a.Harga)/1.1
            else 0
       end+(
       Case when a.PPn in (1) then Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                        when a.Nosat=2 then a.Qnt2
                                                                        else 0
                                                                   end
                                          else Case when c.Nosat=1 then c.Qnt
                                                    when c.nosat=2 then c.qnt2
                                                    else 0
                                               end
                                     end*a.Harga
            when a.PPn=2 then(Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                 when a.Nosat=2 then a.Qnt2
                                                                 else 0
                                                            end
                                   else Case when c.Nosat=1 then c.Qnt
                                             when c.nosat=2 then c.qnt2
                                             else 0
                                               end
                              end*a.Harga)/1.1
            else 0
       end*0.1)+((
       Case when a.PPn in (1) then Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                        when a.Nosat=2 then a.Qnt2
                                                                        else 0
                                                                   end
                                          else Case when c.Nosat=1 then c.Qnt
                                                    when c.nosat=2 then c.qnt2
                                                    else 0
                                               end
                                     end*a.Harga
            when a.PPn=2 then(Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                 when a.Nosat=2 then a.Qnt2
                                                                 else 0
                                                            end
                                   else Case when c.Nosat=1 then c.Qnt
                                             when c.nosat=2 then c.qnt2
                                             else 0
                                               end
                              end*a.Harga)/1.1
            else 0
       end*0.1)*0.001) jumlah,
	    (Case when a.PPn in (0,1) then Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                        when a.Nosat=2 then a.Qnt2
                                                                        else 0
                                                                   end
                                          else Case when c.Nosat=1 then c.Qnt
                                                    when c.nosat=2 then c.qnt2
                                                    else 0
                                               end
                                     end*a.Harga
            when a.PPn=2 then(Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                 when a.Nosat=2 then a.Qnt2
                                                                 else 0
                                                            end
                                   else Case when c.Nosat=1 then c.Qnt
                                             when c.nosat=2 then c.qnt2
                                             else 0
                                               end
                              end*a.Harga)/1.1
            else 0
       end+(
       Case when a.PPn in (1) then Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                        when a.Nosat=2 then a.Qnt2
                                                                        else 0
                                                                   end
                                          else Case when c.Nosat=1 then c.Qnt
                                                    when c.nosat=2 then c.qnt2
                                                    else 0
                                               end
                                     end*a.Harga
            when a.PPn=2 then(Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                 when a.Nosat=2 then a.Qnt2
                                                                 else 0
                                                            end
                                   else Case when c.Nosat=1 then c.Qnt
                                             when c.nosat=2 then c.qnt2
                                             else 0
                                               end
                              end*a.Harga)/1.1
            else 0
       end*0.1)+
       ((Case when a.PPn in (1) then Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                        when a.Nosat=2 then a.Qnt2
                                                                        else 0
                                                                   end
                                          else Case when c.Nosat=1 then c.Qnt
                                                    when c.nosat=2 then c.qnt2
                                                    else 0
                                               end
                                     end*a.Harga
            when a.PPn=2 then(Case when c.NoSC is null then Case when a.Nosat=1 then a.Qnt
                                                                 when a.Nosat=2 then a.Qnt2
                                                                 else 0
                                                            end
                                   else Case when c.Nosat=1 then c.Qnt
                                             when c.nosat=2 then c.qnt2
                                             else 0
                                               end
                              end*a.Harga)/1.1
            else 0
       end*0.1)*0.001))*a.kurs jumlahRp,
        d.AlamatPKP+Case when d.KOTAPKP<>'' then CHAR(13)+d.KOTAPKP else '' end Alamat,
       c.Keterangan, a.NamaBrg NamabrgKom,a.Urut,
       a.Harga
from dbSalesContractdet a 
left outer join dbSalesContract b on a.Nobukti = b.Nobukti
left outer join DBSalesContractKIRIM c on a.Nobukti = c.NoSC and c.urutSC=a.Urut
left outer join vwBrowsCust d on b.KodecustSupp = d.KODECUSTSUPP
left outer join DBBARANGJADI e on a.Kodebrg = e.KODEBRG



GO

-- View: vwCetakSPB
-- Created: 2011-11-03 09:21:09.590 | Modified: 2013-01-07 12:13:39.737
-- =====================================================


CREATE View [dbo].[vwCetakSPB]
as
select A.NOBUKTI, A.NOURUT, A.TANGGAL, A.KODECUSTSUPP, 
       Case when D.USAHA<>'' then D.USAHA+'. ' else '' end+D.NamaCustSupp NamaCustSupp, 
       D.Alamat, D.Kota, D.NEGARA,
        A.NOSPP, A.NoPolKend,
        A.Container, A.NoContainer, A.NoSeal,
        A.ISCETAK, A.IDUser,
        B.URUT, B.KODEBRG, C.NamaBrg Namabrg, '' Jns_Kertas, ''Ukr_Kertas, B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.NoSat, B.ISI,
        B.UrutSPP, E.Nobukti Noso,E.TglSO,E.NOPO NoPesanan, A1.NamaKirim, A1.AlamatKirim,
        (Select NOSPB from DBNOMOR) NODOK, B.Namabrg NamaBrgkom,
        case when B.NOSAT = 1 then b.SAT_1 else b.SAT_2 end as satuanas,
        case when B.NOSAT = 1 then B.QNT else b.QNT2 end as QNTAS,
        A.Catatan
From DBSPB A
Left Outer Join DBSPBDET B on B.NoBukti=A.NoBukti
left outer join (Select  y.nobukti, y.tanggal, x.Urut, x.NoSO, x.UrutSO, y.NamaKirim, y.AlamatKirim
                 From dbSPPDet x
                      Left Outer join dbSPP y on y.nobukti=x.nobukti
                 )A1 on A1.NoBukti=B.NoSPP and A1.Urut=B.UrutSPP
Left Outer Join dbBarang c On C.KodeBrg=B.KodeBrg
Left Outer Join vwBrowsCust D On D.KodeCustSupp=A.KodeCustSupp
Left Outer join (Select x.Nobukti,y.Tanggal TglSO,'' Nopo, x.URUT
                 from DBSODET x      
                      Left Outer join DBSO y on y.NOBUKTI=x.NOBUKTI               
                 group by x.Nobukti, y.TANGGAL, x.URUT) E on E.Nobukti=A1.NoSO and E.URUT=A1.UrutSO

GO

-- View: vwCetakSpbLampiran
-- Created: 2011-11-03 09:21:09.603 | Modified: 2013-01-07 13:44:18.357
-- =====================================================

CREATE view [dbo].[vwCetakSpbLampiran]
as
Select Case when A.NOROLL<>'' then A.NOROLL+' ' else '' end+
       Case when A.NOPALLET<>'' then A.NOPALLET+' ' else '' end+ 
       Case when A.NOLOT<>'' then A.NOLOT+' ' else '' end       
        NoLot, 
       B.Namabrg NamaBrgKom, C.Jns_Kertas, C.Ukr_Kertas, C.GSM,
       A.Qnt,A.Qnt2, A.Sat_1, A.Sat_2, A.NetW, A.GrossW, A.Keterangan,
       B.NoBukti,B.Tanggal, B.NoPolKend, B.NoContainer, B.NoSeal, A.Urut, A.UrutSPB,
       Case when A.Nosat=1 then a.Qnt
            when a.Nosat=2 then a.Qnt2
            else 0
       end Qty,
       Case when A.Nosat=1 then a.Sat_1
            when a.Nosat=2 then a.Sat_2
            else ''
       end Satuan,
       (Select NoSPB from dbnomor) NODok, b.NoSPP
From dbSPBLampiran A
     left Outer join (Select y.NoBukti, Y.Tanggal, y.NoContainer, y.NoPolKend, y.NoSeal,
                             x.Urut, x.KodeBrg, x.Namabrg, x.NoSPP
                      from dbSPBDet x
                           left Outer join dbSPB y on y.NoBukti=x.NoBukti
                     ) B on B.NoBukti=A.NoSPB and B.Urut=A.UrutSPB
     left Outer join (Select kodebrg, namabrg, SAT1, Sat2, '' Jns_Kertas, '' Ukr_Kertas, 0.00 GSM from DBBARANG) C on C.KODEBRG=B.KodeBrg






GO

-- View: vwCetakSPP
-- Created: 2011-12-28 07:17:00.580 | Modified: 2013-01-04 15:35:43.570
-- =====================================================




CREATE View [dbo].[vwCetakSPP]
as


select a.NoBukti,a.NoSO NoSC,b.NoPesan,b.Tanggal,a.KodeBrg,d.NAMABRG namabrgdbbrg ,a.NamaBrg namabrgdbdet ,''Jns_Kertas,''Ukr_Kertas,
       c.NamaCust NAMACUSTSUPP,c.Alamat,'' ALAMAT1,''ALAMAT2,''ALAMATPKP1,'' ALAMATPKP2,c.kodekota Kota,
       case when a.NOSAT = 1 then a.SAT_1 else a.SAT_2 end satuan,
       case when a.NOSAT = 1 then a.QNT else a.QNT2 end QNT,
       b.TglKirim,'' ShippingMark,b.NoLC,b.Packing,b.Catatan, a.Urut
from 
dbSPPDet a 
left outer join dbSPP b on a.NoBukti = b.NoBukti
Left Outer Join vwOutSO_SPP E on E.Nobukti=a.NoSO and E.urut=a.UrutSO
Left Outer join DBSO G on G.Nobukti=A.NoSO
left outer join vwBrowsCustomer c on b.KodeCustSupp = c.KODECUST and c.Sales=G.KODESLS
left outer join DBBARANG d on a.KodeBrg = d.KODEBRG














GO

-- View: vwCost
-- Created: 2015-04-20 09:05:28.237 | Modified: 2015-04-20 09:05:28.237
-- =====================================================







CREATE VIEW [dbo].[vwCost]

AS
------ SALES
select  a.KodeCost,a.KodeSubCost,a.tanggal,C.NIK, C.Nama, A.DEBET Saldo, A.PERKIRAAN KodePerk,D.KETERANGAN 
from vwTransaksi A
left outer join DBPERKCOST B on B.Perkiraan = A.PERKIRAAN and B.KodeCost = A.KodeCost
left outer join dbKaryawan C on C.KodeCost = A.KodeCost and C.KeyNIK = A.KodeSubCost
left outer join DBPERKIRAAN D on d.Perkiraan=a.PERKIRAAN
where A.PERKIRAAN in (select PERKIRAAN from DBPERKCOST where KodeCost='SALES')
union all
select a.KodeCost,a.KodeSubCost,a.tanggal,C.NIK, C.Nama, -A.DEBET Saldo, A.LAWAN KodePerk,d.Keterangan
from vwTransaksi A
left outer join DBPERKCOST B on B.Perkiraan = A.PERKIRAAN and B.KodeCost = A.KodeCost
left outer join dbKaryawan C on C.KodeCost = A.KodeCost and C.KeyNIK = A.KodeSubCost
left outer join DBPERKIRAAN D on d.Perkiraan=a.LAWAN
where A.LAWAN in (select PERKIRAAN from DBPERKCOST where KodeCost='SALES' )
------ KENDARAAN
union all 
select  a.KodeCost,a.KodeSubCost,a.tanggal,C.KODEKEND, C.NAMAKEND, A.DEBET Saldo, A.PERKIRAAN KodePerk,D.KETERANGAN 
from vwTransaksi A
left outer join DBPERKCOST B on B.Perkiraan = A.PERKIRAAN and B.KodeCost = A.KodeCost
left outer join DBKENDARAAN C on C.KodeCost = A.KodeCost and C.KODEKEND = A.KodeSubCost
left outer join DBPERKIRAAN D on d.Perkiraan=a.PERKIRAAN
where A.PERKIRAAN in (select PERKIRAAN from DBPERKCOST where KodeCost='KEND')
union all
select a.KodeCost,a.KodeSubCost,a.tanggal,C.KODEKEND, C.NAMAKEND, -A.DEBET Saldo, A.LAWAN KodePerk,d.Keterangan
from vwTransaksi A
left outer join DBPERKCOST B on B.Perkiraan = A.PERKIRAAN and B.KodeCost = A.KodeCost
left outer join DBKENDARAAN C on C.KodeCost = A.KodeCost and C.KODEKEND = A.KodeSubCost
left outer join DBPERKIRAAN D on d.Perkiraan=a.LAWAN
where A.LAWAN in (select PERKIRAAN from DBPERKCOST where KodeCost='KEND' )









GO

-- View: vwCrossCheckBPPB
-- Created: 2011-12-16 17:07:49.720 | Modified: 2011-12-19 15:19:45.717
-- =====================================================

CREATE View [dbo].[vwCrossCheckBPPB]
as
Select *
from (Select x.Nobukti BPPB_Nobukti, x.Tanggal BPPB_Tanggal, x.Kodebag BPPB_kodebag, x.kodeBiaya BPPB_Kodebiaya, 
             x.SOP BPPB_SOP, x.KodeMesin BPPB_Kodemesin, x.KodeJnsPakai BPPB_KodejnsPakai, 
             x.JnsKertas BPPB_jnsKertas, x.IDUSER BPPB_IDUser, 
             x.JnsPakai BPPB_jnsPakai, x.Perk_Investasi BPPB_PerkInvestasi, x.Kodegdg BPPB_kodegdg,
             y.urut BPPB_Urut, y.kodebrg BPPB_kodebrg, y.Sat_1 BPPB_Sat_1 , y.Sat_2 BPPB_Sat_2 , y.Nosat BPPB_Nosat, 
             Case when y.Nosat=1 then y.Qnt 
                  when y.Nosat=2 then y.Qnt2
                  else 0
             end BPPB_Qty,
             Case when y.Nosat=1 then y.Sat_1
                  when y.Nosat=2 then y.Sat_2
                  else ''
             end BPPB_Satuan,
             y.Isi BPPB_Isi, y.Qnt BPPB_Qnt, y.Qnt2 BPPB_Qnt2, y.TglTiba BPPB_TglTiba, 
             y.TglButuh BPPB_TglButuh, y.MyID BPPB_MyID, y.isInspeksi BPPB_isInspeksi, 
             y.Keterangan BPPB_Keterangan, y.QntBtl BPPB_QntBatal, y.Qnt2Btl BPPB_Qnt2Btl, 
             y.UrutTrans BPPB_UrutTrans, y.HPP BPPB_HPP, y.Nnet BPPB_Nnet,
             Case when x.JnsPakai=0 then 'Stock'
                  when x.JnsPakai=1 then 'Investasi'
                  when x.JnsPakai=2 then 'Rep & Pem Teknik'
                  when x.JnsPakai=3 then 'Rep & Pem Komputer'
                  when x.JnsPakai=4 then 'Rep & Pem Peralatan'
             end BPPB_MyJnsPakai,
             z.*                      
      from DBPermintaanBrg x
           left Outer join DBPermintaanBrgDET y on y.Nobukti=x.Nobukti
           left Outer join (Select x.Nobukti BBPPB_Nobukti, x.Tanggal BBPPB_Tanggal,
                                   y.urut BBPPB_urut,y.kodebrg BBPPB_Kodebrg, 
											  Case when y.Nosat=1 then y.Qnt 
										    		 when y.Nosat=2 then y.Qnt2
													 else 0
											  end BBPPB_Qty,
											  Case when y.Nosat=1 then y.Sat_1
											 		 when y.Nosat=2 then y.Sat_2
													 else ''
											  end BBPPB_Satuan,
											  y.Sat_1 BBPPB_Sat_1, y.Sat_2 BBPPB_Sat_2, 
											  y.Isi BBPPB_Isi, y.Nosat BBPPB_Nosat, y.Qnt BBPPB_Qnt, Y.Qnt2 BBPPB_Qnt2, 
											  Y.NoBPPB BBPPB_NoBPPB, Y.UrutBPPB BBPPB_UrutBPPB, 
											  y.Keterangan BBPPB_Keterangan, y.MyID BBPPB_MyID, y.UrutTrans BBPPB_UrutTrans, 
											  y.HPP BBPPB_HPP,y.nnet BBPPB_nNet
                      from DBBatalMintaBrg x
                      left Outer join DBBatalMintaBrgDET y on y.Nobukti=x.Nobukti) z on z.BBPPB_NoBPPB=x.Nobukti and z.BBPPB_UrutBPPB=y.urut) a                                                          
     left Outer join (Select x. Nobukti BPB_Nobukti, x.Tanggal BPB_Tanggal, 
                             x.Kodebag BPB_kodebag, x.kodeBiaya BPB_KodeBiaya, 
                             x.SOP BPB_SOP, x.KodeMesin BPB_KodeMesin, 
                             x.KodeJnsPakai BPB_KodeJnsPakai, x.JnsKertas BPB_JnsKertas, IDUser BPB_IDUSER, 
                             x.NoBPPB BPB_NOBPPB,x.JnsPakai BPB_JnsPakai, 
                             x.Perk_Investasi BPB_Perk_Investasi, x.Kodegdg BPB_Kodegdg,
                             y.urut BPB_Urut, y.kodebrg BPB_Kodebrg, 
                             Case when y.Nosat=1 then y.Qnt 
											 when y.Nosat=2 then y.Qnt2
									 		 else 0
									  end BPB_Qty,
									  Case when y.Nosat=1 then y.Sat_1
									 		 when y.Nosat=2 then y.Sat_2
											 else ''
									  end BPB_Satuan,
                             y.Sat_1 BPB_Sat_1, y.Sat_2 BPB_Sat_2, y.Nosat BPB_Nosat, 
                             y.Isi BPB_ISI, y.Qnt BPB_Qnt, y.Qnt2 BPB_Qnt2, 
                             y.TglTiba BPB_TglTiba, y.MyID BPB_MyID, 
                             y.NoPermintaan BPB_NoPermintaan, 
                             y.UrutPermintaan BPB_UrutPermintaan, 
                             y.IsInspeksi BPB_IsInspeksi, 
                             y.UrutTrans BPB_UrutTrans, y.KetDet BPB_KetDet, y.HPP BPB_HPP, Y.NNet BPB_NNet,
                             Case when x.JnsPakai=0 then 'Stock'
											 when x.JnsPakai=1 then 'Investasi'
											 when x.JnsPakai=2 then 'Rep & Pem Teknik'
											 when x.JnsPakai=3 then 'Rep & Pem Komputer'
											 when x.JnsPakai=4 then 'Rep & Pem Peralatan'
									  end BPB_MyJnsPakai,
                             z.*
                      from DBPenyerahanBrg x
                      left Outer join DBPenyerahanBrgDET y on y.Nobukti=x.Nobukti
                      left outer join (Select x.Nobukti RBPB_Nobukti, x.Tanggal RBPB_Tanggal, x.Kodebag RBPB_KodeBag, 
															 x.kodeBiaya RBPB_Kodebiaya, x.SOP RBPB_SOP, x.KodeMesin RBPB_kodeMesin, x.KodeJnsPakai RBPB_KodeJnsPakai, 
															 x.JnsKertas RBPB_JnsKertas, x.IDUser RBPB_IDUSER,                             
															 x.JnsPakai RBPB_JnsPakai, x.Perk_Investasi RBPB_Perk_Investasi,
															 y.urut RBPB_urut, y.kodebrg RBPB_kodebrg, 
															 Case when y.Nosat=1 then y.Qnt 
																	 when y.Nosat=2 then y.Qnt2
									 								 else 0
															  end RBPB_Qty,
															  Case when y.Nosat=1 then y.Sat_1
									 								 when y.Nosat=2 then y.Sat_2
																	 else ''
															  end RBPB_Satuan,
															 y.Sat_1 RBPB_Sat_1, 
															 y.Sat_2 RBPB_Sat_2, y.Nosat RBPB_Nosat, y.Isi RBPB_isi, 
															 y.Qnt RBPB_qnt, y.Qnt2 RBPB_Qnt2, y.TglTiba RBPB_TglTiba, y.MyID RBPB_MyID, 
															 y.NoPenyerahan RBPB_NoPenyerahan, y.UrutPenyerahan RBPB_urutPenyerahan, 
															 y.IsInspeksi RBPB_IsInspeksi, y.UrutTrans RBPB_UrutTrans, y.KetDet RBPB_KetDet, 
															 y.HPP RBPB_HPP, y.NNet RBPB_NNet,
															 Case when x.JnsPakai=0 then 'Stock'
																	 when x.JnsPakai=1 then 'Investasi'
																	 when x.JnsPakai=2 then 'Rep & Pem Teknik'
																	 when x.JnsPakai=3 then 'Rep & Pem Komputer'
																	 when x.JnsPakai=4 then 'Rep & Pem Peralatan'
															  end RBPB_MyJnsPakai
													from DBRPenyerahanBrg x
														  left outer join DBRPenyerahanBrgDET y on y.Nobukti=y.Nobukti)z on z.RBPB_NoPenyerahan=x.Nobukti and z.RBPB_urutPenyerahan=y.Urut) b on b.BPB_NoPermintaan=a.BPPB_Nobukti and b.BPB_UrutPermintaan=a.BPPB_Urut    
   left outer join (select  x.Nobukti PPL_Nobukti,x.Tanggal PPL_Tanggal, x.TglKirim PPL_TglKirim, 
                            x.IDUser PPL_IDUser, x.RefNoPermintaan PPL_RefNoPermintaan, x.RefBagPermintaan PPL_RefBagPermintaan, 
                            x.RefNamaBagPermintaan PPL_RefNamaBagPermintaan, x.RefTglPermintaan PPL_RefTglPermintaan,
                            y.urut PPL_urut, y.kodebrg PPL_kodebrg, 
                            Case when y.Nosat=1 then y.Qnt 
											 when y.Nosat=2 then y.Qnt2
									 		 else 0
									  end PPL_Qty,
									  Case when y.Nosat=1 then y.Sat_1
									 		 when y.Nosat=2 then y.Sat_2
											 else ''
									  end PPL_Satuan,y.Sat_1 PPL_Sat_1, y.Sat_2 PPL_Sat_2, y.Nosat PPL_Nosat, 
                            y.Isi PPL_isi, y.Qnt PPL_Qnt, y.Qnt2 PPL_Qnt2, y.TglTiba PPL_TglTiba, y.MyID PPL_MyId, 
                            y.NoPermintaan PPL_NoPermintaan, y.UrutPermintaan PPL_UrutPermintaan, y.Keterangan PPL_Keterangan, 
                            y.QntBtl PPL_QntBtl, y.Qnt2Btl PPL_Qnt2Btl, y.UrutTrans PPL_UrutTrans, y.Pelaksana PPL_Pelaksan, 
                            y.HPP PPL_HPP, Y.NNet PPL_NNet,
                            z.*
                    from DBPPL x
                         left outer join DBPPLDET y on y.Nobukti=x.Nobukti
                         left outer join (Select x.Nobukti BPL_Nobukti, x.Tanggal BPL_Tanggal, x.IDUser BPL_IDuser, 
                                                 y.urut BPL_urut, y.kodebrg BPL_Kodebrg, 
                                                 Case when y.Nosat=1 then y.Qnt 
																		 when y.Nosat=2 then y.Qnt2
									 									 else 0
																  end BPL_Qty,
																  Case when y.Nosat=1 then y.Sat_1
									 									 when y.Nosat=2 then y.Sat_2
																		 else ''
																  end BPL_Satuan,
                                                 y.Sat_1 BPL_Sat_1, 
                                                 y.Sat_2 BPL_Sat_2, y.Isi BPL_isi, y.Nosat BPL_nosat, 
                                                 y.Qnt BPL_Qnt, y.Qnt2 BPL_Qnt2, y.TglTiba BPL_TglTiba, y.MyID BPL_MyID, 
                                                 y.NoPPL BPL_NoPPL, y.UrutPPL BPL_UrutPPL, y.Keterangan BPL_Keterangan, 
                                                 y.NoBatalMintaBrg BPL_NoBatalMintaBrg, y.UrutBatalMintaBrg BPL_UrutBatalMintaBrg, 
                                                 y.UrutTrans BPL_UrutTrans,y.HPP BPL_HPP, y.NNet BPL_NNet
                                          from DBBatalPPL x
                                               left outer join DBBatalPPLDET y on y.Nobukti=x.Nobukti) z on z.BPL_NoPPL=x.Nobukti and z.BPL_UrutPPL=y.urut) c on c.PPL_NoPermintaan=a.BPPB_Nobukti and c.PPL_UrutPermintaan=a.BPPB_Urut
   left outer join (select x.NOBUKTI PO_Nobukti, x.TANGGAL PO_Tanggal, x.TglJatuhTempo PO_TgljatuhTempo, x.KODECUSTSUPP PO_kodecustsupp, 
                           x.RefInt PO_RefInt, x.RefVen PO_RefVendor, x.KODEVLS PO_Kodevls, x.KURS PO_Kurs, 
                           x.PPN PO_PPN, x.TIPEBAYAR PO_TipeBayar, x.HARI PO_Hari, x.TIPEDISC PO_TipeDisc, x.DISC PO_DISC, x.DISCRP PO_DISCRP, 
                           x.NILAIPOT PO_NilaiPot,x.NILAIDPP PO_NilaiDPP, x.NILAIPPN PO_NilaiPPN, 
                           x.NILAINET PO_NilaiNet, x.NILAIPOTRp PO_NilaiPotRp, x.NILAIDPPRp PO_NilaiDPPRp, x.NILAIPPNRp PO_NilaiPPnRp, 
                           x.NILAINETRp PO_NilaiNetRp, x.ISCETAK PO_IsCetak, x.Tipe PO_Tipe, x.IsLengkap PO_Lengkap, 
                           x.PPH PO_PPh, x.Freight PO_Freight, x.Lain2 PO_Lain2, x.IDUser PO_IDUser, 
                           x.RevisiKe PO_RevisiKe,x.TanggalPO PO_TanggalPO,  
                           y.URUT PO_Urut, y.NoPPL PO_NOPPL, y.UrutPPL PO_UrutPPL, 
                           y.KODEBRG PO_Kodebrg,
                           Case when y.Nosat=1 then y.Qnt 
											 when y.Nosat=2 then y.Qnt2
									 		 else 0
									  end PO_Qty,
									  Case when y.Nosat=1 then y.Sat_1
									 		 when y.Nosat=2 then y.Sat_2
											 else ''
									  end PO_Satuan,
                           y.QNT PO_Qnt, y.QNT2 PO_Qnt2, y.SAT_1 PO_Sat_1, y.SAT_2 PO_Sat_2, 
                           y.Nosat PO_Nosat, y.ISI PO_Isi, y.Toleransi PO_Toleransi, y.HARGA PO_Harga, 
                           y.DiscP1 PO_DiscP1, y.DiscRp1 PO_DiscRp1, y.DiscP2 PO_DiscP2, y.DiscRp2 PO_DiscRp2, 
                           y.DiscP3 PO_Discp3, y.DiscRp3 PO_DiscRp3, y.DiscP4 PO_DiscP4, y.DiscRp4 PO_DiscRp4, 
                           y.DISCTOT PO_DiscTot, y.HRGNETTO PO_HrgNetto, y.NDISKON PO_NDiskon, y.NDISKONTOT PO_NDiskonTot, 
                           y.BRUTTO PO_Brutto, y.SUBTOTAL PO_SubTotal, y.NDPP PO_NDPP, y.NPPN PO_NPPn, y.NNET PO_NNet,
                           y.SUBTOTALRp PO_SubTotalRp, y.NDPPRp PO_NdppRp, y.NPPNRp PO_nPPnRp, y.NNETRp PO_NnetRp, 
                           y.NOPO PO_NOPO, y.MyID PO_MyID, y.Catatan PO_Catatan, y.QntBtl PO_QntBtl, 
                           y.Qnt2Btl PO_Qnt2Btl, y.UrutTrans PO_UrutTrans, y.TglKirimPO PO_TglKirimPO,
                           z.*
                    from DBPO x
                         left outer join DBPODET y on y.NOBUKTI=x.NOBUKTI
                         left outer join (select  x.Nobukti BPO_NoBukti, x.Tanggal BPO_Tanggal, x.JenisBatal BPO_JenisBatal,
                                                  y.urut BPO_Urut, y.kodebrg BPO_kodebrg, 
                                                  Case when y.Nosat=1 then y.Qnt 
																		 when y.Nosat=2 then y.Qnt2
									 									 else 0
																  end BPO_Qty,
																  Case when y.Nosat=1 then y.Sat_1
									 									 when y.Nosat=2 then y.Sat_2
																		 else ''
																  end BPO_Satuan,
                                                  y.Sat_1 BPO_Sat_1, y.Sat_2 BPO_Sat_2, 
                                                  y.Nosat BPO_Nosat, y.Isi BPO_Isi, y.Qnt BPO_Qnt, y.Qnt2 BPO_Qnt2, 
                                                  y.MyID BPO_MyID, y.NoPO BPO_NoPO, y.UrutPO BPO_UrutPO, 
                                                  y.Keterangan BPO_Keterangan, y.UrutTrans BPO_UrutTans, 
                                                  y.HPP BPO_Hpp, y.NNet BPO_Nnet
                                          from DBBatalPO x
                                               left outer join DBBatalPODET y on y.Nobukti=x.Nobukti) z on z.BPO_NoPO=x.NOBUKTI and z.BPO_UrutPO=y.URUT) d on d.PO_NOPPL=c.PPL_Nobukti and d.PO_UrutPPL=c.PPL_urut
                                               
                                               
                          
                      
     

GO

-- View: vwCUSTSUPP
-- Created: 2014-07-10 09:42:03.920 | Modified: 2014-07-10 09:42:03.920
-- =====================================================

CREATE View [dbo].[vwCUSTSUPP]
as
     
select	A.KODECUSTSUPP, A.NAMACUSTSUPP, A.ALAMAT1, A.ALAMAT2, A.Kota,  
	A.TELPON, A.FAX, A.EMAIL, A.KODEPOS, A.NEGARA, A.NPWP, 
	A.Tanggal, A.PLAFON, A.HARI, A.HARIHUTPIUT, A.BERIKAT, A.USAHA, 
	A.JENIS, A.NAMAPKP, A.ALAMATPKP1, A.ALAMATPKP2, A.KOTAPKP, 
	A.Sales, A.KodeVls, A.KodeExp, A.KodeTipe, A.IsPpn, A.IsAktif, A.Kind, 
	A.ContactP, A.Alamat1ContP, A.Alamat2ContP, A.KotaContP, A.NegaraContP, 
	A.TelpContP, A.FaxContP, A.EmailContP, A.KODEPOSContP, A.HPContP, 
	A.SyaratPenerimaan, A.SyaratPembayaran, A.Agent, A.Alamat1A, A.Alamat2A, 
	A.KotaA, A.NegaraA, A.ContactA, A.TelpA, A.FaxA, A.EmailA, A.KODEPOSA, 
	A.HPA, A.EmailContA, A.PortOfLoading, A.CountryOfOrigin, 
	A.TglInput, A.iskontrak, A.PPN, A.HargaKe,
	A.ALAMAT1+case when ltrim(A.Alamat2)='' then '' else CHAR(13)+A.ALAMAT2 end ALAMAT,
	A.ALAMAT1+case when ltrim(A.Alamat2)='' then '' else CHAR(13)+A.ALAMAT2 end+CHAR(13)+A.Kota ALAMATKOTA,
	A.Usaha+case when isnull(A.Usaha,'')='' then '' else '. ' end+A.NamaCustSupp Nama,
	A.ALAMATPKP1+case when ltrim(A.ALAMATPKP2)='' then '' else CHAR(13)+A.ALAMATPKP2 end ALAMATPKP,
	A.ALAMATPKP1+case when ltrim(A.ALAMATPKP2)='' then '' else CHAR(13)+A.ALAMATPKP2 end+CHAR(13)+A.KOTAPKP ALAMATKOTAPKP,
	case when A.iskontrak is null then 0 when A.iskontrak=0 then 0 when A.iskontrak=1 then 1 end xKontrak,
	cast(isnull(K.NamaKota,A.KOTA) as varchar(50)) NamaKota, cast(isnull(K.KodeArea,'') as varchar(20)) KodeArea, cast(isnull(Ar.NAMAAREA,'') as varchar(50)) NamaArea, 
	case when A.HargaKe=0 then 'Harga Jual 1'
		when A.HargaKe=1 then 'Harga Jual 2'
		when a.HargaKe=2 then 'Harga Jual 3'
		else ''
	end KetHarga,
	cast(case when A.PPN=0 then 'NONE' when A.PPN=1 then 'Exclude' when A.PPN=2 then 'Include' end as varchar(50)) MyPPN,
	cast(case when A.IsAktif=0 then 'Tidak Aktif' when A.IsAktif=1 then 'Aktif' end as varchar(50)) MyAktif
from	DBCUSTSUPP A
left outer join DBKOTA K on K.KodeKota=A.KOTA
left outer join DBAREA Ar on Ar.KODEAREA=K.KodeArea







GO

-- View: vwDetailKoreksi
-- Created: 2013-06-03 14:32:21.123 | Modified: 2013-06-03 14:32:21.123
-- =====================================================







CREATE View [dbo].[vwDetailKoreksi]
as
Select A.Nobukti,A.tanggal,A.note,A.ISCetak,b.kodebrg,C.namaBrg,c.KodeGrp,c.KodeSubGrp,
       b.SaldoComp,b.QntOpname,b.Selisih,
       A.Kodegdg, b.Qntdb,B.QntCr, c.Sat1 Satuan,b.nosat,B.isi,b.Harga,b.urut,d.nama NamaGDG,
       (b.qntdb-b.qntcr)*b.harga as Total,
       (b.qntdb)*b.harga  HrgAdi,
       (b.qntcr)*b.harga HrgAdo, b.HPP,
       Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi 
From dbKoreksi A 
     left outer join dbKoreksiDet B on b.nobukti=a.nobukti 
     left outer join dbBarang C on c.kodebrg=b.kodebrg 
     left outer join dbGudang D on d.kodegdg=A.kodegdg 












GO

-- View: vwDetailUbahKemasan
-- Created: 2013-01-03 09:08:44.647 | Modified: 2013-01-03 09:08:44.647
-- =====================================================


CREATE View vwDetailUbahKemasan
as
Select A.Nobukti,A.tanggal,A.note,A.ISCetak,b.kodebrg,C.namaBrg,
       b.Kodegdg,b.Qntdb,B.QntCr,b.Satuan,b.nosat,B.isi,b.Harga,b.urut,d.nama NamaGDG, 
       (b.qntdb-b.qntcr)*b.harga as Total, 
      (b.qntdb)*b.HPP2 HrgAdi,
      (b.qntcr)*b.hpp HrgADO,b.Hpp,b.HPP2
From dbubahKemasan A 
     left outer join dbUbahKemasanDet B on b.nobukti=a.nobukti 
     left outer join dbBarang C on c.kodebrg=b.kodebrg 
     left outer join dbGudang D on d.kodegdg=b.kodegdg 
    





GO

-- View: vwGroupCustSupp
-- Created: 2012-06-07 15:03:23.640 | Modified: 2012-06-07 15:03:23.640
-- =====================================================
CREATE View [dbo].[vwGroupCustSupp]
as
     
select case when isnull(Agent,'')='' then KODECUSTSUPP else ISNULL(Agent,'') end KodeCustSupp 
from DBCUSTSUPP
group by case when isnull(Agent,'')='' then KODECUSTSUPP else ISNULL(Agent,'') end



GO

-- View: vwGudang
-- Created: 2011-11-23 18:45:57.493 | Modified: 2011-11-23 18:45:57.493
-- =====================================================
Create View dbo.vwGudang
as
Select * from DBGUDANG

GO

-- View: vwHutPiut
-- Created: 2013-06-03 11:08:31.860 | Modified: 2015-04-20 11:09:40.500
-- =====================================================



CREATE VIEW [dbo].[vwHutPiut]
 
AS
SELECT    NoFaktur, NoRetur, TipeTrans, 
	upper(KodeCustSupp) KodeCustSupp, NoBukti, NoMsk, Urut, Tanggal, JatuhTempo, 
	Debet, Kredit, Saldo, Valas, Kurs, DebetD, KreditD, SaldoD, 
	KodeSales, Tipe, Perkiraan, Catatan, NOINVOICE, KodeVls_, Kurs_,FlagSimbol,KBLB
FROM dbo.DBHUTPIUT







GO

-- View: vwHutPiutBelumlunas
-- Created: 2011-01-24 10:09:24.217 | Modified: 2011-01-24 10:09:24.217
-- =====================================================
Create View dbo.vwHutPiutBelumlunas
as
SELECT DISTINCT NoFaktur, KodeCustSupp
FROM  dbo.vwHutpiut
GROUP BY NoFaktur, KodeCustSupp
HAVING (SUM(Case when Tipe='PT' then Debet-Kredit
                 when Tipe='HT' then Kredit-Debet
                 else 0
            end) <> 0)
GO

-- View: vwJabatan
-- Created: 2011-12-08 20:34:42.440 | Modified: 2011-12-08 20:34:42.440
-- =====================================================
create View vwJabatan
as
Select * from DBJABATAN
GO

-- View: vwJenis
-- Created: 2011-11-23 18:45:57.660 | Modified: 2011-11-23 18:45:57.660
-- =====================================================
Create View dbo.vwJenis
as
Select A.*
from DBJenis A     

GO

-- View: vwJenisJadi
-- Created: 2011-12-08 19:36:36.700 | Modified: 2011-12-08 19:36:36.700
-- =====================================================

Create View [dbo].[vwJenisJadi]
as
Select A.*
from DBJENISBRGJADI A     


GO

-- View: VwKartuBatch
-- Created: 2014-11-19 13:11:19.423 | Modified: 2014-11-19 13:11:19.423
-- =====================================================


Create View VwKartuBatch
as
select B.Tanggal,A.Nobukti,A.Nobatch,A.Kodebrg,C.NamaBrg,
ISnull(A.Qnt1Terima,0)-ISnull(A.Qnt1Reject,0) Qnt1,Isnull(A.Qnt2Terima,0)-ISnull(A.Qnt2Reject,0) Qnt2,
'BPBL' ID
from dbbelidet A
left outer join dbbeli B on A.nobukti=B.nobukti
left outer join dbbarang C on A.KODEBRG=C.KODEBRG
Union All
select B.Tanggal,A.Nobukti,A.Nobatch,A.Kodebrg,C.NAMABRG,
-A.Qnt Qnt,-A.Qnt2 Qnt,'BSPP' ID
from DbSPPDet A
left outer join dbSPP B on A.nobukti=B.nobukti
left outer join dbbarang C on A.KODEBRG=C.KODEBRG
Union All
select B.Tanggal,A.Nobukti,A.Nobatch,A.Kodebrg,C.NAMABRG,
-A.Qnt Qnt,-A.Qnt2 Qnt,'BRPB' ID
from DBRBELIDET A
left outer join DBRBELI B on A.nobukti=B.nobukti
left outer join dbbarang C on A.KODEBRG=C.KODEBRG
Union All
select B.Tanggal,A.Nobukti,A.Nobatch,A.Kodebrg,C.NAMABRG,
A.Qnt Qnt,A.Qnt2 Qnt,'RPNJ' ID
from dbSPBRJualDet A
left outer join dbSPBRJual B on A.nobukti=B.nobukti
left outer join dbbarang C on A.KODEBRG=C.KODEBRG

GO

-- View: vwKartuInvocePL
-- Created: 2013-05-13 12:08:51.547 | Modified: 2013-05-13 12:08:51.547
-- =====================================================



create view [dbo].[vwKartuInvocePL]
as
SELECT 'AWL' AS tipe, '00' Prioritas, '' KodeArea,'' Kodekota,'' KodeSls,b.Kodebrg, '' KodeGdg,0.00 QNT,0.00 NilaiDPP,0.00 NilaiPPN,0.00 jumlahNetto, 
       (b.qntAwal) AS QntDB, (b.Qnt2Awal) Qnt2DB, (b.HrgAwal) HrgDebet, 
       0.00 QntCr,  0.00 Qnt2Cr, 0.00 HrgKredit,
       (b.qntAwal) AS QntSaldo, (b.Qnt2Awal) Qnt2Saldo, (b.HrgAwal) HrgSaldo, 
       Dateadd(MM, 0, Cast(CASE WHEN b.Bulan < 10 THEN '0' ELSE '' END + Cast(b.Bulan AS varchar(2))+'-01-'+ 
                           Cast(b.Tahun AS varchar(4)) AS Datetime)) Tanggal, b.Bulan, b.Tahun, 'Saldo Awal' Nobukti,
      '' KodeCustSupp, '' Keterangan, '' IDUSER, B.HRGRATA HPP
FROM  DBSTOCKBRG b
where b.QNTAWAL<>0 or b.QNT2AWAL<>0
Union All
Select 	'IPL' Tipe, 'A2' Prioritas, e.KodeArea Kodearea,e.KodeKota,f.KeyNik Kodesls,B.KodeBrg, '' KodeGdg,Sum(B.QNT)Qnt,Sum(B.NDPP) NilaiDpp ,Sum(B.NPPN) NilaiPPN,Sum(b.NNET) Jumlahnetto,
   Sum(Isnull(B.Qnt,0)) QntDb, Sum(Isnull(B.Qnt2,0))-Sum(Isnull(B.Qnt2,0)) Qnt2Db, Sum(B.NDPP) HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	Sum(Isnull(B.Qnt,0)) QntSaldo, Sum(Isnull(B.Qnt2,0)) Qnt2Saldo, Sum(B.NDPP) HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	A.KodeCustSupp, '' Keterangan, ''IDUser,
	Sum(B.NDPP/Case when B.Nosat=1 then (B.Qnt)
	                       when B.Nosat=2 then (B.Qnt2)
	                  end)  HPP
from 	DBInvoicePL A
left outer join dbInvoicePLDet B on B.NoBukti=A.NoBukti
left outer join DBBARANG C on C.KODEBRG=B.KodeBrg
left outer join DBCUSTSUPP D on D.KODECUSTSUPP=a.KodeCustSupp 
left outer join DBKOTA E on E.KodeKota=D.Kota
left outer join DBSALESCUSTOMER f on f.KodeCustSupp=d.KODECUSTSUPP
Group By B.KodeBrg, A.TANGGAL,A.NOBUKTI,A.KodeCustSupp,e.KodeArea,f.KeyNik,e.KodeKota
union all
Select 	'RIPL' Tipe, 'B1' Prioritas,e.KodeArea kodearea,e.KodeKota ,f.KeyNik Kodesls,B.KodeBrg, '' KodeGdg,Sum(Isnull(B.QNT,0)),Sum(B.NDPP) NilaiDpp ,Sum(B.NPPN) NilaiPPN,Sum(b.NNET) Jumlahnetto,
   0.00 QntDb, 0.00 Qnt2Db, 0.00 HrgDebet,
	Sum(Isnull(B.Qnt,0)) QntCr, Sum(Isnull(B.Qnt2,0)) Qnt2Cr, Sum(B.NDPP) HrgKredit,
	Sum(-1*(Isnull(B.Qnt,0))) QntSaldo, SUM(-1*(Isnull(B.Qnt2,0))) Qnt2Saldo, SUM(-1*B.NDPP) HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	A.KODECUSTSUPP, '' Keterangan, ''IDUser,
   SUM( B.NDPP/Case when B.Nosat=1 then B.QNT 
	                       when B.Nosat=2 then B.QNT2 
	                  end) HPP
from 	DBRInvoicePL A
left outer join DBRInvoicePLDET B on B.NoBukti=A.NoBukti
left outer join DBBARANG C on C.KODEBRG=B.KodeBrg
left outer join DBCUSTSUPP D on D.KODECUSTSUPP=a.KodeCustSupp 
left outer join DBKOTA E on E.KodeKota=D.Kota
left outer join DBSALESCUSTOMER f on f.KodeCustSupp=d.KODECUSTSUPP
Group By B.KodeBrg,A.TANGGAL,A.NOBUKTI,A.KODECUSTSUPP,e.KodeArea,f.KeyNik,e.KodeKota

GO

-- View: vwKartuPersediaan
-- Created: 2011-10-13 13:03:16.273 | Modified: 2011-10-13 13:03:16.273
-- =====================================================


CREATE View [dbo].[vwKartuPersediaan]
as
Select 	'BPY' Tipe, 'B2' Prioritas, B.KodeBrg, 0.00 QntDb, 0.00 Qnt2Db,0 HrgDebet,
	B.Qnt QntCr, B.Qnt2 Qnt2Cr, 0.00 HrgKredit,
	-B.Qnt QntSaldo, -B.Qnt2 Qnt2Saldo, 0.00 HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	''KodeCustSupp, '' Keterangan, A.IDUser,
    0.00 HPP, A.Kodebag, '' NamaCustSupp
from DBPenyerahanBrg A
left outer join DBPenyerahanBrgDET B on B.NoBukti=A.NoBukti
union all
Select 	'RPB' Tipe, 'A3' Prioritas, B.KodeBrg,B.Qnt QntDb, B.Qnt2 Qnt2Db,0.00 HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	B.Qnt QntSaldo, B.Qnt2 Qnt2Saldo, 0.00 HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	''KodeCustSupp, '' Keterangan, A.IDUser,
    0.00 HPP, A.Kodebag,  '' NamaCustSupp
from DBRPenyerahanBrg A
left outer join DBRPenyerahanBrgDET B on B.NoBukti=A.NoBukti
union all
Select 	'BPB' Tipe, 'A2' Prioritas, B.KodeBrg, B.Qnt QntDb, B.Qnt2 Qnt2Db, B.NDPPRp HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	B.Qnt QntSaldo, B.Qnt2 Qnt2Saldo, B.NDPPRp HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	A.KodeCustSupp, '' Keterangan, A.IDUser,
	case when Case when B.Nosat=1 then B.QNT 
	               when B.Nosat=2 then B.QNT2 
	          end=0 then 0.00 
	    else B.NDPPRp/Case when B.Nosat=1 then B.QNT 
	                       when B.Nosat=2 then B.QNT2 
	                  end end HPP,
	'' Kodebag,  C.NamaCustSupp
from 	dbBeli A
left outer join dbBeliDet B on B.NoBukti=A.NoBukti
left outer join vwBrowsSupp C on C.Kodecustsupp=a.kodecustsupp
union all
Select 	'BRB' Tipe, 'B1' Prioritas, B.KodeBrg, 0.00 QntDb, 0.00 Qnt2Db, 0.00 HrgDebet,
	(B.Qnt-B.QNTTukar) QntCr, (B.Qnt2-B.QNT2Tukar) Qnt2Cr, B.NDPPRp HrgKredit,
	-(B.Qnt-B.QNTTukar) QntSaldo, -(B.QNT2-B.QNT2Tukar) Qnt2Saldo, -B.NDPPRp HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	A.KodeCustSupp, '' Keterangan, A.IDUser,
	case when Case when B.Nosat=1 then B.QNT 
	               when B.Nosat=2 then B.QNT2 
	          end=0 then 0.00 
	    else B.NDPPRp/Case when B.Nosat=1 then B.QNT 
	                       when B.Nosat=2 then B.QNT2 
	                  end end HPP,
	'' KodeBag,  C.NamaCustSupp
from 	dbRBeli A
left outer join dbRBeliDet B on B.NoBukti=A.NoBukti
left outer join vwBrowsSupp C on C.Kodecustsupp=a.kodecustsupp
union all
Select 	'ADI' Tipe, 'A2' Prioritas, B.KodeBrg, B.QntDb, B.QntDb2 Qnt2Db, B.QntDb*B.Harga HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	B.QntDb QntSaldo, B.QntDb2 Qnt2Saldo, B.QntDb*B.Harga HrgSaldo, 
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	'' KodeCustSupp, '' Keterangan, A.IDUser,
	B.Harga HPP, '' KodeBag,  '' NamaCustSupp
from 	dbKoreksi A
left outer join dbKoreksiDet B on B.NoBukti=A.NoBukti
where 	B.QntDb<>0 or B.QntDb2<>0
union all
Select 	'ADO' Tipe, 'B3' Prioritas, B.KodeBrg, 0.00 QntDb, 0.00 Qnt2Db, 0.00 HrgDebet,
	B.QntCr, B.QntCr2 Qnt2Cr, B.QntCr*B.HPP HrgKredit,
	-1*B.QntCr QntSaldo, -1*B.QntCr2 Qnt2Saldo, -1*B.QntCr*B.HPP HrgSaldo, 
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	'' KodeCustSupp, '' Keterangan, A.IDUser,
	B.HPP, '' KodeBag, '' NamaCustSupp
from 	dbKoreksi A
left outer join dbKoreksiDet B on B.NoBukti=A.NoBukti
where 	B.QntCr<>0 or B.QntCr2<>0









GO

-- View: vwKartuStock
-- Created: 2014-11-26 15:11:46.513 | Modified: 2014-11-26 15:11:46.513
-- =====================================================
CREATE view [dbo].[vwKartuStock]
as
SELECT 'AWL' AS Tipe, 'AWL' AS MyTipe, 'A00' Prioritas, b.Kodebrg, b.Kodegdg,0.00 QNT,0.00 NilaiDPP,0.00 NilaiPPN,0.00 jumlahNetto, 
       Sum(b.qntAwal) AS QntDB, Sum(b.Qnt2Awal) Qnt2DB, Sum(b.HrgAwal) HrgDebet, 
       0.00 QntCr,  0.00 Qnt2Cr, 0.00 HrgKredit,
       Sum(b.qntAwal) AS QntSaldo, Sum(b.Qnt2Awal) Qnt2Saldo, Sum(b.HrgAwal) HrgSaldo, 
       Dateadd(MM, 0, Cast(CASE WHEN b.Bulan < 10 THEN '0' ELSE '' END + Cast(b.Bulan AS varchar(2))+'-01-'+ 
                           Cast(b.Tahun AS varchar(4)) AS Datetime)) Tanggal, b.Bulan, b.Tahun, 
      'Saldo Awal' Nobukti, 0 Urut,
      '' KodeCustSupp, '' Keterangan, '' IDUSER, 
      case when Sum(b.qntAwal)=0 then 0 else Sum(B.HRGAwal)/Sum(b.qntAwal) end HPP,
      '' NoBukti1, '' NoBukti2
FROM  DBSTOCKBRG b
where b.QNTAWAL<>0 or b.QNT2AWAL<>0
Group by b.Kodebrg, b.Kodegdg, BULAN, TAHUN
union ALL

Select 	'PBL' Tipe, 'PBL' MyTipe, 'A10' Prioritas, B.KodeBrg, B.KodeGdg, B.QNT Qnt, B.NDPP NilaiDpp ,B.NPPN NilaiPPN, b.NNET Jumlahnetto,
   Isnull(B.Qnt1Terima,0)-Isnull(B.Qnt1Reject,0) QntDb, Isnull(B.Qnt2Terima,0)-Isnull(B.Qnt2Reject,0) Qnt2Db, B.NDPPRp HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	Isnull(B.Qnt1Terima,0)-Isnull(B.Qnt1Reject,0) QntSaldo, Isnull(B.Qnt2Terima,0)-Isnull(B.Qnt2Reject,0) Qnt2Saldo, B.NDPPRp HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.Urut,
	A.KodeSupp, d.NAMACUSTSUPP as  Keterangan, ''IDUser,
	B.NDPPRp/case when isnull(B.Qnt1Terima,0)-isnull(B.Qnt1Reject,0)=0 then 1 else isnull(B.Qnt1Terima,0)-isnull(B.Qnt1Reject,0) end   HPP,
	A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	dbBeli A
left outer join dbBeliDet B on B.NoBukti=A.NoBukti
left outer join DBBARANG C on C.KODEBRG=B.KodeBrg
left outer join dbcustsupp D on d.kodecustsupp=a.kodesupp

union all
Select 	'RPB' Tipe, 'RPB' MyTipe, 'B10' Prioritas, B.KodeBrg, A.KodeGdg,Isnull(B.QNT,0) QNT, B.NDPP NilaiDpp ,B.NPPN NilaiPPN, b.NNET Jumlahnetto,
   0.00 QntDb, 0.00 Qnt2Db, 0.00 HrgDebet,
	Isnull(B.Qnt1,0) QntCr, Isnull(B.Qnt2,0) Qnt2Cr, B.NDPP HrgKredit,
	-1*Isnull(B.Qnt1,0) QntSaldo, -1*Isnull(B.Qnt2,0) Qnt2Saldo, -1*B.NDPP HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.URUT,
	A.KodeSupp,d.namacustsupp as Keterangan, ''IDUser,
   B.NDPP/Case when B.Nosat=1 then B.Qnt1 
	                       when B.Nosat=2 then B.QNT2 
	                  end HPP,
	A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	dbRBeli A
left outer join dbRBeliDet B on B.NoBukti=A.NoBukti
left outer join DBBARANG C on C.KODEBRG=B.KodeBrg
left outer join dbcustsupp D on d.kodecustsupp=a.kodesupp
--Group By B.KodeBrg, A.KodeGdg,A.TANGGAL,A.NOBUKTI,A.KODESUPP, B.Urut
union all
Select 	'PMK' Tipe, 'PMK' MyTipe, 'B20' Prioritas, B.KodeBrg, A.KodeGdg,B.QNT QNt,0.00 NilaiDpp ,0.00 NilaiPPN,0.00 Jumlahnetto,
   0.00 QntDb, 0.00 Qnt2Db, 0.00 HrgDebet,
	Isnull(B.Qnt,0) QntCr, Isnull(B.Qnt2,0) Qnt2Cr, B.Qnt*isnull(B.HPP,0) HrgKredit,
	Isnull(B.Qnt,0)*-1 QntSaldo, Isnull(B.Qnt2,0)*-1 Qnt2Saldo, -1*B.Qnt*isnull(B.HPP,0) HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.Urut,
	''KodeSupp, '' Keterangan, ''IDUser,
	isnull(B.HPP,0) HPP,
	A.Nobukti NoBukti1, A.Nobukti NoBukti2
from 	DBPenyerahanBhn A
left outer join DBPenyerahanBhndet B on B.NoBukti=A.NoBukti
left outer join DBBARANG C on C.KODEBRG=B.KodeBrg
--Group By  B.KodeBrg, A.KodeGdg,A.Tanggal,A.Nobukti, B.Urut
union all
Select 	'RPK' Tipe, 'RPK' MyTipe, 'A20' Prioritas, B.KodeBrg, A.KodeGdg, B.QNT Qnt,0.00 NilaiDpp ,0.00 NilaiPPN,0.00 Jumlahnetto,
   B.Qnt QntDb, B.Qnt2 Qnt2Db, B.Qnt*isnull(B.HPP,0) HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit, 
	B.Qnt QntSaldo, B.Qnt2 Qnt2Saldo, B.Qnt*isnull(B.HPP,0) HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.Urut,
	''KodeSupp, '' Keterangan, ''IDUser,
	isnull(B.HPP,0) HPP,
	A.Nobukti NoBukti1, A.Nobukti NoBukti2
from 	DBRPenyerahanBhn A
left outer join DBRPenyerahanBhndet B on B.NoBukti=A.NoBukti
left outer join DBBARANG C on C.KODEBRG=B.KodeBrg
--Group By B.KodeBrg, A.KodeGdg,A.Tanggal,A.Nobukti, B.Urut
Union All
Select 	'TRI' Tipe, 'TRI' MyTipe, 'B05' Prioritas, B.KodeBrg, B.GdgTujuan,B.QNT Qnt,0.00 NilaiDpp ,0.00 NilaiPPN,0.00 Jumlahnetto,
   B.Qnt, B.Qnt2 Qnt2Db, B.Qnt*B.HPP HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	B.Qnt QntSaldo, B.Qnt2 Qnt2Saldo, B.Qnt*B.HPP HrgSaldo, 
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.Urut,
	'' KodeCustSupp, '' Keterangan, '' IDUSER,
	B.HPP HPP,
	A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	DBTRANSFER A
left outer join DBTRANSFERDET B on B.NoBukti=A.NoBukti
where 	B.Qnt<>0 or B.Qnt2<>0
--Group By B.KodeBrg, B.GdgTujuan,A.Tanggal, A.NoBukti, B.Urut
union all
Select 	'TRO' Tipe, 'TRO' MyTipe, 'B05' Prioritas, B.KodeBrg,B.GDGAsal,B.QNT QNT,0.00 NilaiDpp ,0.00 NilaiPPN,0.00 Jumlahnetto,
   0.00 QntDb, 0.00 Qnt2Db, 0.00 HrgDebet,
	B.Qnt, B.Qnt2 Qnt2Cr, B.Qnt*B.HPP HrgKredit,
	-1*B.Qnt QntSaldo, -1*B.Qnt2 Qnt2Saldo, -1*B.Qnt*B.HPP HrgSaldo, 
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.Urut,
	'' KodeCustSupp, '' Keterangan, ''IDUser,
	B.HPP HPP,
	A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	DBTRANSFER A
left outer join DBTRANSFERDET B on B.NoBukti=A.NoBukti
where 	B.Qnt<>0 or B.Qnt2<>0
--Group By B.KodeBrg, B.GDGASAL,A.Tanggal, A.NoBukti, B.Urut
union all
Select 	'TRI' Tipe, 'PBI' MyTipe, 'B06' Prioritas, B.KodeBrg, A.KodeGdgT, Isnull(B.QNT,0) Qnt,0.00 NilaiDpp ,0.00 NilaiPPN,0.00 Jumlahnetto,
   Isnull(B.Qnt,0) QntDb, Isnull(B.Qnt2,0) Qnt2Db, Isnull(B.Qnt,0)*ISNULL(B.HPP,0) HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	Isnull(B.Qnt,0) QntSaldo, Isnull(B.Qnt2,0) Qnt2Saldo, Isnull(B.Qnt,0)*ISNULL(B.HPP,0) HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.Urut,
	''KodeSupp, '' Keterangan, ''IDUser,
	isnull(B.HPP,0) HPP,
	A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	DBBPPBT A
left outer join DBBPPBTDET B on B.NoBukti=A.NoBukti
left outer join DBBARANG C on C.KODEBRG=B.KodeBrg
--Group By B.KodeBrg, A.KodeGdgT,A.TANGGAL,A.NOBUKTI, B.Urut
Union All
Select 	'TRO' Tipe, 'PBO' MyTipe, 'B06' Prioritas, B.KodeBrg, 'G001' KodeGdg,Isnull(B.QNT,0) Qnt,0.00 NilaiDpp ,0.00 NilaiPPN,0.00 Jumlahnetto,
    0.00 QntDb, 0.00 Qnt2Db, 0.00 HrgDebet,
	Isnull(B.Qnt,0) QntCr, Isnull(B.Qnt2,0) Qnt2Cr, Isnull(B.Qnt,0)*ISNULL(B.HPP,0) HrgKredit, 
	Isnull(B.Qnt,0)*-1 QntSaldo, Isnull(B.Qnt2,0)*-1 Qnt2Saldo, -1*Isnull(B.Qnt,0)*ISNULL(B.HPP,0) HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.Urut,
	''KodeSupp, '' Keterangan, ''IDUser,
	isnull(B.HPP,0) HPP,
	A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	DBBPPBT A
left outer join DBBPPBTdet B on B.NoBukti=A.NoBukti
left outer join DBBARANG C on C.KODEBRG=B.KodeBrg
--Group By B.KodeBrg, A.KodeGdg,A.TANGGAL,A.NOBUKTI, B.Urut
union all
Select 	'UKI' Tipe, 'UKI' MyTipe, 'A60' Prioritas, B.KodeBrg, B.KodeGdg,B.QNTDB QNT,0.00 NilaiDpp ,0.00 NilaiPPN,0.00 Jumlahnetto,
   B.QNTDB, 0.00 Qnt2Db, B.QNTDB*ISNULL(B.HPP,0) HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	B.QntDB QntSaldo,0.00 Qnt2Saldo, B.QNTDB*ISNULL(B.HPP,0) HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.Urut,
	''KodeSupp, '' Keterangan,B.UserID IDUser,
	isnull(B.HPP,0) HPP,
	A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	DBUBAHKEMASAN A
left outer join DBUBAHKEMASANDET B on B.NoBukti=A.NoBukti
left outer join DBBARANG C on C.KODEBRG=B.KodeBrg
where	b.qntdb<>0 
--Group By B.KodeBrg, B.KodeGdg,A.NOBUKTI,A.Tanggal,B.UserID, B.Urut
union all
Select 	'UKO' Tipe, 'UKO' MyTipe, 'B60' Prioritas, B.KodeBrg, B.KodeGdg,B.QNTCR QNT,0.00 NilaiDpp ,0.00 NilaiPPN,0.00 Jumlahnetto,
   0.00 QNTDB, 0.00 Qnt2Db, 0.00 HrgDebet,
	B.QNTCR, 0.00 Qnt2Cr, B.QNTCR*ISNULL(B.HPP,0) HrgKredit,
	-B.QntCR QntSaldo, 0.00 Qnt2Saldo, -B.QNTCR*ISNULL(B.HPP,0) HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,B.Urut,
	''KodeSupp, '' Keterangan,B.UserID IDUser,
	isnull(B.HPP,0) HPP,
	A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	DBUBAHKEMASAN A
left outer join DBUBAHKEMASANDET B on B.NoBukti=A.NoBukti
left outer join DBBARANG C on C.KODEBRG=B.KodeBrg
where	b.qntcr<>0 
--Group By B.KodeBrg, B.KodeGdg,A.NOBUKTI,A.Tanggal,B.UserID, B.URUT
union all
Select 	'ADI' Tipe, 'ADI' MyTipe, 'A70' Prioritas, B.KodeBrg, A.kodegdg, B.QNTDB Qnt,0.00 NilaiDpp ,0.00 NilaiPPN,0.00 Jumlahnetto,
   B.QntDb, B.Qnt2DB Qnt2Db, B.QntDb*isnull(B.HPP,0) HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	B.QntDb QntSaldo, B.Qnt2DB Qnt2Saldo, B.QntDb*isnull(B.Hpp,0) HrgSaldo, 
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.Urut,
	'' KodeCustSupp, '' Keterangan, '' IDUSER,
	isnull(B.HPP,0) HPP,
	A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	dbKoreksi A
left outer join dbKoreksiDet B on B.NoBukti=A.NoBukti
where 	B.QntDb<>0 or B.Qnt2DB<>0
--Group By B.KodeBrg, A.kodegdg,A.Tanggal, A.NoBukti, B.URUT
union all
Select 	'ADO' Tipe, 'ADO' MyTipe, 'B70' Prioritas, B.KodeBrg,A.KodeGdg, B.QNTCR QNT,0.00 NilaiDpp ,0.00 NilaiPPN,0.00 Jumlahnetto,
   0.00 QntDb, 0.00 Qnt2Db, 0.00 HrgDebet,
	B.QntCr, B.Qnt2Cr Qnt2Cr, B.QntCr*B.HPP HrgKredit,
	-1*B.QntCr QntSaldo, -1*B.Qnt2Cr Qnt2Saldo, -1*B.QntCr*B.HPP HrgSaldo, 
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.Urut,
	'' KodeCustSupp, '' Keterangan, ''IDUser,
	B.HPP HPP,
	A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	dbKoreksi A
left outer join dbKoreksiDet B on B.NoBukti=A.NoBukti
where 	B.QntCr<>0 or B.Qnt2CR<>0
--Group By B.KodeBrg, A.kodegdg,A.Tanggal, A.NoBukti, B.URUT
Union ALL
Select 	'PNJ' Tipe, 'PNJ' MyTipe, 'B80' Prioritas, B.KodeBrg,B.KodeGdg,B.QNT QNT,0.00 NilaiDpp ,0.00 NilaiPPN,0.00 Jumlahnetto,
   0.00 QntDb, 0.00 Qnt2Db, 0.00 HrgDebet,
	B.QNT, B.QNT2 Qnt2Cr, B.QNT*B.HPP HrgKredit,
	-1*B.Qnt QntSaldo, -1*B.Qnt2 Qnt2Saldo, -1*B.Qnt*B.HPP HrgSaldo, 
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.Urut,
	'' KodeCustSupp, d.NAMACUSTSUPP as Keterangan, ''IDUser,
	B.HPP HPP,
	A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	dbSPB A
left outer join dbSPBDet B on B.NoBukti=A.NoBukti
left outer join dbcustsupp D on d.kodecustsupp=a.kodecustsupp
where 	(B.Qnt<>0 or B.Qnt2<>0)
and isnull(A.IsBatal,0)=0
--Group By B.KodeBrg, B.KodeGdg,A.Tanggal, A.NoBukti, B.Urut
Union ALL
Select 	'RSPB' Tipe, 'RSPB' MyTipe, case when A.Tanggal=A0.Tanggal then 'B81' else 'A80' end Prioritas, 
	B.KODEBRG, A.KodeGdg,B.QNT QNT,0.00 NilaiDpp ,0.00 NilaiPPN,0.00 Jumlahnetto,
   B.QNT QntDb, B.QNT2 Qnt2Db, B.QNT*B.HPP HrgDebet,
	0.00,  0.00 Qnt2Cr, 0.00 HrgKredit,
	B.Qnt QntSaldo, B.Qnt2 Qnt2Saldo, B.Qnt*B.HPP HrgSaldo, 
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.Urut,
	'' KodeCustSupp, d.NAMACUSTSUPP as Keterangan, ''IDUser,
	B.HPP HPP,
	A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	DBRSPB A
left outer join DBRSPBDet B on B.NoBukti=A.NoBukti
left outer join dbcustsupp D on d.kodecustsupp=a.kodecustsupp
left outer join dbSPB A0 on A0.NoBukti=B.NoSPB
where 	B.Qnt<>0 or B.Qnt2<>0
--Group By B.KodeBrg,B.KodeGdg, A.Tanggal, A.NoBukti, B.Urut

Union ALL
Select 	'RPJ' Tipe, 'RPJ' MyTipe, case when A.Tanggal=A0.Tanggal then 'B82' else 'A80' end Prioritas, 
	B.KODEBRG,B.KodeGdg,B.QNT QNT,0.00 NilaiDpp ,0.00 NilaiPPN,0.00 Jumlahnetto,
   B.QNT QntDb, B.QNT2 Qnt2Db, B.QNT*B.HPP HrgDebet,
	0.00,  0.00 Qnt2Cr, 0.00 HrgKredit,
	B.Qnt QntSaldo, B.Qnt2 Qnt2Saldo, B.Qnt*B.HPP HrgSaldo, 
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti, B.Urut,
	'' KodeCustSupp, d.NAMACUSTSUPP as Keterangan, ''IDUser,
	B.HPP HPP,
	A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	DBSPBRJual A
left outer join DBSPBRJualDet B on B.NoBukti=A.NoBukti
left outer join dbcustsupp D on d.kodecustsupp=a.kodecustsupp
left outer join dbInvoicePLDet C on C.NoBukti=B.NoInv and C.Urut=B.UrutInv
left outer join dbSPB A0 on A0.NoBukti=C.NoSPB
where 	B.Qnt<>0 or B.Qnt2<>0

Union ALL
Select 	'HP' Tipe, 'HP' MyTipe, 'A90' Prioritas, A0.KODEBRG, P0.KodeGdg, 
	B.Qnt, 0.00 NilaiDpp ,0.00 NilaiPPN, 0.00 Jumlahnetto,
	B.Qnt QntDb, 0 Qnt2Db, 
	B.Qnt*ISNULL(B.HPP,0) HrgDebet,
	0.00,  0.00 Qnt2Cr, 0.00 HrgKredit,
	B.Qnt QntSaldo, 0.00 Qnt2Saldo, 
	B.Qnt*ISNULL(B.HPP,0) HrgSaldo, 
	B.TanggalMesin Tanggal, month(B.TanggalMesin) Bulan, year(B.TanggalMesin) Tahun, A.NoBukti, B.Urut,
	'' KodeCustSupp, '' Keterangan, ''IDUser,
	isnull(B.HPP,0) HPP, A.NOBUKTI NoBukti1, A.NOBUKTI NoBukti2
from 	DBHASILPRD A
left outer join DBHASILPRDMSN B on B.NoBukti=A.NoBukti
left outer join DBSPK A0 on A0.NOBUKTI=A.NoSPK
left outer join DBPRoses P0 on P0.KodePrs=A.KodePrs
left outer join (select max(KodePrs) KodePrs from dbProses) P on P.KodePrs=A.KodePrs
where 	B.Qnt<>0
and P.KodePrs is not null
--Group By B.KodeBrg,B.KodeGdg, A.Tanggal, A.NoBukti, B.URUT


--select * from DBHASILPRDMSN
--select * from DBHASILPRD
--select * from DBHASILPRDDET

--select * from DBSPK

--select * from DBPRoses





























GO

-- View: vwKartuStockWIP
-- Created: 2014-11-26 14:38:22.670 | Modified: 2014-11-26 14:38:22.670
-- =====================================================



CREATE view [dbo].[vwKartuStockWIP]
as
SELECT	'AWL' Tipe, 'AWL' MyTipe, 'A00' Prioritas, B.KODEPRS, B.KODEBRG, B.NOSPK, 
	B.QNTAWAL QntDB, B.QNT2AWAL Qnt2DB, B.HRGAWAL HrgDebet, 
	0.00 QntCr,  0.00 Qnt2Cr, 0.00 HrgKredit,
	B.QNTAWAL QntSaldo, B.Qnt2Awal Qnt2Saldo, B.HRGAWAL HrgSaldo,
	CAST(CAST(B.Tahun as varchar(4))+RIGHT('0'+CAST(B.Bulan as varchar(2)),2)+'01' as datetime) Tanggal,
	B.BULAN, B.TAHUN, 'SALDO AWAL' NoBukti, 0 Urut, 
	'' Keterangan,
	case when B.QntAwal=0 then 0 else B.HrgAwal/B.QntAwal end HPP  
FROM  dbSTOCKWIP B
where (B.QNTAWAL<>0 or B.QNT2AWAL<>0 or B.HrgAwal<>0)

union all
Select 	'PRI' Tipe, 'PRI' MyTipe, 'A20' Prioritas, B.KodePrs, C.KodeBrg, B.NoSPK, 
    A.Qnt QntDb, A.Qnt Qnt2Db, A.Qnt*isnull(A.HPP,0) HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	A.Qnt QntSaldo, A.Qnt Qnt2Saldo, A.Qnt*isnull(A.HPP,0) HrgSaldo, 
	A.TanggalMesin Tanggal, month(A.TanggalMesin) Bulan, year(A.TanggalMesin) Tahun, A.NoBukti, A.Urut,
	'' Keterangan,
	isnull(A.HPP,0) HPP
from 	DBHASILPRDMSN A
left outer join DBHASILPRD B on B.NoBukti=A.NoBukti
left outer join DBSPK C on C.NOBUKTI=B.NoSPK

union all
Select 	'PRO' Tipe, 'PRO' MyTipe, 'B20' Prioritas, A.KodePrs, C.KodeBrg, B.NoSPK, 
    0.00 QntDb, 0.00 Qnt2Db, 0.00 HrgDebet,
	A.Qnt QntCr, A.Qnt Qnt2Cr, A.Qnt*isnull(0,0) HrgKredit,
	-A.Qnt QntSaldo, -A.Qnt Qnt2Saldo, -A.Qnt*isnull(0,0) HrgSaldo, 
	B.Tanggal, month(B.Tanggal) Bulan, year(B.Tanggal) Tahun, A.NoBukti, A.Urut,
	'' Keterangan,
	isnull(0,0) HPP
from 	DBHASILPRDDET A
left outer join DBHASILPRD B on B.NoBukti=A.NoBukti
left outer join DBSPK C on C.NOBUKTI=B.NoSPK







GO

-- View: vwKategori
-- Created: 2011-11-23 18:45:57.623 | Modified: 2011-11-23 22:17:03.890
-- =====================================================

CREATE View [dbo].[vwKategori]
as
Select A.*,B.NAMA NamaGdg, C.Keterangan NamaPerkiraan,
       B.NAMA+Case when B.NAMA is null then '' else ' ('+B.KODEGDG+')' end myGudang,
       C.Keterangan+Case when C.Keterangan is null then '' else ' ('+C.Perkiraan+')' end myPerkiraan
from DBKATEGORI A
     Left Outer join DBGUDANG B on B.KODEGDG=A.Kodegdg
     left Outer join DBPERKIRAAN C on C.Perkiraan=A.Perkiraan


GO

-- View: vwKategoriJadi
-- Created: 2011-12-08 19:36:36.767 | Modified: 2011-12-08 19:36:36.767
-- =====================================================


CREATE View [dbo].[vwKategoriJadi]
as
Select A.*,B.NAMA NamaGdg, C.Keterangan NamaPerkiraan,
       B.NAMA+Case when B.NAMA is null then '' else ' ('+B.KODEGDG+')' end myGudang,
       C.Keterangan+Case when C.Keterangan is null then '' else ' ('+C.Perkiraan+')' end myPerkiraan
from DBKATEGORIBRGJADI A
     Left Outer join DBGUDANG B on B.KODEGDG=A.Kodegdg
     left Outer join DBPERKIRAAN C on C.Perkiraan=A.Perkiraan



GO

-- View: vwKelompok
-- Created: 2011-11-23 18:45:57.620 | Modified: 2011-11-23 22:18:09.923
-- =====================================================

CREATE View [dbo].[vwKelompok]
as
Select A.*,B.Keterangan NamaPerkiraan,
       B.Keterangan+Case when B.Keterangan is null then '' else ' ('+B.Perkiraan+')' end myPerkiraan
from DBKELOMPOK A
     left Outer join DBPERKIRAAN B on B.Perkiraan=A.Perkiraan


GO

-- View: vwLabaRugiHPP
-- Created: 2011-11-22 15:40:56.017 | Modified: 2011-11-22 15:40:56.017
-- =====================================================
Create View dbo.vwLabaRugiHPP
as
Select * 
from DBLRHPP
GO

-- View: vwMasterBeli
-- Created: 2012-11-20 12:06:35.753 | Modified: 2015-04-21 09:21:48.027
-- =====================================================



CREATE    View [dbo].[vwMasterBeli]
as
Select 	A.NoBukti, A.Tanggal, A.KodeSupp, C.NAMACUSTSUPP, C.Kota,NoPO,A.UserBatal,A.tglbatal,
	A.Handling, A.FakturSupp, isnull(A.IsBatal,0) IsBatal,
        sum(B.SubTotal) TotSubTotal, sum(B.NDiskon) TotDiskon, 
	sum(B.SubTotal)-sum(B.NDiskon) TotTotal, sum(B.NDPP) TotDPP, 
	sum(B.NPPN) TotPPN, sum(B.NNet) TotNet,
	sum(B.SubTotal*A.Kurs) TotSubTotalRp, sum(B.NDiskon*A.Kurs) TotDiskonRp, 
	sum(B.SubTotal*A.Kurs)-sum(B.NDiskon*A.Kurs) TotTotalRp, sum(B.NDPP*A.Kurs) TotDPPRp, 
	sum(B.NPPN*A.Kurs) TotPPNRp, sum(B.NNet*A.Kurs) TotNetRp, a.Keterangan,a.TipeBayar
	,
	A.IsOtorisasi1, A.OtoUser1, A.TglOto1, A.IsOtorisasi2, A.OtoUser2, A.TglOto2, 
	A.IsOtorisasi3, A.OtoUser3, A.TglOto3, A.IsOtorisasi4, A.OtoUser4, A.TglOto4,B.KodeGdg,
	A.IsOtorisasi5, A.OtoUser5, A.TglOto5, A.MAXOL
From dbBeli A
Left Outer Join dbBeliDet B on B.NoBukti=A.NoBukti
Left Outer Join DBCUSTSUPP C on c.KODECUSTSUPP=a.KodeSupp
Group By A.NoBukti, A.Tanggal, A.KodeSupp, C.NAMACUSTSUPP, C.Kota,
	A.Handling, A.FakturSupp, isnull(A.IsBatal,0), a.Keterangan,a.TipeBayar,NOPO,
	A.IsOtorisasi1, A.OtoUser1, A.TglOto1, A.IsOtorisasi2, A.OtoUser2, A.TglOto2, 
	A.IsOtorisasi3, A.OtoUser3, A.TglOto3, A.IsOtorisasi4, A.OtoUser4, A.TglOto4,
	A.IsOtorisasi5, A.OtoUser5, A.TglOto5, A.MAXOL,A.UserBatal,A.tglbatal,B.KodeGdg




GO

-- View: vwMasterKoreksi
-- Created: 2014-02-19 10:17:43.033 | Modified: 2014-02-19 10:18:55.800
-- =====================================================


CREATE View [dbo].[vwMasterKoreksi]
as
Select a.nobukti+' Tanggal : '+convert(varchar(10),a.tanggal,105) + '   Gudang : '+a.KodeGdg as GroupNobukti, 
       A.Nobukti,a.Tanggal,
	A.IsOtorisasi1, A.OtoUser1, A.TglOto1, A.IsOtorisasi2, A.OtoUser2, A.TglOto2, 
	A.IsOtorisasi3, A.OtoUser3, A.TglOto3, A.IsOtorisasi4, A.OtoUser4, A.TglOto4,
	A.IsOtorisasi5, A.OtoUser5, A.TglOto5,
        Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                       Case when A.IsOtorisasi2=1 then 1 else 0 end+
                       Case when A.IsOtorisasi3=1 then 1 else 0 end+
                       Case when A.IsOtorisasi4=1 then 1 else 0 end+
                       Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                  else 1
             end As Bit) NeedOtorisasi,A.NOURUT
From dbKoreksi A 



GO

-- View: vwMasterOutstandingPO
-- Created: 2012-11-20 12:07:12.353 | Modified: 2012-11-29 10:51:34.710
-- =====================================================









CREATE   View [dbo].[vwMasterOutstandingPO]
As
Select 	A.NoBukti, A.Tanggal, A.KodeSupp, C.NAMACUSTSUPP, 
	A.IsBatal,
        	sum(B.SubTotal) TotSubTotal, sum(B.NDiskon) TotDiskon, 
	sum(B.SubTotal)-sum(B.NDiskon) TotTotal, sum(B.NDPP) TotDPP, 
	sum(B.NPPN) TotPPN, sum(B.NNet) TotNet,
	sum(B.SubTotal*A.Kurs) TotSubTotalRp, sum(B.NDiskon*A.Kurs) TotDiskonRp, 
	sum(B.SubTotal*A.Kurs)-sum(B.NDiskon*A.Kurs) TotTotalRp, sum(B.NDPP*A.Kurs) TotDPPRp, 
	sum(B.NPPN*A.Kurs) TotPPNRp, sum(B.NNet*A.Kurs) TotNetRp
From dbPO A
Left Outer Join dbPODet B on B.NoBukti=A.NoBukti
Left Outer Join (select Kodebrg,NoPO,Isnull(Sum(Qnt*Isi),0)QntB from dbBelidet group by Kodebrg,NoPO)B1 On B1.NOPO=A.NoBukti and B1.Kodebrg=B.Kodebrg
Left Outer Join DBCUSTSUPP C on c.KODECUSTSUPP=a.KodeSupp
where (B.Qnt*B.Isi)<>Isnull(QntB,0)
and
Case when Isnull(A.IsClose,0)=0 Then Isnull(B.IsClose,0)else Isnull(A.IsClose,0) end=0
Group By A.NoBukti, A.Tanggal, A.KodeSupp, C.NAMACUSTSUPP, A.IsBatal









GO

-- View: vwMasterPO
-- Created: 2012-11-20 11:59:00.907 | Modified: 2013-01-02 13:56:58.393
-- =====================================================





CREATE  View [dbo].[vwMasterPO]
as

Select 	A.NoBukti, A.Tanggal, A.KodeSupp, C.NAMACUSTSUPP, C.Kota,
	A.Handling, A.FakturSupp, isnull(A.IsBatal,0) IsBatal,
        sum(B.SubTotal) TotSubTotal, sum(B.NDiskon) TotDiskon, 
	sum(B.SubTotal)-sum(B.NDiskon) TotTotal, sum(B.NDPP) TotDPP, 
	sum(B.NPPN) TotPPN, sum(B.NNet) TotNet,
	sum(B.SubTotal*A.Kurs) TotSubTotalRp, sum(B.NDiskon*A.Kurs) TotDiskonRp, 
	sum(B.SubTotal*A.Kurs)-sum(B.NDiskon*A.Kurs) TotTotalRp, sum(B.NDPP*A.Kurs) TotDPPRp, 
	sum(B.NPPN*A.Kurs) TotPPNRp, sum(B.NNet*A.Kurs) TotNetRp
From dbPO A
Left Outer Join dbPODet B on B.NoBukti=A.NoBukti
Left Outer Join  dbCustSupp C on c.KodeCustSupp=a.KodeSupp  
Group By A.NoBukti, A.Tanggal, A.KodeSupp, C.NAMACUSTSUPP, C.Kota,
	A.Handling, A.FakturSupp, isnull(A.IsBatal,0)






GO

-- View: vwMasterPOOut
-- Created: 2014-02-13 11:53:13.300 | Modified: 2014-07-18 10:11:44.057
-- =====================================================






CREATE View [dbo].[vwMasterPOOut]
as

Select 	A.NoBukti, A.Tanggal, A.KodeSupp, C.NAMACUSTSUPP, C.Kota,
b.Qnt-isnull(e.QntTerima,0) QntSisa,ISNULL(QntTerima,0)QntTerima,
	A.Handling, A.FakturSupp, --isnull(A.IsBatal,0) IsBatal,
       0.00 --sum(B.SubTotal) 
        TotSubTotal, --sum(B.NDiskon) 
     0.00   TotDiskon, 
	0.00--sum(B.SubTotal)-sum(B.NDiskon) 
	TotTotal, 0.00--sum(B.NDPP)
	 TotDPP, 
	0.00--sum(B.NPPN)
		 TotPPN, 0.00--sum(B.NNet) 
		 TotNet,
	0.00--sum(B.SubTotal*A.Kurs) 
	TotSubTotalRp, 0.00--sum(B.NDiskon*A.Kurs) 
	TotDiskonRp, 
	0.00--sum(B.SubTotal*A.Kurs)-sum(B.NDiskon*A.Kurs) 
	TotTotalRp, 0.00--sum(B.NDPP*A.Kurs) 
	TotDPPRp, 
	0.00--sum(B.NPPN*A.Kurs) 
	TotPPNRp, 0.00--sum(B.NNet*A.Kurs) 
	TotNetRp, b.KODEBRG ,B.NAMABRG, qnt, f.qntbatal, b.urut, b.IsBatal, b.UserBatal, b.TglBatal,b.SATUAN
From dbPO A
Left Outer Join dbPODet B on B.NoBukti=A.NoBukti
Left Outer Join  dbCustSupp C on c.KodeCustSupp=a.KodeSupp  
left outer join DBBARANG d on d.KODEBRG=b.KODEBRG
left outer join
	(Select NOBUKTI , Urut, KodeBrg, sum(QntBatal ) QntBatal
	 from dbPODet
	 group by NOBUKTI, Urut, KodeBrg) f on f.NOBUKTI=A.NoBukti and f.Urut=b.urut and B.KodeBrg=b.KodeBrg
left outer join
	(Select NoPO , UrutPO, KodeBrg, sum(Qnt ) QntTerima
	 from dbbelidet
	 group by NOpo, Urutpo, KodeBrg) e on e.NoPO =A.NoBukti and e.UrutPO=b.Urut and e.KodeBrg=b.KodeBrg	 
Group By A.NoBukti, A.Tanggal, A.KodeSupp, C.NAMACUSTSUPP, C.Kota,
	A.Handling, A.FakturSupp, isnull(A.IsBatal,0), b.KODEBRG , B.NamaBrg ,QNT ,f.QntBatal,e.QntTerima, b.urut, b.IsBatal, b.UserBatal, b.TglBatal, SATUAN








GO

-- View: vwMasterRBeli
-- Created: 2014-02-13 11:53:13.267 | Modified: 2014-02-13 11:53:13.267
-- =====================================================





CREATE View [dbo].[vwMasterRBeli]
as
Select 	A.NoBukti, A.Tanggal, A.KodeSupp, C.NAMACUSTSUPP, A.NoBeli, C.Kota,
	A.Handling, A.FakturSupp,
        sum(B.SubTotal) TotSubTotal, sum(B.NDiskon) TotDiskon, 
	sum(B.SubTotal)-sum(B.NDiskon) TotTotal, sum(B.NDPP) TotDPP, 
	sum(B.NPPN) TotPPN, sum(B.NNet) TotNet,Kodegdg,
	sum(B.SubTotal*A.Kurs) TotSubTotalRp, sum(B.NDiskon*A.Kurs) TotDiskonRp, 
	sum(B.SubTotal*A.Kurs)-sum(B.NDiskon*A.Kurs) TotTotalRp, sum(B.NDPP*A.Kurs) TotDPPRp, 
	sum(B.NPPN*A.Kurs) TotPPNRp, sum(B.NNet*A.Kurs) TotNetRp,
        A.IsOtorisasi1, A.OtoUser1, A.TglOto1, A.IsOtorisasi2, A.OtoUser2, A.TglOto2, 
	A.IsOtorisasi3, A.OtoUser3, A.TglOto3, A.IsOtorisasi4, A.OtoUser4, A.TglOto4,
	A.IsOtorisasi5, A.OtoUser5, A.TglOto5, A.MAXOL,        
        Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                       Case when A.IsOtorisasi2=1 then 1 else 0 end+
                       Case when A.IsOtorisasi3=1 then 1 else 0 end+
                       Case when A.IsOtorisasi4=1 then 1 else 0 end+
                       Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                  else 1
             end As Bit) NeedOtorisasi,TglFpj,NOpajak,A.IsBatal 
From dbRBeli A
Left Outer Join dbRBeliDet B on B.NoBukti=A.NoBukti
Left Outer Join dbCustSupp C on c.KODECUSTSUPP=a.KodeSupp
Group By A.NoBukti, A.Tanggal, A.KodeSupp, C.NAMACUSTSUPP, A.NoBeli, C.Kota,
	A.Handling, A.FakturSupp, A.KodeGdg, a.ISotorisasi1,OtoUser1,a.TglOto1,TglFpj,NOpajak, A.IsOtorisasi2, A.OtoUser2, A.TglOto2, 
	A.IsOtorisasi3, A.OtoUser3, A.TglOto3, A.IsOtorisasi4, A.OtoUser4, A.TglOto4,
	A.IsOtorisasi5, A.OtoUser5, A.TglOto5, A.MAXOL,A.IsBatal 













GO

-- View: vwMasterUbahKemasan
-- Created: 2013-07-11 15:16:11.343 | Modified: 2013-07-11 15:16:11.343
-- =====================================================

CREATE View [dbo].[vwMasterUbahKemasan]
as
Select a.nobukti+' Tanggal : '+convert(varchar(10),a.tanggal,105) as GroupNobukti, 
       A.Nobukti, A.NOURUT, a.Tanggal, A.NOTE, A.IsCetak, A.NilaiCetak,
       A.IsOtorisasi1, A.OtoUser1, A.TglOto1,
       A.IsOtorisasi2, A.OtoUser2, A.TglOto2,
       A.IsOtorisasi3, A.OtoUser3, A.TglOto3,
       A.IsOtorisasi4, A.OtoUser4, A.TglOto4,
       A.IsOtorisasi5, A.OtoUser5, A.TglOto5
From  DBUBAHKEMASAN A 






GO

-- View: vwMesin
-- Created: 2011-11-23 18:45:57.590 | Modified: 2011-11-23 18:45:57.590
-- =====================================================
Create View dbo.vwMesin
as
Select * from DBMESIN

GO

-- View: vwOSBarang
-- Created: 2012-12-05 11:18:32.517 | Modified: 2012-12-05 11:18:32.517
-- =====================================================



CREATE View [dbo].[vwOSBarang]
as     
select a.Kodebrg,Isnull(SUM(a.QNT*isi),0)QntBPPB,Isnull(b.Qnt,0)QntBP,Isnull(SUM(a.QNT*isi),0)-Isnull(b.Qnt,0)OSBP,isnull(e.Sisa,0)OSPPL,Isnull(f.sisa,0)OSPO from DBBPPBDET a 
left Outer Join (select Kodebrg,SUM(Qnt*isi)Qnt from DBPenyerahanBhnDET group by kodebrg)b On b.kodebrg=a.KodeBrg 
Left Outer join (select a.kodebrg,SUM(a.Qnt*isi)QntPPL,Isnull(b.Qnt,0) QntPO,SUM(a.Qnt*isi)-Isnull(b.Qnt,0)sisa from DBPPLDET a
                 Left Outer Join (select NoPPL,Kodebrg,SUM(Qnt*isi)Qnt from DBPODET group by NoPPL,Kodebrg)b On a.Nobukti=b.NoPPL and a.kodebrg=b.KODEBRG
                 group by a.kodebrg,b.Qnt
                 having SUM(a.Qnt*isi)-Isnull(b.Qnt,0)<>0)e on e.KODEBRG=a.KODEBRG
Left Outer Join (select a.kodebrg,SUM(a.Qnt*isi)QntPO,Isnull(b.Qnt,0)QntBeli,SUM(a.Qnt*isi)-isnull(b.Qnt,0)sisa from DBPODET a
                 left Outer Join (select NoPO,Kodebrg,SUM(Qnt*isi)Qnt from DBBELIDET Group by NoPO,KODEBRG)b On a.NOBUKTI=b.NoPO and a.KODEBRG=b.KODEBRG
                 group by a.KodeBrg,b.Qnt
                 having SUM(a.Qnt*isi)-isnull(b.Qnt,0)<>0)f On f.KODEBRG=a.KODEBRG                 
group by a.KodeBrg,b.Qnt,e.Sisa,f.sisa
having (Isnull(SUM(a.QNT*isi),0)-Isnull(b.Qnt,0))-Isnull(e.Sisa,0)-Isnull(f.sisa,0)>0


GO

-- View: vwOutBeli
-- Created: 2014-09-30 10:45:02.050 | Modified: 2015-04-21 15:43:53.700
-- =====================================================


CREATE View [dbo].[vwOutBeli]
as

select X.NOBUKTI+' '+right('00000000'+cast(X.URUT as varchar(8)),8) KeyUrut,
	X.NOBUKTI, X.NOURUT, X.TANGGAL, X.KODECUSTSUPP, X.NOPO, X.KodeGdg, 
	X.Flagtipe, X.TipePPN,
	Cs.NAMACUSTSUPP,
	Cs.ALAMAT ALAMATCUSTSUPP, Cs.KOTA KOTACUSTSUPP, Cs.NamaKota NAMAKOTACUSTSUPP,  
	X.URUT, X.KODEBRG, Br.NAMABRG, max(X.KetNamaBrg) KetNamaBrg, 
	Br.NAMABRG+case when max(ISNULL(X.KetNamaBrg,''))='' then '' else CHAR(13)+max(X.KetNamaBrg) end NamaBrgPlus,
	Br.SAT1, Br.SAT2, Br.NFix,
	Br.ISI1, Br.ISI2, Br.IsJasa,
	sum(X.Qnt) Qnt, SUM(X.Qnt1) Qnt1, SUM(X.Qnt2) Qnt2, 
	max(X.NOSAT) NoSat, max(X.SATUAN) Satuan, max(X.ISI) Isi,
	case when MAX(X.NoSat)=1 then sum(X.Qnt1RBeli) else sum(X.Qnt2RBeli) end QntRBeli, 
	sum(X.Qnt1RBeli) Qnt1RBeli, sum(X.Qnt2RBeli) Qnt2RBeli, 
	SUM(X.Qnt)-case when MAX(X.NoSat)=1 then sum(X.Qnt1RBeli) else sum(X.Qnt2RBeli) end QntSisa,
	SUM(X.Qnt1)-sum(X.Qnt1RBeli) Qnt1Sisa,
	SUM(X.Qnt2)-sum(X.Qnt2RBeli) Qnt2Sisa,
	NilaiOL, MAXOL
from
	(
	select A.NOBUKTI, A.NOURUT, A.TANGGAL, A.KodeSupp KODECUSTSUPP, A.NoPOHd NOPO, B.KodeGdg, 
		A.Flagtipe, A.TipePPN, B.URUT, B.KODEBRG, isnull(B.NamaBrg,'') KetNamaBrg, 
		B.QntTerima-B.QntReject Qnt, B.Qnt1Terima-B.Qnt1Reject QNT1, B.Qnt2Terima-B.Qnt2Reject QNT2, B.NOSAT,
		case when B.NOSAT=1 then C.SAT1 when b.NOSAT=2 then C.SAT2 End Satuan, B.ISI, 
		0 Qnt1RBeli, 0 Qnt2RBeli,
		(Case when A.IsOtorisasi1=1 then 1 else 0 end+
        Case when A.IsOtorisasi2=1 then 1 else 0 end+
        Case when A.IsOtorisasi3=1 then 1 else 0 end+
        Case when A.IsOtorisasi4=1 then 1 else 0 end+
        Case when A.IsOtorisasi5=1 then 1 else 0 end) NilaiOL,
        A.MAXOL 
	from DBBELI A, DBBELIDET B,DBBARANG C
	where B.NOBUKTI=A.NOBUKTI and B.KODEBRG=C.KODEBRG
	
	--union all
	--select A.NOBUKTI, A.TANGGAL, A.KodeSupp KODECUSTSUPP,
	--	B.URUTPBL URUT, B.KODEBRG,
	--	0 Qnt, 0 Qnt1, 0 Qnt2, 0 NoSat, '' Satuan, 0 Isi,
	--	B.Qnt1 Qnt1RBeli, B.QNT2 Qnt2RBeli,
	--	(Case when A.IsOtorisasi1=1 then 1 else 0 end+
    --    Case when A.IsOtorisasi2=1 then 1 else 0 end+
    --    Case when A.IsOtorisasi3=1 then 1 else 0 end+
    --    Case when A.IsOtorisasi4=1 then 1 else 0 end+
    --    Case when A.IsOtorisasi5=1 then 1 else 0 end) NilaiOL,
    --    A.MAXOL 
	--from DBBELI A, DBRBELIDET B
	--where B.NOPBL=A.NOBUKTI

	union all
	select A.NOBUKTI, A.NOURUT, A.TANGGAL, A.KodeSupp KODECUSTSUPP, A.NoPOHd NOPO, B.KodeGdg, 
		A.Flagtipe, A.TipePPN, B.UrutBeli URUT, B.KODEBRG, '' KetNamaBrg,
		0 Qnt, 0 Qnt1, 0 Qnt2, 0 NoSat,case when B.NOSAT=1 then B.SAT_1 when b.NOSAT=2 then B.Sat_2 End SatuanSatuan, 0 Isi,
		B.Qnt1Terima Qnt1RBeli, B.Qnt2Terima Qnt2RBeli,
		(Case when A.IsOtorisasi1=1 then 1 else 0 end+
        Case when A.IsOtorisasi2=1 then 1 else 0 end+
        Case when A.IsOtorisasi3=1 then 1 else 0 end+
        Case when A.IsOtorisasi4=1 then 1 else 0 end+
        Case when A.IsOtorisasi5=1 then 1 else 0 end) NilaiOL,
        A.MAXOL 
	from DBBELI A, DBinvoiceDET B
	where B.NoBeli=A.NOBUKTI

	) X
left outer join vwCUSTSUPP Cs on Cs.KODECUSTSUPP=X.KODECUSTSUPP
left outer join vwBarang Br on Br.KODEBRG=X.KodeBrg
group by X.NOBUKTI, X.NOURUT, X.TANGGAL, X.KODECUSTSUPP, X.NOPO, X.KodeGdg, 
	X.Flagtipe, X.TipePPN, Cs.NAMACUSTSUPP, 
	Cs.ALAMAT, Cs.KOTA, Cs.NamaKota, 
	X.Urut, X.KODEBRG, Br.NAMABRG, Br.SAT1, Br.SAT2, Br.NFix,
	Br.ISI1, Br.ISI2, Br.IsJasa,
	X.NilaiOL, X.MAXOL





GO

-- View: vwOutBP_Inspeksi
-- Created: 2011-06-09 10:49:13.820 | Modified: 2011-06-09 10:49:13.820
-- =====================================================

CREATE View [dbo].[vwOutBP_Inspeksi]
as
select	A.Nobukti, A.urut, A.NOPO, A.URUTPO, A.kodebrg, A.Sat_1, A.Sat_2, A.Isi, A.Qnt, A.Qnt2, 
	0.00 QntBatal, 0.00 Qnt2Batal, isnull(C.QntIns,0) QntIns, isnull(C.Qnt2Ins,0) Qnt2Ins,
	A.Qnt-isnull(C.QntIns,0) QntSisaIns, A.Qnt2-isnull(C.Qnt2Ins,0) Qnt2SisaIns,
	A.Qnt-isnull(C.QntIns,0) QntSisa, A.Qnt2-isnull(C.Qnt2Ins,0) Qnt2Sisa, A.Nosat
from 	DBBELIDET A
left outer join (select NOBUKTI,URUT, NoPPL, UrutPPL, KodeBrg, sum(Qnt) QntPO, sum(Qnt2) Qnt2Po
	              from DBPODET
	              group by NOBUKTI,URUT, NoPPL, UrutPPL, KodeBrg ) B on B.NOBUKTI=A.NOPO and B.URUT=A.URUTPO
left outer join (select NoBP, UrutBP, KodeBrg, sum(Qnt1) QntIns, sum(Qnt2) Qnt2Ins
	              from dbInspeksiDet
	              group by NoBP, UrutBP, KodeBrg
	) C on C.NoBP=A.NoBukti and C.UrutBP=A.Urut
left outer join dbPPLDet P on P.NoBukti=B.NOPPL and P.Urut=B.UrutPPL
left outer join dbPermintaanBrgDet P2 on P2.NoBukti=P.NoPermintaan and P2.Urut=P.UrutPermintaan
where	P2.IsInspeksi=1


GO

-- View: vwOutBPPB
-- Created: 2013-06-03 12:13:04.730 | Modified: 2013-06-03 12:13:04.730
-- =====================================================

CREATE View [dbo].[vwOutBPPB]
as
Select A.NOBUKTI, A.TANGGAL, B.URUT, B.KODEBRG, A.KodeGdg, A.KodeGdgT, B.QNT, B.Qnt2, B.NOSAT, B.ISI, B.SATUAN,
       ISNULL(C.Qnt,0) QntBPPBT, ISNULL(C.Qnt2,0) Qnt2BPPBT,
       (B.QNT-ISNULL(C.Qnt,0)) QntSisa, 
       (B.QNT2-ISNULL(C.Qnt2,0)) Qnt2Sisa
From DBBPPB A
     Left Outer join DBBPPBDET B on B.NOBUKTI=A.NOBUKTI
     left Outer join (Select x.NoBPPB, x.UrutBPPB, x.NOSAT, x.ISI, SUM(x.QNT) Qnt, SUM(x.Qnt2) Qnt2
                      from DBBPPBTDET x
                      Group by x.NoBPPB, x.UrutBPPB, x.NOSAT, x.ISI) C on C.NoBPPB=A.NOBUKTI and C.UrutBPPB=B.URUT
     left Outer join dbbarang BR on BR.KODEBRG=B.KODEBRG
Where Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                       Case when A.IsOtorisasi2=1 then 1 else 0 end+
                       Case when A.IsOtorisasi3=1 then 1 else 0 end+
                       Case when A.IsOtorisasi4=1 then 1 else 0 end+
                       Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                  else 1
             end As Bit)=0 and (B.QNT-ISNULL(C.Qnt,0)>0 or B.Qnt2-ISNULL(c.Qnt2,0)>0) 


GO

-- View: vwOutInspeksi
-- Created: 2011-02-11 15:18:57.637 | Modified: 2011-03-03 12:00:28.937
-- =====================================================

CREATE View [dbo].[vwOutInspeksi]
as

select	A.Nobukti, A.urut, A.kodebrg, A.reject1 Qnt, A.reject2 Qnt2, 
	isnull(C.QntSJ,0) QntSJ, isnull(C.Qnt2SJ,0) Qnt2SJ,
	A.reject1-isnull(C.QntSJ,0) QntSisa, A.reject2-isnull(C.Qnt2SJ,0) Qnt2Sisa
from 	dbInspeksiDet A
left outer join
	(select NoInspek, UrutInspek, KodeBrg, sum(Qnt1) QntSJ, sum(Qnt2) Qnt2SJ
	from dbSPengantarDet
	group by NoInspek, UrutInspek, KodeBrg
	) C on C.NoInspek=A.NoBukti and C.UrutInspek=A.Urut and C.KodeBrg=A.KodeBrg


GO

-- View: vwOutInspeksi_RBP
-- Created: 2011-06-09 15:29:23.970 | Modified: 2011-06-14 10:21:23.603
-- =====================================================

CREATE View [dbo].[vwOutInspeksi_RBP]
as
Select A.NOBUKTI,A.urut,A.KODECUSTSUPP, A.TANGGAL,A.KODEBRG,
       A.Sat_1,a.Sat_2,a.Nosat,a.Isi,
       A.Qnt QntIns, A.Qnt2 Qnt2Ins,
       A.OK1, A.OK2, A.Reject1, A.Reject2,
       A.Pending1, A.Pending2,A.NOBP,A.urutBP,C.NOPO,c.URUTPO,
       isnull(B.NOPBL,'') NOPBL,isnull(B.URUTPBL,0) URUTPBL,
       isnull(B.noins,'') NOINS,isnull(B.Urutins,'')URUTINS ,
       isnull(B.qnt,0) QntRBP, isnull(B.qnt2,0) Qnt2RBP,
       isnull(D.qnt,0) QntKNS, 
       isnull(D.qnt2,0) Qnt2KNS,
       isnull(B.qntTukar,0) qntTukar, 
       isnull(B.Qnt2Tukar,0) Qnt2Tukar,
       A.Reject1-isnull(B.qnt,0) QntSisaIns,
       A.Reject2-isnull(B.qnt2,0) Qnt2SisaIns,
       A.Pending1-isnull(D.qnt,0) QntSisaKNS,
       A.Pending2-isnull(D.qnt2,0) Qnt2SisaKNS,
       C.HARGA,C.KODEGDG,C.KODEVLS,C.KURS,C.PPN,C.TIPEBAYAR,C.DISC,C.DISCRP
from (Select A.NOBUKTI,B.URUT, A.KODECUSTSUPP,A.TANGGAL, B.NOBP,B.URUTBP,(B.Qnt1) Qnt, (B.qnt2) Qnt2,
             (B.OK1) OK1, (B.OK2) OK2,
             (B.Reject1) Reject1, (B.Reject2) Reject2,
             (B.Pending1) Pending1, (B.Pending2) Pending2,
             B.KODEBRG,B.Sat_1,B.Sat_2,B.Nosat,B.Isi
      from DBINSPEKSI A
      left outer join DBINSPEKSIDET B on B.NOBUKTI=A.NOBUKTI) A
      Left Outer join (select NOPBL,URUTPBL,NOINS,Urutins, SUM(Qnt) Qnt ,SUM(Qnt2) qnt2, SUM(QntTukar) qntTukar, SUM(QNT2Tukar) Qnt2Tukar 
                       from DBRBELIDET
                       Group by NOPBL,URUTPBL,NOINS,UrutINS) B on B.NOPBL=A.NOBP and B.URUTPBL=A.URUTBP
      Left Outer join (Select a.NOBUKTI,a.URUT,a.NOPO,URUTPO,a.HARGA,B.KODEVLS,B.KURS,B.PPN,B.TIPEBAYAR,B.DISC,B.DISCRP,
                              B.KODEGDG
                       from DBBELIDET A
                       left outer join DBBELI B on B.NOBUKTI=A.NOBUKTI) C On C.NOBUKTI=A.NOBP and C.URUT=A.URUTBP 
      Left Outer join (select NOPBL,URUTPBL,NOINS,Urutins, SUM(Qnt) Qnt ,SUM(Qnt2) qnt2
                       from DBKonsesiDET
                       Group by NOPBL,URUTPBL,NOINS,UrutINS) D on D.NOINS=A.NOBUKTI and D.URUTINS=A.URUT      


GO

-- View: VwOutInvoicePL
-- Created: 2014-09-24 10:57:10.383 | Modified: 2023-05-21 14:40:07.013
-- =====================================================


CREATE View [dbo].[VwOutInvoicePL]
As
select X.NOBUKTI+' '+right('00000000'+cast(X.URUT as varchar(8)),8) KeyUrut,
	X.NOBUKTI, X.TANGGAL, X.KODECUSTSUPP, Cs.NAMACUSTSUPP,
	Cs.ALAMAT ALAMATCUSTSUPP, Cs.KOTA KOTACUSTSUPP, Cs.NamaKota NAMAKOTACUSTSUPP, 
	X.URUT, X.KODEBRG, Br.NAMABRG, Br.SAT1, Br.SAT2, Br.NFix,
	Br.ISI1, Br.ISI2,
	sum(X.Qnt) Qnt, SUM(X.Qnt2) Qnt2, 
	max(X.NOSAT) NoSat, max(X.SATUAN) Satuan, max(X.ISI) Isi,
	case when MAX(X.NoSat)=1 then sum(X.Qnt1SPBRJual) else sum(X.Qnt2SPBRJual) end QntSPBRJual, 
	sum(X.Qnt1SPBRJual) Qnt1SPBRJual, sum(X.Qnt2SPBRJual) Qnt2SPBRJual, 
	SUM(X.Qnt)-case when MAX(X.NoSat)=1 then sum(X.Qnt1SPBRJual) else sum(X.Qnt2SPBRJual) end QntSisa,
	SUM(X.Qnt)-sum(X.Qnt1SPBRJual) Qnt1Sisa,
	SUM(X.Qnt2)-sum(X.Qnt2SPBRJual) Qnt2Sisa,
	NilaiOL, MAXOL,x.Noso,x.nobatch,HARGA 
from
	(
	
	select A.NOBUKTI, A.TANGGAL, A.KodeCustSupp KODECUSTSUPP,  
		B.URUT, B.KODEBRG, 
		B.Qnt, B.QNT2, B.NOSAT, B.SAT_1 Satuan, B.ISI, 
		0 Qnt1SPBRJual, 0 Qnt2SPBRJual,
		(Case when A.IsOtorisasi1=1 then 1 else 0 end+
        Case when A.IsOtorisasi2=1 then 1 else 0 end+
        Case when A.IsOtorisasi3=1 then 1 else 0 end+
        Case when A.IsOtorisasi4=1 then 1 else 0 end+
        Case when A.IsOtorisasi5=1 then 1 else 0 end) NilaiOL,
        A.MAXOL,B.NoSO,B.nobatch  
	from DBInvoicePL A, dbInvoicePLDet B
	where B.NOBUKTI=A.NOBUKTI
	
	union all
	select A.NOBUKTI, A.TANGGAL, A.KodeCustSupp KODECUSTSUPP, 
		B.UrutInv URUT, B.KODEBRG,
		0 Qnt, 0 Qnt2, 0 NoSat, '' Satuan, 0 Isi,
		B.Qnt Qnt1SPBRJual, B.QNT2 Qnt2SPBRJual,
		(Case when A.IsOtorisasi1=1 then 1 else 0 end+
        Case when A.IsOtorisasi2=1 then 1 else 0 end+
        Case when A.IsOtorisasi3=1 then 1 else 0 end+
        Case when A.IsOtorisasi4=1 then 1 else 0 end+
        Case when A.IsOtorisasi5=1 then 1 else 0 end) NilaiOL,
        A.MAXOL,''NoSO,'' NObatch 
	from DBInvoicePL A, dbSPBRJualDet B
	where B.Noinv=A.NOBUKTI
	
	
	) X
left outer join vwCUSTSUPP Cs on Cs.KODECUSTSUPP=X.KODECUSTSUPP
left outer join DBBARANG Br on Br.KODEBRG=X.KodeBrg
left outer join dbInvoicePLDet d on d.NoBukti =x.NoBukti 
group by X.NOBUKTI, X.TANGGAL, X.KODECUSTSUPP, Cs.NAMACUSTSUPP, 
	Cs.ALAMAT, Cs.KOTA, Cs.NamaKota, 
	X.Urut, X.KODEBRG, Br.NAMABRG, Br.SAT1, Br.SAT2, Br.NFix,
	Br.ISI1, Br.ISI2,
	X.NilaiOL, X.MAXOL
	,X.Noso,X.Nobatch,HARGA 








GO

-- View: vwOutInvoicePL_RInvoicePL
-- Created: 2013-01-15 14:40:07.823 | Modified: 2013-01-15 14:40:07.823
-- =====================================================

CREATE View [dbo].[vwOutInvoicePL_RInvoicePL]
As
Select A.KodeBrg, A.NAMABRG, A.NamabrgKom, A.NamaProduk, A.QNT, A.QNT2, A.Qty, A.SAT_1, A.SAT_2, A.Satuan,
       A.ISI, A.NOSAT, A.NetW, A.GrossW, 
       ISNULL(b.qty,0) QtyRetur, ISNULL(b.NetW,0) NetWRetur,
       ISNULL(b.GrossW,0) GrossWRetur, ISNULL(b.Qnt1,0) QntRetur,
       ISNULL(b.Qnt2,0) Qnt2Retur,
       A.Qty-ISNULL(b.qty,0) QtySisa,
       A.QNT-ISNULL(b.Qnt1,0) QntSisa,
       A.QNT2-ISNULL(b.Qnt2,0) Qnt2Sisa,
       A.NetW-ISNULL(b.NetW,0) NetWSisa,
       A.GrossW-ISNULL(b.GrossW,0) GrossWSisa, A.NoBukti, A.Urut, A.HARGA, A.NoSPB
From (    
          Select a.KodeBrg, a.Namabrg NamabrgKom, b.namabrg,
				 'Nama Produk : '+b.Namabrg+CHAR(13)+'Nama Komersil : '+ a.namabrg NamaProduk ,
				 case when a.NOSAT=1 then a.QNT
						when a.NOSAT=2 then a.QNT2
						else 0
				 end Qty,
				 case when a.NOSAT=1 then a.SAT_1
						when a.NOSAT=2 then a.SAT_2
						else ''
				 end Satuan,
				 a.NetW, a.GrossW, a.QNT, A.QNT2, a.SAT_1, a.SAT_2, a.NOSAT, a.ISI,
				 a.NoBukti, a.Urut, A.HARGA, D.NoBukti NoSPB
		from dbInvoicePLDet a
			  left outer join DBBARANG b on b.KODEBRG=a.KodeBrg
                 left Outer join dbSPBDet D on D.NoBukti=a.NoSPB and D.UrutSPP=a.UrutSPB  
                 Left Outer join dbSPPDet C on c.NoBukti=D.NoSPP and c.Urut=D.UrutSPP
                 
		) A
Left Outer join (Select x.NoInvoice, x.UrutInvoice, SUM(x.QNT) Qnt1, SUM(x.QNT2) Qnt2,
                        SUM(x.netW) NetW, SUM(x.GrossW) GrossW,
                        Sum(case when x.NOSAT=1 then x.QNT
						               when x.NOSAT=2 then x.QNT2
						               else 0
				                end) Qty
                 from DBRInvoicePLDET x
                 Group by x.NoInvoice, x.UrutInvoice) b on b.NoInvoice=A.NoBukti and b.UrutInvoice=A.Urut 





GO

-- View: vwOutPermintaanBrg
-- Created: 2011-06-04 09:49:10.237 | Modified: 2011-12-20 15:56:20.147
-- =====================================================

CREATE VIEW [dbo].[vwOutPermintaanBrg]
AS
SELECT A.Nobukti, A.urut, A.kodebrg, A.Sat_1, A.Sat_2, A.Isi, A.Qnt, A.Qnt2, A.TglTiba, A.isInspeksi, 
       ISNULL(B.QntBPB, 0) AS QntBPB, 
       ISNULL(B.Qnt2BPB, 0) AS Qnt2BPB, 
       ISNULL(c.QntPPL, 0) AS QntPPl, 
       ISNULL(c.Qnt2PPL, 0) AS Qnt2PPL,
       ISNULL(d.QntBBP,0) QntBBP, 
       ISNULL(d.Qnt2BBP,0) Qnt2BBP,
       ISNULL(e.qntBPL,0) AS QntBPL,
       ISNULL(e.Qnt2BPL,0) AS Qnt2BPL, 
       A.Qnt - ISNULL(B.QntBPB, 0)-ISNULL(d.QntBBP, 0) AS QntSisaBPB, 
       A.Qnt2 - ISNULL(B.Qnt2BPB, 0)-ISNULL(d.Qnt2BBP, 0) AS Qnt2SisaBPB, 
       A.Qnt - ISNULL(d.QntBBP, 0) - ISNULL(C.QntPPL,0)+ISNULL(e.QntBPL,0) AS QntSisa, 
       A.Qnt2 - ISNULL(d.Qnt2BBP, 0) - ISNULL(C.Qnt2PPL, 0)+ISNULL(e.Qnt2BPL,0) AS Qnt2Sisa, 
       B.NoPermintaan, A.Nosat, A.Keterangan, F.JnsPakai,
       Case when F.JnsPakai=0 then 'Stock'
				when F.JnsPakai=1 then 'Investasi'
				when F.JnsPakai=2 then 'Rep & Pem Teknik'
				when F.JnsPakai=3 then 'Rep & Pem Komputer'
				when F.JnsPakai=4 then 'Rep & Pem Peralatan'
		 end MyJnsPakai,
		 Case when A.Nosat=1 then A.Qnt
            when A.Nosat=2 then A.Qnt2
            else 0
       end BPPB_QntBPPB,
       Case when A.Nosat=1 then isnull(d.QntBBP,0)
            when A.Nosat=2 then isnull(d.Qnt2BBP,0)
            else 0
       end BPPB_QntBBP,
       Case when A.Nosat=1 then isnull(B.QntBPB,0)
            when A.Nosat=2 then isnull(B.Qnt2BPB,0)
            else 0
       end BPPB_QntBPB,
       Case when A.Nosat=1 then isnull(C.QntPPL,0)
            when A.Nosat=2 then isnull(C.Qnt2PPL,0)
            else 0
       end BPPB_QntPPL,
       Case when A.Nosat=1 then isnull(e.QntBPL,0)
            when A.Nosat=2 then isnull(e.Qnt2BPL,0)
            else 0
       end BPPB_QntBPL,
       Case when A.Nosat=1 then A.Qnt - ISNULL(B.QntBPB, 0)-ISNULL(d.QntBBP, 0)
            when A.Nosat=2 then A.Qnt2 - ISNULL(B.Qnt2BPB, 0)-ISNULL(d.Qnt2BBP, 0)
            else 0
       end BPPB_QntSisaBPB,
       Case when A.Nosat=1 then A.Qnt - ISNULL(d.QntBBP, 0) - ISNULL(C.QntPPL,0)+ISNULL(e.QntBPL,0)
            when A.Nosat=2 then A.Qnt2 - ISNULL(d.Qnt2BBP, 0) - ISNULL(C.Qnt2PPL, 0)+ISNULL(e.Qnt2BPL,0)
            else 0
       end BPPB_QntSisa,
		 Case when A.Nosat=1 then A.Sat_1
            when A.Nosat=2 then A.Sat_2
            else ''
       end BPPB_Satuan
FROM dbo.DBPermintaanBrgDET AS A 
LEFT OUTER JOIN (SELECT x.NoPermintaan, x.UrutPermintaan, x.kodebrg, SUM(x.Qnt) AS QntBPB, SUM(x.Qnt2) AS Qnt2BPB
                 FROM dbo.DBPenyerahanBrgDET x
                 GROUP BY x.NoPermintaan, x.UrutPermintaan, x.kodebrg) AS B ON B.NoPermintaan = A.Nobukti AND B.UrutPermintaan = A.urut AND 
                 B.kodebrg = A.kodebrg 
LEFT OUTER JOIN (SELECT x.NoPermintaan, x.UrutPermintaan, x.kodebrg, 
                 SUM(x.Qnt) AS QntPPL, 
                 SUM(x.Qnt2) AS Qnt2PPL
                 FROM dbo.DBPPLDET AS x 
                 GROUP BY x.NoPermintaan, x.UrutPermintaan, x.kodebrg) AS c ON c.NoPermintaan = A.Nobukti AND c.UrutPermintaan = A.urut AND 
                      c.kodebrg = A.kodebrg
LEFT Outer join (select x.NoBPPB, x.UrutBPPB, x.kodebrg,
                        SUM(x.Qnt) QntBBP, SUM(x.Qnt2) Qnt2BBP
                 from  DBBatalMintaBrgDet x
                 group by x.NoBPPB, x.UrutBPPB, x.kodebrg) d on d.NoBPPB=A.Nobukti and d.UrutBPPB=A.urut  
LEFT OUTER JOIN (SELECT y.NoPermintaan, y.UrutPermintaan, x.kodebrg, 
                 SUM(x.Qnt) AS QntBPL, 
                 SUM(x.Qnt2) AS Qnt2BPL
                 FROM dbo.DBBatalPPLDET AS x
                      left outer join (Select y.NoPermintaan,y.UrutPermintaan,y.kodebrg, y.Nobukti,y.urut
                                       From DBPPLDET y 
                                       Group by y.NoPermintaan,y.UrutPermintaan,y.kodebrg, y.Nobukti,y.urut) y on y.Nobukti=x.NoPPL and y.urut=x.UrutPPL
                 GROUP BY y.NoPermintaan, y.UrutPermintaan, x.kodebrg) AS e ON e.NoPermintaan = A.Nobukti AND e.UrutPermintaan = A.urut AND 
                      c.kodebrg = A.kodebrg
Left Outer join DBPermintaanBrg F on F.Nobukti=A.Nobukti                      


GO

-- View: vwOutPO
-- Created: 2011-05-05 15:41:36.280 | Modified: 2011-09-16 08:43:29.037
-- =====================================================
CREATE View [dbo].[vwOutPO]
as

select	A.Nobukti, A.urut, A.NoPPL, A.UrutPPL, A.kodebrg, A.Sat_1, A.Sat_2, A.Isi, A.Qnt, A.Qnt2, 
	      isnull(B.QntBatal,0) QntBatal, isnull(B.Qnt2Batal,0) Qnt2Batal, 
	      isnull(C.QntBeli,0) QntBeli, isnull(C.Qnt2Beli,0) Qnt2Beli,
	      A.Qnt-isnull(C.QntBeli,0) QntSisaBeli, 
	      A.Qnt2-isnull(C.Qnt2Beli,0) Qnt2SisaBeli,
	      A.Qnt-isnull(B.QntBatal,0)-isnull(C.QntBeli,0)+ISNULL(C.QntTukar,0) QntSisa, 
	      A.Qnt2-isnull(B.Qnt2Batal,0)-isnull(C.Qnt2Beli,0)+ISNULL(C.Qnt2Tukar,0) Qnt2Sisa,
	      ISNULL(C.QntTukar,0) QntTukar, ISNULL(C.Qnt2Tukar,0) Qnt2Tukar
from 	dbPODet A
left outer join
	(Select NoPO, UrutPO, KodeBrg, sum(Qnt) QntBatal, sum(Qnt2) Qnt2Batal
	 from dbBatalPODet
	 group by NoPO, UrutPO, KodeBrg) B on B.NoPO=A.NoBukti and B.UrutPO=A.Urut and B.KodeBrg=A.KodeBrg
left outer join
	(select x.NoPO, x.URUTPO, x.KODEBRG, sum(Qnt) QntBeli, sum(Qnt2) Qnt2Beli, sum(y.QntTukar) QntTukar, sum(y.Qnt2Tukar) Qnt2Tukar
	 from dbBeliDet x
	      left outer join(select NOPBL, URUTPBL, KodeBrg, sum(QNTTukar) QntTukar, sum(QNT2Tukar) Qnt2Tukar
	                      from DBRBELIDET A 
	                      group by NOPBL, URUTPBL, KodeBrg) y on y.NOPBL=x.NoBukti and y.URUTPBL=x.Urut
	 group by x.NOPO, x.URUTPO, x.KODEBRG) C on C.NoPO=A.NoBukti and C.UrutPO=A.Urut and C.KodeBrg=A.KODEBRG

GO

-- View: vwOutPO_BP
-- Created: 2011-05-05 15:40:51.680 | Modified: 2011-06-09 11:17:17.323
-- =====================================================
CREATE View [dbo].[vwOutPO_BP]
as
select	A.NoBukti, A.Urut, A.NoPPL, A.UrutPPL, '' NoInspeksi, 0 UrutInspeksi, A.KodeBrg, A.Sat_1, A.Sat_2, A.Isi, A.Qnt, A.Qnt2, 
	isnull(B.QntBatal,0) QntBatal, isnull(B.Qnt2Batal,0) Qnt2Batal, 
	isnull(C.QntBeli,0) QntBeli, isnull(C.Qnt2Beli,0) Qnt2Beli,
	A.Qnt-isnull(C.QntBeli,0)+ISNULL(D.QntTukar,0) QntSisaBeli, 
	A.Qnt2-isnull(C.Qnt2Beli,0)+ISNULL(D.Qnt2Tukar,0) Qnt2SisaBeli,
	A.Qnt-isnull(B.QntBatal,0)-isnull(C.QntBeli,0)+ISNULL(D.QntTukar,0) QntSisa, 
	A.Qnt2-isnull(B.Qnt2Batal,0)-isnull(C.Qnt2Beli,0)+ISNULL(D.Qnt2Tukar,0) Qnt2Sisa,
	A.Nosat,A.Catatan
from 	dbPODet A
left outer join
	(
	select NoPO, UrutPO, KodeBrg, sum(Qnt) QntBatal, sum(Qnt2) Qnt2Batal
	from dbBatalPODet
	group by NoPO, UrutPO, KodeBrg
	) B on B.NoPO=A.NoBukti and B.UrutPO=A.Urut and B.KodeBrg=A.KodeBrg
left outer join
	(select NoPO, UrutPO, KodeBrg, sum(Qnt) QntBeli, sum(Qnt2) Qnt2Beli
	from dbBeliDet
	group by NoPO, UrutPO, KodeBrg
	) C on C.NoPO=A.NoBukti and C.UrutPO=A.Urut and C.KodeBrg=A.KodeBrg
Left outer join (Select y.NOPO,y.URUTPO,SUM(QNTTUKAR) QntTukar, SUM(Qnt2Tukar) Qnt2Tukar
                 from DBRBELIDET x
                 left Outer Join DBBELIDET y on y.NOBUKTI=x.NOPBL and y.URUT=x.URUTPBL
                 Group by y.NOPO,y.URUTPO) D on D.NOPO=C.NOPO and D.URUTPO=C.URUTPO 

GO

-- View: vwOutPO_Inspeksi
-- Created: 2011-05-05 15:42:41.480 | Modified: 2011-05-05 15:42:41.480
-- =====================================================



CREATE View [dbo].[vwOutPO_Inspeksi]
as

select	A.Nobukti, A.urut, A.NoPPL, A.UrutPPL, A.kodebrg, A.Sat_1, A.Sat_2, A.Isi, A.Qnt, A.Qnt2, 
	isnull(B.QntBatal,0) QntBatal, isnull(B.Qnt2Batal,0) Qnt2Batal, isnull(C.QntIns,0) QntIns, isnull(C.Qnt2Ins,0) Qnt2Ins,
	A.Qnt-isnull(C.QntIns,0) QntSisaIns, A.Qnt2-isnull(C.Qnt2Ins,0) Qnt2SisaIns,
	A.Qnt-isnull(B.QntBatal,0)-isnull(C.QntIns,0) QntSisa, A.Qnt2-isnull(B.Qnt2Batal,0)-isnull(C.Qnt2Ins,0) Qnt2Sisa, A.Nosat
from 	dbPODet A
left outer join
	(
	select NoPO, UrutPO, KodeBrg, sum(Qnt) QntBatal, sum(Qnt2) Qnt2Batal
	from dbBatalPODet
	group by NoPO, UrutPO, KodeBrg
	) B on B.NoPO=A.NoBukti and B.UrutPO=A.Urut and B.KodeBrg=A.KodeBrg
left outer join
	(select NoPO, UrutPO, KodeBrg, sum(Qnt1) QntIns, sum(Qnt2) Qnt2Ins
	from dbInspeksiDet
	group by NoPO, UrutPO, KodeBrg
	) C on C.NoPO=A.NoBukti and C.UrutPO=A.Urut and C.KodeBrg=A.KodeBrg
left outer join dbPPLDet P on P.NoBukti=A.NOPPL and P.Urut=A.UrutPPL
left outer join dbPermintaanBrgDet P2 on P2.NoBukti=P.NoPermintaan and P2.Urut=P.UrutPermintaan
where	P2.IsInspeksi=1





GO

-- View: vwOutPOBatal
-- Created: 2014-02-13 11:53:13.270 | Modified: 2014-07-18 10:07:35.923
-- =====================================================





CREATE View [dbo].[vwOutPOBatal]
as

select c.TANGGAL,A.Nobukti, NAMACUSTSUPP,a.urut, A.NoPPL, A.UrutPPL, A.kodebrg, A.Satuan,A.Isi, A.Qnt, 
	      isnull(B.QntBatal,0) QntBatal, A.NAMABRG,
	      A.Qnt-isnull(e.QntTerima,0) QntSisa, ISNULL(QntTerima,0)QntTerima
	 
from 	dbPODet A
left outer join DBPO c on c.NOBUKTI =a.NOBUKTI 
left outer join DBBARANG d on d.KODEBRG =a.KODEBRG 
left Outer join DBCUSTSUPP f on f.KODECUSTSUPP=c.KODESUPP

left outer join
	(Select NOBUKTI , Urut, KodeBrg, sum(QntBatal ) QntBatal
	 from dbPODet
	 group by NOBUKTI, Urut, KodeBrg) B on B.NOBUKTI=A.NoBukti and B.Urut=A.Urut and B.KodeBrg=A.KodeBrg
left outer join
	(Select NoPO , UrutPO, KodeBrg, sum(Qnt ) QntTerima
	 from dbbelidet
	 group by NOpo, Urutpo, KodeBrg) e on e.NoPO =A.NoBukti and e.UrutPO=A.Urut and e.KodeBrg=A.KodeBrg	 
where
Cast(Case when Case when c.IsOtorisasi1=1 then 1 else 0 end+
                       Case when c.IsOtorisasi2=1 then 1 else 0 end+
                       Case when c.IsOtorisasi3=1 then 1 else 0 end+
                       Case when c.IsOtorisasi4=1 then 1 else 0 end+
                       Case when c.IsOtorisasi5=1 then 1 else 0 end=c.MaxOL then 0
                  else 1
             end As Bit)=0 







GO

-- View: vwOutPPL
-- Created: 2014-02-13 11:53:13.260 | Modified: 2015-04-21 08:55:56.120
-- =====================================================





CREATE VIEW [dbo].[vwOutPPL]
AS
/*
select	A.Nobukti, A.NoUrut, A.Tanggal,c.NMDEP, 
B.urut, B.kodebrg, Br.NAMABRG, B.Sat, B.Nosat, B.Isi, B.Qnt, Isnull(B.QntPO,0)QntPO, B.Keterangan, isnull(B.Qnt,0)-Isnull(B.QntPO,0)-Isnull(B.Qntbatal,0) SisaPPL, B.IsClose,br.tolerate
,B.Qnt-isnull(e.QntTerima,0) QntSisa, QntTerima,B.QntBatal,B.Tglbatal,B.IsBatal,B.userbatal,
A.IsOtorisasi1, A.OtoUser1, A.TglOto1,
       A.IsOtorisasi2, A.OtoUser2, A.TglOto2,
       A.IsOtorisasi3, A.OtoUser3, A.TglOto3,
       A.IsOtorisasi4, A.OtoUser4, A.TglOto4,
       A.IsOtorisasi5, A.OtoUser5, A.TglOto5,
       Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi
from	DBPPL A
left outer join DBPPLDET B on B.Nobukti=A.Nobukti
left outer join DBBARANG Br on Br.KODEBRG=B.kodebrg
left outer join DBDEPART c on c.KDDEP=a.KDDep
left outer join
	(Select NoPPL , UrutPPL, KodeBrg, sum(Qnt ) QntTerima
	 from DBPODET
	 group by NoPPL, UrutPPL, KodeBrg) e on e.NoPPL =B.NoBukti and e.UrutPPL=B.Urut and e.KodeBrg=B.KodeBrg	 
where B.Qnt-Isnull(B.QntPO,0)>0 and a.IsOtorisasi1 =1
and isnull(A.IsBatal,0)=0
*/


select B.Nobukti,B.urut,S.NoPPL,S.UrutPPL,B.kodebrg,S.Kodebrg KOdebrgPO,Sum(isnull(B.Qnt,0)) Qnt,
Sum(isnull(B.Qnt,0)) QNTPR,Sum(isnull(S.QNT,0)) QNTPO,Sum(isnull(S.QNT,0)) QntTerima,
SUM(Isnull(B.Qntbatal,0)) QntBatal,SUM(Isnull(S.QntBatal,0)) QntBatalPO
,B.Isbatal BatalpR,B.IsClose ClosePR,S.IsClose ClosePO,S.Isbatal BatalPO,
B1.IsOtorisasi1, B1.OtoUser1, B1.TglOto1, B1.IsOtorisasi2, B1.OtoUser2, B1.TglOto2,
       B1.IsOtorisasi3, B1.OtoUser3, B1.TglOto3,
       B1.IsOtorisasi4, B1.OtoUser4, B1.TglOto4,
       B1.IsOtorisasi5, B1.OtoUser5, B1.TglOto5,
       Cast(Case when Case when b1.IsOtorisasi1=1 then 1 else 0 end+
                      Case when B1.IsOtorisasi2=1 then 1 else 0 end+
                      Case when B1.IsOtorisasi3=1 then 1 else 0 end+
                      Case when B1.IsOtorisasi4=1 then 1 else 0 end+
                      Case when B1.IsOtorisasi5=1 then 1 else 0 end=B1.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi
		,c.NMDEP,
Sum(isnull(B.Qnt,0)) - Sum(isnull(S.QNT,0)) QntSisa,B1.Nourut,
B1.Tanggal,B.sat,
 B.NamaBrg NamaBrg,
B.Nosat,B.Isi,S.Tolerate,B.Keterangan,B.IsClose,
Sum(isnull(B.Qnt,0))-Sum(Isnull(S.Qnt,0))-Sum(Isnull(B.Qntbatal,0)) SisaPPL
,B.Tglbatal,B.IsBatal,B.userbatal,ISnull(B.IsJasa,0) IsJasa,
MONTH(B1.Tanggal) BULAN, YEAR(B1.Tanggal) TAHUN
from DBPPLDET B 
Left Outer Join DBPODET S on B.Nobukti=S.NoPPL and B.urut=S.UrutPPL
Left Outer JOin DBPPL B1 on B.Nobukti=b1.Nobukti
left outer join DBDEPART c on c.KDDEP=B1.KDDep
LEFT Outer Join DBBARANG D on B.kodebrg=D.kodebrg
--where B.Nobukti in ('SJE/PR/0114/0013','SJE/PR/0114/0010')and S.NOBUKTI is null
Where  B1.IsOtorisasi1 =1 and isnull(b1.IsBatal,0)=0 and ISNULL(B.Isbatal,0)=0
group by B.Nobukti,B.urut,S.NoPPL,S.UrutPPL,B.Isbatal,B.IsClose,S.IsClose,S.Isbatal,
B.kodebrg,S.Kodebrg,B1.IsOtorisasi1,B1.Tanggal,
 B1.IsOtorisasi2, B1.OtoUser2, B1.TglOto2,
       B1.IsOtorisasi3, B1.OtoUser3, B1.TglOto3,
       B1.IsOtorisasi4, B1.OtoUser4, B1.TglOto4,
       B1.IsOtorisasi5, B1.OtoUser5, B1.TglOto5,B1.MaxOL
       ,c.NMDEP,B1.Nourut,B.Sat,D.NamaBrg,B.Nosat,B.Isi,S.Tolerate,B.Keterangan
,B.IsClose,B.Tglbatal,B.IsBatal,B.userbatal, B1.OtoUser1, B1.TglOto1,B.NamaBrg,B.IsJasa
having Sum(isnull(B.Qnt,0)) <>Sum(isnull(S.QNT,0))









GO

-- View: vwOutRJual
-- Created: 2013-02-05 11:18:37.143 | Modified: 2014-03-05 13:37:18.703
-- =====================================================


CREATE View [dbo].[vwOutRJual]
as

select	A.NoBukti, A.Urut, A.KodeBrg,  A.Sat_1, A.Sat_2, A.NoSat, A.Isi, A.Qnt, A.Qnt2, 
	isnull(C.QntSPB,0) QntSPB, isnull(C.Qnt2SPB,0) Qnt2SPB,
	A.Qnt-isnull(C.QntSPB,0) QntSisa, A.Qnt2-isnull(C.Qnt2SPB,0) Qnt2Sisa,
     a.NetW, A.GrossW, A.NoInvoice, A.UrutInvoice, A.NamaBrg, B.IsFLag
from 	DBRInvoicePLDET A
left outer join
	(select NoINV, UrutINV, KodeBrg, sum(Qnt) QntSPB, sum(Qnt2) Qnt2SPB
	 from dbSPBRjualDet
	 group by NoINV, UrutINV, KodeBrg) C on C.NoINV=A.NoBukti and C.UrutINV=A.Urut and C.KodeBrg=A.KodeBrg
	Left Outer Join DBRInvoicePL B on B.NoBukti=A.NoBukti

GO

-- View: vwOutSC
-- Created: 2011-08-19 09:45:37.840 | Modified: 2011-08-19 09:45:37.840
-- =====================================================

Create VIew [dbo].[vwOutSC]
as
Select a.Nobukti, b.Urut, b.Sat_1, b.Sat_2, b.Isi, b.Nosat, b.Qnt, b.Qnt2,
       b.Kodebrg, isnull(C.Qnt,0) QntSC, isnull(C.Qnt2,0) Qnt2SC,
       b.Qnt-isnull(C.Qnt,0) QntSisa,
       b.Qnt2-isnull(C.Qnt2,0) Qnt2Sisa
from dbSalesContract a
     left outer join dbSalesContractDet b on b.Nobukti=a.Nobukti
     left outer join (Select NoSC,UrutSC, SUM(Qnt) Qnt, SUM(Qnt2) Qnt2
                      from DBSHIPPINGDET 
                      group by NoSC,UrutSC) C on C.NoSC=a.Nobukti and C.UrutSC=b.Urut

GO

-- View: vwOutSC_SPP
-- Created: 2011-09-21 10:12:22.183 | Modified: 2011-09-21 17:50:20.290
-- =====================================================

CREATE View [dbo].[vwOutSC_SPP]
as

select	A.NoBukti, A.Urut, A.KodeBrg, A.Sat_1, A.Sat_2, A.NoSat, A.Isi, A.Qnt, A.Qnt2, 
	isnull(C.QntSPP,0) QntSPP, isnull(C.Qnt2SPP,0) Qnt2SPP,
	A.Qnt-isnull(C.QntSPP,0) QntSisa, A.Qnt2-isnull(C.Qnt2SPP,0) Qnt2Sisa,
	A.NamaBrg NamabrgKom
from 	dbSalesContractDet A
left Outer Join (select NoSC, UrutSC, KodeBrg, sum(Qnt) QntSPP, sum(Qnt2) Qnt2SPP
	              from dbSPPLokalDet
	              group by NoSC, UrutSC, KodeBrg) C on C.NoSC=A.NoBukti and C.UrutSC=A.Urut and C.KodeBrg=A.KodeBrg
Left Outer Join dbSalesContract B on B.Nobukti=A.Nobukti	              
where B.IsLokal=0



GO

-- View: vwOutSHIP
-- Created: 2011-08-19 15:28:49.410 | Modified: 2011-09-21 18:30:51.487
-- =====================================================

CREATE View [dbo].[vwOutSHIP]
as

select	A.NoBukti, A.Urut, A.KodeBrg, A.NamaBrg, A.Sat_1, A.Sat_2, A.NoSat, A.Isi,isnull(B.Qnt,0) Qnt, 
   isnull(B.Qnt2,0) Qnt2, 
	isnull(B.Qnt,0) QntSPB, isnull(B.Qnt2,0) Qnt2SPB,
	isnull(B.Qnt,0)-isnull(C.QntSPB,0) QntSisa, isnull(B.Qnt2,0)-isnull(C.Qnt2SPB,0) Qnt2Sisa,
	B.NetW,B.GrossW, A.NoSC
from 	DBSHIPPINGDET A
left outer join (select NoShip, UrutSHIP, KodeBrg, sum(Qnt) QntSPB, sum(Qnt2) Qnt2SPB
	              from dbInvoicePLDet
	              group by NoSHIP, UrutSHIP, KodeBrg) C on C.NoSHIP=A.NoBukti and C.UrutSHIP=A.Urut
Left Outer Join (Select x.NoSHIP,x.UrutSHIP, SUM(y.QNT) Qnt, SUM(y.qnt2) Qnt2,
                             sum(y.NetW) NetW, SUM(y.GrossW) GrossW
                 from dbSPPDet x
                      left Outer Join dbSPBDet y on y.NoSPP=x.NoBukti and y.UrutSPP=x.Urut
                 group by x.NoSHIP, x.UrutSHIP) B on B.NoSHIP=A.Nobukti and B.UrutSHIP=A.Urut   
left Outer join DBSHIPPING D on D.NoBukti=A.Nobukti
where D.isclose=1                            
	 



GO

-- View: vwOutSHIP_SPP
-- Created: 2011-08-19 08:46:40.327 | Modified: 2011-12-27 20:03:10.237
-- =====================================================




CREATE View [dbo].[vwOutSHIP_SPP]
as
select A.NoBukti, A.Urut, A.KodeBrg, A.Sat_1, A.Sat_2, A.NoSat, A.Isi, A.Qnt, A.Qnt2, 
	    isnull(C.QntSPP,0) QntSPP, isnull(C.Qnt2SPP,0) Qnt2SPP,
	    A.Qnt-isnull(C.QntSPP,0) QntSisa, A.Qnt2-isnull(C.Qnt2SPP,0) Qnt2Sisa,
	    A.NoSC, A.Namabrg NamabrgKom, A.shippingMark
from 	DBSHIPPINGDET A
left outer join(select NoSHIP, UrutSHIP, KodeBrg, sum(Qnt) QntSPP, sum(Qnt2) Qnt2SPP
	             from dbSPPDet
	             group by NoSHIP, UrutSHIP, KodeBrg) C on C.NoSHIP=A.NoBukti and C.UrutSHIP=A.Urut 
left Outer join (Select Nobukti
                 from dbSalesContract) D on D.Nobukti=A.NoSC	



GO

-- View: vwOutSO_SPP
-- Created: 2014-02-13 11:53:45.523 | Modified: 2015-03-24 10:37:19.007
-- =====================================================


CREATE View [dbo].[vwOutSO_SPP]
as
select A.NoBukti, A.Urut, A.KodeBrg, A.SATUAN, A.NoSat, A.Isi, A.Qnt, A.Qnt2, 
	    isnull(C.QntSPP,0) QntSPP, isnull(C.Qnt2SPP,0) Qnt2SPP,
	    A.Qnt-isnull(C.QntSPP,0) QntSisa, A.Qnt2-isnull(C.Qnt2SPP,0) Qnt2Sisa,
	    B.CATATAN, D.Namabrg NamabrgKom, B.IsLengkap, B.MasaBerlaku,A.IScloseDet,B.TANGGAL
from 	DBSODET A
Left Outer join DBSO B on b.NOBUKTI=A.NOBUKTI
left outer join(select NoSO, UrutSO, KodeBrg, sum(Qnt) QntSPP, sum(Qnt2) Qnt2SPP
	             from dbSPPDet
	             group by NoSO, UrutSO, KodeBrg) C on C.NoSO=A.NoBukti and C.UrutSo=A.Urut 
Left Outer join DBBARANG D on D.KODEBRG=A.KODEBRG
GO

-- View: vwOutSPB
-- Created: 2014-02-19 10:17:43.010 | Modified: 2014-02-19 10:18:40.073
-- =====================================================

CREATE view [dbo].[vwOutSPB]
as
With InvoicePL(NoInvoice, Kodecust, NoSPB, UrutSPB, Qnt, Qnt2)
AS
(Select A.NoBukti, a.KodeCustSupp, B.NoSPB, B.UrutSPB, Sum(B.QNT) Qnt, Sum(B.QNT2) Qnt2
 From dbInvoicePL A
      Left Outer join dbInvoicePLDet B on b.NoBukti=A.NoBukti
 Group by A.NoBukti, a.KodeCustSupp, B.NoSPB, B.UrutSPB)

Select A.NoBukti, B.KodeBrg, B.ISI, B.NOSAT,
       Case when B.NOSAT=1 then B.SAT_1 
            when B.NOSAT=2 then B.SAT_2
            else ''
       end Satuan, B.qnt, B.QNT2, B.NetW, B.GrossW,
       ISNULL(c.qnt,0) QntInv,
       B.QNT-ISNULL(c.qnt,0) Sisa,ISNULL(A.FlagTipe,0) FlagTipe       
From dbSPB a
     Left Outer join dbSPBDet b on b.NoBukti=a.NoBukti 
     left Outer join InvoicePL c on c.NoSPB=b.NoBukti and c.UrutSPB=b.urut
where B.QNT-ISNULL(c.qnt,0)>0


GO

-- View: vwOutSPB_RSPB
-- Created: 2014-02-19 10:17:42.977 | Modified: 2014-02-19 10:18:32.160
-- =====================================================

CREATE View [dbo].[vwOutSPB_RSPB]
as

Select A.NoBukti, A.Urut, A.KodeBrg, A.NamaBrg, A.Sat_1, A.Sat_2, A.NoSat, A.Isi, A.Qnt, A.Qnt2, 
	    isnull(C.QntRSPB,0) QntRSPB, isnull(C.Qnt2RSPB,0) Qnt2RSPB,
	    A.Qnt-isnull(C.QntRSPB,0) QntSisa, A.Qnt2-isnull(C.Qnt2RSPB,0) Qnt2Sisa,
	    A.NetW,A.GrossW, 'Ekspor' TipeSPP, B.Catatan, B.isClose, b.IsOtorisasi1,b.OtoUser1,b.TglOto1,
	    ISNULL(B.FlagTipe,0) FlagTipe
from 	DBSPBDet A
left outer join (select NoSPB, UrutSPB, KodeBrg, sum(Qnt) QntRSPB, sum(Qnt2) Qnt2RSPB
	              from DBRSPBDet
	              group by NoSPB, UrutSPB, KodeBrg) C on C.NoSPB=A.NoBukti and C.UrutSPB=A.Urut 
Left Outer Join DBSPB B on B.NoBukti=A.NoBukti
--where b.IsOtorisasi1=1


GO

-- View: vwOutSPBRJual
-- Created: 2014-09-24 11:37:06.870 | Modified: 2014-09-24 11:37:06.870
-- =====================================================
Create    View [dbo].[vwOutSPBRJual]
as

select X.NOBUKTI+' '+right('00000000'+cast(X.URUT as varchar(8)),8) KeyUrut,
	X.NOURUT, X.NOBUKTI, X.TANGGAL, X.KODECUSTSUPP, Cs.NAMACUSTSUPP,
	Cs.ALAMAT ALAMATCUSTSUPP, Cs.KOTA KOTACUSTSUPP, Cs.NamaKota NAMAKOTACUSTSUPP, 
	X.NoRPJ, X.URUT, X.KODEBRG, Br.NAMABRG, Br.SAT1, Br.SAT2, Br.NFix,
	Br.ISI1, Br.ISI2, 
	sum(X.Qnt) Qnt, SUM(X.Qnt1) Qnt1, SUM(X.Qnt2) Qnt2, 
	max(X.NOSAT) NoSat, max(X.SATUAN) Satuan, max(ISI) Isi, 
	sum(X.QntInv) QntInv, SUM(X.Qnt)-SUM(X.QntInv) QntSisa,
	SUM(X.Qnt)-SUM(X.QntInv) Qnt1Sisa, SUM(X.Qnt)-SUM(X.QntInv) Qnt2Sisa,
	X.NilaiOL, X.MaxOL
from
	(
	select A.NoUrut, A.NOBUKTI, A.TANGGAL, A.KodeCustSupp KODECUSTSUPP, 
		A.NoRPJ, B.URUT, B.KODEBRG, 
		B.Qnt, B.QNT1, B.QNT2, B.NOSAT, B.SAT_1 SATUAN, B.ISI, 
		0 QntInv,
		(Case when A.IsOtorisasi1=1 then 1 else 0 end+
        Case when A.IsOtorisasi2=1 then 1 else 0 end+
        Case when A.IsOtorisasi3=1 then 1 else 0 end+
        Case when A.IsOtorisasi4=1 then 1 else 0 end+
        Case when A.IsOtorisasi5=1 then 1 else 0 end) NilaiOL,
        A.MAXOL
	from dbSPBRJual A, dbSPBRJualDet B
	where B.NOBUKTI=A.NOBUKTI
	union all
	select A.NoUrut, A.NOBUKTI, A.TANGGAL, A.KodeCustSupp KODECUSTSUPP, 
		A.NoRPJ ,B.UrutSPR URUT, B.KODEBRG, 
		0 Qnt, 0 QNT2, 0 QNT2, 0 NoSat, '' Satuan, 0 Isi,
		B.Qnt QntInv,
		(Case when A.IsOtorisasi1=1 then 1 else 0 end+
        Case when A.IsOtorisasi2=1 then 1 else 0 end+
        Case when A.IsOtorisasi3=1 then 1 else 0 end+
        Case when A.IsOtorisasi4=1 then 1 else 0 end+
        Case when A.IsOtorisasi5=1 then 1 else 0 end) NilaiOL,
        A.MAXOL 
	from dbSPBRJual A, DBINVOICERPJDet B
	where B.NOSPR=A.NOBUKTI
	) X
left outer join vwCUSTSUPP Cs on Cs.KODECUSTSUPP=X.KODECUSTSUPP
left outer join DBBARANG Br on Br.KODEBRG=X.KodeBrg
group by X.NOURUT, X.NOBUKTI, X.TANGGAL, X.KODECUSTSUPP, Cs.NAMACUSTSUPP,
	Cs.ALAMAT, Cs.KOTA, Cs.NamaKota, 
	X.NoRPJ, X.Urut, X.KODEBRG, Br.NAMABRG, Br.SAT1, Br.SAT2, Br.NFix,
	Br.ISI1, Br.ISI2,
	X.NilaiOL, X.MaxOL



GO

-- View: vwOutSPK_HasilP
-- Created: 2014-04-14 11:01:54.660 | Modified: 2014-04-14 11:01:54.660
-- =====================================================


CREATE View [dbo].[vwOutSPK_HasilP]
AS
Select A.NoBukti,A.TANGGAL,A.KodeBrg KodeBrgJ,E.NamaBrg NamaBrgJ ,A.Qnt*A.isi QntJ,A.Nosat NosatJ,A.Isi IsiJ,A.Satuan SatJ,
       ISNULL(Case when A.Nosat=1 then Case when B.NOSAT=1 then B.QNT
                                            when B.NOSAT=2 then B.QNT*A.isi
                                            else 0
                                       end
                   when A.Nosat=2 then Case when B.NOSAT=1 then B.QNT/A.isi
                                            when B.NOSAT=2 then B.QNT
                                            else 0
                                       end
                   else 0
              end,0)*Case when A.nosat=1 then 1
                          When A.nosat=2 then A.Isi 
                     end QntH,
       (A.QNT*A.Isi)-(
       ISNULL(Case when A.Nosat=1 then Case when B.NOSAT=1 then B.QNT
                                            when B.NOSAT=2 then B.QNT*A.isi
                                            else 0
                                       end
                   when A.Nosat=2 then Case when B.NOSAT=1 then B.QNT/A.isi
                                            when B.NOSAT=2 then B.QNT
                                            else 0
                                       end
                   else 0
              end,0)*Case when A.nosat=1 then 1
                          When A.nosat=2 then A.Isi 
                     end) SisaSPK
From dbSPK A
     Left Outer join dbBarang E on E.KodeBrg=A.Kodebrg
     Left Outer join (Select y.NoSPK,y.KODEBRG, y.KodeGdg, y.QNT, y.NOSAT, y.ISI, y.SATUAN
                      from DBHASILPRD x
                           left Outer join DBHASILPRDDET y on y.NOBUKTI=x.NOBUKTI) B on B.NoSPK=A.NOBUKTI and B.KODEBRG=A.KODEBRG
where (A.QNT*A.isi)-(
       ISNULL(Case when A.Nosat=1 then Case when B.NOSAT=1 then B.QNT
                                            when B.NOSAT=2 then B.QNT*A.isi
                                            else 0
                                       end
                   when A.Nosat=2 then Case when B.NOSAT=1 then B.QNT/A.isi
                                            when B.NOSAT=2 then B.QNT
                                            else 0
                                       end
                   else 0
              end,0)*Case when A.nosat=1 then 1
                          When A.nosat=2 then A.Isi 
                     end)>0 


GO

-- View: vwOutSPK_Pakai
-- Created: 2014-04-21 13:31:36.003 | Modified: 2014-09-12 11:39:31.103
-- =====================================================




CREATE View [dbo].[vwOutSPK_Pakai]
as

select NOBUKTI, URUT, KODEBRG, NOSAT, 
sum(QNTSPK) QntSPK, sum(QntPakai) QntPakai, sum(QNTSisa) QntSisa, KodePrs
from
(
select NOBUKTI, URUT, KODEBRG, NOSAT, QNT QntSPK, 0.00 QntPakai, QNT QntSisa, KodePrs
from DBSPKDET
union all
select NoSPK NoBukti, UrutSPK Urut, kodebrg, NoSat,
0.00 QntSPK, case when NoSat=1 then Qnt else Qnt2 end QntPakai,
-1*case when NoSat=1 then Qnt else Qnt2 end QntSisa, B.KodePrs 
from DBPenyerahanBhnDET A
left outer join DBPenyerahanBhn B on A.Nobukti = B.nobukti
) X group by NOBUKTI, URUT, KODEBRG, NOSAT, KodePrs





GO

-- View: vwOutSPP
-- Created: 2011-10-19 08:41:19.427 | Modified: 2014-09-11 10:45:25.173
-- =====================================================



CREATE View [dbo].[vwOutSPP]
as

select	A.NoBukti, A.Urut, A.KodeBrg, A.NamaBrg, A.Sat_1, A.Sat_2, A.NoSat, A.Isi, A.Qnt, A.Qnt2, 
	isnull(C.QntSPB,0) QntSPB, isnull(C.Qnt2SPB,0) Qnt2SPB,
	A.Qnt-(isnull(C.QntSPB,0)-isnull(D.QNTRSPB,0)) QntSisa, A.Qnt2-(isnull(C.Qnt2SPB,0)-isnull(D.QNT2RSPB,0)) Qnt2Sisa,
	A.NetW,A.GrossW, 'Ekspor' TipeSPP, B.Catatan, B.isClose, 
     Case when A.NOSAT=1 then A.SAT_1
          when A.NOSAT=2 then A.SAT_2
          else ''
     end Satuan, A.NoSO, A.UrutSO, A.isCetakKitir,D.QNT2RSPB,D.QNTRSPB
from 	dbSPPDet A
left outer join
	(select NoSPP, UrutSPP, KodeBrg, sum(Qnt) QntSPB, sum(Qnt2) Qnt2SPB
	from dbSPBDet
	group by NoSPP, UrutSPP, KodeBrg
	) C on C.NoSPP=A.NoBukti and C.UrutSPP=A.Urut and C.KodeBrg=A.KodeBrg
	Left Outer Join dbSPP B on B.NoBukti=A.NoBukti
Left Outer join
   (Select b.NoSPP,B.UrutSPP,SUM(A.QNT) QNTRSPB,SUM(A.QNT2) QNT2RSPB
     from DBRSPBDet A
     Left OUter join dbSPBDet B on A.NoSPB =B.NoBukti and A.UrutSPB=B.Urut  
     left Outer join DBRSPB y on y.NoBukti=A.NoBukti
                                  where Cast(Case when Case when y.IsOtorisasi1=1 then 1 else 0 end+
                                                       Case when y.IsOtorisasi2=1 then 1 else 0 end+
                                                       Case when y.IsOtorisasi3=1 then 1 else 0 end+
                                                       Case when y.IsOtorisasi4=1 then 1 else 0 end+
                                                       Case when y.IsOtorisasi5=1 then 1 else 0 end=y.MaxOL then 0
                                                  else 1
                                       end As Bit)=0
     group By b.NoSPP,B.UrutSPP
   ) D on A.NoBukti=D.NoSPP And A.Urut=D.UrutSPP


GO

-- View: vwOutSPRK
-- Created: 2011-03-03 11:57:52.240 | Modified: 2011-12-29 13:36:09.397
-- =====================================================

CREATE VIEW [dbo].[vwOutSPRK]
AS
SELECT  A.Nobukti, A.urut, A.kodebrg, A.Sat_1, A.Sat_2, A.Isi, A.Qnt, A.Qnt2, 
        ISNULL(B.QntPO, 0) AS QntPO, 
        ISNULL(B.Qnt2PO, 0) AS Qnt2PO,
        ISNULL(B.QntBPO, 0) AS QntBPO, 
        ISNULL(B.Qnt2BPO, 0) AS Qnt2BPO, 
        ISNULL(D.QntBSPRK, 0) AS QntBSPRK, 
        ISNULL(D.Qnt2BSPRK, 0) AS Qnt2BSPRK, 
        A.Qnt - ISNULL(B.QntPO, 0)+ISNULL(B.QntBPO, 0)- ISNULL(D.QntBSPRK, 0) AS QntSisaPO, 
        A.Qnt2 - ISNULL(B.Qnt2PO, 0)+ISNULL(B.Qnt2BPO, 0)- ISNULL(D.Qnt2BSPRK, 0) AS Qnt2SisaPO, 
        A.Qnt - ISNULL(B.QntPO, 0)+ISNULL(B.QntBPO, 0) - ISNULL(D.QntBSPRK, 0) AS QntSisa, 
        A.Qnt2 - ISNULL(B.Qnt2PO, 0)+ISNULL(B.Qnt2BPO, 0) - ISNULL(D.Qnt2BSPRK, 0) AS Qnt2Sisa,
        E.NamaBag, A.nosat, A.Pelaksana,
        A.IsInspeksi,A.Keterangan,A.Catatan,A.KodeGrp,
        Case when A.Nosat=1 then A.Qnt
            when A.Nosat=2 then A.Qnt2
            else 0
       end SPRK_Qty,
       Case when A.Nosat=1 then ISNULL(D.QntBSPRK,0)
            when A.Nosat=2 then ISNULL(D.Qnt2BSPRK,0)
            else 0
       end SPRK_QtyBtl,
       Case when A.Nosat=1 then ISNULL(B.QntPO,0)
            when A.Nosat=2 then ISNULL(B.Qnt2PO,0)
            else 0
       end SPRK_QtyPO,
       Case when A.Nosat=1 then ISNULL(B.QntBPO,0)
            when A.Nosat=2 then ISNULL(B.Qnt2BPO,0)
            else 0
       end SPRK_QtyBPO,
       Case when A.Nosat=1 then A.Qnt - ISNULL(B.QntPO, 0)+ISNULL(B.QntBPO, 0) - ISNULL(D.QntBSPRK, 0)
            when A.Nosat=2 then A.Qnt2 - ISNULL(B.Qnt2PO, 0)+ISNULL(B.Qnt2BPO, 0) - ISNULL(D.Qnt2BSPRK, 0)
            else 0
       end SPRK_QtySisa,
       Case when A.Nosat=1 then A.Sat_1
            when A.Nosat=2 then A.Sat_2
            else ''
       end SPRK_Satuan,
       C.JnsPakai,
       Case when C.JnsPakai=0 then 'Stock'
				when c.JnsPakai=1 then 'Investasi'
				when c.JnsPakai=2 then 'Rep & Pem Teknik'
				when c.JnsPakai=3 then 'Rep & Pem Komputer'
				when c.JnsPakai=4 then 'Rep & Pem Peralatan'
		 end MyJnsPakai, C.Perk_Investasi, c.Kodegdg, c.SOP, C.Tanggal, C.KodeBag, C.KodeMesin
FROM dbo.DBSPRKDET AS A 
LEFT OUTER JOIN (SELECT  x.NoPPL, x.UrutPPL, KODEBRG, SUM(x.QNT) AS QntPO, SUM(x.QNT2) AS Qnt2PO,
                         ISNULL(y.qnt,0) QntBPO,ISNULL(y.Qnt2,0) Qnt2BPO
                 FROM  dbo.DBPODET x
                       left Outer join (Select  NoPO, UrutPO, SUM(Qnt) Qnt, SUM(Qnt2) Qnt2
                                        from DBBatalPODET  
                                        group by NoPO, UrutPO) y on y.NoPO=x.NOBUKTI and y.UrutPO=x.URUT 
                 GROUP BY x.NoPPL, x.UrutPPL, x.KODEBRG, y.Qnt,y.Qnt2) AS B ON B.NoPPL = A.Nobukti AND B.UrutPPL = A.urut
left Outer join dbSPRK c on c.NoBukti=A.NoBukti
LEFT OUTER JOIN (SELECT  NoSPRK, UrutSPRK, KODEBRG, SUM(QNT) AS QntBSPRK, SUM(QNT2) AS Qnt2BSPRK
                 FROM  dbo.DBBatalSPRKDET
                 GROUP BY NoSPRK, UrutSPRK, KODEBRG) AS D ON D.NoSPRK = A.Nobukti AND D.UrutSPRK = A.urut                 
left outer join DBBAGIAN E on E.KodeBag=c.KodeBag





GO

-- View: vwOutstandingBeli
-- Created: 2012-11-29 14:29:46.490 | Modified: 2012-12-19 14:05:58.230
-- =====================================================







CREATE View [dbo].[vwOutstandingBeli]
as

select 	A.NoBukti, A.Urut, A.KodeBrg, isnull(B.QntSat1,0) QntRBeliSat1, isnull(B.QntSat2,0) QntRBeliSat2   
from 	dbBeliDet A
left outer join vwQntRBeliDariBeli B on B.NoBeli=A.NoBukti and B.UrutPBL=A.Urut
where	A.Qnt*A.Isi>isnull(B.QntSat1,0)














GO

-- View: vwOutstandingPO
-- Created: 2013-05-13 12:08:51.980 | Modified: 2014-11-19 10:03:40.273
-- =====================================================


CREATE    View [dbo].[vwOutstandingPO]
as

select 	A.NoBukti, A.Urut, A.KodeBrg,A.namaBrg,((A.Qnt*A.Isi)-(A.QntBatal*isi))-Isnull(B.QntSat1,0)QNTOS
,A.Qnt*a.ISI QntPO,A.Satuan,isnull(B.QntSat1,0) QntBeliSat1,
A.QNT,
(A.Qnt*A.Isi)-(A.QntBatal*isi) - isnull(B.QntSat1,0) OS  
from 	dbPODet A
left outer join  vwQntBeliDariPO B on B.NOPO=A.NoBukti and B.UrutPO=A.Urut
where	((A.Qnt*A.Isi)-(A.QntBatal*isi)) - isnull(B.QntSat1,0)>0
GO

-- View: vwOutTBJ_RBJ
-- Created: 2011-08-25 16:11:45.830 | Modified: 2011-08-25 16:11:45.830
-- =====================================================

CREATE View [dbo].[vwOutTBJ_RBJ]
as
Select A.Nobukti,A.Urut,A.Kodebrg,A.Kodegdg, A.Qnt,A.Qnt2, A.Nosat,A.Isi,A.Sat_1,A.Sat_2,
       isnull(B.Qnt,0) QntR, isnull(B.Qnt2,0) Qnt2R,
       A.Qnt-ISNULL(B.Qnt,0) qntSisa,
       A.Qnt2-ISNULL(B.Qnt2,0) Qnt2Sisa
From DbPenerimaanBrgJadiDet A
     left Outer join (Select x.NoTerima,x.UrutTerima, SUM(x.Qnt) Qnt, SUM(x.qnt2) Qnt2
                      from DbRPenerimaanBrgJadiDet x
                      Group by x.Noterima,x.UrutTerima) B on B.NoTerima=A.Nobukti and B.urutTerima=A.Urut
Where (A.Qnt-ISNULL(B.Qnt,0)<>0) Or (A.Qnt2-ISNULL(B.Qnt2,0)<>0)  

GO

-- View: vwpemakaianbrg
-- Created: 2011-09-30 13:32:15.170 | Modified: 2011-12-20 20:34:17.353
-- =====================================================

CREATE View [dbo].[vwpemakaianbrg]
as

SELECT a.Nobukti,b.Tanggal, a.kodebrg,c.NAMABRG,c.KodeJnsBrg,  b.Kodebag,d.NamaBag
,e.KodeJnsPakai,f.Keterangan,e.KodeMesin,g.NamaMesin,case when a.Nosat = 1 then a.Sat_1 else a.Sat_2 end as satuan,
case when a.Nosat = 1 then a.Qnt else a.Qnt2 end as QNT,a.hpp,
a.Qnt *ISNULL(a.HPP,0) as total,
Case when b.JnsPakai=0 then 'Stock'
	  when b.JnsPakai=1 then 'Investasi'
	  when b.JnsPakai=2 then 'Rep & Pem Teknik'
	  when b.JnsPakai=3 then 'Rep & Pem Komputer'
	  when b.JnsPakai=4 then 'Rep & Pem Peralatan'
end MyJnsPakai,b.JnsPakai
FROM DBPenyerahanBrgdet a 
left outer join DBPenyerahanBrg b on a.Nobukti = b.Nobukti
left outer join DBBARANG c on a.kodebrg = c.KODEBRG
left outer join DBBAGIAN d on b.Kodebag = d.KodeBag
left outer join DBPermintaanBrg e on b.NoBPPB=e.Nobukti
left outer join DBJNSPAKAI f on e.KodeJnsPakai = f.KodeJNSPakai
left outer join DBMESIN g on e.KodeMesin = g.KodeMesin


GO

-- View: vwPenerimaanBrg
-- Created: 2011-09-30 13:32:16.733 | Modified: 2011-12-21 08:22:01.347
-- =====================================================

CREATE View [dbo].[vwPenerimaanBrg]
as
select  a.NOBUKTI,b.TANGGAL,b.KODECUSTSUPP, d.NAMACUSTSUPP,
        a.KODEBRG,c.NAMABRG,a.Nosat,a.QNT,a.QNT2,a.SAT_1,a.SAT_2,f.NOPPL,c.ISJASA,c.KodeJnsBrg,
        f.tipe,
        case when a.nosat =1 then a.sat_1 
             else a.sat_2 
        end as satuan,
        case when a.Nosat = 1 then a.QNT 
             else a.QNT2 
        end as quantity,
        a.HARGA,b.KODEVLS,b.KURS,
        a.SUBTOTAL,a.SUBTOTALRp,
        a.NDPP,a.NDPPRp, a.NPPN, a.NPPNRp, a.NNET, a.NNETRp,        
        c.KodeKategori,g.Keterangan NamaKategori,g.Perkiraan PerkPersediaan, h.Keterangan NamaPerkPersediaan, 
        d.PERKIRAAN PerkHutang, d.NamaPerkiraan NamaPerkHutang
from DBBELIDET a 
left outer join DBBELI b on a.NOBUKTI = b.NOBUKTI
left outer join DBBARANG c on a.KODEBRG = c.KODEBRG
left outer join vwBrowsSupp d on b.KODECUSTSUPP = d.KODECUSTSUPP
left outer join (Select x.NOBUKTI NOPO, x.URUT URutPO, y.Tipe, x.NoPPL
                 from DBPODET x
                      left outer join DBPO y on y.NOBUKTI=x.NOBUKTI 
                 Group by x.NOBUKTI, x.URUT, x.NoPPL, y.Tipe) f on f.NOPO=a.NOPO and f.URutPO=a.URUTPO
left outer join DBKATEGORI g on g.KodeKategori=c.KodeKategori
left outer join DBPERKIRAAN h on h.Perkiraan=g.Perkiraan

GO

-- View: vwPerkiraan
-- Created: 2011-11-22 14:44:27.420 | Modified: 2011-11-22 14:44:27.420
-- =====================================================
Create View dbo.vwPerkiraan
as
select a.*,
                 Case when a.Tipe=0 then 'General'
                      when a.Tipe=1 then 'Detail'
                      else '''' 
                 end mytipe, 
                 Case when a.DK=0 then 'Debet'
                      when a.DK=1 then 'Kredit'
                      else '''' 
                 end myDK ,
                 Case when a.Kelompok=0 then 'Aktiva'
                      when a.Kelompok=1 then 'Kewajiban'
                      when a.Kelompok=2 then 'Modal'
                      when a.Kelompok=3 then 'Kelompok'
                      when a.Kelompok=4 then 'Pendapatan'
                      when a.Kelompok=5 then 'Biaya'
                      else '' 
                 end myKelompok from dbPerkiraan a 
GO

-- View: vwPerusahaan
-- Created: 2012-10-25 13:21:44.743 | Modified: 2012-10-25 13:21:44.743
-- =====================================================

CREATE VIEW [dbo].[vwPerusahaan]
AS
SELECT KODEUSAHA, NAMA, ALAMAT1 + CHAR(13) + ALAMAT2 + CHAR(13) + 'Telp ' + Telpon + ', ' + 'Fax ' + Fax + CHAR(13)+
       'E-mail : '+Email AS Alamat, ALAMAT1 AlamatReport, LOGO, 
       Direksi, Jabatan, KOTA, email,
       NPWP, NAMAPKP, ALAMATPKP1+CHAR(13)+ALAMATPKP2+CHAR(13)+KOTAPKP AlamatPKP1, TGLPENGUKUHAN,
       NPWP1, NAMAPKP1, ALAMATPKP21+CHAR(13)+ALAMATPKP22+CHAR(13)+KOTAPKP1 AlamatPKP2, TGLPENGUKUHAN1
FROM dbo.DBPERUSAHAAN

GO

-- View: vwPostBiaya
-- Created: 2011-11-23 18:45:57.607 | Modified: 2011-11-23 22:13:33.877
-- =====================================================

CREATE View [dbo].[vwPostBiaya]
as
Select A.KODEBAG, B.NamaBag, A.KodeMesin, C.NamaMesin, A.PERKIRAAN, D.Keterangan NamaPerkiraan,
       B.NamaBag+Case when B.NamaBag is null then '' else ' ('+B.KodeBag+')' end myBagian,
       C.NamaMesin+Case when C.NamaMesin is null then '' else ' ('+C.KodeMesin+')' end myMesin, 
       D.Keterangan+Case when D.Keterangan is null then '' else ' ('+D.Perkiraan+')' end myPerkiraan
from DBPOSTBIAYA A
     left outer join DBBAGIAN B on B.KodeBag=A.KODEBAG
     left outer join DBMESIN C on C.KodeMesin=A.KodeMesin
     left outer join DBPERKIRAAN D on D.Perkiraan=A.PERKIRAAN


GO

-- View: vwPostHutPiut
-- Created: 2013-12-17 12:18:07.163 | Modified: 2023-04-15 19:47:28.040
-- =====================================================








CREATE View [dbo].[vwPostHutPiut]
as
SELECT A.NOBUKTI NoFaktur, '' NoRetur, 'T' TipeTrans, A.KodeSupp KODECUSTSUPP, 
	'' NoBukti, 1 NoMsk, 1 Urut, A.TANGGAL, A.TANGGAL+A.HARI JatuhTempo, 
	0 Debet, sum(B.NNETRp) Kredit, Sum(B.NNETRp) Saldo, 
	A.KodeVls Valas, A.KURS, 
	0 DebetD, case when A.KODEVLS='IDR' then 0 else sum(B.NNet) end KreditD, 
	case when A.KODEVLS='IDR' then 0 else sum(B.NNet) end SaldoD, 
    '' KodeSales, 'HT' Tipe, J.Perkiraan PERKIRAAN, '' Catatan, 
    'PBL' NoInvoice, A.NOBUKTI NoPajak, A.KodeVls KodeVls_, A.Kurs Kurs_,
    A.IsOtorisasi1 IsOtorisasi, A.NoJurnal
FROM   DBBELI A      
LEft Outer join DBBELIDET B on B.NOBUKTI=A.NOBUKTI
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='HT'AND X.Urut=2) J on 1=1
Group by A.NoBukti, A.KodeSupp, A.TANGGAL, A.HARI,
	A.KodeVls, A.Kurs, A.IsOtorisasi1, A.NoJurnal,J.Perkiraan

-- Retur Pembelian
union all
SELECT A.NOBELI NoFaktur, A.NOBUKTI NoRetur, 'T' TipeTrans, A.KodeSupp KODECUSTSUPP, 
	'' NoBukti, 1 NoMsk, 1 Urut, A.TANGGAL, A.TANGGAL JatuhTempo, 
	sum(B.NNETRp) Debet, 0 Kredit, -1*Sum(B.NNETRp) Saldo, 
	A.KodeVls Valas, A.KURS, 
	case when A.KODEVLS='IDR' then 0 else sum(B.NNet) end DebetD, 0 KreditD, 
	-1*case when A.KODEVLS='IDR' then 0 else sum(B.NNet) end SaldoD, 
    '' KodeSales, 'HT' Tipe, J.Perkiraan PERKIRAAN, '' Catatan, 
    'RPB' NoInvoice, A.NOBUKTI NoPajak, ISNULL(Bl.KodeVls,A.KodeVls) KodeVls_, isnull(Bl.Kurs,A.Kurs) Kurs_,
    A.IsOtorisasi1 IsOtorisasi, A.NoJurnal
FROM   DBRBELI A      
LEft Outer join DBRBELIDET B on B.NOBUKTI=A.NOBUKTI
left outer join DBBELI Bl on Bl.NOBUKTI=A.NOBELI
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='HT'AND X.Urut=2) J on 1=1
Group by A.NoBukti, A.NOBELI, A.KodeSupp, A.TANGGAL, A.HARI,
	A.KodeVls, A.Kurs, Bl.KODEVLS, Bl.KURS, A.IsOtorisasi1, A.NoJurnal,J.PERKIRAAN

-- Debet Note
union all
select B.NoInv NoFaktur, A.NOBUKTI NoRetur, 'T' Tipetrans, A.KodeSupp KODECUSTSUPP, 
       '' NoBukti, 1 NoMsk, 1 Urut, A.TANGGAL, A.TANGGAL JatuhTempo, 
       sum(B.NilaiRp) Debet, 0.00 Kredit, -sum(B.NilaiRp) Saldo, 
       B.KodeVls Valas, B.Kurs KURS, 
       case when B.KodeVLS='IDR' then 0 else sum(B.Nilai) end DebetD, 0.00 KreditD, 
       case when B.KodeVLS='IDR' then 0 else -sum(B.Nilai) end SaldoD, 
       '' KodeSales, 'HT' Tipe, 
       J.Perkiraan PERKIRAAN, '' Catatan, 'DN' NoInvoice, A.NOBUKTI NoPajak,
       isnull(Bl.KodeVls,B.KodeVls) KodeVls_, isnull(Bl.Kurs,B.Kurs) Kurs_,
       A.IsOtorisasi1 IsOtorisasi, A.NoJurnal
FROM   DBDebetNote A      
LEft Outer join DBDebetNoteDET B on B.NOBUKTI=A.NOBUKTI
left outer join DBBELI Bl on Bl.NOBUKTI=B.NoInv
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='HT'AND X.Urut=2) J on 1=1
Group by A.NoBukti, A.KodeSupp, A.Tanggal,
	B.KodeVls, B.Kurs, A.NoJurnal, B.NoInv,
	Bl.KODEVLS, Bl.Kurs, A.IsOtorisasi1, A.NoJurnal,J.PERKIRAAN
		
-- Invoice Penjualan

union all
SELECT A.NoBukti NoFaktur, '' NoRetur, 'T' TipeTrans, A.KodeCustSupp KODECUSTSUPP, 
	a.NoJurnal  NoBukti, 1 NoMsk, 1 Urut, A.TANGGAL, A.TANGGAL+D.HARI JatuhTempo, 
	sum(B.NNET) Debet, 0 Kredit, Sum(B.NNETRp) Saldo, 
	A.Valas, A.KURS, 
	case when A.Valas='IDR' then 0 else sum(B.NNet) end DebetD, 0 KreditD, 
	case when A.Valas='IDR' then 0 else sum(B.NNet) end SaldoD, 
    '' KodeSales, 'PT' Tipe, j.PERKIRAAN PERKIRAAN, '' Catatan, 
    'INVC' NoInvoice, A.NoBukti NoPajak, A.Valas KodeVls_, A.Kurs Kurs_,
    A.IsOtorisasi1 IsOtorisasi, A.NoJurnal
FROM   dbInvoicePL A      
LEft Outer join dbInvoicePLDet B on B.NOBUKTI=A.NOBUKTI
left outer join dbSPP C on c.NoBukti=a.NoSPP
left outer join DBSO D on D.NOBUKTI=c.NoSHIP
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='PT'AND X.Urut=2) J on 1=1 
Group by A.NoBukti, A.KodeCustSupp, A.TANGGAL, D.HARI,
	A.Valas, A.Kurs, A.IsOtorisasi1, A.NoJurnal,J.Perkiraan

-- Retur Penjualan
union all
SELECT A.NoInvoice NoFaktur, A.NOBUKTI NoRetur, 'T' TipeTrans, A.KODECUSTSUPP, 
	'' NoBukti, 1 NoMsk, 1 Urut, A.TANGGAL, A.TANGGAL JatuhTempo, 
	0 Debet, sum(B.NNETRp) Kredit, -1*Sum(B.NNETRp) Saldo, 
	A.KodeVls Valas, A.KURS, 
	0 DebetD, case when A.KODEVLS='IDR' then 0 else sum(B.NNet) end KreditD, 
	-1*case when A.KODEVLS='IDR' then 0 else sum(B.NNet) end SaldoD, 
    '' KodeSales, 'PT' Tipe, J.PERKIRAAN PERKIRAAN, '' Catatan, 
    'RPJ' NoInvoice, A.NOBUKTI NoPajak, ISNULL(Bl.Valas,A.KodeVls) KodeVls_, isnull(Bl.Kurs,A.Kurs) Kurs_,
    A.IsOtorisasi1 IsOtorisasi, A.NoJurnal
FROM   DBINVOICERPJ A      
LEft Outer join DBINVOICERPJDet B on B.NOBUKTI=A.NOBUKTI
left outer join dbInvoicePL Bl on Bl.NOBUKTI=A.NoInvoice
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='PT'AND X.Urut=2) J on 1=1
Group by A.NoBukti, A.NoInvoice, A.KODECUSTSUPP, A.TANGGAL, A.HARI,
	A.KodeVls, A.Kurs, Bl.Valas, Bl.KURS, A.IsOtorisasi1, A.NoJurnal,J.PERKIRAAN

-- Kredit Note
union all
select B.NoInv NoFaktur, A.NOBUKTI NoRetur, 'T' Tipetrans, A.KodeSupp KODECUSTSUPP, 
       '' NoBukti, 1 NoMsk, 1 Urut, A.TANGGAL, A.TANGGAL JatuhTempo, 
       0.00 Debet, sum(B.NilaiRp) Kredit, -sum(B.NilaiRp) Saldo, 
       B.KodeVls Valas, B.Kurs KURS, 
       case when B.KodeVLS='IDR' then 0 else sum(B.Nilai) end DebetD, 0.00 KreditD, 
       case when B.KodeVLS='IDR' then 0 else -sum(B.Nilai) end SaldoD, 
       '' KodeSales, 'PT' Tipe, 
       J.Perkiraan PERKIRAAN, '' Catatan, 'KN' NoInvoice, A.NOBUKTI NoPajak,
       isnull(Bl.Valas,B.KodeVls) KodeVls_, isnull(Bl.Kurs,B.Kurs) Kurs_,
       A.IsOtorisasi1 IsOtorisasi, A.NoJurnal
FROM   DBKreditNote A      
LEft Outer join DBKreditNoteDET B on B.NOBUKTI=A.NOBUKTI
left outer join dbInvoicePL Bl on Bl.NOBUKTI=B.NoInv
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='PT'AND X.Urut=2) J on 1=1
Group by A.NoBukti, A.KodeSupp, A.Tanggal,
	B.KodeVls, B.Kurs, A.NoJurnal, B.NoInv,
	Bl.Valas, Bl.Kurs, A.IsOtorisasi1, A.NoJurnal,J.PERKIRAAN




GO

-- View: vwPostJurnalOto
-- Created: 2014-10-01 11:27:01.077 | Modified: 2023-04-15 19:12:30.670
-- =====================================================






CREATE  View [dbo].[vwPostJurnalOto]  
as  
SELECT A.NoJurnal NOBUKTI, A.NOURUT, A.TANGGAL TANGGAL,'01' DEVISI, 
	'Pembelian '+isnull(Cs.NamaCustSupp,'')  NOTE,0 LAMPIRAN, 
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
	min(B.Urut) URUT, 
	isnull(F.PerkPers,'') PERKIRAAN, J.Perkiraan LAWAN,
	A.NOBUKTI+' '+isnull(Cs.NamaCustSupp,'') KETERANGAN, 
	'' KETERANGAN2, 
	SUM(B.NDPP) DEBET, 0 KREDIT, A.KODEVLS Valas, A.KURS, 
	SUM(B.NDPPRP) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, 
	'' CUSTSUPPP,'' CUSTSUPPL, '' KODEP, 
	'' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '' KODEBAG, '' STATUSGIRO, 
	'BPL' JENIS, A.NOBUKTI NOBUKTITRANS
FROM DBO.DBBELI A 
LEFT OUTER JOIN DBO.DBbeliDET B ON B.NOBUKTI=A.NOBUKTI 
LEFT OUTER JOIN DBO.DBCUSTSUPP Cs ON Cs .KODECUSTSUPP=A.KODESUPP
Left Outer Join dbo.DBBARANG Br on Br.KODEBRG=B.KODEBRG
Left Outer join dbo.dbSubGroup F on f.KodeGrp=Br.KODEGRP and F.KodeSubGrp=Br.KODESUBGRP
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='HT'AND X.Urut=2) J on 1=1
--where A.NoJurnal<>''
GROUP BY A.NOBUKTI, A.NOURUT, A.TANGGAL, Cs.NAMACUSTSUPP, A.KODESUPP,J.Perkiraan,
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL,
	F.PerkPers, A.KODEVLS, A.KURS, A.NOURUT,
	A.NoJurnal, F.PerkH

Union ALL
SELECT A.NoJurnal NOBUKTI, A.NOURUT, A.TANGGAL TANGGAL,'01' DEVISI, 
	'PPN Masukan '+isnull(Cs.NAMACUSTSUPP,'') NOTE,0 LAMPIRAN, 
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
	min(B.Urut)+100 URUT, 
	isnull(J.Perkiraan,'') PERKIRAAN, K.Perkiraan LAWAN,
	'PPN '+isnull(A.NOBUKTI,'')+' '+isnull(Cs.NAMACUSTSUPP,'') KETERANGAN, 
	'' KETERANGAN2, 
	SUM(B.NPPN) DEBET, 0 KREDIT, A.KODEVLS Valas, A.KURS, 
	SUM(B.NPPNRp) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, 
	'' CUSTSUPPP,'' CUSTSUPPL, '' KODEP, 
	'' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '' KODEBAG, '' STATUSGIRO,
	'BPL' JENIS, A.NOBUKTI NOBUKTITRANS
FROM DBO.DBbeli A 
LEFT OUTER JOIN DBO.DBBELIDET B ON B.NOBUKTI=A.NOBUKTI 
LEFT OUTER JOIN DBO.DBCUSTSUPP Cs ON Cs.KODECUSTSUPP=A.KODESUPP
Left Outer join dbo.DBPOSTHUTPIUT J on J.Kode='PPM'
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='HT'AND X.Urut=2) K on 1=1
--where A.NoJurnal<>''
GROUP BY A.NOBUKTI, A.NOURUT, A.TANGGAL, Cs.NAMACUSTSUPP, A.KODESUPP,K.Perkiraan,
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL,
	A.KODEVLS, A.KURS, A.NOURUT,
	A.NoJurnal, J.Perkiraan
having SUM(B.NPPNRp)<>0
union all
--Rbeli
SELECT A.NoJurnal NOBUKTI, A.NOURUT, A.TANGGAL TANGGAL,'01' DEVISI, 
	'Retur Beli '+isnull(Cs.NamaCustSupp,'') NOTE,0 LAMPIRAN, 
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
	MIN(B.URUT) URUT, 
	K.PERKIRAAN PERKIRAAN, isnull(F.PerkPers,'') LAWAN,
	'RB '+A.NOBUKTI+' '+isnull(Cs.NamaCustSupp,'') KETERANGAN, 
	'' KETERANGAN2, 
	SUM(B.NDPP) DEBET, 0 KREDIT, A.KODEVLS Valas, A.KURS, 
	SUM(B.NDPPRP) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, 
	'' CUSTSUPPP,'' CUSTSUPPL, '' KODEP, 
	'' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '' KODEBAG, '' STATUSGIRO, 
	'RPB' JENIS, A.NOBUKTI NOBUKTITRANS
FROM DBO.DBRBELI A 
LEFT OUTER JOIN DBO.DBRBELIDET B ON B.NOBUKTI=A.NOBUKTI 
LEFT OUTER JOIN DBO.DBCUSTSUPP Cs ON Cs.KODECUSTSUPP=A.KODESUPP
Left Outer Join dbo.DBBARANG Br on Br.KODEBRG=B.KODEBRG
Left Outer join dbo.dbSubGroup F on F.KodeGrp=Br.KODEGRP and F.KodeSubGrp=Br.KODESUBGRP
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='HT'AND X.Urut=2) K on 1=1
--where A.NoJurnal<>''
GROUP BY A.NOBUKTI, A.NOURUT, A.TANGGAL, Cs.NAMACUSTSUPP, A.KODESUPP,K.Perkiraan,
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL,
	F.PerkPers, A.KODEVLS, A.KURS, A.NOURUT,
	A.NoJurnal, F.PerkH

union All
SELECT A.NoJurnal NOBUKTI, A.NOURUT, A.TANGGAL TANGGAL,'01' DEVISI, 
	'PPN '+A.NOBUKTI+' '+isnull(Cs.NAMACUSTSUPP,'') NOTE,0 LAMPIRAN, 
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
	MIN(B.URUT)+100 URUT, 
	K.PERKIRAAN PERKIRAAN, isnull(J.Perkiraan,'') LAWAN,
	'PPN '+A.NOBUKTI+' '+isnull(Cs.NAMACUSTSUPP,'') KETERANGAN, 
	'' KETERANGAN2, 
	SUM(B.NPPN) DEBET, 0 KREDIT, A.KODEVLS Valas, A.KURS, 
	SUM(B.NPPNRP) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, 
	'' CUSTSUPPP,'' CUSTSUPPL, '' KODEP, 
	'' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '' KODEBAG, '' STATUSGIRO, 
	'RPB' JENIS, A.NOBUKTI NOBUKTITRANS
FROM DBO.DBRBELI A 
LEFT OUTER JOIN DBO.DBRBELIDET B ON B.NOBUKTI = A.NOBUKTI 
LEFT OUTER JOIN DBO.DBCUSTSUPP Cs ON Cs.KODECUSTSUPP = A.KODESUPP
Left Outer join dbo.DBPOSTHUTPIUT J on J.Kode='PPM'
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='HT'AND X.Urut=2) K on 1=1
--where A.NoJurnal<>''
GROUP BY A.NOBUKTI, A.NOURUT, A.TANGGAL, Cs.NAMACUSTSUPP, A.KODESUPP,K.Perkiraan,
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL,
	A.KODEVLS, A.KURS, A.NOURUT,
	A.NoJurnal, J.Perkiraan
having SUM(B.NPPNRp)<>0


-- Debet Note
union all
SELECT A.NoJurnal NOBUKTI, A.NoUrut, A.TANGGAL,'01' DEVISI, 
      'Debet Note : ' + A.NOBUKTI +' TANGGAL : '+ Convert(Varchar(15),A.Tanggal, 105) NOTE,0 LAMPIRAN, 
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
       CAST(ROW_NUMBER() Over(PARTITION BY A.NoJurnal Order by A.Nojurnal) As int) URUT,  
       K.Perkiraan PERKIRAAN, 
       J.PERKIRAAN  LAWAN, 
       'Debet Note : ' + isnull(I.NAMACUSTSUPP,'') + ' (' + Isnull(I.KODECUSTSUPP,'') + ')'+CHAR(13)+ 
       'No. Invoice : '+B.NoInv KETERANGAN, '' KETERANGAN2, 
       Sum(B.Nilai) DEBET, 0 KREDIT, B.KodeVLS VALAS, B.Kurs, 
       Sum(B.NilaiRp) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, '' CUSTSUPPP, '' CUSTSUPPL, '' KODEP, 
       '' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '01' KODEBAG, '' STATUSGIRO, 
       'DN' JENIS, A.NOBUKTI NOBUKTITRANS
FROM  DBO.DBDebetNote A 
LEFT OUTER JOIN DBO.DBDebetNoteDET B ON B.NOBUKTI = A.NOBUKTI 
Left Outer join (Select x.NoFaktur, Min(x.Tanggal) Tanggal
                 From dbo.vwHutPiut x
                 where TipeTrans='T'
                 Group by x.NoFaktur) C on C.NoFaktur=B.NoInv
Left outer join dbo.vwCUSTSUPP I on I.KODECUSTSUPP=A.KodeSupp 
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='BD') J on 1=1
 Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='HT'AND X.Urut=2) K on 1=1               
--Where A.NoJurnal<>''
Group by A.NoJurnal, A.TglJurnal, A.TANGGAL, B.kodevls, B.Kurs,B.NoInv, C.Tanggal, 
      A.NOBUKTI, A.NoUrut, i.NAMACUSTSUPP, I.KODECUSTSUPP,A.TANGGAL,A.KodeSupp,K.Perkiraan,
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
       J.Perkiraan,A.NoUrutJurnal
       
       
-- Surat Jalan
UNION ALL
SELECT A.NoJurnal NOBUKTI, A.NoUrut, A.Tanggal,'01' DEVISI, 
	'Surat Jalan '+A.NoBukti+' '+isnull(Cs.NAMACUSTSUPP,'') NOTE, 0 LAMPIRAN, 
	A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
	CAST(ROW_NUMBER() Over(PARTITION BY A.NoJurnal Order by A.Nojurnal) As int) URUT,  
	isnull(J.Perkiraan,'') PERKIRAAN, 
	isnull(Sg.PerkPers,'') LAWAN, 
	'Surat Jalan '+A.NoBukti+' '+isnull(Cs.NAMACUSTSUPP,'') KETERANGAN, '' KETERANGAN2, 
	Sum(B.Qnt * B.HPP) DEBET, 0 KREDIT, 'IDR' VALAS, 1 KURS, 
	Sum(B.Qnt * B.HPP) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, '' CUSTCUPPP, '' CUSTSUPPL, '' KODEP, 
	'' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '01' KODEBAG, '' STATUSGIRO, 
	'SPB' JENIS, A.NoBukti NOBUKTITRANS
FROM  DBO.DBSPB A 
LEFT OUTER JOIN DBO.dbSPBDet B ON B.NOBUKTI=A.NOBUKTI
LEFT OUTER JOIN DBO.DBCUSTSUPP Cs ON Cs.KODECUSTSUPP=A.KodeCustSupp
Left Outer Join dbo.DBBARANG Br on Br.KODEBRG=B.KODEBRG
Left Outer join dbo.dbSubGroup Sg on Sg.KodeGrp=Br.KODEGRP and Sg.KodeSubGrp=Br.KODESUBGRP 
Left Outer Join dbo.DBPOSTHUTPIUT J on J.Kode='HPP'
--Where A.NoJurnal<>''
Group by A.NoJurnal, A.TglJurnal,A.KodeCustSupp, Cs.NAMACUSTSUPP, 
      A.NOBUKTI, A.NoUrut, A.TANGGAL,
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
       Sg.PerkPers, J.Perkiraan, A.NoUrutJurnal


-- Retur Surat Jalan
UNION ALL
SELECT A.NoJurnal NOBUKTI, A.NoUrut, A.Tanggal,'01' DEVISI, 
	'Retur Surat Jalan : ' + A.NOBUKTI +' TANGGAL : '+ Convert(Varchar(15),A.Tanggal, 105) NOTE,0 LAMPIRAN, 
	A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
	CAST(ROW_NUMBER() Over(PARTITION BY A.NoJurnal Order by A.Nojurnal) As int) URUT,  
	isnull(Sg.PerkPers,'') PERKIRAAN, 
	isnull(J.Perkiraan,'') LAWAN, 
	'Retur Surat Jalan : ' + isnull(Cs.NAMACUSTSUPP,'') + ' (' + Isnull(A.KodeCustSupp,'') + ')'+CHAR(13)+ 
	'No. Retur Surat Jalan : '+A.Nobukti+' TANGGAL : '+ Convert(Varchar(15),A.Tanggal, 105) KETERANGAN, '' KETERANGAN2, 
	Sum(B.Qnt * B.HPP) DEBET, 0 KREDIT, 'IDR' VALAS, 1 KURS, 
	Sum(B.Qnt * B.HPP) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, '' CUSTCUPPP, '' CUSTSUPPL, '' KODEP, 
	'' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '01' KODEBAG, '' STATUSGIRO,
	'RSPB' JENIS, A.NoBukti NOBUKTITRANS
FROM  DBO.DBRSPB A 
LEFT OUTER JOIN DBO.DBRSPBDet B ON B.NOBUKTI = A.NOBUKTI 
LEFT OUTER JOIN DBO.DBCUSTSUPP Cs ON Cs.KODECUSTSUPP=A.KodeCustSupp
Left Outer Join dbo.DBBARANG Br on Br.KODEBRG=B.KODEBRG
Left Outer join dbo.dbSubGroup Sg on Sg.KodeGrp=Br.KODEGRP and Sg.KodeSubGrp=Br.KODESUBGRP 
Left Outer Join dbo.DBPOSTHUTPIUT J on J.Kode='HPP'
--Where A.NoJurnal<>''
Group by A.NoJurnal, A.TglJurnal,A.KodeCustSupp, Cs.NAMACUSTSUPP, 
	A.NOBUKTI, A.NoUrut, A.TANGGAL,
	A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
	Sg.PerkPers, J.Perkiraan, A.NoUrutJurnal


-- Invoice Penjualan      
Union ALL
SELECT A.NoJurnal NOBUKTI, A.NOURUT, A.Tanggal TANGGAL,'01' DEVISI, 
	'Penjualan '+isnull(Cs.NAMACUSTSUPP,'') NOTE, 0 LAMPIRAN, 
	A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
	MIN(B.Urut) URUT,  
	j.Perkiraan PERKIRAAN, BS.PerkPers 
	LAWAN, 
	A.NoBukti+' '+isnull(Cs.NAMACUSTSUPP,'') KETERANGAN,'' KETERANGAN2, 
	Sum(B.NDPP) DEBET, 0 KREDIT, A.VALAS, A.Kurs, 
	Sum(B.NDPPRp) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, 
	A.KodeCustSupp CUSTSUPPP, '' CUSTSUPPL, '' KODEP, 
	'' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '01' KODEBAG, '' STATUSGIRO, 
	'INVC' JENIS, A.NoBukti NOBUKTITRANS
FROM  DBO.DBInvoicePL A 
LEFT OUTER JOIN DBO.dbInvoicePLDet B ON B.NOBUKTI=A.NOBUKTI 
LEFT OUTER JOIN DBO.DBBARANG Br ON Br.KODEBRG=B.KODEBRG 
LEFT OUTER JOIN dbo.DBSUBGROUP bS on Bs.KodeSubGrp=BR.KODESUBGRP
Left outer join dbo.DBCUSTSUPP Cs on Cs.KODECUSTSUPP=A.KodeCustSupp
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='PT'AND X.Urut=2) J on 1=1 
--Where A.noJurnal<>''
Group by A.NoJurnal, A.NOURUT, A.Valas, A.Kurs, 
	A.NOBUKTI, Cs.NAMACUSTSUPP, A.KODECUSTSUPP, A.TANGGAL,A.KodeCustSupp,J.Perkiraan,BS.PerkPers ,
	A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL 

Union All
SELECT A.NoJurnal NOBUKTI, A.NOURUT, A.Tanggal TANGGAL,'01' DEVISI, 
	'Faktur Pajak '+' '+isnull(Cs.NAMACUSTSUPP,'') NOTE,0 LAMPIRAN, 
	A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
	MIN(B.Urut)+1000 URUT,  
	K.Perkiraan PERKIRAAN, J.Perkiraan  LAWAN, 
	A.NoBukti+' '+isnull(Cs.NAMACUSTSUPP,'') KETERANGAN,'' KETERANGAN2, 
	Sum(B.NPPN) DEBET, 0 KREDIT, A.VALAS, A.Kurs, 
	Sum(B.NPPNRp) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, 
	A.KodeCustSupp CUSTSUPPP, '' CUSTSUPPL, '' KODEP, 
	'' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '01' KODEBAG, '' STATUSGIRO, 
	'INVC' JENIS, A.NoBukti NOBUKTITRANS
FROM  DBO.DBInvoicePL A 
LEFT OUTER JOIN DBO.dbInvoicePLDet B ON B.NOBUKTI = A.NOBUKTI
Left outer join dbo.DBCUSTSUPP Cs on Cs.KODECUSTSUPP=A.KodeCustSupp
Left Outer join dbo.DBPOSTHUTPIUT J on J.Kode='PPM'
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='PT' AND X.Urut=2) K on 1=1 
--Where A.noJurnal<>''
Group by A.NoJurnal, A.NOURUT, A.Valas, A.Kurs,
	A.NOBUKTI, Cs.NAMACUSTSUPP, A.KODECUSTSUPP, A.TANGGAL,K.Perkiraan,
	A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
	J.Perkiraan
Having SUM(B.NPPNRp)<>0


-- Penerimaan Retur Jual
Union All
SELECT A.NoJurnal NOBUKTI, A.NoUrut, A.Tanggal,'01' DEVISI, 
      'Penerimaan Retur Penjualan : ' + A.NOBUKTI +' TANGGAL : '+ Convert(Varchar(15),A.Tanggal, 105) NOTE,0 LAMPIRAN, 
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
       CAST(ROW_NUMBER() Over(PARTITION BY A.NoJurnal Order by A.Nojurnal) As int) URUT,  
       isnull(Sg.PerkPers,'') PERKIRAAN, 
       isnull(J.Perkiraan,'') LAWAN, 
       isnull(Cs.NAMACUSTSUPP,'') + ' (' + Isnull(A.KodeCustSupp,'') + ')' KETERANGAN, '' KETERANGAN2, 
       Sum(B.Qnt * B.HPP) DEBET, 0 KREDIT, 'IDR' VALAS, 1 KURS, 
       Sum(B.Qnt * B.HPP) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, '' CUSTCUPPP, '' CUSTSUPPL, '' KODEP, 
       '' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '01' KODEBAG, '' STATUSGIRO, 
       'SPR' JENIS, A.NoBukti NOBUKTITRANS
FROM  DBO.dbSPBRJual A 
LEFT OUTER JOIN DBO.dbSPBRJualDet B ON B.NOBUKTI = A.NOBUKTI 
LEFT OUTER JOIN DBO.DBCUSTSUPP Cs ON Cs.KODECUSTSUPP=A.KodeCustSupp
Left Outer Join dbo.DBBARANG Br on Br.KODEBRG=B.KODEBRG
Left Outer join dbo.dbSubGroup Sg on Sg.KodeGrp=Br.KODEGRP and Sg.KodeSubGrp=Br.KODESUBGRP 
Left Outer Join dbo.DBPOSTHUTPIUT J on J.Kode='HPP'
--Where A.noJurnal<>''
Group by A.NoJurnal, A.TglJurnal,A.KodeCustSupp, Cs.NAMACUSTSUPP, 
      A.NOBUKTI, A.NoUrut, A.TANGGAL,
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
       Sg.PerkPers, J.Perkiraan, A.NoUrutJurnal


-- Invoice Retur Jual
union all
SELECT A.NoJurnal NOBUKTI, A.NoUrut, A.TANGGAL,'01' DEVISI, 
      'Retur Invoice Penjualan : ' + isnull(I.NAMACUSTSUPP,'') + ' (' + Isnull(I.KODECUSTSUPP,'') + ')' NOTE,0 LAMPIRAN, 
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL,
       min(B.Urut) URUT,  
       BS.PerkH PERKIRAAN, 
       j.PERKIRAAN  LAWAN, 
       A.NoBukti+' '+isnull(I.NAMACUSTSUPP,'') KETERANGAN,'' KETERANGAN2,
       Sum(B.NDPP) DEBET, 0 KREDIT, A.Kodevls VALAS, A.Kurs, 
       Sum(B.NDPPRp) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, '' CUSTSUPPP, A.KODECUSTSUPP CUSTSUPPL, '' KODEP, 
       '' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '01' KODEBAG, '' STATUSGIRO, 
       'RPJ' JENIS, A.NoBukti NOBUKTITRANS
FROM  DBO.DBINVOICERPJ A 
LEFT OUTER JOIN DBO.DBINVOICERPJDet B ON B.NOBUKTI = A.NOBUKTI 
LEFT OUTER JOIN DBO.DBBARANG F ON F.KODEBRG = B.KODEBRG 
Left outer join dbo.vwCUSTSUPP I on I.KODECUSTSUPP=A.KodeCustSupp
LEFT OUTER JOIN dbo.DBSUBGROUP bS on Bs.KodeSubGrp=f.KODESUBGRP AND BS.KodeGrp=F.KODEGRP
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='PT'AND X.Urut=2) J on 1=1 
--Where A.NoJurnal<>''
Group by A.NoJurnal, A.TglJurnal, A.Tanggal, A.KODEVLS, A.Kurs, 
      A.NOBUKTI, A.NoUrut, i.NAMACUSTSUPP, I.KODECUSTSUPP,A.TANGGAL,A.KODECUSTSUPP,BS.PerkH,
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1,    
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL,
       J.Perkiraan,A.NoUrutJurnal
Union All
SELECT A.NoJurnal NOBUKTI, A.NoUrut, A.TANGGAL,'01' DEVISI, 
      'Retur Invoice Penjualan : ' + isnull(I.NAMACUSTSUPP,'') + ' (' + Isnull(I.KODECUSTSUPP,'') + ')' NOTE,0 LAMPIRAN, 
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL,
       min(B.Urut)+1000 URUT,  
       K.Perkiraan PERKIRAAN, 
       j.PERKIRAAN  LAWAN, 
       A.NoBukti+' '+isnull(I.NAMACUSTSUPP,'') KETERANGAN,'' KETERANGAN2,
       Sum(B.nPPN) DEBET, 0 KREDIT, A.Kodevls VALAS, A.Kurs, 
       Sum(B.NPPNRp) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, '' CUSTSUPPP, A.KODECUSTSUPP CUSTSUPPL, '' KODEP, 
       '' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '01' KODEBAG, '' STATUSGIRO, 
       'RPJ' JENIS, A.NoBukti NOBUKTITRANS
FROM  DBO.DBINVOICERPJ A 
LEFT OUTER JOIN DBO.DBINVOICERPJDet B ON B.NOBUKTI = A.NOBUKTI 
LEFT OUTER JOIN DBO.DBBARANG F ON F.KODEBRG = B.KODEBRG 
Left outer join dbo.vwCUSTSUPP I on I.KODECUSTSUPP=A.KodeCustSupp
Left Outer join dbo.DBPOSTHUTPIUT K on k.Kode='PPM'
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='PT'AND X.Urut=2) J on 1=1 
--Where A.NoJurnal<>''
Group by A.NoJurnal, A.TglJurnal, A.Tanggal, A.KODEVLS, A.Kurs, 
      A.NOBUKTI, A.NoUrut, i.NAMACUSTSUPP, I.KODECUSTSUPP,A.TANGGAL,A.KODECUSTSUPP,K.Perkiraan,
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1,    
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL,
       J.Perkiraan,A.NoUrutJurnal


-- Kredit Note       
union all
SELECT A.NoJurnal NOBUKTI, A.NoUrut, A.TANGGAL,'01' DEVISI, 
      'Kredit Note : ' + A.NOBUKTI +' TANGGAL : '+ Convert(Varchar(15),A.Tanggal, 105) NOTE,0 LAMPIRAN, 
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
       CAST(ROW_NUMBER() Over(PARTITION BY A.NoJurnal Order by A.Nojurnal) As int) URUT,  
       J.Perkiraan PERKIRAAN, 
       isnull(B.PerkHP,'')  LAWAN, 
       'Kredit Note : ' + isnull(I.NAMACUSTSUPP,'') + ' (' + Isnull(I.KODECUSTSUPP,'') + ')'+CHAR(13)+ 
       'No. Invoice : '+B.NoInv KETERANGAN, '' KETERANGAN2, 
       Sum(B.Nilai) DEBET, 0 KREDIT, B.KodeVLS VALAS, B.Kurs, 
       Sum(B.NilaiRp) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, '' CUSTSUPPP, '' CUSTSUPPL, '' KODEP, 
       '' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '01' KODEBAG, '' STATUSGIRO, 
       'KN' JENIS, A.NOBUKTI NOBUKTITRANS
FROM  DBO.DBKreditNote A 
LEFT OUTER JOIN DBO.DBKreditNoteDET B ON B.NOBUKTI = A.NOBUKTI 
Left outer join dbo.vwCUSTSUPP I on I.KODECUSTSUPP=A.KodeSupp
Left Outer join (Select x.Perkiraan
                 from dbo.DBPOSTHUTPIUT x
                 where x.Kode='BK') J on 1=1
--Where A.noJurnal<>''
Group by A.NoJurnal, A.TglJurnal, A.TANGGAL, B.kodevls, B.Kurs, B.NoInv, B.PerkHP, 
      A.NOBUKTI, A.NoUrut, i.NAMACUSTSUPP, I.KODECUSTSUPP, A.TANGGAL,
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
       J.Perkiraan,A.NoUrutJurnal

-- Penyerahan Bahan       
union All
SELECT A.NoJurnal NOBUKTI, A.NoUrut, A.Tanggal,'01' DEVISI, 
      'Penyerahan Bahan : ' + A.NOBUKTI + ' Untuk SPK : ' + A.NoBPPB NOTE,0 LAMPIRAN, 
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
       CAST(ROW_NUMBER() Over(PARTITION BY A.NoJurnal Order by A.Nojurnal) As int) URUT,  
       ISNULL(J.Perkiraan,'') PERKIRAAN, 
        H.PerkPers Lawan, 
       'Penyerahan Bahan : ' + + H.NamaSubGrp + ' (' + H.KodeSubGrp + ')'+CHAR(13)+ 
       'No. Penyerahan Bahan : '+A.Nobukti+' TANGGAL : '+ Convert(Varchar(15),A.Tanggal, 105)KETERANGAN, '' KETERANGAN2, 
       Sum(B.QNT*B.HPP) DEBET, 0 KREDIT, 'IDR' VALAS, 1 KURS, 
       Sum(B.QNT*B.HPP) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, '' CUSTCUPPP, '' CUSTSUPPL, '' KODEP, 
       '' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '01' KODEBAG, '' STATUSGIRO, 
      'BP' JENIS, A.Nobukti NOBUKTITRANS
FROM  DBO.DBPenyerahanBhn A 
LEFT OUTER JOIN DBO.DBPenyerahanBhnDET B ON B.NOBUKTI = A.NOBUKTI 
LEFT OUTER JOIN DBO.DBBARANG F ON F.KODEBRG = B.KODEBRG LEFT OUTER JOIN DBO.DBGROUP G ON G.KODEGRP = F.KODEGRP
LEFT OUTER JOIN DBO.dbSubGroup H ON H.KodeGrp = F.KODEGRP and H.KodeSubGrp=F.KODESUBGRP
Left Outer Join (Select Perkiraan 
                 from dbo.DBPOSTHUTPIUT 
                 where Kode='WIP') J on 1=1
--Where A.noJurnal<>''
Group by A.NoJurnal, A.TglJurnal, H.KodeSubGrp,A.NoBPPB,
      A.NOBUKTI, A.Nourut, H.NamaSubGrp, H.KodeSubGrp,A.TANGGAL,
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
       A.NoUrutJurnal,H.PerkPers, J.Perkiraan

-- Retur Penyerahan Bahan
union All
SELECT A.NoJurnal NOBUKTI, A.Nourut, A.Tanggal,'01' DEVISI, 
      'Retur Penyerahan Bahan : ' + A.NOBUKTI + ' untuk Penyerahan : ' + A.NoPenyerahanBhn NOTE,0 LAMPIRAN, 
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL,
       CAST(ROW_NUMBER() Over(PARTITION BY A.NoJurnal Order by A.Nojurnal) As int) URUT,  
       H.PerkPers PERKIRAAN, 
       ISNULL(J.Perkiraan,'') Lawan, 
       'Retur Penyerahan Bahan : ' + + H.NamaSubGrp + ' (' + H.KodeSubGrp + ')'+CHAR(13)+ 
       'No. Penyerahan Bahan : '+A.Nobukti+' TANGGAL : '+ Convert(Varchar(15),A.Tanggal, 105)KETERANGAN, '' KETERANGAN2, 
       Sum(B.QNT*B.HPP) DEBET, 0 KREDIT, 'IDR' VALAS, 1 KURS, 
       Sum(B.QNT*B.HPP) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, '' CUSTCUPPP, '' CUSTSUPPL, '' KODEP, 
       '' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '01' KODEBAG, '' STATUSGIRO, 
      'RBP' JENIS, A.Nobukti NOBUKTITRANS
FROM  DBO.DBRPenyerahanBhn A 
LEFT OUTER JOIN DBO.DBRPenyerahanBhnDET B ON B.NOBUKTI = A.NOBUKTI 
LEFT OUTER JOIN DBO.DBBARANG F ON F.KODEBRG = B.KODEBRG LEFT OUTER JOIN DBO.DBGROUP G ON G.KODEGRP = F.KODEGRP
LEFT OUTER JOIN DBO.dbSubGroup H ON H.KodeGrp = F.KODEGRP and H.KodeSubGrp=F.KODESUBGRP
Left Outer Join (Select Perkiraan 
                 from dbo.DBPOSTHUTPIUT 
                 where Kode='WIP') J on 1=1
--Where A.noJurnal<>''
Group by A.NoJurnal, A.TglJurnal, H.KodeSubGrp,A.NoPenyerahanBhn,
      A.NOBUKTI, A.Nourut, H.NamaSubGrp, H.KodeSubGrp,A.TANGGAL,
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
       A.NoUrutJurnal,H.PerkPers, J.Perkiraan


-- Ubah Kemasan
Union ALL
SELECT A.NoJurnal NOBUKTI, A.NOURUT, A.Tanggal,'01' DEVISI, 
      'Ubah Kemasan : ' + A.NOBUKTI + ' ' + H.NamaSubGrp + ' (' + H.KodeSubGrp + ')' NOTE,0 LAMPIRAN, 
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
       CAST(ROW_NUMBER() Over(PARTITION BY A.NoJurnal Order by A.Nojurnal) As int) URUT,  
       --Case when Sum(B.QNTDB)<>0 then J.Perkiraan
       --     when Sum(B.QNTCR)<>0 then H.PerkPers
       --     else ''
       --end  PERKIRAAN, 
       '' PERKIRAAN,
       Case when Sum(B.QNTDB)<>0 then H.PerkPers
            when Sum(B.QNTCR)<>0 then J.Perkiraan
            else ''
       end LAWAN, 
       'Ubah Kemasan : ' + + H.NamaSubGrp + ' (' + H.KodeSubGrp + ')'+CHAR(13)+ 
       'No. Ubah Kemasan : '+A.Nobukti+' TANGGAL : '+ Convert(Varchar(15),A.Tanggal, 105)KETERANGAN, '' KETERANGAN2, 
       Sum(Case when B.QNTDB<>0 then B.QNTDB 
                when B.QNTCR<>0 then B.QNTCR
                else 0
           end * B.HPP) DEBET, 0 KREDIT, 'IDR' VALAS, 1 KURS, 
       Sum(Case when B.QNTDB<>0 then B.QNTDB 
                when B.QNTCR<>0 then B.QNTCR
                else 0
           end * B.HPP) DEBETRP, 0 KREDITRP, 'BMM' TIPETRANS, 'C' TPHC, '' CUSTCUPPP, '' CUSTSUPPL, '' KODEP, 
       '' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '01' KODEBAG, '' STATUSGIRO, 
      'KMS' JENIS, A.NOBUKTI NOBUKTITRANS
FROM  DBO.DBUBAHKEMASAN A 
LEFT OUTER JOIN DBO.DBUBAHKEMASANDET B ON B.NOBUKTI = A.NOBUKTI 
LEFT OUTER JOIN DBO.DBBARANG F ON F.KODEBRG = B.KODEBRG LEFT OUTER JOIN DBO.DBGROUP G ON G.KODEGRP = F.KODEGRP
LEFT OUTER JOIN DBO.dbSubGroup H ON H.KodeGrp = F.KODEGRP and H.KodeSubGrp=F.KODESUBGRP
Left Outer Join (Select Perkiraan 
                 from dbo.DBPOSTHUTPIUT 
                 where Kode='BYO') J on 1=1
--Where A.noJurnal<>''
Group by A.NoJurnal, A.TglJurnal, H.KodeSubGrp,
      A.NOBUKTI, A.NOURUT, H.NamaSubGrp, H.KodeSubGrp,A.TANGGAL,
       A.IsOtorisasi1, A.OTOUSER1, A.TGLOTO1, 
       A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
       A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
       A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
       A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
       A.NoUrutJurnal,H.PerkPers, J.Perkiraan

--- Hasil Produksi
union all
SELECT A.NoJurnal NOBUKTI, A.NOURUT, A.TANGGAL TANGGAL,'01' DEVISI, 
	'Hasil Produksi SPK : '+A.NoSPK  NOTE,0 LAMPIRAN, 
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
	min(B.Urut) URUT, 
	'' PERKIRAAN, '' LAWAN,
	A.NOBUKTI KETERANGAN, 
	'' KETERANGAN2, 
	0 DEBET, 0 KREDIT, '' Valas, 1 KURS, 
	0 DEBETRP, 0 KREDITRP, '' TIPETRANS, 'C' TPHC, 
	'' CUSTSUPPP,'' CUSTSUPPL, '' KODEP, 
	'' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '' KODEBAG, '' STATUSGIRO, 
	'PRD' JENIS, A.NOBUKTI NOBUKTITRANS
FROM DBO.DBHASILPRD A 
LEFT OUTER JOIN DBO.DBhasilprdDET B ON B.NOBUKTI=A.NOBUKTI 
--LEFT OUTER JOIN DBO.DBCUSTSUPP Cs ON Cs .KODECUSTSUPP=A.KODESUPP
--Left Outer Join dbo.DBBARANG Br on Br.KODEBRG=B.KODEBRG
--Left Outer join dbo.dbSubGroup F on f.KodeGrp=Br.KODEGRP and F.KodeSubGrp=Br.KODESUBGRP
--Left Outer join (Select x.Perkiraan
--                 from dbo.DBPOSTHUTPIUT x
--                 where x.Kode='HT'AND X.Urut=2) J on 1=1
--where A.NoJurnal<>''
GROUP BY A.NOBUKTI, A.NOURUT, A.TANGGAL, ---J.Perkiraan,
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL,
	A.NOURUT, A.NoJurnal, A.NoSPK

--- Transfer Gudang
union all
SELECT A.NoJurnal NOBUKTI, A.NOURUT, A.TANGGAL TANGGAL,'01' DEVISI, 
	'Transfer Gudang '  NOTE,0 LAMPIRAN, 
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
	min(B.Urut) URUT, 
	'' PERKIRAAN, '' LAWAN,
	A.NOBUKTI KETERANGAN, 
	'' KETERANGAN2, 
	0 DEBET, 0 KREDIT, '' Valas, 1 KURS, 
	0 DEBETRP, 0 KREDITRP, '' TIPETRANS, 'C' TPHC, 
	'' CUSTSUPPP,'' CUSTSUPPL, '' KODEP, 
	'' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '' KODEBAG, '' STATUSGIRO, 
	'TRF' JENIS, A.NOBUKTI NOBUKTITRANS
FROM DBO.DBTRANSFER A 
LEFT OUTER JOIN DBO.DBTRANSFERDET B ON B.NOBUKTI=A.NOBUKTI 
--LEFT OUTER JOIN DBO.DBCUSTSUPP Cs ON Cs .KODECUSTSUPP=A.KODESUPP
--Left Outer Join dbo.DBBARANG Br on Br.KODEBRG=B.KODEBRG
--Left Outer join dbo.dbSubGroup F on f.KodeGrp=Br.KODEGRP and F.KodeSubGrp=Br.KODESUBGRP
--Left Outer join (Select x.Perkiraan
--                 from dbo.DBPOSTHUTPIUT x
--                 where x.Kode='HT'AND X.Urut=2) J on 1=1
--where A.NoJurnal<>''
GROUP BY A.NOBUKTI, A.NOURUT, A.TANGGAL, ---J.Perkiraan,
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL,
	A.NOURUT, A.NoJurnal


--- Opname
union all
SELECT A.NoJurnal NOBUKTI, A.NOURUT, A.TANGGAL TANGGAL,'01' DEVISI, 
	'Opname Bahan '  NOTE,0 LAMPIRAN, 
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL, 
	min(B.Urut) URUT, 
	'' PERKIRAAN, '' LAWAN,
	A.NOBUKTI KETERANGAN, 
	'' KETERANGAN2, 
	0 DEBET, 0 KREDIT, '' Valas, 1 KURS, 
	0 DEBETRP, 0 KREDITRP, '' TIPETRANS, 'C' TPHC, 
	'' CUSTSUPPP,'' CUSTSUPPL, '' KODEP, 
	'' KODEL, '' NOAKTIVAP, '' NOAKTIVAL, '' STATUSAKTIVAP, '' STATUSAKTIVAL, '' NOBON, '' KODEBAG, '' STATUSGIRO, 
	'OPNBHN' JENIS, A.NOBUKTI NOBUKTITRANS
FROM DBO.DBKOREKSI A 
LEFT OUTER JOIN DBO.DBKOREKSIDET B ON B.NOBUKTI=A.NOBUKTI 
--LEFT OUTER JOIN DBO.DBCUSTSUPP Cs ON Cs .KODECUSTSUPP=A.KODESUPP
--Left Outer Join dbo.DBBARANG Br on Br.KODEBRG=B.KODEBRG
--Left Outer join dbo.dbSubGroup F on f.KodeGrp=Br.KODEGRP and F.KodeSubGrp=Br.KODESUBGRP
--Left Outer join (Select x.Perkiraan
--                 from dbo.DBPOSTHUTPIUT x
--                 where x.Kode='HT'AND X.Urut=2) J on 1=1
--where A.NoJurnal<>''
GROUP BY A.NOBUKTI, A.NOURUT, A.TANGGAL, ---J.Perkiraan,
	A.ISOTORISASI1, A.OTOUSER1, A.TGLOTO1, 
	A.ISOTORISASI2, A.OTOUSER2, A.TGLOTO2, 
	A.ISOTORISASI3, A.OTOUSER3, A.TGLOTO3, 
	A.ISOTORISASI4, A.OTOUSER4, A.TGLOTO4, 
	A.ISOTORISASI5, A.OTOUSER5, A.TGLOTO5, A.MaxOL,
	A.NOURUT, A.NoJurnal






GO

-- View: vwQntBeliDariPO
-- Created: 2012-11-20 12:08:22.637 | Modified: 2012-11-20 12:08:22.637
-- =====================================================





CREATE View vwQntBeliDariPO
as

select NOPO, UrutPO, KodeBrg, sum(Qnt*Isi) QntSat1 from dbBeliDet
where NOPO<>'-' group by NOPO, UrutPO, KodeBrg















GO

-- View: vwQntRBeliDariBeli
-- Created: 2012-11-29 14:29:32.227 | Modified: 2012-12-19 14:05:28.943
-- =====================================================






CREATE View [dbo].[vwQntRBeliDariBeli]
as

select B.NoBeli, A.UrutPBL, A.KodeBrg, sum(A.Qnt) QntSat1, sum(A.Qnt2) QntSat2 from dbRBeliDet A, dbRBeli B
where A.NoBukti=B.NoBukti and B.NoBeli<>'-' group by B.NoBeli, A.UrutPBL, A.KodeBrg
















GO

-- View: vwRegStock
-- Created: 2011-02-11 15:18:57.600 | Modified: 2011-02-11 15:18:57.600
-- =====================================================
CREATE View dbo.vwRegStock
as

Select 	Tipe, Prioritas, KodeBrg, QntDb, Qnt2Db, HrgDebet, QntCr, Qnt2Cr, HrgKredit, 
	QntSaldo, Qnt2Saldo, HrgSaldo, Tanggal, Bulan, Tahun, NoBukti, 
	KodeCustSupp, Keterangan, IDUser, HPP
From 	dbo.vwKartuStock


GO

-- View: VwReportBeliGudang
-- Created: 2013-06-03 12:53:21.013 | Modified: 2015-03-09 15:28:01.013
-- =====================================================





CREATE  View [dbo].[VwReportBeliGudang]
as
Select 	A.NoBukti,A.TANGGAL, B.NoPO, B.UrutPO,A.KODESUPP KodeCustSupp,I.NAMACUSTSUPP,
	    B.Urut, B.KodeBrg, H.NamaBrg,b.QNT as qntbeli,b.SATUAN as satbeli,
	    isnull(B.Qnt1Terima,0) as qnt, h.SAT1 as satuan,
        isnull(b.Qnt2Terima,0) as Qnt2,h.SAT2 As satuan2,
        B.Qnt1Reject as qntreject,
        B.Qnt2Reject as qnt2reject,
        B.Harga, B.HrgNetto,B.DiscP,B.DiscTot,
        case when a.kodevls<>'IDR' then B.NDPP else 0 end as NDPP
        ,B.NDPPRp,b.NPPNRp,b.NNETRp,
        B.KodeGdg,A.KODEVLS,A.KURS,A.FAKTURSUPP,
        Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi,J.NAMA NamaGdg
From dbBeliDet B 
Left Outer Join dbBeli A On A.NoBukti=b.NoBukti
Left Outer Join dbBarang H on H.KodeBrg=B.KodeBrg
Left Outer Join DBCUSTSUPP I on A.KODESUPP = I.KODECUSTSUPP
left outer join DBGUDANG J on B.KodeGdg=J.KODEGDG






GO

-- View: VwreportBeliReject
-- Created: 2013-05-13 12:08:51.920 | Modified: 2013-05-13 12:08:51.920
-- =====================================================
CREATE View [dbo].[VwreportBeliReject]
as
Select 	A.NoBukti,A.TANGGAL, B.NoPO, B.UrutPO,A.KODESUPP,I.KODECUSTSUPP,I.NAMACUSTSUPP,
	B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt, B.NoSat, B.Isi, B.Satuan,
        0.00 Qnt2, '' SatuanRoll, B.Harga, B.HrgNetto,
        B.DiscP DiscP1, B.DiscTot DiscRp1,B.DiscTot,
        B.SubTotal TotalUSD, B.SubTotal TotalIDR, B.NDPP NDPP,
        B.NPPN NPPN, B.BYAngkut Beban, B.SubTotal + B.BYAngkut Total, B.KodeGdg
From dbBeliDet B 
Left Outer Join dbBeli A On A.NoBukti=b.NoBukti
Left Outer Join dbBarang H on H.KodeBrg=B.KodeBrg
Left Outer join DBCUSTSUPP I on A.KODESUPP = I.KODECUSTSUPP


GO

-- View: VwreportBP
-- Created: 2013-06-10 11:04:36.080 | Modified: 2013-06-10 11:04:36.080
-- =====================================================



CREATE View [dbo].[VwreportBP]
as
Select 	A.NoBukti,A.NoBPPB,
	B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt, B.NoSat, B.Isi Isi, B.Sat Satuan, B.Qnt*B.HPP NilaiHPP, A.Tanggal,
	Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi 
From dbPenyerahanBhn A
Left Outer join  dbPenyerahanBhnDet B on B.NoBukti=a.NoBukti
Left Outer join dbBarang H on H.KodeBrg=b.KodeBrg





GO

-- View: VwReportBPPBKeluar
-- Created: 2013-01-21 13:28:27.293 | Modified: 2013-01-21 13:28:27.293
-- =====================================================

Create View [dbo].[VwReportBPPBKeluar]
as

Select 	A.KodeGdgT,A.NoBukti, A.Tanggal, A.KdDep, C.NmDep,Qnt QMinta,Qnt2 QKirim,B.KodeBrg,D.NamaBrg,Nosat,Satuan
From dbBPPB A
Left Outer Join dbBPPBdet B On A.NoBukti=B.NoBukti
Left Outer Join dbBarang D On B.Kodebrg=D.Kodebrg
Left Outer Join dbDEPART C on c.KdDEP=a.KdDEP
GO

-- View: vwReportDaftarHarga
-- Created: 2011-11-04 09:16:21.633 | Modified: 2011-11-04 09:16:21.633
-- =====================================================

CREATE View [dbo].[vwReportDaftarHarga]
as
Select X.KODEBRG,X.NAMABRG, MAX(X.Bln1) Bln1, MAX(X.Bln2) Bln2, MAX(X.Bln3) Bln3, MAX(X.Bln4) Bln4, MAX(X.Bln5) Bln5, MAX(X.Bln6) Bln6,
       MAX(X.Bln7) Bln7, MAX(X.Bln8) Bln8, MAX(X.Bln9) Bln9, MAX(X.Bln10) Bln10, MAX(X.Bln11) Bln11, MAX(X.Bln12) Bln12,
       X.Tahun, X.SAT_1
From (
	select b.KODEBRG, C.NAMABRG,YEAR(a.tanggal) Tahun,B.SAT_1,
			 Case when month(a.tanggal)= 1 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln1,
			 Case when month(a.tanggal)= 2 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln2,
			 Case when month(a.tanggal)= 3 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln3,
			 Case when month(a.tanggal)= 4 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln4,
			 Case when month(a.tanggal)= 5 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln5,
			 Case when month(a.tanggal)= 6 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln6,
			 Case when month(a.tanggal)= 7 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln7,
			 Case when month(a.tanggal)= 8 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln8,
			 Case when month(a.tanggal)= 9 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln9,
			 Case when month(a.tanggal)= 10 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln10,
			 Case when month(a.tanggal)= 11 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln11,
			 Case when month(a.tanggal)= 12 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln12       
	From DBPO a
		  left outer join DBPODET b on b.NOBUKTI=a.NOBUKTI
		  left outer join DBBARANG C on C.KODEBRG=b.KODEBRG    
	group by b.KODEBRG,C.NAMABRG,month(a.tanggal),YEAR(a.tanggal), B.SAT_1)X
	
	group by  X.KODEBRG,X.NAMABRG,x.Tahun,X.SAT_1
	

GO

-- View: VwreportDebetNotte
-- Created: 2013-06-03 13:57:48.763 | Modified: 2013-06-03 13:57:48.763
-- =====================================================


CREATE View [dbo].[VwreportDebetNotte]
as
Select  a.NoBukti,x.tanggal,z.kodecustsupp,z.NAMACUSTSUPP, a.NoInv,a.KodeVLS,a.Kurs,
    Isnull(a.nilai,0) NDPP,Isnull(a.nilairp,0) NDPPRP,a.Keterangan,
      Cast(Case when Case when X.IsOtorisasi1=1 then 1 else 0 end+
                      Case when X.IsOtorisasi2=1 then 1 else 0 end+
                      Case when X.IsOtorisasi3=1 then 1 else 0 end+
                      Case when X.IsOtorisasi4=1 then 1 else 0 end+
                      Case when X.IsOtorisasi5=1 then 1 else 0 end=X.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi
	From  dbDebetNoteDet a
	left Outer join DBDebetNote x on a.NOBUKTI = x.NOBUKTI
	Left Outer Join DBCUSTSUPP z on x.KodeSupp = z.KODECUSTSUPP





GO

-- View: VwreportHasilPrd
-- Created: 2013-06-10 11:35:47.127 | Modified: 2013-06-24 16:39:04.360
-- =====================================================




CREATE View [dbo].[VwreportHasilPrd]
as 
Select A.nobukti,A.tanggal,A.keterangan,B.urut,B.Kodebrg,B.Qnt,B.Satuan,B.isi,B.Nospk,B.HPP*b.QNT*B.ISI as HPP,C.NamaBrg,
       Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi 
From  dbHasilPrd A
Left Outer join DbHasilPRDDet B on a.nobukti = B.nobukti
Left Outer Join dbBarang C on C.KodeBrg=B.KodeBrg





GO

-- View: VwreportHasilPrdACC
-- Created: 2013-06-24 10:36:50.257 | Modified: 2013-06-24 16:38:39.693
-- =====================================================






CREATE View [dbo].[VwreportHasilPrdACC]
as 
Select A.nobukti,A.tanggal,A.keterangan,B.urut,B.Kodebrg,B.Qnt,B.Satuan,B.isi,B.Nospk,
       B.HPP*B.QNT*B.ISI as HPP,C.NamaBrg,
       Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi 
From  dbHasilPrd A
Left Outer join DbHasilPRDDet B on a.nobukti = B.nobukti
Left Outer Join dbBarang C on C.KodeBrg=B.KodeBrg








GO

-- View: VwreportInvoice
-- Created: 2013-06-03 13:50:49.020 | Modified: 2015-03-09 15:28:00.940
-- =====================================================


CREATE View  [dbo].[VwreportInvoice]
as


Select  a.NoBukti,c.kurs,c.kodevls,b.NoBukti NoBeli ,b.kodebrg,b.qnt,b.SATUAN,
		e.namabrg,b.harga,B.DISCTOT,case when c.kodevls<>'IDR' then NDPPVLS else 0 end as NDPPVLS,
		B.NDPP,B.NPPN,B.NNET,C.KodeSupp KodeCustSupp,D.NAMACUSTSUPP,C.TANGGAL,
		Cast(Case when Case when C.IsOtorisasi1=1 then 1 else 0 end+
                      Case when C.IsOtorisasi2=1 then 1 else 0 end+
                      Case when C.IsOtorisasi3=1 then 1 else 0 end+
                      Case when C.IsOtorisasi4=1 then 1 else 0 end+
                      Case when C.IsOtorisasi5=1 then 1 else 0 end=C.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi
From  dbInvoiceDet a
Left Outer Join (select a.NoBukti,b.kodebrg,sum(b.qnt) qnt,b.satuan,b.harga,b.disctot, sum(ndpp) ndppvls,Sum(NDPPrp)NDPP,Sum(NPPNrp)NPPN,Sum(NNETrp)NNET 
from dbBeli a Left Outer Join dbBeliDet b On a.NoBukti=b.noBukti Group by a.NoBukti,b.KODEBRG,b.SATUAN,b.HARGA,b.DISCTOT)b On a.NoBeli=b.NoBukti
Left Outer join DBInvoice C on A.NOBUKTI = C.NOBUKTI 
Left Outer Join dbCustSupp D On C.KodeSupp=D.KodeCustSupp
left Outer Join DBBARANG E on E.KODEBRG=b.KODEBRG






GO

-- View: VwReportInvoicePembelian
-- Created: 2013-01-07 10:14:35.767 | Modified: 2013-01-07 10:14:35.767
-- =====================================================

Create View [dbo].[VwReportInvoicePembelian]
as

Select  a.NoBukti,b.NoBukti NoBeli ,NDPP,NPPN,NNET
From  dbInvoiceDet a
Left Outer Join (select a.NoBukti,Sum(NDPP)NDPP,Sum(NPPN)NPPN,Sum(NNET)NNET from dbBeli a Left Outer Join dbBeliDet b On a.NoBukti=b.noBukti Group by a.NoBukti)b On a.NoBeli=b.NoBukti
GO

-- View: VwreportInvoicePenjualan
-- Created: 2013-06-03 14:13:11.053 | Modified: 2013-06-03 14:13:11.053
-- =====================================================





CREATE View [dbo].[VwreportInvoicePenjualan]
as
select 	B.NoBukti, B.Urut, B.NoSPB, B.UrutSPB, B.KodeBrg, C.NAMABRG,x.Tanggal tglSPB,B.NoSPP,
        a.KURS,a.Valas,z.kodesls,p.nama,
        case when b.NOSAT=1 then B.QNT else B.QNT2 end as qnt,
        case when b.NOSAT=1 then B.SAT_1 else B.SAT_2 end as satuan,
        B.HARGA, B.DiscP, B.DISCTOT, B.NDPP,B.NDPPRp,B.NPPNRp, B.NNETRp, B.KetDetail,
        A.Tanggal,A.KodeCustSupp,D.NAMACUSTSUPP,   
		Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
		Case when A.IsOtorisasi2=1 then 1 else 0 end+
		Case when A.IsOtorisasi3=1 then 1 else 0 end+
		Case when A.IsOtorisasi4=1 then 1 else 0 end+
		Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
		else 1
		end As Bit) Needotorisasi
from	dbInvoicePLDet B
left outer join dbBarang C on C.KodeBrg=B.KodeBrg
left outer join DBInvoicePL A on B.NoBukti = A.NoBukti
Left outer join DBCUSTSUPP D on A.KodeCustSupp = D.KODECUSTSUPP
left outer join dbSPB X on B.NoSPB = X.NoBukti
left outer join dbSPP y on y.NoBukti=x.NoSPP
left outer join DBSO z on z.NOBUKTI=y.NoSHIP
left outer join dbKaryawan p on p.KeyNIK=z.KODESLS




GO

-- View: VwReportInVoiceRPembelian
-- Created: 2013-01-07 10:14:56.083 | Modified: 2013-01-07 10:14:56.083
-- =====================================================

Create view [dbo].[VwReportInVoiceRPembelian]
as
Select 	B.NoBukti, B.UrutPBL,
	B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt, B.NoSat, B.Isi, B.Satuan,
        0.00 Qnt2, '' SatuanRoll, B.Harga,
        B.DiscP DiscP1, B.DiscTot DiscRp1, B.DiscTot,
        B.SubTotal TotalUSD, B.SubTotal TotalIDR, B.NDPP NDPP,
        B.NPPN NPPN, B.BYAngkut Beban, B.SubTotal + B.BYAngkut Total
From dbRBeliDet B
Left Outer Join dbBarang H on H.KodeBrg=B.KodeBrg 
GO

-- View: VwReportJual
-- Created: 2012-11-01 12:56:54.733 | Modified: 2012-11-01 12:56:54.733
-- =====================================================

CREATE view [dbo].[VwReportJual]
as
Select 	A.NoBukti+right('00000000'+cast(A.Urut as varchar(8)),8) KeyNoBukti,
        A.*, C.NamaCustSupp, T.Nama NamaTipe, ST.Nama NamaSubTipe,
        cast(left(A.NoBukti,2) as varchar(50)) Left2NoBukti
From dbPenjualan A
Left Outer Join DBCUSTSUPP C on C.KODECUSTSUPP=A.KodeCustSupp
Left Outer Join DBTIPETRANS T on T.KODETIPE=A.KodeTipe
Left Outer Join DBSUBTIPETRANS ST on ST.KODETIPE=A.KodeTipe and ST.KODESUBTIPE=A.KodeSubTipe


GO

-- View: VwreportOpnameBahan
-- Created: 2013-06-03 14:32:58.230 | Modified: 2013-06-03 14:32:58.230
-- =====================================================



CREATE View [dbo].[VwreportOpnameBahan]
as
Select * from vwdetailKoreksi Where noBukti Like '%OPN%'




GO

-- View: VwreportOPnamebarang
-- Created: 2013-06-03 14:33:33.750 | Modified: 2013-06-03 14:33:33.750
-- =====================================================



CREATE View [dbo].[VwreportOPnamebarang]
as
Select * from vwdetailKoreksi Where noBukti Like '%OPBJ%'--'OPN%'



GO

-- View: vwreportoutSO
-- Created: 2013-05-13 12:08:51.610 | Modified: 2013-05-13 12:08:51.610
-- =====================================================



Create View [dbo].[vwreportoutSO]
as
Select  A.NoBukti+right('00000'+cast(A.Urut as varchar(5)),5) KeyNoBukti, A.Nobukti, 
P.Tanggal, P.Kodecust KodeCustSupp, S.NamaCust NamaCustSupp,
A.urut, A.kodebrg, B.NamaBrg, A.Satuan, A.Isi,
A.Qnt, A.Qnt2, A.QntSPP, A.Qnt2SPP,
A.QntSisa, A.Qnt2Sisa,P.MasaBerlaku,P.NoPesanan,P.TglKirim,P.TGLJATUHTEMPO
From    vwBrowsOutSO_SPP A
Left Outer Join DBSO P on P.NoBukti=A.NoBukti
Left Outer Join vwBrowsCustomer S on S.KodeCust=P.KodeCust and S.Sales=P.KODESLS
Left Outer Join dbBarang B on B.KodeBrg=A.KodeBrg
where A.islengkap=0


GO

-- View: VwreportOutSPB
-- Created: 2013-05-13 12:08:51.567 | Modified: 2015-03-11 09:53:07.077
-- =====================================================





CREATE View [dbo].[VwreportOutSPB] 
as
Select A.*,B.NAMABRG NamaBarang,C.Tanggal,C.kodeCustSupp,D.NAMACUSTSUPP,
           A.Nobukti+Cast(A.Urut as varchar(5)) MyKey,Z.NOBUKTI Noso,Z.TANGGAL TanggalSO
from dbSPBDet A
     left outer join DBBARANG B on B.KODEBRG=A.Kodebrg
     Left Outer join dbSPB C on A.NoBukti = C.NoBukti
     Left Outer join DBCUSTSUPP D on c.KodeCustSupp = D.KODECUSTSUPP
     Left Outer join (Select x.NoBukti, x.NoSPP
                      from dbSPBDet x
                      group by x.NoBukti, x.NoSPP) y on y.NoBukti=C.NoBukti
     Left Outer Join (Select x.NoBukti, x.Tanggal,y.NoSO, x.TglKirim
                      from DBSPP x 
                        left outer join dbSPPDet y on y.NoBukti=x.NoBukti
                      Group by x.NoBukti, x.Tanggal,y.NoSO, x.TglKirim) v On v.NoBukti=y.NoSPP 
    left outer join DBSO Z on Z.NOBUKTI=v.NoSO
     






GO

-- View: VwreportOUtSPK
-- Created: 2013-06-03 16:32:27.753 | Modified: 2013-06-03 16:32:27.753
-- =====================================================

Create View [dbo].[VwreportOUtSPK]
as

select a.NOBUKTI ,E.TANGGAL, a.Kodebrg, d.NAMABRG, a.Qnt QntBPPB,
sum(case when a.NOSAT=1 then isnull(b.Qnt,0) else b.Qnt2 end) QntBP,
a.QNT-sum(case when a.NOSAT=1 then isnull(b.Qnt,0) else b.Qnt2 end) Sisa
from DBSPKDET a
left outer join DBPenyerahanBhnDET b on b.NoSPK=a.NOBUKTI and b.UrutSPK=a.URUT 
--left Outer Join (select Kodebrg,SUM(Qnt*isi)Qnt from DBPenyerahanBhnDET group by kodebrg)b On b.kodebrg=a.KodeBrg 
--left Outer Join (select Kodebrg,SUM(SALDOQNT)Qnt from DBSTOCKBRG group by kodebrg )c On c.kodebrg=a.KodeBrg
Left Outer Join DBBARANG d On a.KODEBRG=d.kodebrg 
Left outer Join DBSPK E on A.NOBUKTI = E.NOBUKTI
group by a.NOBUKTI, a.Urut, a.KodeBrg, a.Qnt, a.Isi, d.NAMABRG, E.TANGGAL
having a.QNT-sum(case when a.NOSAT=1 then isnull(b.Qnt,0) else b.Qnt2 end)>0


GO

-- View: VwReportOutSPP
-- Created: 2013-05-13 12:08:51.577 | Modified: 2015-03-11 09:53:07.110
-- =====================================================



CREATE View [dbo].[VwReportOutSPP] 
as
Select  A.NoBukti+right('00000'+cast(A.Urut as varchar(5)),5) KeyNoBukti, A.Nobukti, P.Tanggal, P.KodeCustSupp, S.Namacust NamaCustSupp,
        A.urut, A.kodebrg, B.NamaBrg, '' Jns_Kertas, '' Ukr_Kertas, A.Sat_1, A.Sat_2, A.Isi,
        Case when A.NoSat=1 then A.Qnt
             when A.NoSat=2 then A.Qnt2
             else 0
        end Qnt, A.Qnt2,
        Case when A.NoSat=1 then A.QntSPB
             when A.NoSat=2 then A.Qnt2SPB
             else 0
        end QntSPB, A.Qnt2SPB,
        Case when A.NoSat=1 then A.QntSisa
             when A.NoSat=2 then A.Qnt2Sisa
             else 0
        end QntSisa, A.Qnt2Sisa,
        Case when A.NOSAT=1 then A.SAT_1
             when A.NOSAT=2 then A.SAT_2
             else ''
        end Satuan, P.Tglkirim,
        P.NoPesan
From    vwBrowsOutSPP A
Left Outer Join dbSPP P on P.NoBukti=A.NoBukti
left Outer join DBSO SO on SO.NOBUKTI=A.noso
Left Outer Join vwBrowsCustomer S on S.KodeCust=P.KodeCustSupp and s.Sales=SO.KODESLS
Left Outer Join dbBarang B on B.KodeBrg=A.KodeBrg
where A.isclose=0 

GO

-- View: VwReportOutStandingBPPB
-- Created: 2013-01-21 13:25:23.927 | Modified: 2013-01-21 13:25:23.927
-- =====================================================
CREATE View [dbo].[VwReportOutStandingBPPB]
as

Select  a.NoBukti,Tanggal,b.KodeBrg,c.NamaBrg,Qnt,Qnt2,A.KodeGdg,A.KodeGdgT
From dbBPPB a Left Outer Join dbBPPBDet b On a.NoBukti=b.NoBukti
left Outer Join dbBarang c On c.KodeBrg=b.KodeBrg
where Qnt<>Qnt2

GO

-- View: VwReportOutStandingPO
-- Created: 2013-01-07 10:15:07.063 | Modified: 2013-01-07 10:15:07.063
-- =====================================================
CREATE View [dbo].[VwReportOutStandingPO]
as
Select 	A.*, H.NamaBrg,I.TANGGAL,I.KODESUPP KOdeCustSupp,J.NAMACUSTSUPP
From vwOutstandingPO A
Left Outer Join dbBarang H on H.KodeBrg=A.KodeBrg
Left Outer Join DBPO I on A.NoBukti = I.NOBUKTI
left Outer Join DBCUSTSUPP J on I.KODESUPP = J.KODECUSTSUPP
GO

-- View: VwReportOutStandingPR
-- Created: 2013-01-07 10:15:22.863 | Modified: 2013-01-07 10:15:22.863
-- =====================================================
CREATE View [dbo].[VwReportOutStandingPR]
as
select A1.Nobukti,A1.Tanggal,a.kodebrg,C.KODESUPP KOdeCustSupp,D.NAMACUSTSUPP, a.Sat,c.NAMABRG,SUM(a.Qnt*isi)QntPPL,Isnull(b.Qnt,0) QntPO,SUM(a.Qnt*isi)-Isnull(b.Qnt,0)sisa from DBPPLDET a
Left Outer Join (select NoPPL,Kodebrg,SUM(Qnt*isi)Qnt from DBPODET  group by NoPPL,Kodebrg)b On a.Nobukti=b.NoPPL and a.kodebrg=b.KODEBRG
left Outer Join DBBARANG c On c.KODEBRG=a.kodebrg
Left Outer Join dbPPL A1 On A1.NoBukti=A.NoBukti 
Left Outer Join DBCUSTSUPP D on C.KODESUPP=D.KODECUSTSUPP
where Case when Isnull(A1.IsClose,0)=0 Then Isnull(A.IsClose,0)else Isnull(A1.IsClose,0) end=0
group by a.kodebrg,a.Sat,b.Qnt,c.NAMABRG,A1.Nobukti,A1.Tanggal,C.KODESUPP,D.NAMACUSTSUPP
having SUM(a.Qnt*isi)-Isnull(b.Qnt,0)<>0
GO

-- View: VwReportOutStandingSO
-- Created: 2013-01-18 16:31:30.357 | Modified: 2015-03-11 09:53:07.133
-- =====================================================


CREATE View [dbo].[VwReportOutStandingSO]
as
select  A.NoBukti, A.Urut, A.NoBukti+right('000000'+cast(A.Urut as varchar(6)),6) KeyUrut,
        A.KODEBRG, A.NamaBrg, A.QNT, A.QNT2, A.NOSAT, A.Satuan, A.ISI, A.QntSJ, A.Qnt2SJ, A.SatuanRoll,
        A.QNT-A.QntSJ QntSisa, A.QNT2-A.QNT2SJ Qnt2Sisa,
        C.KODECUSTSUPP,C.NAMACUSTSUPP,A.Tanggal,B.MasaBerlaku,B.NoPesanan,
        A.QNT2SJ Qnt2Spp,A.QntSJ QntSpp,B.TglKirim
--select * 
from    vwSOBelumSuratJlnDet A 
Left Outer Join  DBSO B on A.NoBukti = B.NOBUKTI
Left Outer Join DBCUSTSUPP C on B.KODECUST = C.KODECUSTSUPP



GO

-- View: VwReportOutstandingSO2
-- Created: 2013-01-25 09:11:09.357 | Modified: 2013-01-25 09:11:09.357
-- =====================================================
Create view VwReportOutstandingSO2
as
Select  A.NoBukti+right('00000'+cast(A.Urut as varchar(5)),5) KeyNoBukti, A.Nobukti, P.Tanggal, P.Kodecust KodeCustSupp, S.NamaCust NamaCustSupp,
        A.urut, A.kodebrg, B.NamaBrg, A.Satuan, A.Isi,
        A.Qnt, A.Qnt2, A.QntSPP, A.Qnt2SPP,
        A.QntSisa, A.Qnt2Sisa
From    vwBrowsOutSO_SPP A
Left Outer Join DBSO P on P.NoBukti=A.NoBukti
Left Outer Join vwBrowsCustomer S on S.KodeCust=P.KodeCust and S.Sales=P.KODESLS
Left Outer Join dbBarang B on B.KodeBrg=A.KodeBrg


GO

-- View: VwReportPembelian
-- Created: 2012-11-01 12:56:54.903 | Modified: 2012-11-01 12:56:54.903
-- =====================================================


Create View [dbo].[VwReportPembelian]
as
Select 	A.NoBukti+right('00000000'+cast(A.Urut as varchar(8)),8) KeyNoBukti,
        A.*, C.NamaCustSupp, T.Nama NamaTipe, ST.Nama NamaSubTipe,
        cast(left(A.NoBukti,2) as varchar(50)) Left2NoBukti
From dbPembelian A
Left Outer Join DBCUSTSUPP C on C.KODECUSTSUPP=A.KodeCustSupp
Left Outer Join DBTIPETRANS T on T.KODETIPE=A.KodeTipe
Left Outer Join DBSUBTIPETRANS ST on ST.KODETIPE=A.KodeTipe and ST.KODESUBTIPE=A.KodeSubTipe

GO

-- View: VwReportPenerimaanACC
-- Created: 2013-05-13 12:08:51.950 | Modified: 2015-03-09 15:28:00.997
-- =====================================================


CREATE view [dbo].[VwReportPenerimaanACC]
as

Select 	B.NoBukti,B.NoPO,I.TANGGAL,I.KODESUPP KodeCustSupp,J.NAMACUSTSUPP,
	B.Urut, B.KodeBrg, H.NamaBrg, B.QntTerima qnt, B.NoSat, B.Isi, B.Satuan,
	    k.QNT qntpo,b.QNT qntgdg, b.QntReject reject,b.Qnt2Reject reject2,
        Qnt2Terima Qnt2, '' SatuanRoll, B.Harga,
        (B.NDISKON+B.DISCTOT)*i.kurs Disctotal,
        (B.NDPP+B.NPPN)*i.kurs TotalIDR, B.NDPP*i.kurs NDPP,
        B.NPPN*i.kurs NPPN, B.BYAngkut Beban, B.SubTotal + B.BYAngkut Total,
        case when i.kurs=1 then 0 else b.disctot end as disctotusd,
        case when i.kurs=1 then 0 else b.ndpp end as Ndppusd,
        case when i.kurs=1 then 0 else b.nppn end as NPPNusd,
        case when i.kurs=1 then 0 else b.subtotal end as totalusd,
        I.kurs,I.KODEVLS--,b.Qnt2 qntgdg2,
        ,Cast(Case when Case when I.IsOtorisasi1=1 then 1 else 0 end+
		Case when I.IsOtorisasi2=1 then 1 else 0 end+
		Case when I.IsOtorisasi3=1 then 1 else 0 end+
		Case when I.IsOtorisasi4=1 then 1 else 0 end+
		Case when I.IsOtorisasi5=1 then 1 else 0 end=I.MaxOL then 0
		else 1
		end As Bit) Needotorisasi
From  DBBELIDET B 
Left Outer Join dbBarang H on H.KodeBrg=B.KodeBrg
Left Outer join DBBELI I on B.NOBUKTI = I.NOBUKTI
Left Outer Join DBCUSTSUPP J on I.KODESUPP = J.KODECUSTSUPP
Left outer join DBPODET K on K.NOBUKTI=B.NOBUKTI and k.KODEBRG=b.KODEBRG 



GO

-- View: VwreportPermintaanBahan
-- Created: 2013-06-03 14:29:18.257 | Modified: 2013-06-03 14:29:18.257
-- =====================================================




CREATE View [dbo].[VwreportPermintaanBahan]
as
Select 	A.NoBukti, A.TANGGAL,A.KodeGdg,A.KodeGdgT,a.kddep,c.NMDEP,
	B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt,B.Qnt2M, B.Satuan Satuan,
	B.Qnt2,B.Qnt2P,
	Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi 
From dbBPPB A
Left Outer join dbBPPBDet B on B.NoBukti=a.NoBukti
Left Outer join dbBarang H on H.KodeBrg=b.KodeBrg
left outer join DBDEPART c on c.KDDEP=a.KDDEP




GO

-- View: VwreportPLinvoice
-- Created: 2013-01-30 16:01:49.020 | Modified: 2013-02-01 13:36:57.100
-- =====================================================

CREATE View [dbo].[VwreportPLinvoice]
as
select 	B.NoBukti, B.Urut, B.NoSPB, B.UrutSPB, B.KodeBrg, C.NAMABRG,x.Tanggal tglSPB,B.NoSPP,
        B.PPN, B.DISC, B.KURS, B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.NOSAT, B.ISI, B.NetW, B.GrossW,
        B.HARGA, B.DiscP, B.DiscRp, B.DISCTOT, B.HRGNETTO, B.NDISKON, B.SUBTOTAL, B.NDPP, B.NPPN, B.NNET,
        B.SUBTOTALRp, B.NDPPRp, B.NPPNRp, B.NNETRp, B.KetDetail,
        A.Tanggal,A.KodeCustSupp,D.NAMACUSTSUPP
from	dbInvoicePLDet B
left outer join dbBarang C on C.KodeBrg=B.KodeBrg
left outer join DBInvoicePL A on B.NoBukti = A.NoBukti
Left outer join DBCUSTSUPP D on A.KodeCustSupp = D.KODECUSTSUPP
left outer join dbSPB X on B.NoSPB = X.NoBukti



GO

-- View: VwreportPO
-- Created: 2013-06-03 13:41:53.343 | Modified: 2013-06-03 13:41:53.343
-- =====================================================



CREATE view [dbo].[VwreportPO]
as
Select 	B.NoBukti,I.TANGGAL,I.KODESUPP KodeCustSupp,J.NAMACUSTSUPP, '' NoSPP, 0 UrutSPP,
	B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt, B.NoSat, B.Isi, B.Satuan,
        0.00 Qnt2, '' SatuanRoll, B.Harga,
        (B.NDISKON+B.DISCTOT)*i.kurs Disctotal,
        (B.NDPP+B.NPPN)*i.kurs TotalIDR, B.NDPP*i.kurs NDPP,
        B.NPPN*i.kurs NPPN, B.BYAngkut Beban, B.SubTotal + B.BYAngkut Total,
        case when i.kurs=1 then 0 else b.disctot end as disctotusd,
        case when i.kurs=1 then 0 else b.ndpp end as Ndppusd,
        case when i.kurs=1 then 0 else b.nppn end as NPPNusd,
        case when i.kurs=1 then 0 else b.subtotal end as totalusd,
        I.kurs,I.KODEVLS,
        Cast(Case when Case when I.IsOtorisasi1=1 then 1 else 0 end+
                      Case when I.IsOtorisasi2=1 then 1 else 0 end+
                      Case when I.IsOtorisasi3=1 then 1 else 0 end+
                      Case when I.IsOtorisasi4=1 then 1 else 0 end+
                      Case when I.IsOtorisasi5=1 then 1 else 0 end=I.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi
From  dbPODet B 
Left Outer Join dbBarang H on H.KodeBrg=B.KodeBrg
Left Outer join DBPO I on B.NOBUKTI = I.NOBUKTI
Left Outer Join DBCUSTSUPP J on I.KODESUPP = J.KODECUSTSUPP 



GO

-- View: VwReportPurchasingReq
-- Created: 2013-06-03 13:35:04.340 | Modified: 2013-06-03 13:35:04.340
-- =====================================================


CREATE view [dbo].[VwReportPurchasingReq]
as

Select 	A.NoBukti,A.Tanggal,H.KODESUPP KodeCustSupp,I.NAMACUSTSUPP, 
	B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt, B.NoSat, B.Isi Isi, B.Sat Satuan,B.Keterangan,
	 Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi

From dbPPL A
Left Outer join dbPPLDet B on B.NoBukti=a.NoBukti
Left Outer join dbBarang H on H.KodeBrg=b.KodeBrg
Left Outer Join DBCUSTSUPP I on H.KODESUPP=i.KODECUSTSUPP


GO

-- View: VwReportRBeli
-- Created: 2012-11-01 12:56:54.920 | Modified: 2012-11-01 12:56:54.920
-- =====================================================

CREATE View [dbo].[VwReportRBeli]
as
Select 	A.NoBukti+right('00000000'+cast(A.Urut as varchar(8)),8) KeyNoBukti,
        A.*, C.NamaCustSupp, T.Nama NamaTipe, ST.Nama NamaSubTipe,
        cast(left(A.NoBukti,2) as varchar(50)) Left2NoBukti
From dbRPembelian A
Left Outer Join DBCUSTSUPP C on C.KODECUSTSUPP=A.KodeCustSupp
Left Outer Join DBTIPETRANS T on T.KODETIPE=A.KodeTipe
Left Outer Join DBSUBTIPETRANS ST on ST.KODETIPE=A.KodeTipe and ST.KODESUBTIPE=A.KodeSubTipe

GO

-- View: VwReportRevisiPO
-- Created: 2013-01-07 10:16:15.090 | Modified: 2013-01-07 10:16:15.090
-- =====================================================
CREATE View [dbo].[VwReportRevisiPO]
as
Select 	B.NoBukti,I.TANGGAL,I.KODESUPP KodeCustSupp,J.NAMACUSTSUPP, '' NoSPP, 0 UrutSPP,
	B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt, B.NoSat, B.Isi, B.Satuan,
        0.00 Qnt2, '' SatuanRoll, B.Harga,
        B.DiscP DiscP1, B.DiscTot DiscRp1, B.DiscTot,
        B.SubTotal TotalUSD, B.SubTotal TotalIDR, B.NDPP NDPP,
        B.NPPN NPPN, B.BYAngkut Beban, B.SubTotal + B.BYAngkut Total
From  dbPODet B 
Left Outer Join dbBarang H on H.KodeBrg=B.KodeBrg
Left Outer join DBPO I on B.NOBUKTI = I.NOBUKTI
Left Outer Join DBCUSTSUPP J on I.KODESUPP = J.KODECUSTSUPP 
GO

-- View: VwreportRInvoice
-- Created: 2013-01-18 14:57:59.257 | Modified: 2013-01-18 14:57:59.257
-- =====================================================

CREATE View [dbo].[VwreportRInvoice]
as
Select 	B.NoBukti, B.UrutPBL,I.KODESUPP KodeCustSupp,j.NAMACUSTSUPP,I.TANGGAL,
	B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt, B.NoSat, B.Isi, B.Satuan,
        0.00 Qnt2, '' SatuanRoll, B.Harga,
        B.DiscP DiscP1, B.DiscTot DiscRp1, B.DiscTot,
        B.SubTotal TotalUSD, B.SubTotal TotalIDR, B.NDPP NDPP,
        B.NPPN NPPN, B.BYAngkut Beban, B.SubTotal + B.BYAngkut Total
        
From dbRBeliDet B
Left Outer Join dbBarang H on H.KodeBrg=B.KodeBrg 
Left Outer Join DBRBELI I on B.NOBUKTI = I.NOBUKTI
Left Outer Join DBCUSTSUPP J on I.KODESUPP = J.KODECUSTSUPP 
GO

-- View: VwReportRInvoicePenjualan
-- Created: 2013-06-03 14:14:44.973 | Modified: 2013-06-03 14:14:44.973
-- =====================================================




CREATE View [dbo].[VwReportRInvoicePenjualan]
as
select 	B.NOBUKTI,D.TANGGAL, B.URUT, B.KODEBRG, B.PPN, B.DISC, B.KURS,D.NOSPB,D.NoSPP,E.Tanggal TglSPB,F.Tanggal TglSpp,
        B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.ISI, B.HARGA, B.DiscP1, B.DiscRp1,
        B.DiscP2, B.DiscRp2, B.DiscP3, B.DiscRp3, B.DiscP4, B.DiscRp4, B.DISCTOT,
        B.BYANGKUT, B.HRGNETTO, B.NDISKON, B.SUBTOTAL, B.NDPP, B.NPPN, B.NNET, B.SUBTOTALRp,
        B.NDPPRp, B.NPPNRp, B.NNETRp, B.NOInvoice, B.URUTInvoice, B.Keterangan,
        C.NamaBrg, B.QntTukar, B.Qnt2Tukar, B.netW, B.GrossW,
        'Nama Produk : '+c.Namabrg+' '+'Nama Komersil : '+ b.namabrg NamaProduk,
        D.KODECUSTSUPP,G.NAMACUSTSUPP,
		Cast(Case when Case when D.IsOtorisasi1=1 then 1 else 0 end+
		Case when D.IsOtorisasi2=1 then 1 else 0 end+
		Case when D.IsOtorisasi3=1 then 1 else 0 end+
		Case when D.IsOtorisasi4=1 then 1 else 0 end+
		Case when D.IsOtorisasi5=1 then 1 else 0 end=D.MaxOL then 0
		else 1
		end As Bit) Needotorisasi
        
from	dbRInvoicePLDet B
left outer join dbBarang C on C.KodeBrg=B.KodeBrg
left outer join DBRInvoicePL D on B.NOBUKTI=D.NOBUKTI
Left Outer Join dbSPB E on D.NOSPB = E.NoBukti
Left Outer join dbSPP F on D.NoSPP = F.NoBukti
Left Outer join DBCUSTSUPP G on D.KODECUSTSUPP=G.KODECUSTSUPP







GO

-- View: VwReportRjual
-- Created: 2012-11-01 12:56:54.960 | Modified: 2012-11-01 12:56:54.960
-- =====================================================


Create View [dbo].[VwReportRjual]
as
Select 	A.NoBukti+right('00000000'+cast(A.Urut as varchar(8)),8) KeyNoBukti,
        A.*, C.NamaCustSupp, T.Nama NamaTipe, ST.Nama NamaSubTipe,
        cast(left(A.NoBukti,2) as varchar(50)) Left2NoBukti
From dbRPenjualan A
Left Outer Join DBCUSTSUPP C on C.KODECUSTSUPP=A.KodeCustSupp
Left Outer Join DBTIPETRANS T on T.KODETIPE=A.KodeTipe
Left Outer Join DBSUBTIPETRANS ST on ST.KODETIPE=A.KodeTipe and ST.KODESUBTIPE=A.KodeSubTipe

GO

-- View: VwReportRPembelianGDg
-- Created: 2013-06-03 13:53:00.930 | Modified: 2013-06-03 13:53:00.930
-- =====================================================


CREATE view [dbo].[VwReportRPembelianGDg]
as
Select 	A.NoBukti,A.TANGGAL, a.Nobeli, A.KODESUPP KodeCustSupp,I.NAMACUSTSUPP,
	    B.Urut, B.KodeBrg, H.NamaBrg,b.QNT as qntretur,b.SATUAN as satrbeli,
	    isnull(B.Qnt1,0) as qnt, h.SAT1 as satuan,
        isnull(b.Qnt2,0) as Qnt2,h.SAT2 As satuan2,
        B.Harga, B.HrgNetto,B.DiscP,B.DiscTot,
        case when a.KODEVLS<>'IDR' then b.NDPP else 0 end as ndpp,B.NDPPRp,b.NPPNRp,b.NNETRp,
        A.KODEVLS,A.KURS,A.FAKTURSUPP,
        Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi
        
From dbRBeliDet B
Left Outer Join dbBarang H on H.KodeBrg=B.KodeBrg 
left Outer Join DBRBELI A on B.NOBUKTI=A.NOBUKTI
Left Outer Join DBCUSTSUPP I on A.KODESUPP = I.KODECUSTSUPP





GO

-- View: VwReportRPenyerahanBahan
-- Created: 2013-06-03 14:27:09.800 | Modified: 2013-06-03 14:27:09.800
-- =====================================================
CREATE View [dbo].[VwReportRPenyerahanBahan]
as
Select 	A.NoBukti, 
B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt, B.NoSat, B.Isi Isi, B.Sat Satuan,A.Tanggal,
Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi 
From dbRPenyerahanBhn A
Left Outer join  dbRPenyerahanBhnDet B on B.NoBukti=a.NoBukti
Left Outer join dbBarang H on H.KodeBrg=b.KodeBrg  



GO

-- View: VwReportRPLInvoice
-- Created: 2013-02-01 14:18:16.590 | Modified: 2013-02-01 14:25:05.233
-- =====================================================
CREATE View VwReportRPLInvoice
as
select 	B.NOBUKTI,D.TANGGAL, B.URUT, B.KODEBRG, B.PPN, B.DISC, B.KURS,D.NOSPB,D.NoSPP,E.Tanggal TglSPB,F.Tanggal TglSpp,
        B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.ISI, B.HARGA, B.DiscP1, B.DiscRp1,
        B.DiscP2, B.DiscRp2, B.DiscP3, B.DiscRp3, B.DiscP4, B.DiscRp4, B.DISCTOT,
        B.BYANGKUT, B.HRGNETTO, B.NDISKON, B.SUBTOTAL, B.NDPP, B.NPPN, B.NNET, B.SUBTOTALRp,
        B.NDPPRp, B.NPPNRp, B.NNETRp, B.NOInvoice, B.URUTInvoice, B.Keterangan,
        C.NamaBrg, B.QntTukar, B.Qnt2Tukar, B.netW, B.GrossW,
        'Nama Produk : '+c.Namabrg+' '+'Nama Komersil : '+ b.namabrg NamaProduk,
        D.KODECUSTSUPP,G.NAMACUSTSUPP
from	dbRInvoicePLDet B
left outer join dbBarang C on C.KodeBrg=B.KodeBrg
left outer join DBRInvoicePL D on B.NOBUKTI=D.NOBUKTI
Left Outer Join dbSPB E on D.NOSPB = E.NoBukti
Left Outer join dbSPP F on D.NoSPP = F.NoBukti
Left Outer join DBCUSTSUPP G on D.KODECUSTSUPP=G.KODECUSTSUPP



GO

-- View: VwReportSO
-- Created: 2013-06-03 13:59:19.797 | Modified: 2013-06-03 13:59:19.797
-- =====================================================
CREATE View [dbo].[VwReportSO]
as
Select 	A.NoBukti, A.NoSPB, B.UrutSPB,A.TANGGAL,I.KODECUSTSUPP,I.NAMACUSTSUPP,
	A.NoBukti+right('0000000000'+cast(B.Urut as varchar(10)),10) NoBuktiUrut,
        B.Urut, B.KodeBrg, H.NamaBrg,
        case when b.NOSAT=1 then B.Qnt else b.QNT2 end as qntjual,b.QNT, B.NoSat, B.Isi, H.Sat1 Satuan,
        B.Qnt2, H.Sat2 Satuan2, B.Harga,
        B.DiscP1,B.DiscTot,B.NDPP,a.KURS,a.KODEVLS,B.NDPPRp,B.NPPNRp,B.NNETRp,
        Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi 
From dbSO A
Left Outer join dbSODet B on B.NoBukti=a.NoBukti
Left Outer Join vwSatuanBrg H on H.KodeBrg=B.KodeBrg --and H.NoSat=B.NoSat
Left Outer join DBCUSTSUPP I on a.KODECUST = I.KODECUSTSUPP





GO

-- View: vwreportSOx
-- Created: 2013-01-18 16:28:26.957 | Modified: 2013-01-31 09:06:04.520
-- =====================================================


CREATE View [dbo].[vwreportSOx]
as
Select  A.NoBukti+right('00000'+cast(A.Urut as varchar(5)),5) KeyNoBukti, A.Nobukti, 
P.Tanggal, P.Kodecust KodeCustSupp, S.NamaCust NamaCustSupp,
A.urut, A.kodebrg, B.NamaBrg, A.Satuan, A.Isi,
A.Qnt, A.Qnt2, A.QntSPP, A.Qnt2SPP,
A.QntSisa, A.Qnt2Sisa,P.MasaBerlaku,P.NoPesanan,P.TglKirim,P.TGLJATUHTEMPO
From    vwBrowsOutSO_SPP A
Left Outer Join DBSO P on P.NoBukti=A.NoBukti
Left Outer Join vwBrowsCustomer S on S.KodeCust=P.KodeCust and S.Sales=P.KODESLS
Left Outer Join dbBarang B on B.KodeBrg=A.KodeBrg
where A.islengkap=0


GO

-- View: VwreportSPB
-- Created: 2013-06-03 14:10:02.747 | Modified: 2013-06-03 14:10:02.747
-- =====================================================


CREATE View [dbo].[VwreportSPB]
as
select 	B.NOBUKTI, B.URUT, B.NoSPP NoSC, B.UrutSPP UrutSC, B.KODEBRG, C.NAMABRG, '' Jns_Kertas, ''Ukr_Kertas,
        B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.ISI, B.NetW, B.GrossW, '' KetDetail,
        A.Tanggal,a.KodeCustSupp,D.NAMACUSTSUPP, 
		Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
		Case when A.IsOtorisasi2=1 then 1 else 0 end+
		Case when A.IsOtorisasi3=1 then 1 else 0 end+
		Case when A.IsOtorisasi4=1 then 1 else 0 end+
		Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
		else 1
		end As Bit)NeedOtorisasi
from	dbSPBDet B
left outer join dbBarang C on C.KodeBrg=B.KodeBrg
Left Outer join dbSPB A on B.NoBukti = A.NoBukti
Left Outer Join DBCUSTSUPP D on A.KodeCustSupp = D.KODECUSTSUPP



GO

-- View: VwreportSPBACC
-- Created: 2013-06-24 10:36:50.300 | Modified: 2013-06-24 14:54:37.000
-- =====================================================



CREATE View [dbo].[VwreportSPBACC]
as
select 	B.NOBUKTI, B.URUT, B.NoSPP NoSC, B.UrutSPP UrutSC, B.KODEBRG, C.NAMABRG, '' Jns_Kertas, ''Ukr_Kertas,
        B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.ISI, B.NetW, B.GrossW, '' KetDetail,
        A.Tanggal,a.KodeCustSupp,D.NAMACUSTSUPP, 
		Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
		Case when A.IsOtorisasi2=1 then 1 else 0 end+
		Case when A.IsOtorisasi3=1 then 1 else 0 end+
		Case when A.IsOtorisasi4=1 then 1 else 0 end+
		Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
		else 1
		end As Bit)NeedOtorisasi, B.HPP, B.HPP*B.QNT Total
from	dbSPBDet B
left outer join dbBarang C on C.KodeBrg=B.KodeBrg
Left Outer join dbSPB A on B.NoBukti = A.NoBukti
Left Outer Join DBCUSTSUPP D on A.KodeCustSupp = D.KODECUSTSUPP



GO

-- View: VwReportSPBRJual
-- Created: 2015-03-09 15:28:01.037 | Modified: 2015-03-11 09:53:07.033
-- =====================================================



CREATE View [dbo].[VwReportSPBRJual]
as
select 	B.NOBUKTI,D.TANGGAL, B.URUT, B.KODEBRG,D.Tanggal TglSPB,
        B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.ISI,
        'Nama Produk : '+c.Namabrg+' '+'Nama Komersil : '+ b.namabrg NamaProduk,
        D.KODECUSTSUPP,G.NAMACUSTSUPP,
		Cast(Case when Case when D.IsOtorisasi1=1 then 1 else 0 end+
		Case when D.IsOtorisasi2=1 then 1 else 0 end+
		Case when D.IsOtorisasi3=1 then 1 else 0 end+
		Case when D.IsOtorisasi4=1 then 1 else 0 end+
		Case when D.IsOtorisasi5=1 then 1 else 0 end=D.MaxOL then 0
		else 1
		end As Bit) Needotorisasi
        
from	dbSPBRJualDet B
left outer join dbBarang C on C.KodeBrg=B.KodeBrg
left outer join dbSPBRJual D on B.NOBUKTI=D.NOBUKTI
Left Outer join DBCUSTSUPP G on D.KODECUSTSUPP=G.KODECUSTSUPP


GO

-- View: VwReportSPP
-- Created: 2013-06-03 14:07:29.153 | Modified: 2013-06-03 14:07:29.153
-- =====================================================
CREATE View [dbo].[VwReportSPP]
as
select 	B.NOBUKTI, B.URUT, B.NoSO, B.UrutSO, B.KODEBRG, C.NAMABRG,D.Tanggal,D.KodeCustSupp,E.NAMACUSTSUPP,
        B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.ISI, B.NetW, B.GrossW, B.KetDetail,
        B.Nobukti+Cast(B.urut As Varchar(5)) MyKey,
        B.NamaBrg+Char(13)+'('+C.NamaBrg+')' NamaBrgKom,
        B.ShippingMark, Case when B.Nosat=1 then B.Sat_1 when B.nosat=2 then B.Sat_2 else '' end Satuan,
        D.NoPesan,D.TglKirim,B.Kodegdg,       
	Cast(Case when Case when D.IsOtorisasi1=1 then 1 else 0 end+
    Case when D.IsOtorisasi2=1 then 1 else 0 end+
    Case when D.IsOtorisasi3=1 then 1 else 0 end+
    Case when D.IsOtorisasi4=1 then 1 else 0 end+
    Case when D.IsOtorisasi5=1 then 1 else 0 end=D.MaxOL then 0
    else 1
    end As Bit) NeeDOtorisasi
from	dbSPPDet B
left outer join dbBarang C on C.KodeBrg=B.KodeBrg
Left Outer join dbSPP D on B.NoBukti = D.NoBukti
Left Outer join DBCUSTSUPP E on D.KodeCustSupp = E.KODECUSTSUPP





GO

-- View: VwreportSPPB
-- Created: 2013-01-30 15:52:51.043 | Modified: 2013-02-01 11:31:09.150
-- =====================================================

CREATE View [dbo].[VwreportSPPB]
as
Select A.*,B.NAMABRG NamaBarang,C.Tanggal,C.kodeCustSupp,D.NAMACUSTSUPP,
           A.Nobukti+Cast(A.Urut as varchar(5)) MyKey,Z.NOBUKTI Noso,Z.TANGGAL TanggalSO
from dbSPBDet A
     left outer join DBBARANG B on B.KODEBRG=A.Kodebrg
     Left Outer join dbSPB C on A.NoBukti = C.NoBukti
     Left Outer join DBCUSTSUPP D on c.KodeCustSupp = D.KODECUSTSUPP
     Left Outer join (Select x.NoBukti, x.NoSPP
                      from dbSPBDet x
                      group by x.NoBukti, x.NoSPP) y on y.NoBukti=C.NoBukti
     Left Outer Join (Select x.NoBukti, x.Tanggal,y.NoSO, x.TglKirim
                      from DBSPP x 
                        left outer join dbSPPDet y on y.NoBukti=x.NoBukti
                      Group by x.NoBukti, x.Tanggal,y.NoSO, x.TglKirim) v On v.NoBukti=y.NoSPP 
    left outer join DBSO Z on Z.NOBUKTI=v.NoSO
     


GO

-- View: VwReportSppx
-- Created: 2013-01-30 14:00:03.827 | Modified: 2013-01-31 11:09:43.957
-- =====================================================

CREATE View [dbo].[VwReportSppx]
as
Select  A.NoBukti+right('00000'+cast(A.Urut as varchar(5)),5) KeyNoBukti, A.Nobukti, P.Tanggal, P.KodeCustSupp, S.Namacust NamaCustSupp,
        A.urut, A.kodebrg, B.NamaBrg, '' Jns_Kertas, '' Ukr_Kertas, A.Sat_1, A.Sat_2, A.Isi,
        Case when A.NoSat=1 then A.Qnt
             when A.NoSat=2 then A.Qnt2
             else 0
        end Qnt, A.Qnt2,
        Case when A.NoSat=1 then A.QntSPB
             when A.NoSat=2 then A.Qnt2SPB
             else 0
        end QntSPB, A.Qnt2SPB,
        Case when A.NoSat=1 then A.QntSisa
             when A.NoSat=2 then A.Qnt2Sisa
             else 0
        end QntSisa, A.Qnt2Sisa,
        Case when A.NOSAT=1 then A.SAT_1
             when A.NOSAT=2 then A.SAT_2
             else ''
        end Satuan, P.Tglkirim,
        P.NoPesan
From    vwBrowsOutSPP A
Left Outer Join dbSPP P on P.NoBukti=A.NoBukti
left Outer join DBSO SO on SO.NOBUKTI=A.noso
Left Outer Join vwBrowsCustomer S on S.KodeCust=P.KodeCustSupp and s.Sales=SO.KODESLS
Left Outer Join dbBarang B on B.KodeBrg=A.KodeBrg
where A.isclose=0 
    


GO

-- View: VwReportSpRk
-- Created: 2013-06-03 14:17:57.390 | Modified: 2013-06-03 14:17:57.390
-- =====================================================


CREATE View [dbo].[VwReportSpRk]
as
Select 	A.Tanggal,B.NoBukti,A.KODEBRG KodeBrgJadi,i.NAMABRG NmBrgjadi,
	B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt, B.NoSat, B.Isi Isi, B.Satuan Satuan
	 ,Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi 
From dbSPKDet B 
Left Outer Join DbSPK A on  B.nobukti = A.nobukti
Left Outer join dbBarang H on H.KodeBrg=b.KodeBrg
Left Outer Join DBBARANG I on A.KODEBRG = I.KODEBRG


GO

-- View: vwReportStockBrg
-- Created: 2013-07-11 17:38:52.523 | Modified: 2013-07-11 17:38:52.523
-- =====================================================
CREATE view [dbo].[vwReportStockBrg]
as
Select  a.BULAN, a.TAHUN, a.KODEBRG, a.KODEGDG, a.QNTAWAL, a.HRGAWAL, 
	a.QNTPBL, a.QNT2PBL, a.HRGPBL, a.QNTRPB, a.QNT2RPB, a.HRGRPB, 
	a.QNTPNJ, a.QNT2PNJ, a.HRGPNJ, a.QNTRPJ, a.QNT2RPJ, a.HRGRPJ, 
	a.QNTADI, a.QNT2ADI, a.HRGADI, a.QNTADO, a.QNT2ADO, a.HRGADO, 
	a.QNTUKI, a.QNT2UKI, a.HRGUKI, a.QNTUKO, a.QNT2UKO, a.HRGUKO, 
	a.QNTTRI, a.QNT2TRI, a.HRGTRI, a.QNTTRO, a.QNT2TRO, a.HRGTRO,
	a.QNTPMK, a.QNT2PMK, a.HRGPMK, a.QNTRPK, a.QNT2RPK, a.HRGRPK,
	a.QntHPrd, a.Qnt2HPrd, a.HRGHPrd, 
	a.HRGRATA, a.QNTIN, a.QNT2IN, a.RPIN, a.QNTOUT, a.QNT2OUT, a.RPOUT, 
	a.SALDOQNT, a.SALDO2QNT, a.SALDORP, a.SaldoAV, a.Saldo2AV, 
	B.QntMin,B.QntMax,
    b.NAMABRG, c.NAMA Namagdg, b.SAT1, b.Sat2,B.ISI1,B.ISI2,B.ISI3,
    b.KODEGRP, b.KODESUBGRP
from DBSTOCKBRG a
     left outer join DBBARANG b on b.KODEBRG=a.KODEBRG --and b.Kodegdg=a.KODEGDG
     left outer join DBGUDANG c on c.KODEGDG=a.KODEGDG




GO

-- View: VwReporttransfer
-- Created: 2013-06-10 11:36:28.560 | Modified: 2013-06-10 11:36:28.560
-- =====================================================

Create View [dbo].[VwReporttransfer]
as
Select A.nobukti, a.NoUrut, a.Tanggal,  A.Note Keterangan, A.NoPenyerahan,
	 B.URUT,  B.KODEBRG, C.NAMABRG, '' Jns_Kertas, '' Ukr_Kertas,
    B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.ISI, B.GdgAsal, B.GdgTujuan, D.Nama+' ('+B.gdgAsal+')' NamagdgAsal,
    E.Nama+' ('+B.GdgTujuan+')' NamagdgTujuan,
    A.IsOtorisasi1, A.OtoUser1, A.TglOto1, A.IsOtorisasi2, A.OtoUser2, A.TglOto2,
	A.IsOtorisasi3, A.OtoUser3, A.TglOto3, A.IsOtorisasi4, A.OtoUser4, A.TglOto4,
	A.IsOtorisasi5, A.OtoUser5, A.TglOto5,
        Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                       Case when A.IsOtorisasi2=1 then 1 else 0 end+
                       Case when A.IsOtorisasi3=1 then 1 else 0 end+
                       Case when A.IsOtorisasi4=1 then 1 else 0 end+
                       Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                  else 1
             end As Bit) NeedOtorisasi
from dbTransfer a
Left Outer JOin DBTRANSFERDET B on A.NOBUKTI=B.NOBUKTI
left outer join dbBarang C on C.KodeBrg=B.KodeBrg
left outer join dbGudang D on d.Kodegdg=B.GdgAsal
left outer join dbgudang E on E.kodegdg=B.GdgTujuan






--select * from VwReporttransfer

GO

-- View: VwReportUbahKemasanBahan
-- Created: 2013-01-21 13:31:31.560 | Modified: 2013-01-21 13:31:31.560
-- =====================================================

create view [dbo].[VwReportUbahKemasanBahan]
as
Select * from vwDetailUbahKemasan where NoBukti Like '%KMS%'

GO

-- View: vwRepPO
-- Created: 2011-03-23 13:31:20.770 | Modified: 2011-11-04 09:11:15.923
-- =====================================================

CREATE View [dbo].[vwRepPO]
as
Select 	A.NOBUKTI, A.Tanggal, A.TglJatuhTempo, A.KodeCustSupp, C.NamaCustSupp, A.KodeVls, A.Kurs, 
	B.Urut, B.KODEBRG, D.NAMABRG, case when B.NoSat=1 then B.Qnt else B.Qnt2 end Qnt,
	case when B.NoSat=1 then D.SAT1 else D.Sat2 end Satuan, 
	B.HRGNETTO Harga, B.SUBTOTAL, B.NDPP, B.NPPN , B.NNET,
	E.SyaratPembayaran, E.SyaratPengiriman,
	A.Tipe, F.QntSisa, F.Qnt2Sisa, F.QntBeli, F.Qnt2Beli 
From 	DBPO A
Left Outer Join DBPODET B on B.NOBUKTI=A.NOBUKTI
Left Outer Join DBCUSTSUPP C on C.KODECUSTSUPP=A.KODECUSTSUPP 
Left Outer Join DBBARANG D on D.KODEBRG=B.KODEBRG
Left Outer Join DBNOTEPO E on E.NOBUKTI=A.NOBUKTI 
left Outer join vwOutPO F on F.Nobukti=B.NOBUKTI and F.urut=B.URUT







GO

-- View: vwRpDetBeli
-- Created: 2011-02-11 15:18:57.667 | Modified: 2011-03-03 12:04:22.160
-- =====================================================

CREATE View [dbo].[vwRpDetBeli]
as

Select 	NoBukti, Sum(SubTotal) TotSubTotal, Sum(NDiskon) TotDiskon, Sum(SubTotal)-Sum(NDiskon) TotTotal,
	Sum(NDPP) TotDPP, Sum(NPPN) TotPPN, SUm(NNet) TotNet, Sum(SubTotalRp) TotSubTotalRp, Sum(NDiskon*Kurs) TotDiskonRp,
	Sum(SubTotalRp)-Sum(NDiskon*Kurs) TotTotalRp, Sum(NDPPRp) TotDPPRp, Sum(NPPNRp) TotPPNRp, Sum(NNETRp) TotNetRp
From 	dbBeliDet
Group By NoBukti


GO

-- View: vwRpDetInvoicePL
-- Created: 2013-01-26 08:59:27.000 | Modified: 2013-01-26 08:59:27.000
-- =====================================================


CREATE View [dbo].[vwRpDetInvoicePL]
as

Select 	NoBukti, Sum(SubTotal) TotSubTotal, Sum(NDiskon) TotDiskon, Sum(SubTotal)-Sum(NDiskon) TotTotal,
	Sum(NDPP) TotDPP, Sum(NPPN) TotPPN, SUm(NNet) TotNet, Sum(SubTotalRp) TotSubTotalRp, Sum(NDiskon*Kurs) TotDiskonRp,
	Sum(SubTotalRp)-Sum(NDiskon*Kurs) TotTotalRp, Sum(NDPPRp) TotDPPRp, Sum(NPPNRp) TotPPNRp, Sum(NNETRp) TotNetRp
From 	dbInvoicePLDet
Group By NoBukti



GO

-- View: vwRpDetInvoiceRPJ
-- Created: 2013-06-03 11:07:48.253 | Modified: 2013-06-03 11:07:48.253
-- =====================================================

CREATE View [dbo].[vwRpDetInvoiceRPJ]
as
Select 	NoBukti, Sum(SubTotal) TotSubTotal, Sum(NDiskon) TotDiskon, Sum(SubTotal)-Sum(NDiskon) TotTotal,
	Sum(NDPP) TotDPP, Sum(NPPN) TotPPN, SUm(NNet) TotNet, Sum(SubTotalRp) TotSubTotalRp, Sum(NDiskon*Kurs) TotDiskonRp,
	Sum(SubTotalRp)-Sum(NDiskon*Kurs) TotTotalRp, Sum(NDPPRp) TotDPPRp, Sum(NPPNRp) TotPPNRp, Sum(NNETRp) TotNetRp
From 	DBINVOICERPJDet
Group By NoBukti


GO

-- View: vwRpDetPO
-- Created: 2011-02-11 15:18:57.603 | Modified: 2011-04-15 09:57:11.047
-- =====================================================







CREATE View [dbo].[vwRpDetPO]
as

Select 	NoBukti, Sum(Brutto) TotBrutto,Sum(SubTotal) TotSubTotal, Sum(NDISKONTOT) TotDiskon, Sum(SubTotal)-Sum(NDiskon) TotTotal,
	Sum(NDPP) TotDPP, Sum(NPPN) TotPPN, SUm(NNet) TotNet, Sum(SubTotalRp) TotSubTotalRp, Sum(NDISKONTOT*Kurs) TotDiskonRp,
	Sum(SubTotalRp)-Sum(NDISKONTOT*Kurs) TotTotalRp, Sum(NDPPRp) TotDPPRp, Sum(NPPNRp) TotPPNRp, Sum(NNETRp) TotNetRp
From 	dbo.dbPODet
Group By NoBukti







GO

-- View: vwRpDetRBeli
-- Created: 2011-02-11 15:18:57.607 | Modified: 2013-02-25 15:28:55.097
-- =====================================================

CREATE View [dbo].[vwRpDetRBeli]
as

Select 	NoBukti, Sum(SubTotal) TotSubTotal, Sum(NDiskon) TotDiskon, Sum(SubTotal)-Sum(NDiskon) TotTotal,
	Sum(NDPP) TotDPP, Sum(NPPN) TotPPN, SUm(NNet) TotNet, Sum(SubTotalRp) TotSubTotalRp, Sum(NDiskon*Kurs) TotDiskonRp,
	Sum(SubTotalRp)-Sum(NDiskon*Kurs) TotTotalRp, Sum(NDPPRp) TotDPPRp, Sum(NPPNRp) TotPPNRp, Sum(NNETRp) TotNetRp
From 	dbRBeliDet
Group By NoBukti


GO

-- View: vwRpDetRevPO
-- Created: 2011-04-15 15:32:59.090 | Modified: 2011-04-15 15:32:59.090
-- =====================================================








CREATE View [dbo].[vwRpDetRevPO]
as

Select 	NoBukti, Sum(Brutto) TotBrutto,Sum(SubTotal) TotSubTotal, Sum(NDISKONTOT) TotDiskon, Sum(SubTotal)-Sum(NDiskon) TotTotal,
	Sum(NDPP) TotDPP, Sum(NPPN) TotPPN, SUm(NNet) TotNet, Sum(SubTotalRp) TotSubTotalRp, Sum(NDISKONTOT*Kurs) TotDiskonRp,
	Sum(SubTotalRp)-Sum(NDISKONTOT*Kurs) TotTotalRp, Sum(NDPPRp) TotDPPRp, Sum(NPPNRp) TotPPNRp, Sum(NNETRp) TotNetRp
From 	dbo.dbRevPODet
Group By NoBukti








GO

-- View: vwRpDetRInvoicePL
-- Created: 2013-02-21 11:19:15.850 | Modified: 2013-02-21 11:25:32.217
-- =====================================================
CREATE VIEW dbo.vwRpDetRInvoicePL
AS
SELECT     NOBUKTI, SUM(SUBTOTAL) AS TotSubTotal, SUM(NDISKON) AS TotDiskon, SUM(SUBTOTAL) - SUM(NDISKON) AS TotTotal, SUM(NDPP) AS TotDPP, SUM(NPPN) 
                      AS TotPPN, SUM(NNET) AS TotNet, SUM(SUBTOTALRp) AS TotSubTotalRp, SUM(NDISKON * KURS) AS TotDiskonRp, SUM(SUBTOTALRp) - SUM(NDISKON * KURS) 
                      AS TotTotalRp, SUM(NDPPRp) AS TotDPPRp, SUM(NPPNRp) AS TotPPNRp, SUM(NNETRp) AS TotNetRp
FROM         dbo.DBRInvoicePLDET
GROUP BY NOBUKTI

GO

-- View: vwRpDetSO
-- Created: 2012-12-17 11:49:43.877 | Modified: 2012-12-17 11:49:43.877
-- =====================================================
CREATE View [dbo].[vwRpDetSO]
As

Select 	NoBukti, Sum(SubTotal) TotSubTotal, Sum(NDiskon) TotDiskon, Sum(SubTotal)-Sum(NDiskon) TotTotal,
	Sum(NDPP) TotDPP, Sum(NPPN) TotPPN, SUm(NNet) TotNet, Sum(SubTotalRp) TotSubTotalRp, Sum(NDiskon*Kurs) TotDiskonRp,
	Sum(SubTotalRp)-Sum(NDiskon*Kurs) TotTotalRp, Sum(NDPPRp) TotDPPRp, Sum(NPPNRp) TotPPNRp, Sum(NNETRp) TotNetRp,
	SUM(Qnt) Qnt, SUM(Qnt2) Qnt2
From 	dbSODet
Group By NoBukti






GO

-- View: vwRPemakaianBrg
-- Created: 2011-09-30 13:32:18.460 | Modified: 2011-12-20 21:12:52.710
-- =====================================================

CREATE View [dbo].[vwRPemakaianBrg]
as

SELECT a.Nobukti,b.Tanggal, a.kodebrg,c.NAMABRG,b.Kodebag,d.NamaBag,c.KodeJnsBrg,b.KodeJnsPakai,
e.Keterangan,a.Hpp,a.NNet,
Case when b.JnsPakai=0 then 'Stock'
	  when b.JnsPakai=1 then 'Investasi'
	  when b.JnsPakai=2 then 'Rep & Pem Teknik'
	  when b.JnsPakai=3 then 'Rep & Pem Komputer'
	  when b.JnsPakai=4 then 'Rep & Pem Peralatan'
end MyJnsPakai,b.JnsPakai
,case when a.Nosat = 1 then a.Sat_1 else a.Sat_2 end as satuan,
case when a.Nosat = 1 then a.Qnt else a.Qnt2 end as QNT,
case when a.Nosat = 1 then a.Qnt * a.Hpp else a.Qnt2 * a.Hpp end as total
FROM DBRPenyerahanBrgDET a 
left outer join DBRPenyerahanBrg b on a.Nobukti = b.Nobukti
left outer join DBBARANG c on a.kodebrg = c.KODEBRG
left outer join DBBAGIAN d on b.Kodebag = d.KodeBag
left outer join DBJNSPAKAI e on b.KodeJnsPakai = e.KodeJNSPakai


GO

-- View: vwRpenerimaanbrg
-- Created: 2011-11-03 17:37:08.547 | Modified: 2011-12-20 19:49:06.590
-- =====================================================
CREATE View [dbo].[vwRpenerimaanbrg]
as

select  a.NOBUKTI,b.TANGGAL,b.KODECUSTSUPP, d.NAMACUSTSUPP,a.KODEBRG,c.NAMABRG,a.Nosat,a.QNT,a.QNT2,a.SAT_1,a.SAT_2,f.NOPPL,c.ISJASA,c.KodeJnsBrg,
        isnull(z.tipe,0) Tipe,
        case when a.nosat =1 then a.sat_1 else a.sat_2 end as satuan,a.nnet,a.PPN,
        case when a.Nosat = 1 then a.QNT else a.QNT2 end as quantity,a.harga,b.KODEVLS,b.KURS,
        case when a.Nosat = 1 then a.QNT *  a.HARGA else a.QNT2 * a.HARGA end as jumlah,
        case when a.Nosat =1 then (a.QNT * a.HARGA) * a.KURS else (a.QNT2 * a.HARGA) * a.KURS end as NilaiDPp,a.NPPN,
        case when a.Nosat =1 then ((a.QNT * a.HARGA) * a.KURS) + a.nppn else ((a.QNT2 * a.HARGA) * a.KURS) + a.PPN end as total
from DBRBELIDET a 
     left outer join DBRBELI b on a.NOBUKTI = b.NOBUKTI
     left outer join DBBARANG c on a.KODEBRG = c.KODEBRG
     left outer join vwBrowsSupp d on b.KODECUSTSUPP = d.KODECUSTSUPP
     left outer join dbpo z on z.NOBUKTI=a.NOPO
     LEFT OUTER JOIN (select NoPPL, NOBUKTI NOPO, URUT URutPO
                      from DBPODET 
                      GRoup by NoPPL, NOBUKTI, URUT) f on f.NOPO=a.NOPO and f.URutPO=a.URUTPO
GO

-- View: vwSatuanBrg
-- Created: 2012-12-17 12:03:34.377 | Modified: 2012-12-17 12:03:34.377
-- =====================================================

CREATE View [dbo].[vwSatuanBrg]
As
select A.KODEBRG, A.NAMABRG ,A.SAT1, A.ISI1,A.Sat2,A.Isi2,A.KODEGRP, E.NAMA NamaGrp
from dbBarang A
     left outer join DBGROUP E on E.KODEGRP=A.KODEGRP

GO

-- View: vwSOBelumLengkap
-- Created: 2012-12-17 11:54:27.380 | Modified: 2012-12-17 11:54:27.380
-- =====================================================
CREATE View [dbo].[vwSOBelumLengkap]
As

select distinct A.NoBukti
from dbSODet A
left outer join DBSPPDET C on C.NOSO=A.NOBukti and C.UrutSO=A.Urut
group by A.NoBukti, A.Urut, A.Qnt, A.Qnt2
having	A.Qnt-sum(isnull(C.Qnt,0))>0 or A.Qnt2-sum(isnull(C.Qnt2,0))>0

GO

-- View: vwSOBelumSuratJln
-- Created: 2012-12-17 12:00:04.717 | Modified: 2013-01-28 13:16:29.067
-- =====================================================



CREATE  View [dbo].[vwSOBelumSuratJln]
As

select 	B.Kota KodeKota, B.kota NamaKota, A.NoBukti, A.Tanggal, A.KodeCust, B.NamaCustsupp, A.NoAlamatKirim, F.Alamat AlamatKirim,
	A.Catatan, A.KodeGdg, A.INSGdg, A.INSBrg, Cast(0 as Bit)IsPPN,a.Jam, A.FlagTipe, a.IsLengkap
from 	dbSO A
left outer join dbCustsupp B on B.KodeCustsupp=A.KodeCust
left outer join (select distinct NOSO from DBSPPDET) D on D.NOSO=A.NOBUKTI
left outer join vwSOBelumLengkap E on E.NoBukti=A.NOBUKTI
left outer join vwAlamatCust F on F.KodeCustSupp=A.KodeCust and F.Nomor=A.NoAlamatKirim
--where 	D.NoBukti is null or isnull(E.NOBUKTI,'')<>''
where 	A.NoUrut<>'BONUS' and (D.NoSO is null or isnull(E.NOBUKTI,'')<>'') and
      Masaberlaku>=GETDATE()
group by  B.Kota, A.NoBukti, A.Tanggal, A.KodeCust, B.NamaCustsupp, A.NoAlamatKirim, 
         F.Alamat, A.Catatan, A.KodeGdg, A.INSGdg, A.INSBrg,a.Jam, A.FlagTipe, A.IsLengkap




GO

-- View: vwSOBelumSuratJlnDet
-- Created: 2012-12-17 12:03:42.190 | Modified: 2013-01-28 13:16:38.063
-- =====================================================



CREATE View [dbo].[vwSOBelumSuratJlnDet]
As

select 	C0.Kota KodeKota, C0.Kota NamaKota, A0.KodeGdg, A.NoBukti, A0.Tanggal, A.Urut, A.KODEBRG, D.NamaBrg, 
	A.QNT, A.QNT2, A.NOSAT, D.Sat1 Satuan, A.ISI, D.Sat2 SatuanRoll,
	(isnull(C.Qnt,0)) QntSJ, (isnull(C.Qnt2,0)) Qnt2SJ, A.IsCetakKitir
from dbSODet A
left outer join dbSO A0 on A0.NoBukti=A.NoBukti
left outer join dbCustSupp C0 on C0.KodeCustsupp=A0.KodeCust
left outer join (Select x.noso,x.urutso,sum(x.Qnt) qnt,Sum(x.Qnt2) qnt2
                 from dbSPPDet x
                 group by x.noso,x.urutso) C on C.NOSO=A.NoBukti and C.UrutSO=A.Urut
left outer join vwSatuanBrg D on D.KodeBrg=A.KodeBrg
where A0.NoUrut<>'BONUS' and (not ((A.Qnt2<>0 and (A.Qnt2<=(isnull(C.Qnt2,0)))) or (A.Qnt2=0 and (A.Qnt<=(isnull(C.Qnt,0)))))) and
A0.masaberlaku>=GETDATE()



GO

-- View: vwSPB
-- Created: 2012-01-11 14:09:03.090 | Modified: 2013-04-05 09:57:54.077
-- =====================================================

CREATE view [dbo].[vwSPB]
as

Select x.NoBukti NoSPB, x.Tanggal TglSPB, y.NoSPP, y.TglSPP, '' Noship, null TglShip, w.NoSC, w.TglSC,0 IsLokal,
       x.KodeCustSupp, x.ISFlag
from (Select x.NoBukti,y.Tanggal, x.NoSPP, y.KodeCustSupp, y.ISFlag
      From DBSPBDet x           
           left Outer join DBSPB y on y.NoBukti=x.NoBukti
      Group by x.NoBukti,y.Tanggal, x.NoSPP, y.KodeCustSupp, y.ISFlag) x 
     
     left Outer Join (Select x.NoBukti NoSPP, y.Tanggal TglSPP, x.NoSO
                     from DBSPPDet x
                          left outer join DBSPP y on y.NoBukti=x.NoBukti
                     Group by x.NoBukti,y.Tanggal, x.NoSO) y on y.NoSPP=x.NoSPP
    left Outer join (Select x.Nobukti NoSC, y.Tanggal TglSC
                     From DBSODET x
                          left Outer join DBSO y on y.Nobukti=x.Nobukti
                     Group by x.Nobukti,y.Tanggal) w on w.NoSC=y.NoSO

GO

-- View: vwSPK
-- Created: 2014-04-14 11:18:42.560 | Modified: 2014-04-14 11:18:42.560
-- =====================================================

Create View [dbo].[vwSPK]
as
select NOBUKTI,NoUrut,TANGGAL,KODEBRG,NoBatch,TglExpired,Qnt,Nosat,Satuan,Isi,KodeBOM from DBSPK       
Union All
select NoBukti,Case When LEN(Urut)=1 Then '000'+CONVERT(Varchar(1),Urut)
                    When LEN(Urut)=2 Then '00'+CONVERT(Varchar(2),Urut) 
                    When LEN(Urut)=3 Then '0'+CONVERT(Varchar(3),Urut) end
      ,Null,KODEBRG,'',Null,Qnt,NOSAT,SATUAN,ISI,KodeBOMDet             from DBSPKDET  
      where Isnull(KodeBOMDet,'')<>''  


GO

-- View: vwStock
-- Created: 2013-06-03 11:09:47.540 | Modified: 2013-06-03 11:09:47.540
-- =====================================================

CREATE View [dbo].[vwStock]
as
SELECT 'AWL' AS tipe, '00' Prioritas, b.Kodebrg, b.Kodegdg, 
       (b.qntAwal) AS QntDB, (b.Qnt2Awal) Qnt2DB, (b.HrgAwal) HrgDebet, 
       0.00 QntCr,  0.00 Qnt2Cr, 0.00 HrgKredit,
       (b.qntAwal) AS QntSaldo, (b.Qnt2Awal) Qnt2Saldo, (b.HrgAwal) HrgSaldo, 
       Dateadd(MM, 0, Cast(CASE WHEN b.Bulan < 10 THEN '0' ELSE '' END + Cast(b.Bulan AS varchar(2))+'-01-'+ 
                           Cast(b.Tahun AS varchar(4)) AS Datetime)) Tanggal, b.Bulan, b.Tahun, 'Saldo Awal' Nobukti,
      '' KodeCustSupp, '' Keterangan, '' IDUSER, B.HRGRATA, '' Ket, 'BHN' xCode
FROM  DBSTOCKBRG b
where b.QNTAWAL<>0 or b.QNT2AWAL<>0
UNION all
Select 	'BP' Tipe, '01' Prioritas, B.KodeBrg, B.kodegdg,
          Case when B.NOSAT=1 then  B.Qnt 
               when B.NOSAT=2 then  B.Qnt*B.ISI
               else 0
          end  QntDb, 
          Case when B.NOSAT=1 then  B.Qnt/B.ISI 
               when B.NOSAT=2 then  B.Qnt
               else 0
          end Qnt2Db, B.NDPPRp HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	Case when B.NOSAT=1 then  B.Qnt 
               when B.NOSAT=2 then  B.Qnt*B.ISI
               else 0
          end  QntSaldo, 
          Case when B.NOSAT=1 then  B.Qnt/B.ISI 
               when B.NOSAT=2 then  B.Qnt
               else 0
          end Qnt2Saldo, B.NDPPRp HrgSaldo,
	A.TANGGAL , month(A.TANGGAL) Bulan, year(A.TANGGAL) Tahun, A.NoBukti,
	A.KODESUPP, d.NAMACUSTSUPP Keterangan, '' IDUser,
	case when Case when B.Nosat=1 then B.QNT 
	               when B.Nosat=2 then B.QNT/B.ISI
	          end=0 then 0.00 
	    else B.NDPPRp/Case when B.Nosat=1 then B.QNT 
	                       when B.Nosat=2 then B.QNT*B.ISI
	                  end end HPP,d.NAMACUSTSUPP ket, 'BHN' xCode
from 	dbBeli A
left outer join dbBeliDet B on B.NoBukti=A.NoBukti
left outer join DBBARANG C on C.KODEBRG=B.KodeBrg
left outer join vwBrowsSupp d on d.KODECUSTSUPP=A.KODESUPP
union all
Select 	'RPB' Tipe, '10' Prioritas, B.KodeBrg, A.KODEGDG,
          0.00 QntDb, 0.00 Qnt2Db, 0.00 HrgDebet,
	Case when B.NOSAT=1 then  B.Qnt 
               when B.NOSAT=2 then  B.Qnt*B.ISI
               else 0
          end QntCr, 
          Case when B.NOSAT=1 then  B.Qnt/B.ISI 
               when B.NOSAT=2 then  B.Qnt
               else 0
          end Qnt2Cr, B.NDPPRp HrgKredit,
	-Case when B.NOSAT=1 then  B.Qnt 
               when B.NOSAT=2 then  B.Qnt*B.ISI
               else 0
          end QntSaldo, 
          -Case when B.NOSAT=1 then  B.Qnt/B.ISI 
               when B.NOSAT=2 then  B.Qnt
               else 0
          end Qnt2Saldo, -B.NDPPRp HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	A.KodeSupp, d.NAMACUSTSUPP Keterangan, '' IDUser,
	case when Case when B.Nosat=1 then B.QNT 
	               when B.Nosat=2 then B.QNT/B.ISI
	          end=0 then 0.00 
	    else B.NDPPRp/Case when B.Nosat=1 then B.QNT 
	                       when B.Nosat=2 then B.QNT*B.ISI 
	                  end end HPP,d.NAMACUSTSUPP Ket, 'BHN' xCode
from 	dbRBeli A
left outer join dbRBeliDet B on B.NoBukti=A.NoBukti
left outer join DBBARANG C on C.KODEBRG=B.KodeBrg
left outer join vwBrowsSupp d on a.KODESUPP = d.KODECUSTSUPP
union all
Select 	'BPPB' Tipe, '00' Prioritas, B.KodeBrg, A.KodeGdg, 
          0.00 QntDb, 0.00 Qnt2Db, (B.Qnt*B.HPP) HrgDebet,
	B.Qnt  QntCr, B.Qnt2 Qnt2Cr, (B.Qnt*B.HPP) HrgKredit,
	-B.Qnt QntSaldo, -B.Qnt2 Qnt2Saldo, -(B.Qnt*B.HPP) HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	'' KodeCustSupp, '' Keterangan, '' IDUser,
	B.HPP,'' Ket, 'BHN' xCode
from DBBPPBT A
left outer join DBBPPBTDET B on B.NoBukti=A.NoBukti
union all
Select 	'BPPBT' Tipe, '00' Prioritas, B.KodeBrg, A.KodeGdgT, 
          B.Qnt QntDb, B.Qnt2 Qnt2Db,(B.Qnt*B.HPP) HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	B.Qnt QntSaldo, B.Qnt2 Qnt2Saldo, (B.Qnt*B.HPP) HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	'' KodeCustSupp, '' Keterangan, '' IDUser,
	B.HPP,'' Ket, 'BHN' xCode
from DBBPPBT A
left outer join DBBPPBTDET B on B.NoBukti=A.NoBukti
union all
Select 'BPB' Tipe, '02' Prioritas, B.KodeBrg, A.KODEGDG, 
       0.00 QntDb, 0.00 Qnt2Db,0 HrgDebet,
       B.Qnt QntCr, B.Qnt2 Qnt2Cr, (B.Qnt*B.HPP) HrgKredit,
       -B.Qnt QntSaldo, -B.Qnt2 Qnt2Saldo, -(B.Qnt*B.HPP) HrgSaldo,
       A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
       '' KodeCustSupp, '' Keterangan,'' IDUser,
       B.HPP,'' Ket, 'BHN' xCode
from DBPenyerahanBhn A
left outer join DBPenyerahanBhnDET B on B.NoBukti=A.NoBukti
left Outer join DBBARANG E on E.KODEBRG=B.kodebrg
union all
Select 	'RBPB' Tipe, '02' Prioritas, B.KodeBrg,A.KODEGDG,
          B.Qnt QntDb, B.Qnt2 Qnt2Db,(B.Qnt*B.HPP) HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	B.Qnt QntSaldo, B.Qnt2 Qnt2Saldo, (B.Qnt*B.HPP) HrgSaldo,
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	'' KodeCustSupp, '' Keterangan, '' IDUser,
          B.HPP,'' Ket, 'BHN' xCode
from DBRPenyerahanBhn A
left outer join DBRPenyerahanBhnDET B on B.NoBukti=A.NoBukti
left Outer join DBBARANG E on E.KODEBRG=B.kodebrg
union all
Select 	'ADI' Tipe, '03' Prioritas, B.KodeBrg, A.kodegdg,
          Case when B.NOSAT=1 then  B.QNTDB 
               when B.NOSAT=2 then  B.QNTDB*B.ISI
               else 0
          end QntDb, 
          Case when B.NOSAT=1 then  B.QNTDB/B.ISI 
               when B.NOSAT=2 then  B.QNTDB
               else 0
          end Qnt2Db, 
          Case when B.NOSAT=1 then  B.QNTDB 
               when B.NOSAT=2 then  B.QNTDB*B.ISI
               else 0
          end*B.Harga HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	Case when B.NOSAT=1 then  B.QNTDB 
               when B.NOSAT=2 then  B.QNTDB*B.ISI
               else 0
          end QntSaldo, 
          Case when B.NOSAT=1 then  B.QNTDB/B.ISI 
               when B.NOSAT=2 then  B.QNTDB
               else 0
          end Qnt2Saldo, 
          Case when B.NOSAT=1 then  B.QNTDB 
               when B.NOSAT=2 then  B.QNTDB*B.ISI
               else 0
          end*B.Harga HrgSaldo, 
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	'' KodeCustSupp, '' Keterangan, '' IDUser,
	B.Harga HPP,'' Ket, 'BHN' xCode
from 	dbKoreksi A
left outer join dbKoreksiDet B on B.NoBukti=A.NoBukti
where 	B.QntDb<>0
union all
Select 	'ADO' Tipe, '11' Prioritas, B.KodeBrg,A.KodeGdg, 
          0.00 QntDb, 0.00 Qnt2Db, 0.00 HrgDebet,
	Case when B.NOSAT=1 then  B.QNTCR 
               when B.NOSAT=2 then  B.QNTCR*B.ISI
               else 0
          end QntCr, 
          Case when B.NOSAT=1 then  B.QNTCR/B.ISI 
               when B.NOSAT=2 then  B.QNTCR
               else 0
          end Qnt2Cr, B.QntCr*B.HPP HrgKredit,
	-Case when B.NOSAT=1 then  B.QNTCR 
               when B.NOSAT=2 then  B.QNTCR*B.ISI
               else 0
          end QntSaldo, 
          -Case when B.NOSAT=1 then  B.QNTCR/B.ISI 
               when B.NOSAT=2 then  B.QNTCR
               else 0
          end Qnt2Saldo,          
          -Case when B.NOSAT=1 then  B.QNTCR/B.ISI 
               when B.NOSAT=2 then  B.QNTCR
               else 0
          end*B.HPP HrgSaldo, 
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	'' KodeCustSupp, '' Keterangan, '' IDUser,
	B.HPP,'' Ket, 'BHN' xCode
from 	dbKoreksi A
left outer join dbKoreksiDet B on B.NoBukti=A.NoBukti
where 	B.QntCr<>0
union ALL
Select 	'PRD' Tipe, '03' Prioritas, B.KodeBrg, B.kodegdg,
          Case when B.NOSAT=1 then  B.QNT 
               when B.NOSAT=2 then  B.QNT*B.ISI
               else 0
          end QntDb, 
          Case when B.NOSAT=1 then  B.QNT/B.ISI 
               when B.NOSAT=2 then  B.QNT
               else 0
          end Qnt2Db, 
          Case when B.NOSAT=1 then  B.QNT/B.ISI  
               when B.NOSAT=2 then  B.QNT
               else 0
          end*isnull(c.HPPBrg,0) HrgDebet,
	0.00 QntCr, 0.00 Qnt2Cr, 0.00 HrgKredit,
	Case when B.NOSAT=1 then  B.QNT 
               when B.NOSAT=2 then  B.QNT*B.ISI
               else 0
          end QntSaldo, 
          Case when B.NOSAT=1 then  B.QNT/B.ISI 
               when B.NOSAT=2 then  B.QNT
               else 0
          end Qnt2Saldo, 
          Case when B.NOSAT=1 then  B.QNT/B.ISI  
               when B.NOSAT=2 then  B.QNT
               else 0
          end*isnull(C.HPPBrg,0) HrgSaldo, 
	A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
	'' KodeCustSupp, '' Keterangan, '' IDUser,
	isnull(c.HPPBrg,0) HPP,'' Ket, 'BHN' xCode
from 	DBHASILPRD A
left outer join DBHASILPRDDET B on B.NoBukti=A.NoBukti
left Outer join dbHPPProduksi C on C.KodeBrg=B.KODEBRG and C.Bulan=month(A.Tanggal) and c.Tahun=year(A.Tanggal)
where 	B.Qnt<>0
union All
Select 	'TRI' Tipe, '05' Prioritas, B.KodeBrg, B.GDGTUJUAN,
		B.QNT QNTDB, B.QNT2 QNT2DB,(B.QNT*B.HPP) HRGDEBET,
		0.00 QNTCR, 0.00 QNT2CR, 0.00 HRGKREDIT,
		B.QNT QNTSALDO, B.QNT2 QNT2SALDO, (B.QNT*B.HPP) HRGSALDO,
		A.TANGGAL, MONTH(A.TANGGAL) BULAN, YEAR(A.TANGGAL) TAHUN, A.NOBUKTI,
		A.IDUSER KODECUSTSUPP,A.IDUSER KETERANGAN, A.IDUSER,
		B.HPP,A.IDUSER KET, 'BHN' xCode
from DBTRANSFER A
left outer join DBTRANSFERDET B on B.NoBukti=A.NoBukti
union all
Select 	'TRO' Tipe, '13' Prioritas, B.KodeBrg, B.GDGASAL,
		0.00 QntDb, 0.00 Qnt2Db,0.00 HrgDebet,
		B.Qnt  QntCr, B.Qnt2 Qnt2Cr, (B.Qnt*B.HPP) HrgKredit,
		-B.Qnt QntSaldo, -B.Qnt2 Qnt2Saldo, -(B.Qnt*B.HPP) HrgSaldo,
		A.Tanggal, month(A.Tanggal) Bulan, year(A.Tanggal) Tahun, A.NoBukti,
		A.iduser KodeCustSupp, a.IDUser Keterangan, A.IDUser,
		B.HPP,a.IDUser Ket, 'BHN' xCode
from DBTRANSFER A
left outer join DBTRANSFERDET B on B.NoBukti=A.NoBukti
union All
Select 	'SPB' Tipe, '05' Prioritas, B.KodeBrg,B.Kodegdg,
		0.00 QNTDB, 0.00 QNT2DB,0.00 HRGDEBET,
		B.QNT QNTCR, B.QNT2 QNT2CR, (B.QNT*B.HPP) HRGKREDIT,
		-B.QNT QNTSALDO, -B.QNT2 QNT2SALDO, -(B.QNT*B.HPP) HRGSALDO,
		A.TANGGAL, MONTH(A.TANGGAL) BULAN, YEAR(A.TANGGAL) TAHUN, A.NOBUKTI,
		A.IDUSER KODECUSTSUPP,A.IDUSER KETERANGAN, A.IDUSER,
		B.HPP,D.NAMACUSTSUPP KET, 'BHN' xCode
from DBSPB A
left outer join dbSPBDet B on B.NoBukti=A.NoBukti
Left Outer join vwBrowsCust D on D.KODECUSTSUPP=A.KodeCustSupp
union all
Select 	'RSPB' Tipe, '05' Prioritas, B.KodeBrg,A.Kodegdg,
		B.QNT QNTDB, B.QNT2 QNT2DB,(B.QNT*B.HPP) HRGDEBET,
		0.00 QNTCR, 0.00 QNT2CR, 0.00 HRGKREDIT,
		B.QNT QNTSALDO, B.QNT2 QNT2SALDO, (B.QNT*B.HPP) HRGSALDO,
		A.TANGGAL, MONTH(A.TANGGAL) BULAN, YEAR(A.TANGGAL) TAHUN, A.NOBUKTI,
		A.IDUSER KODECUSTSUPP,A.IDUSER KETERANGAN, A.IDUSER,
		B.HPP,A.IDUSER KET, 'BHN' xCode
from DBRSPB A
left outer join DBRSPBDet B on B.NoBukti=A.NoBukti
union all
Select 	'RSPB' Tipe, '04' Prioritas, B.KodeBrg,B.Kodegdg,
		B.QNT QNTDB, B.QNT2 QNT2DB,(B.QNT*B.HPP) HRGDEBET,
		0.00 QNTCR, 0.00 QNT2CR, 0.00 HRGKREDIT,
		B.QNT QNTSALDO, B.QNT2 QNT2SALDO, (B.QNT*B.HPP) HRGSALDO,
		A.TANGGAL, MONTH(A.TANGGAL) BULAN, YEAR(A.TANGGAL) TAHUN, A.NOBUKTI,
		A.IDUSER KODECUSTSUPP,A.IDUSER KETERANGAN, A.IDUSER,
		B.HPP,A.IDUSER KET, 'BHN' xCode
from dbSPBRJual A
left outer join dbSPBRJualDet B on B.NoBukti=A.NoBukti
union All
Select 	'INVC' Tipe, '05' Prioritas, B.KodeBrg,C.KodeGdg,
		B.QNT QNTDB, B.QNT2 QNT2DB,(B.QNT*B.HPP) HRGDEBET,
		0.00 QNTCR, 0.00 QNT2CR, 0.00 HRGKREDIT,
		B.QNT QNTSALDO, B.QNT2 QNT2SALDO, (B.QNT*B.HPP ) HRGSALDO,
		A.TANGGAL, MONTH(A.TANGGAL) BULAN, YEAR(A.TANGGAL) TAHUN, A.NOBUKTI,
		A.KODECUSTSUPP,D.NAMACUSTSUPP KETERANGAN, '' IDUSER,
		B.HPP,'' KET, 'BHN' xCode
from DBInvoicePL A
left outer join dbInvoicePLDet B on B.NoBukti=A.NoBukti
left Outer join (Select Kodegdg, NoBukti,Urut 
                 from dbSPBDet 
                 Group by Kodegdg, NoBukti,Urut) C on C.NoBukti=B.NoSPB and C.Urut=B.UrutSPB
Left Outer join vwBrowsCust D on D.KODECUSTSUPP=A.KodeCustSupp
union all
Select 	'RINVC' Tipe, '05' Prioritas, B.KodeBrg,''KodeGdg,
		B.QNT QNTDB, B.QNT2 QNT2DB,(B.QNT*B.HPP) HRGDEBET,
		0.00 QNTCR, 0.00 QNT2CR, 0.00 HRGKREDIT,
		B.QNT QNTSALDO, B.QNT2 QNT2SALDO, (B.QNT*B.HPP ) HRGSALDO,
		A.TANGGAL, MONTH(A.TANGGAL) BULAN, YEAR(A.TANGGAL) TAHUN, A.NOBUKTI,
		A.KODECUSTSUPP,D.NAMACUSTSUPP KETERANGAN, '' IDUSER,
		B.HPP,'' KET, 'BHN' xCode
from DBInvoiceRPJ A
left outer join DBINVOICERPJDet B on B.NoBukti=A.NoBukti
Left Outer join vwBrowsCust D on D.KODECUSTSUPP=A.KodeCustSupp


GO

-- View: vwSubCost
-- Created: 2014-09-11 10:45:06.320 | Modified: 2014-11-10 09:31:16.043
-- =====================================================






CREATE View [dbo].[vwSubCost]
as

Select cast('KEND' as varchar(20)) KodeCost, 
	A.KODEKEND KodeSubCost,
	A.NAMAKEND NamaSubCost
from DBKENDARAAN A     

union all

Select cast('SALES' as varchar(20)) KodeCost, 
	cast(A.KeyNIK as varchar(20)) KodeSubCost,
	A.Nama NamaSubCost
from dbKaryawan A     
where KodeCost = 'SALES'





GO

-- View: vwSubJenis
-- Created: 2011-11-23 18:45:57.690 | Modified: 2011-11-23 22:20:52.767
-- =====================================================

CREATE View [dbo].[vwSubJenis]
as
Select A.*, B.Keterangan NamaJnsBrg,
       B.Keterangan+Case when B.Keterangan is null then '' else ' ('+B.KodeJnsBrg+')' end myJenis
from DBSUBJENIS A     
     left Outer join DBJenis B on B.KodeJnsBrg=A.KodeJnsBrg


GO

-- View: vwSubJenisJadi
-- Created: 2011-12-08 19:36:36.830 | Modified: 2011-12-08 19:36:36.830
-- =====================================================


CREATE View [dbo].[vwSubJenisJadi]
as
Select A.*       
from DBSUBJENISBRGJADI A     



GO

-- View: vwSubKategori
-- Created: 2011-11-23 18:45:57.643 | Modified: 2011-11-23 22:19:45.500
-- =====================================================

CREATE View [dbo].[vwSubKategori]
as
Select A.*,B.Keterangan NamaKategori,
       B.Keterangan+Case when B.Keterangan is null then '' else ' ('+B.KodeKategori+')' end myKategori
from DBSUBKATEGORI A     
     left Outer join DBKATEGORI B on B.KodeKategori=A.KodeKategori


GO

-- View: vwSubKategoriJadi
-- Created: 2011-12-08 19:36:36.863 | Modified: 2011-12-08 19:36:36.863
-- =====================================================


CREATE View [dbo].[vwSubKategoriJadi]
as
Select A.*
from DBSUBKATEGORIBRGJADI A



GO

-- View: vwSumberAktivitasUser
-- Created: 2011-06-01 13:55:38.677 | Modified: 2011-06-01 13:55:38.677
-- =====================================================




CREATE  View [dbo].[vwSumberAktivitasUser]
as
Select 1 Urutan, 'USR' KodeSumber, 'Pemakai' NamaSumber
union all Select 5 Urutan, 'GDG' KodeSumber, 'Gudang' NamaSumber
union all Select 8 Urutan, 'GRP' KodeSumber, 'Group Brg' NamaSumber
union all Select 10 Urutan, 'BRG' KodeSumber, 'Barang' NamaSumber
union all Select 13 Urutan, 'SUP' KodeSumber, 'Supplier' NamaSumber
union all Select 15 Urutan, 'ARE' KodeSumber, 'Area' NamaSumber
union all Select 17 Urutan, 'SSA' KodeSumber, 'Sub Area' NamaSumber
union all Select 30 Urutan, 'KOT' KodeSumber, 'Kota/ Kab.' NamaSumber
union all Select 33 Urutan, 'KEC' KodeSumber, 'Kecamatan' NamaSumber
union all Select 35 Urutan, 'DES' KodeSumber, 'Desa/ Kel.' NamaSumber
union all Select 40 Urutan, 'SLS' KodeSumber, 'Salesman' NamaSumber
union all Select 46 Urutan, 'JCU' KodeSumber, 'Jenis Cust' NamaSumber
union all Select 48 Urutan, 'LCU' KodeSumber, 'Lokasi Cust' NamaSumber
union all Select 50 Urutan, 'CUS' KodeSumber, 'Customer' NamaSumber
union all Select 60 Urutan, 'PO' KodeSumber, 'P.O' NamaSumber
union all Select 63 Urutan, 'PBL' KodeSumber, 'Pembelian' NamaSumber
union all Select 70 Urutan, 'RPB' KodeSumber, 'Retur Beli' NamaSumber
union all Select 80 Urutan, 'SO' KodeSumber, 'S.O' NamaSumber
union all Select 83 Urutan, 'PNJ' KodeSumber, 'Penjualan' NamaSumber
union all Select 86 Urutan, 'RPJ' KodeSumber, 'Retur Jual' NamaSumber
union all Select 88 Urutan, 'PT' KodeSumber, 'Lunas Piutang' NamaSumber
union all Select 90 Urutan, 'OPN' KodeSumber, 'Opname' NamaSumber
union all Select 93 Urutan, 'TRS' KodeSumber, 'Transfer Brg' NamaSumber
union all Select 96 Urutan, 'KMS' KodeSumber, 'U Kemas' NamaSumber
union all Select 100 Urutan, 'LN' KodeSumber, 'Lain-lain' NamaSumber
















GO

-- View: vwSumberJurnal
-- Created: 2014-10-01 09:10:32.290 | Modified: 2014-10-01 09:10:32.290
-- =====================================================



CREATE  View [dbo].[vwSumberJurnal]
as

select '010' MyUrut, 'PBL' JenisTrans, 'Pembelian' NamaTrans, 'DBBELI' NamaTabel
union all select '015' MyUrut, 'BPL' JenisTrans, 'Invoice Pembelian' NamaTrans, 'DBINVOICE' NamaTabel
union all select '020' MyUrut, 'RPB' JenisTrans, 'Retur Pembelian' NamaTrans, 'DBRBELI' NamaTabel
union all select	'030' MyUrut, 'DN' JenisTrans, 'Debet Note' NamaTrans, 'DBDEBETNOTE' NamaTabel
union all select	'040' MyUrut, 'SPB' JenisTrans, 'Surat Jalan' NamaTrans, 'DBSPB' NamaTabel
union all select	'045' MyUrut, 'RSPB' JenisTrans, 'Retur Surat Jalan' NamaTrans, 'DBSPB' NamaTabel
union all select	'050' MyUrut, 'INVC' JenisTrans, 'Invoice Penjualan' NamaTrans, 'DBINVOICEPL' NamaTabel
union all select	'060' MyUrut, 'SPR' JenisTrans, 'Retur Penjualan' NamaTrans, 'DBINVOICERPJ' NamaTabel
union all select	'065' MyUrut, 'RPJ' JenisTrans, 'Nota Retur Penjualan' NamaTrans, 'DBINVOICERPJ' NamaTabel
union all select	'070' MyUrut, 'KN' JenisTrans, 'Kredit Note' NamaTrans, 'DBKREDITNOTE' NamaTabel
union all select	'120' MyUrut, 'HPD' JenisTrans, 'Hasil Produksi' NamaTrans, 'DBHASILPRD' NamaTabel
union all select	'080' MyUrut, 'BP' JenisTrans, 'Pemakaian' NamaTrans, 'DBPENYERAHANBHN' NamaTabel
union all select	'090' MyUrut, 'RBP' JenisTrans, 'Retur Pemakaian' NamaTrans, 'DBRPENYERAHANBHN' NamaTabel
union all select	'110' MyUrut, 'KMS' JenisTrans, 'Ubah Kemasan' NamaTrans, 'DBUBAHKEMASAN' NamaTabel
union all select	'100' MyUrut, 'OPN' JenisTrans, 'Koreksi/ Opname' NamaTrans, 'DBKOREKSI' NamaTabel








GO

-- View: vwTransaksi
-- Created: 2014-10-01 09:46:46.430 | Modified: 2015-04-20 09:05:02.913
-- =====================================================



CREATE VIEW [dbo].[vwTransaksi]
AS
SELECT A.NOBUKTI, A.NOURUT, A.TANGGAL, B.DEVISI, A.NOTE, A.LAMPIRAN, 
	A.IsOtorisasi1, A.OtoUser1, A.TglOto1, A.IsOtorisasi2, A.OtoUser2, A.TglOto2, 
	A.IsOtorisasi3, A.OtoUser3, A.TglOto3, A.IsOtorisasi4, A.OtoUser4, A.TglOto4, 
    A.IsOtorisasi5, A.OtoUser5, A.TglOto5, A.MaxOL,
	B.URUT, B.PERKIRAAN, B.LAWAN, B.KETERANGAN, B.KETERANGAN2, B.DEBET, B.KREDIT, B.VALAS, B.KURS, B.DEBETRP, B.KREDITRP, 
    B.TIPETRANS, B.TPHC, B.CUSTSUPPP, B.CUSTSUPPL, B.KODEP, B.KODEL, 
    B.NOAKTIVAP, B.NOAKTIVAL, B.STATUSAKTIVAP, B.STATUSAKTIVAL, B.NOBON, B.KODEBAG, 
    B.STATUSGIRO, A.JENIS FlagJenis, B.TipeTrans Jenis, '' NoBuktiTrans, 'T' AsalTrans, B.KODECOST, B.KODESUBCOST   
FROM DBTRANS A 
LEFT OUTER JOIN DBTRANSAKSI B ON B.NOBUKTI = A.NOBUKTI
UNION ALL
Select A.NoBukti, A.NOURUT, A.Tanggal, A.Devisi, A.Note, A.Lampiran, 
	A.IsOtorisasi1, A.OtoUser1, A.TglOto1, A.IsOtorisasi2, A.OtoUser2, A.TglOto2, 
	A.IsOtorisasi3, A.OtoUser3, A.TglOto3, A.IsOtorisasi4, A.OtoUser4, A.TglOto4, 
    A.IsOtorisasi5, A.OtoUser5, A.TglOto5, A.MaxOL,
    A.Urut, A.Perkiraan, A.Lawan, A.Keterangan, A.Keterangan2, A.Debet, A.Kredit, A.Valas, A.Kurs, A.DebetRp, A.KreditRp, 
	A.TipeTrans, A.TPHC, A.CustSuppP, A.CustSuppL, A.KodeP, A.KodeL, 
	A.NoAktivaP, A.NoAktivaL, A.StatusAktivaP, A.StatusAktivaL, A.Nobon, A.KodeBag, 
	A.StatusGiro, '1' FlagJENIS, A.Jenis, A.NoBuktiTrans, 'O' AsalTrans, '' KodeCost, '' KodeSubCost
--From vwPostJurnalOto a
from DBJurnalOto A





GO

-- View: vwTransInvoice
-- Created: 2014-09-30 10:36:57.350 | Modified: 2015-04-21 15:22:56.833
-- =====================================================


CREATE View [dbo].[vwTransInvoice]
As

select A.NOBUKTI, A.NOURUT, A.TANGGAL, A.TglJatuhTempo, A.KODESUPP KODECUSTSUPP,
	Cs.NAMACUSTSUPP,
	Cs.ALAMATKOTA Alamat, Cs.ALAMATKOTA, Cs.KOTA, Cs.NamaKota, 
	A.NoPO, B.KodeGdg KodeGdg, G.NAMA NamaGdg, A.KETERANGAN, A.NOFAKTUR, 
	A.KODEVLS, A.KURS, A.PPN, A.TIPEBAYAR, A.HARI, A.TipeDisc, A.DISC, A.DISCRP, 
	A.IsBatal, A.UserBatal, A.TglBatal, 
	A.KodeExp, Ex.NAMACUSTSUPP NamaExp, Ex.ALAMATKOTA AlamatKotaExp, 
	A.CetakKe, A.IDUser,
	A.IsOtorisasi1, A.OtoUser1, A.TglOto1, 
	A.IsOtorisasi2, A.OtoUser2, A.TglOto2, 
	A.IsOtorisasi3, A.OtoUser3, A.TglOto3, 
	A.IsOtorisasi4, A.OtoUser4, A.TglOto4, 
	A.IsOtorisasi5, A.OtoUser5, A.TglOto5,
	Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                       Case when A.IsOtorisasi2=1 then 1 else 0 end+
                       Case when A.IsOtorisasi3=1 then 1 else 0 end+
                       Case when A.IsOtorisasi4=1 then 1 else 0 end+
                       Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                  else 1
             end As Bit) NeedOtorisasi, 
	A.NoJurnal, A.NoUrutJurnal, A.TglJurnal, A.MaxOL, 
	A.Flagtipe, A.TipePPN, A.NoInvoice, A.TglInvoice, A.NoFakturPajak, A.TglFakturPajak, A.NoBuktiPotong, A.TglBuktiPotong, 
	B.URUT, B.KODEBRG, Br.NAMABRG, isnull(B.NAMABRG,'') KetNamaBrg, 
	Br.NAMABRG+case when ISNULL(B.NamaBrg,'')='' then '' else CHAR(13)+B.NAMABRG end NamaBrgPlus,
	Br.NFix, B.QNT, B.NOSAT, B.SATUAN, B.SAT_1, B.SAT_2, B.ISI,
	Br.SAT1, Br.SAT2, Br.ISI1, Br.ISI2, 
	B.HARGA, B.DISCP, B.DISCTOT, B.BYANGKUT, 
	B.UrutPO, B.HPP, B.QntTerima, B.Qnt1Terima, B.Qnt2Terima, 
	B.HRGNETTO, B.NDISKON, B.SUBTOTAL, B.NDPP, B.NPPN, B.NNET,
	case when A.KODEVLS='IDR' then 0 else B.NDISKON end NDISKOND,
	case when A.KODEVLS='IDR' then 0 else B.SUBTOTAL end SUBTOTALD,
	case when A.KODEVLS='IDR' then 0 else B.NDPP end NDPPD,
	case when A.KODEVLS='IDR' then 0 else B.NPPN end NPPND,
	case when A.KODEVLS='IDR' then 0 else B.NNET end NNETD, 
	B.NDISKONRp, 
	B.SUBTOTALRp, B.NDPPRp, B.NPPNRp, B.NNETRp, B.NoBeli, B.UrutBeli, 
	B.KetReject, B.DiscP2, B.DiscP3, B.DiscP4, B.DiscP5,
	B.Qnt2Terima Qnt2, B.Qnt1Terima Qnt1,
	B.NoSPJ
from DBINVOICE A
left outer join DBInvoiceDET B on B.NOBUKTI=A.NOBUKTI
left outer join vwCUSTSUPP Cs on Cs.KODECUSTSUPP=A.KODESUPP
left outer join vwBarang Br on Br.KODEBRG=B.KodeBrg
left outer join vwCUSTSUPP Ex on Ex.KODECUSTSUPP=A.KodeExp
left outer join DBGUDANG G on G.KODEGDG=B.KodeGdg







GO

-- View: VwTransInvoiceRPJ
-- Created: 2014-09-24 13:32:30.643 | Modified: 2014-09-24 13:32:30.643
-- =====================================================
Create view VwTransInvoiceRPJ
as
select A.NoBukti, A.NoUrut, A.Tanggal, A.TglJatuhTempo, A.KODECUSTSUPP, Cs.NAMACUSTSUPP,
	Cs.ALAMAT Alamat, Cs.ALAMATKOTA, Cs.KOTA, Cs.NamaKota,
	A.NoInvoice, A.TglInvoice, A.NORPJ, A.KODEVLS, A.KURS, A.PPN, A.TIPEBAYAR, A.HARI, A.IDUser,
	A.Catatan, 
	A.IsOtorisasi1, A.OtoUser1, A.TglOto1, 
	A.IsOtorisasi2, A.OtoUser2, A.TglOto2, 
	A.IsOtorisasi3, A.OtoUser3, A.TglOto3, 
	A.IsOtorisasi4, A.OtoUser4, A.TglOto4, 
	A.IsOtorisasi5, A.OtoUser5, A.TglOto5,
	Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                       Case when A.IsOtorisasi2=1 then 1 else 0 end+
                       Case when A.IsOtorisasi3=1 then 1 else 0 end+
                       Case when A.IsOtorisasi4=1 then 1 else 0 end+
                       Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                  else 1
             end As Bit) NeedOtorisasi,   
	A.NoJurnal, A.NoUrutJurnal, A.TglJurnal, A.IsFlag, A.MaxOL,
	A.IsCetak, A.CetakKe, A.KodeSls, K.NAMA NamaSls, 
	A.IsBatal, A.UserBatal, A.TglBatal, A.Flagtipe, A.TipePPN,
	B.Urut, B.Kodebrg, Br.NAMABRG, B.NamaBrg NamaBrgKom,  B.NOSPR, B.UrutSPR, 
	B.SAT_1 Satuan, Br.SAT1, Br.SAT2, Br.NFix, 
	B.Qnt, B.Qnt2, B.Nosat, B.Isi, Br.ISI1, Br.ISI2, 
	B.Harga, B.DiscP, B.DiscRp, B.DISCTOT, B.HRGNETTO, 
	B.NDISKON, B.SUBTOTAL, B.NDPP, B.NPPN, B.NNET,
	case when A.KODEVLS='IDR' then 0 else B.NDISKON end NDISKOND,
	case when A.KODEVLS='IDR' then 0 else B.SUBTOTAL end SUBTOTALD,
	case when A.KODEVLS='IDR' then 0 else B.NDPP end NDPPD,
	case when A.KODEVLS='IDR' then 0 else B.NPPN end NPPND,
	case when A.KODEVLS='IDR' then 0 else B.NNET end NNETD, 
	 B.SUBTOTALRp, B.NDPPRp, B.NPPNRp, B.NNETRp, 
	B.Keterangan, B.UrutTrans, B.HPP, B.DiscP2, B.DiscP3, B.DiscP4, B.DiscP5
from DBINVOICERPJ A
left outer join DBINVOICERPJDet B on B.NoBukti=A.NoBukti
left outer join vwCUSTSUPP Cs on Cs.KODECUSTSUPP=A.KodeCustSupp
left outer join vwBarang Br on Br.KODEBRG=B.KodeBrg
left outer join dbKaryawan K on K.KeyNIK=A.KODESLS






--select * from DBINVOICERPJ
--alter table DBINVOICERPJ add catatan Varchar(200)
--alter table DBINVOICERPJ add iscetak Bit
--alter table DBINVOICERPJ add CetakKe INteger
--alter table DBINVOICERPJ add TipePPN Tinyint
--alter table dbinvoicerpjdet add NamaBrg varchar(200)


GO

-- View: vwTransSPBRJual
-- Created: 2014-09-24 09:35:19.397 | Modified: 2014-11-19 15:34:40.567
-- =====================================================



CREATE View [dbo].[vwTransSPBRJual]
As

select A.NoBukti, A.NoUrut, A.Tanggal, A.NoRPJ, A.NoSO, A.KodeCustSupp, Cs.NAMACUSTSUPP,
	Cs.ALAMATKOTA Alamat, Cs.ALAMATKOTA, Cs.KOTA, Cs.NamaKota,
	A.NoPolKend, A.Container, A.NoContainer, A.NoSeal, A.Sopir, A.Catatan, 
	A.IsCetak, A.CetakKe, A.IDUser, A.IsClose, A.IsFlag, 
	A.IsOtorisasi1, A.OtoUser1, A.TglOto1, 
	A.IsOtorisasi2, A.OtoUser2, A.TglOto2, 
	A.IsOtorisasi3, A.OtoUser3, A.TglOto3, 
	A.IsOtorisasi4, A.OtoUser4, A.TglOto4, 
	A.IsOtorisasi5, A.OtoUser5, A.TglOto5,
	Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                       Case when A.IsOtorisasi2=1 then 1 else 0 end+
                       Case when A.IsOtorisasi3=1 then 1 else 0 end+
                       Case when A.IsOtorisasi4=1 then 1 else 0 end+
                       Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                  else 1
             end As Bit) NeedOtorisasi, 
	A.NoJurnal, A.NoUrutJurnal, A.TglJurnal, A.MaxOL, 
	A.IsBatal, A.UserBatal, A.TglBatal, A.FlagTipe, A.TipePPN,
	B.Urut, B.Noinv, B.UrutInv, B.KodeBrg, Br.NAMABRG, B.Namabrg NamaBrgKom, Br.NFix, 
	B.QNT, B.QNT1, B.QNT2, B.SAT_1 Satuan, B.SAT_1, B.SAT_2, Br.SAT1, Br.SAT2, B.NOSAT, B.ISI, Br.ISI1, Br.ISI2, 
	B.NetW, B.GrossW, B.HPP, B.KodeGdg, G.NAMA NamaGdg, B.HPP*B.QNT1 NilaiHPP,A.Kodegdg KodeGdgHD,H.NAMA NamaGDGHD
	,B.Nobatch
from dbSPBRJual A
left outer join dbSPBRJualDet B on B.NoBukti=A.NoBukti
left outer join vwCUSTSUPP Cs on Cs.KODECUSTSUPP=A.KodeCustSupp
left outer join vwBarang Br on Br.KODEBRG=B.KodeBrg
left outer join DBGUDANG G on G.KODEGDG=B.KodeGdg
Left Outer Join DBGUDANG H on A.KodeGdg=H.KODEGDG





GO

-- View: vwValas
-- Created: 2011-12-08 20:45:04.003 | Modified: 2011-12-08 20:45:04.003
-- =====================================================
Create View dbo.vwValas
as
Select A.KODEVLS,A.NAMAVLS,A.Simbol,B.Tanggal,B.Kurs 
from dbVALAS A
     left Outer join DBVALASDET B on B.Kodevls=A.KODEVLS
GO

-- View: VwVerifikasi
-- Created: 2011-06-16 14:40:19.047 | Modified: 2011-06-16 14:40:19.047
-- =====================================================
CREATE VIEW dbo.VwVerifikasi
AS
SELECT     NOBUKTI AS noBP, TANGGAL AS tglbp, NOSPB, TGLSPB, KODECUSTSUPP
FROM         dbo.DBBELI AS a

GO

-- View: VwReportBeliGudang
-- Created: 2013-06-03 12:53:21.013 | Modified: 2015-03-09 15:28:01.013
-- =====================================================





CREATE  View [dbo].[VwReportBeliGudang]
as
Select 	A.NoBukti,A.TANGGAL, B.NoPO, B.UrutPO,A.KODESUPP KodeCustSupp,I.NAMACUSTSUPP,
	    B.Urut, B.KodeBrg, H.NamaBrg,b.QNT as qntbeli,b.SATUAN as satbeli,
	    isnull(B.Qnt1Terima,0) as qnt, h.SAT1 as satuan,
        isnull(b.Qnt2Terima,0) as Qnt2,h.SAT2 As satuan2,
        B.Qnt1Reject as qntreject,
        B.Qnt2Reject as qnt2reject,
        B.Harga, B.HrgNetto,B.DiscP,B.DiscTot,
        case when a.kodevls<>'IDR' then B.NDPP else 0 end as NDPP
        ,B.NDPPRp,b.NPPNRp,b.NNETRp,
        B.KodeGdg,A.KODEVLS,A.KURS,A.FAKTURSUPP,
        Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi,J.NAMA NamaGdg
From dbBeliDet B 
Left Outer Join dbBeli A On A.NoBukti=b.NoBukti
Left Outer Join dbBarang H on H.KodeBrg=B.KodeBrg
Left Outer Join DBCUSTSUPP I on A.KODESUPP = I.KODECUSTSUPP
left outer join DBGUDANG J on B.KodeGdg=J.KODEGDG






GO

-- View: VwreportBeliReject
-- Created: 2013-05-13 12:08:51.920 | Modified: 2013-05-13 12:08:51.920
-- =====================================================
CREATE View [dbo].[VwreportBeliReject]
as
Select 	A.NoBukti,A.TANGGAL, B.NoPO, B.UrutPO,A.KODESUPP,I.KODECUSTSUPP,I.NAMACUSTSUPP,
	B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt, B.NoSat, B.Isi, B.Satuan,
        0.00 Qnt2, '' SatuanRoll, B.Harga, B.HrgNetto,
        B.DiscP DiscP1, B.DiscTot DiscRp1,B.DiscTot,
        B.SubTotal TotalUSD, B.SubTotal TotalIDR, B.NDPP NDPP,
        B.NPPN NPPN, B.BYAngkut Beban, B.SubTotal + B.BYAngkut Total, B.KodeGdg
From dbBeliDet B 
Left Outer Join dbBeli A On A.NoBukti=b.NoBukti
Left Outer Join dbBarang H on H.KodeBrg=B.KodeBrg
Left Outer join DBCUSTSUPP I on A.KODESUPP = I.KODECUSTSUPP


GO

-- View: VwreportBP
-- Created: 2013-06-10 11:04:36.080 | Modified: 2013-06-10 11:04:36.080
-- =====================================================



CREATE View [dbo].[VwreportBP]
as
Select 	A.NoBukti,A.NoBPPB,
	B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt, B.NoSat, B.Isi Isi, B.Sat Satuan, B.Qnt*B.HPP NilaiHPP, A.Tanggal,
	Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi 
From dbPenyerahanBhn A
Left Outer join  dbPenyerahanBhnDet B on B.NoBukti=a.NoBukti
Left Outer join dbBarang H on H.KodeBrg=b.KodeBrg





GO

-- View: VwReportBPPBKeluar
-- Created: 2013-01-21 13:28:27.293 | Modified: 2013-01-21 13:28:27.293
-- =====================================================

Create View [dbo].[VwReportBPPBKeluar]
as

Select 	A.KodeGdgT,A.NoBukti, A.Tanggal, A.KdDep, C.NmDep,Qnt QMinta,Qnt2 QKirim,B.KodeBrg,D.NamaBrg,Nosat,Satuan
From dbBPPB A
Left Outer Join dbBPPBdet B On A.NoBukti=B.NoBukti
Left Outer Join dbBarang D On B.Kodebrg=D.Kodebrg
Left Outer Join dbDEPART C on c.KdDEP=a.KdDEP
GO

-- View: vwReportDaftarHarga
-- Created: 2011-11-04 09:16:21.633 | Modified: 2011-11-04 09:16:21.633
-- =====================================================

CREATE View [dbo].[vwReportDaftarHarga]
as
Select X.KODEBRG,X.NAMABRG, MAX(X.Bln1) Bln1, MAX(X.Bln2) Bln2, MAX(X.Bln3) Bln3, MAX(X.Bln4) Bln4, MAX(X.Bln5) Bln5, MAX(X.Bln6) Bln6,
       MAX(X.Bln7) Bln7, MAX(X.Bln8) Bln8, MAX(X.Bln9) Bln9, MAX(X.Bln10) Bln10, MAX(X.Bln11) Bln11, MAX(X.Bln12) Bln12,
       X.Tahun, X.SAT_1
From (
	select b.KODEBRG, C.NAMABRG,YEAR(a.tanggal) Tahun,B.SAT_1,
			 Case when month(a.tanggal)= 1 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln1,
			 Case when month(a.tanggal)= 2 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln2,
			 Case when month(a.tanggal)= 3 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln3,
			 Case when month(a.tanggal)= 4 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln4,
			 Case when month(a.tanggal)= 5 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln5,
			 Case when month(a.tanggal)= 6 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln6,
			 Case when month(a.tanggal)= 7 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln7,
			 Case when month(a.tanggal)= 8 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln8,
			 Case when month(a.tanggal)= 9 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln9,
			 Case when month(a.tanggal)= 10 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln10,
			 Case when month(a.tanggal)= 11 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln11,
			 Case when month(a.tanggal)= 12 then Case when SUM(b.qnt)<>0 then SUM(b.NDPPRp)/SUM(b.QNT) else 0 end
					else 0
			 end Bln12       
	From DBPO a
		  left outer join DBPODET b on b.NOBUKTI=a.NOBUKTI
		  left outer join DBBARANG C on C.KODEBRG=b.KODEBRG    
	group by b.KODEBRG,C.NAMABRG,month(a.tanggal),YEAR(a.tanggal), B.SAT_1)X
	
	group by  X.KODEBRG,X.NAMABRG,x.Tahun,X.SAT_1
	

GO

-- View: VwreportDebetNotte
-- Created: 2013-06-03 13:57:48.763 | Modified: 2013-06-03 13:57:48.763
-- =====================================================


CREATE View [dbo].[VwreportDebetNotte]
as
Select  a.NoBukti,x.tanggal,z.kodecustsupp,z.NAMACUSTSUPP, a.NoInv,a.KodeVLS,a.Kurs,
    Isnull(a.nilai,0) NDPP,Isnull(a.nilairp,0) NDPPRP,a.Keterangan,
      Cast(Case when Case when X.IsOtorisasi1=1 then 1 else 0 end+
                      Case when X.IsOtorisasi2=1 then 1 else 0 end+
                      Case when X.IsOtorisasi3=1 then 1 else 0 end+
                      Case when X.IsOtorisasi4=1 then 1 else 0 end+
                      Case when X.IsOtorisasi5=1 then 1 else 0 end=X.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi
	From  dbDebetNoteDet a
	left Outer join DBDebetNote x on a.NOBUKTI = x.NOBUKTI
	Left Outer Join DBCUSTSUPP z on x.KodeSupp = z.KODECUSTSUPP





GO

-- View: VwreportHasilPrd
-- Created: 2013-06-10 11:35:47.127 | Modified: 2013-06-24 16:39:04.360
-- =====================================================




CREATE View [dbo].[VwreportHasilPrd]
as 
Select A.nobukti,A.tanggal,A.keterangan,B.urut,B.Kodebrg,B.Qnt,B.Satuan,B.isi,B.Nospk,B.HPP*b.QNT*B.ISI as HPP,C.NamaBrg,
       Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi 
From  dbHasilPrd A
Left Outer join DbHasilPRDDet B on a.nobukti = B.nobukti
Left Outer Join dbBarang C on C.KodeBrg=B.KodeBrg





GO

-- View: VwreportHasilPrdACC
-- Created: 2013-06-24 10:36:50.257 | Modified: 2013-06-24 16:38:39.693
-- =====================================================






CREATE View [dbo].[VwreportHasilPrdACC]
as 
Select A.nobukti,A.tanggal,A.keterangan,B.urut,B.Kodebrg,B.Qnt,B.Satuan,B.isi,B.Nospk,
       B.HPP*B.QNT*B.ISI as HPP,C.NamaBrg,
       Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi 
From  dbHasilPrd A
Left Outer join DbHasilPRDDet B on a.nobukti = B.nobukti
Left Outer Join dbBarang C on C.KodeBrg=B.KodeBrg








GO

-- View: VwreportInvoice
-- Created: 2013-06-03 13:50:49.020 | Modified: 2015-03-09 15:28:00.940
-- =====================================================


CREATE View  [dbo].[VwreportInvoice]
as


Select  a.NoBukti,c.kurs,c.kodevls,b.NoBukti NoBeli ,b.kodebrg,b.qnt,b.SATUAN,
		e.namabrg,b.harga,B.DISCTOT,case when c.kodevls<>'IDR' then NDPPVLS else 0 end as NDPPVLS,
		B.NDPP,B.NPPN,B.NNET,C.KodeSupp KodeCustSupp,D.NAMACUSTSUPP,C.TANGGAL,
		Cast(Case when Case when C.IsOtorisasi1=1 then 1 else 0 end+
                      Case when C.IsOtorisasi2=1 then 1 else 0 end+
                      Case when C.IsOtorisasi3=1 then 1 else 0 end+
                      Case when C.IsOtorisasi4=1 then 1 else 0 end+
                      Case when C.IsOtorisasi5=1 then 1 else 0 end=C.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi
From  dbInvoiceDet a
Left Outer Join (select a.NoBukti,b.kodebrg,sum(b.qnt) qnt,b.satuan,b.harga,b.disctot, sum(ndpp) ndppvls,Sum(NDPPrp)NDPP,Sum(NPPNrp)NPPN,Sum(NNETrp)NNET 
from dbBeli a Left Outer Join dbBeliDet b On a.NoBukti=b.noBukti Group by a.NoBukti,b.KODEBRG,b.SATUAN,b.HARGA,b.DISCTOT)b On a.NoBeli=b.NoBukti
Left Outer join DBInvoice C on A.NOBUKTI = C.NOBUKTI 
Left Outer Join dbCustSupp D On C.KodeSupp=D.KodeCustSupp
left Outer Join DBBARANG E on E.KODEBRG=b.KODEBRG






GO

-- View: VwReportInvoicePembelian
-- Created: 2013-01-07 10:14:35.767 | Modified: 2013-01-07 10:14:35.767
-- =====================================================

Create View [dbo].[VwReportInvoicePembelian]
as

Select  a.NoBukti,b.NoBukti NoBeli ,NDPP,NPPN,NNET
From  dbInvoiceDet a
Left Outer Join (select a.NoBukti,Sum(NDPP)NDPP,Sum(NPPN)NPPN,Sum(NNET)NNET from dbBeli a Left Outer Join dbBeliDet b On a.NoBukti=b.noBukti Group by a.NoBukti)b On a.NoBeli=b.NoBukti
GO

-- View: VwreportInvoicePenjualan
-- Created: 2013-06-03 14:13:11.053 | Modified: 2013-06-03 14:13:11.053
-- =====================================================





CREATE View [dbo].[VwreportInvoicePenjualan]
as
select 	B.NoBukti, B.Urut, B.NoSPB, B.UrutSPB, B.KodeBrg, C.NAMABRG,x.Tanggal tglSPB,B.NoSPP,
        a.KURS,a.Valas,z.kodesls,p.nama,
        case when b.NOSAT=1 then B.QNT else B.QNT2 end as qnt,
        case when b.NOSAT=1 then B.SAT_1 else B.SAT_2 end as satuan,
        B.HARGA, B.DiscP, B.DISCTOT, B.NDPP,B.NDPPRp,B.NPPNRp, B.NNETRp, B.KetDetail,
        A.Tanggal,A.KodeCustSupp,D.NAMACUSTSUPP,   
		Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
		Case when A.IsOtorisasi2=1 then 1 else 0 end+
		Case when A.IsOtorisasi3=1 then 1 else 0 end+
		Case when A.IsOtorisasi4=1 then 1 else 0 end+
		Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
		else 1
		end As Bit) Needotorisasi
from	dbInvoicePLDet B
left outer join dbBarang C on C.KodeBrg=B.KodeBrg
left outer join DBInvoicePL A on B.NoBukti = A.NoBukti
Left outer join DBCUSTSUPP D on A.KodeCustSupp = D.KODECUSTSUPP
left outer join dbSPB X on B.NoSPB = X.NoBukti
left outer join dbSPP y on y.NoBukti=x.NoSPP
left outer join DBSO z on z.NOBUKTI=y.NoSHIP
left outer join dbKaryawan p on p.KeyNIK=z.KODESLS




GO

-- View: VwReportInVoiceRPembelian
-- Created: 2013-01-07 10:14:56.083 | Modified: 2013-01-07 10:14:56.083
-- =====================================================

Create view [dbo].[VwReportInVoiceRPembelian]
as
Select 	B.NoBukti, B.UrutPBL,
	B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt, B.NoSat, B.Isi, B.Satuan,
        0.00 Qnt2, '' SatuanRoll, B.Harga,
        B.DiscP DiscP1, B.DiscTot DiscRp1, B.DiscTot,
        B.SubTotal TotalUSD, B.SubTotal TotalIDR, B.NDPP NDPP,
        B.NPPN NPPN, B.BYAngkut Beban, B.SubTotal + B.BYAngkut Total
From dbRBeliDet B
Left Outer Join dbBarang H on H.KodeBrg=B.KodeBrg 
GO

-- View: VwReportJual
-- Created: 2012-11-01 12:56:54.733 | Modified: 2012-11-01 12:56:54.733
-- =====================================================

CREATE view [dbo].[VwReportJual]
as
Select 	A.NoBukti+right('00000000'+cast(A.Urut as varchar(8)),8) KeyNoBukti,
        A.*, C.NamaCustSupp, T.Nama NamaTipe, ST.Nama NamaSubTipe,
        cast(left(A.NoBukti,2) as varchar(50)) Left2NoBukti
From dbPenjualan A
Left Outer Join DBCUSTSUPP C on C.KODECUSTSUPP=A.KodeCustSupp
Left Outer Join DBTIPETRANS T on T.KODETIPE=A.KodeTipe
Left Outer Join DBSUBTIPETRANS ST on ST.KODETIPE=A.KodeTipe and ST.KODESUBTIPE=A.KodeSubTipe


GO

-- View: VwreportOpnameBahan
-- Created: 2013-06-03 14:32:58.230 | Modified: 2013-06-03 14:32:58.230
-- =====================================================



CREATE View [dbo].[VwreportOpnameBahan]
as
Select * from vwdetailKoreksi Where noBukti Like '%OPN%'




GO

-- View: VwreportOPnamebarang
-- Created: 2013-06-03 14:33:33.750 | Modified: 2013-06-03 14:33:33.750
-- =====================================================



CREATE View [dbo].[VwreportOPnamebarang]
as
Select * from vwdetailKoreksi Where noBukti Like '%OPBJ%'--'OPN%'



GO

-- View: vwreportoutSO
-- Created: 2013-05-13 12:08:51.610 | Modified: 2013-05-13 12:08:51.610
-- =====================================================



Create View [dbo].[vwreportoutSO]
as
Select  A.NoBukti+right('00000'+cast(A.Urut as varchar(5)),5) KeyNoBukti, A.Nobukti, 
P.Tanggal, P.Kodecust KodeCustSupp, S.NamaCust NamaCustSupp,
A.urut, A.kodebrg, B.NamaBrg, A.Satuan, A.Isi,
A.Qnt, A.Qnt2, A.QntSPP, A.Qnt2SPP,
A.QntSisa, A.Qnt2Sisa,P.MasaBerlaku,P.NoPesanan,P.TglKirim,P.TGLJATUHTEMPO
From    vwBrowsOutSO_SPP A
Left Outer Join DBSO P on P.NoBukti=A.NoBukti
Left Outer Join vwBrowsCustomer S on S.KodeCust=P.KodeCust and S.Sales=P.KODESLS
Left Outer Join dbBarang B on B.KodeBrg=A.KodeBrg
where A.islengkap=0


GO

-- View: VwreportOutSPB
-- Created: 2013-05-13 12:08:51.567 | Modified: 2015-03-11 09:53:07.077
-- =====================================================





CREATE View [dbo].[VwreportOutSPB] 
as
Select A.*,B.NAMABRG NamaBarang,C.Tanggal,C.kodeCustSupp,D.NAMACUSTSUPP,
           A.Nobukti+Cast(A.Urut as varchar(5)) MyKey,Z.NOBUKTI Noso,Z.TANGGAL TanggalSO
from dbSPBDet A
     left outer join DBBARANG B on B.KODEBRG=A.Kodebrg
     Left Outer join dbSPB C on A.NoBukti = C.NoBukti
     Left Outer join DBCUSTSUPP D on c.KodeCustSupp = D.KODECUSTSUPP
     Left Outer join (Select x.NoBukti, x.NoSPP
                      from dbSPBDet x
                      group by x.NoBukti, x.NoSPP) y on y.NoBukti=C.NoBukti
     Left Outer Join (Select x.NoBukti, x.Tanggal,y.NoSO, x.TglKirim
                      from DBSPP x 
                        left outer join dbSPPDet y on y.NoBukti=x.NoBukti
                      Group by x.NoBukti, x.Tanggal,y.NoSO, x.TglKirim) v On v.NoBukti=y.NoSPP 
    left outer join DBSO Z on Z.NOBUKTI=v.NoSO
     






GO

-- View: VwreportOUtSPK
-- Created: 2013-06-03 16:32:27.753 | Modified: 2013-06-03 16:32:27.753
-- =====================================================

Create View [dbo].[VwreportOUtSPK]
as

select a.NOBUKTI ,E.TANGGAL, a.Kodebrg, d.NAMABRG, a.Qnt QntBPPB,
sum(case when a.NOSAT=1 then isnull(b.Qnt,0) else b.Qnt2 end) QntBP,
a.QNT-sum(case when a.NOSAT=1 then isnull(b.Qnt,0) else b.Qnt2 end) Sisa
from DBSPKDET a
left outer join DBPenyerahanBhnDET b on b.NoSPK=a.NOBUKTI and b.UrutSPK=a.URUT 
--left Outer Join (select Kodebrg,SUM(Qnt*isi)Qnt from DBPenyerahanBhnDET group by kodebrg)b On b.kodebrg=a.KodeBrg 
--left Outer Join (select Kodebrg,SUM(SALDOQNT)Qnt from DBSTOCKBRG group by kodebrg )c On c.kodebrg=a.KodeBrg
Left Outer Join DBBARANG d On a.KODEBRG=d.kodebrg 
Left outer Join DBSPK E on A.NOBUKTI = E.NOBUKTI
group by a.NOBUKTI, a.Urut, a.KodeBrg, a.Qnt, a.Isi, d.NAMABRG, E.TANGGAL
having a.QNT-sum(case when a.NOSAT=1 then isnull(b.Qnt,0) else b.Qnt2 end)>0


GO

-- View: VwReportOutSPP
-- Created: 2013-05-13 12:08:51.577 | Modified: 2015-03-11 09:53:07.110
-- =====================================================



CREATE View [dbo].[VwReportOutSPP] 
as
Select  A.NoBukti+right('00000'+cast(A.Urut as varchar(5)),5) KeyNoBukti, A.Nobukti, P.Tanggal, P.KodeCustSupp, S.Namacust NamaCustSupp,
        A.urut, A.kodebrg, B.NamaBrg, '' Jns_Kertas, '' Ukr_Kertas, A.Sat_1, A.Sat_2, A.Isi,
        Case when A.NoSat=1 then A.Qnt
             when A.NoSat=2 then A.Qnt2
             else 0
        end Qnt, A.Qnt2,
        Case when A.NoSat=1 then A.QntSPB
             when A.NoSat=2 then A.Qnt2SPB
             else 0
        end QntSPB, A.Qnt2SPB,
        Case when A.NoSat=1 then A.QntSisa
             when A.NoSat=2 then A.Qnt2Sisa
             else 0
        end QntSisa, A.Qnt2Sisa,
        Case when A.NOSAT=1 then A.SAT_1
             when A.NOSAT=2 then A.SAT_2
             else ''
        end Satuan, P.Tglkirim,
        P.NoPesan
From    vwBrowsOutSPP A
Left Outer Join dbSPP P on P.NoBukti=A.NoBukti
left Outer join DBSO SO on SO.NOBUKTI=A.noso
Left Outer Join vwBrowsCustomer S on S.KodeCust=P.KodeCustSupp and s.Sales=SO.KODESLS
Left Outer Join dbBarang B on B.KodeBrg=A.KodeBrg
where A.isclose=0 

GO

-- View: VwReportOutStandingBPPB
-- Created: 2013-01-21 13:25:23.927 | Modified: 2013-01-21 13:25:23.927
-- =====================================================
CREATE View [dbo].[VwReportOutStandingBPPB]
as

Select  a.NoBukti,Tanggal,b.KodeBrg,c.NamaBrg,Qnt,Qnt2,A.KodeGdg,A.KodeGdgT
From dbBPPB a Left Outer Join dbBPPBDet b On a.NoBukti=b.NoBukti
left Outer Join dbBarang c On c.KodeBrg=b.KodeBrg
where Qnt<>Qnt2

GO

-- View: VwReportOutStandingPO
-- Created: 2013-01-07 10:15:07.063 | Modified: 2013-01-07 10:15:07.063
-- =====================================================
CREATE View [dbo].[VwReportOutStandingPO]
as
Select 	A.*, H.NamaBrg,I.TANGGAL,I.KODESUPP KOdeCustSupp,J.NAMACUSTSUPP
From vwOutstandingPO A
Left Outer Join dbBarang H on H.KodeBrg=A.KodeBrg
Left Outer Join DBPO I on A.NoBukti = I.NOBUKTI
left Outer Join DBCUSTSUPP J on I.KODESUPP = J.KODECUSTSUPP
GO

-- View: VwReportOutStandingPR
-- Created: 2013-01-07 10:15:22.863 | Modified: 2013-01-07 10:15:22.863
-- =====================================================
CREATE View [dbo].[VwReportOutStandingPR]
as
select A1.Nobukti,A1.Tanggal,a.kodebrg,C.KODESUPP KOdeCustSupp,D.NAMACUSTSUPP, a.Sat,c.NAMABRG,SUM(a.Qnt*isi)QntPPL,Isnull(b.Qnt,0) QntPO,SUM(a.Qnt*isi)-Isnull(b.Qnt,0)sisa from DBPPLDET a
Left Outer Join (select NoPPL,Kodebrg,SUM(Qnt*isi)Qnt from DBPODET  group by NoPPL,Kodebrg)b On a.Nobukti=b.NoPPL and a.kodebrg=b.KODEBRG
left Outer Join DBBARANG c On c.KODEBRG=a.kodebrg
Left Outer Join dbPPL A1 On A1.NoBukti=A.NoBukti 
Left Outer Join DBCUSTSUPP D on C.KODESUPP=D.KODECUSTSUPP
where Case when Isnull(A1.IsClose,0)=0 Then Isnull(A.IsClose,0)else Isnull(A1.IsClose,0) end=0
group by a.kodebrg,a.Sat,b.Qnt,c.NAMABRG,A1.Nobukti,A1.Tanggal,C.KODESUPP,D.NAMACUSTSUPP
having SUM(a.Qnt*isi)-Isnull(b.Qnt,0)<>0
GO

-- View: VwReportOutStandingSO
-- Created: 2013-01-18 16:31:30.357 | Modified: 2015-03-11 09:53:07.133
-- =====================================================


CREATE View [dbo].[VwReportOutStandingSO]
as
select  A.NoBukti, A.Urut, A.NoBukti+right('000000'+cast(A.Urut as varchar(6)),6) KeyUrut,
        A.KODEBRG, A.NamaBrg, A.QNT, A.QNT2, A.NOSAT, A.Satuan, A.ISI, A.QntSJ, A.Qnt2SJ, A.SatuanRoll,
        A.QNT-A.QntSJ QntSisa, A.QNT2-A.QNT2SJ Qnt2Sisa,
        C.KODECUSTSUPP,C.NAMACUSTSUPP,A.Tanggal,B.MasaBerlaku,B.NoPesanan,
        A.QNT2SJ Qnt2Spp,A.QntSJ QntSpp,B.TglKirim
--select * 
from    vwSOBelumSuratJlnDet A 
Left Outer Join  DBSO B on A.NoBukti = B.NOBUKTI
Left Outer Join DBCUSTSUPP C on B.KODECUST = C.KODECUSTSUPP



GO

-- View: VwReportOutstandingSO2
-- Created: 2013-01-25 09:11:09.357 | Modified: 2013-01-25 09:11:09.357
-- =====================================================
Create view VwReportOutstandingSO2
as
Select  A.NoBukti+right('00000'+cast(A.Urut as varchar(5)),5) KeyNoBukti, A.Nobukti, P.Tanggal, P.Kodecust KodeCustSupp, S.NamaCust NamaCustSupp,
        A.urut, A.kodebrg, B.NamaBrg, A.Satuan, A.Isi,
        A.Qnt, A.Qnt2, A.QntSPP, A.Qnt2SPP,
        A.QntSisa, A.Qnt2Sisa
From    vwBrowsOutSO_SPP A
Left Outer Join DBSO P on P.NoBukti=A.NoBukti
Left Outer Join vwBrowsCustomer S on S.KodeCust=P.KodeCust and S.Sales=P.KODESLS
Left Outer Join dbBarang B on B.KodeBrg=A.KodeBrg


GO

-- View: VwReportPembelian
-- Created: 2012-11-01 12:56:54.903 | Modified: 2012-11-01 12:56:54.903
-- =====================================================


Create View [dbo].[VwReportPembelian]
as
Select 	A.NoBukti+right('00000000'+cast(A.Urut as varchar(8)),8) KeyNoBukti,
        A.*, C.NamaCustSupp, T.Nama NamaTipe, ST.Nama NamaSubTipe,
        cast(left(A.NoBukti,2) as varchar(50)) Left2NoBukti
From dbPembelian A
Left Outer Join DBCUSTSUPP C on C.KODECUSTSUPP=A.KodeCustSupp
Left Outer Join DBTIPETRANS T on T.KODETIPE=A.KodeTipe
Left Outer Join DBSUBTIPETRANS ST on ST.KODETIPE=A.KodeTipe and ST.KODESUBTIPE=A.KodeSubTipe

GO

-- View: VwReportPenerimaanACC
-- Created: 2013-05-13 12:08:51.950 | Modified: 2015-03-09 15:28:00.997
-- =====================================================


CREATE view [dbo].[VwReportPenerimaanACC]
as

Select 	B.NoBukti,B.NoPO,I.TANGGAL,I.KODESUPP KodeCustSupp,J.NAMACUSTSUPP,
	B.Urut, B.KodeBrg, H.NamaBrg, B.QntTerima qnt, B.NoSat, B.Isi, B.Satuan,
	    k.QNT qntpo,b.QNT qntgdg, b.QntReject reject,b.Qnt2Reject reject2,
        Qnt2Terima Qnt2, '' SatuanRoll, B.Harga,
        (B.NDISKON+B.DISCTOT)*i.kurs Disctotal,
        (B.NDPP+B.NPPN)*i.kurs TotalIDR, B.NDPP*i.kurs NDPP,
        B.NPPN*i.kurs NPPN, B.BYAngkut Beban, B.SubTotal + B.BYAngkut Total,
        case when i.kurs=1 then 0 else b.disctot end as disctotusd,
        case when i.kurs=1 then 0 else b.ndpp end as Ndppusd,
        case when i.kurs=1 then 0 else b.nppn end as NPPNusd,
        case when i.kurs=1 then 0 else b.subtotal end as totalusd,
        I.kurs,I.KODEVLS--,b.Qnt2 qntgdg2,
        ,Cast(Case when Case when I.IsOtorisasi1=1 then 1 else 0 end+
		Case when I.IsOtorisasi2=1 then 1 else 0 end+
		Case when I.IsOtorisasi3=1 then 1 else 0 end+
		Case when I.IsOtorisasi4=1 then 1 else 0 end+
		Case when I.IsOtorisasi5=1 then 1 else 0 end=I.MaxOL then 0
		else 1
		end As Bit) Needotorisasi
From  DBBELIDET B 
Left Outer Join dbBarang H on H.KodeBrg=B.KodeBrg
Left Outer join DBBELI I on B.NOBUKTI = I.NOBUKTI
Left Outer Join DBCUSTSUPP J on I.KODESUPP = J.KODECUSTSUPP
Left outer join DBPODET K on K.NOBUKTI=B.NOBUKTI and k.KODEBRG=b.KODEBRG 



GO

-- View: VwreportPermintaanBahan
-- Created: 2013-06-03 14:29:18.257 | Modified: 2013-06-03 14:29:18.257
-- =====================================================




CREATE View [dbo].[VwreportPermintaanBahan]
as
Select 	A.NoBukti, A.TANGGAL,A.KodeGdg,A.KodeGdgT,a.kddep,c.NMDEP,
	B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt,B.Qnt2M, B.Satuan Satuan,
	B.Qnt2,B.Qnt2P,
	Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi 
From dbBPPB A
Left Outer join dbBPPBDet B on B.NoBukti=a.NoBukti
Left Outer join dbBarang H on H.KodeBrg=b.KodeBrg
left outer join DBDEPART c on c.KDDEP=a.KDDEP




GO

-- View: VwreportPLinvoice
-- Created: 2013-01-30 16:01:49.020 | Modified: 2013-02-01 13:36:57.100
-- =====================================================

CREATE View [dbo].[VwreportPLinvoice]
as
select 	B.NoBukti, B.Urut, B.NoSPB, B.UrutSPB, B.KodeBrg, C.NAMABRG,x.Tanggal tglSPB,B.NoSPP,
        B.PPN, B.DISC, B.KURS, B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.NOSAT, B.ISI, B.NetW, B.GrossW,
        B.HARGA, B.DiscP, B.DiscRp, B.DISCTOT, B.HRGNETTO, B.NDISKON, B.SUBTOTAL, B.NDPP, B.NPPN, B.NNET,
        B.SUBTOTALRp, B.NDPPRp, B.NPPNRp, B.NNETRp, B.KetDetail,
        A.Tanggal,A.KodeCustSupp,D.NAMACUSTSUPP
from	dbInvoicePLDet B
left outer join dbBarang C on C.KodeBrg=B.KodeBrg
left outer join DBInvoicePL A on B.NoBukti = A.NoBukti
Left outer join DBCUSTSUPP D on A.KodeCustSupp = D.KODECUSTSUPP
left outer join dbSPB X on B.NoSPB = X.NoBukti



GO

-- View: VwreportPO
-- Created: 2013-06-03 13:41:53.343 | Modified: 2013-06-03 13:41:53.343
-- =====================================================



CREATE view [dbo].[VwreportPO]
as
Select 	B.NoBukti,I.TANGGAL,I.KODESUPP KodeCustSupp,J.NAMACUSTSUPP, '' NoSPP, 0 UrutSPP,
	B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt, B.NoSat, B.Isi, B.Satuan,
        0.00 Qnt2, '' SatuanRoll, B.Harga,
        (B.NDISKON+B.DISCTOT)*i.kurs Disctotal,
        (B.NDPP+B.NPPN)*i.kurs TotalIDR, B.NDPP*i.kurs NDPP,
        B.NPPN*i.kurs NPPN, B.BYAngkut Beban, B.SubTotal + B.BYAngkut Total,
        case when i.kurs=1 then 0 else b.disctot end as disctotusd,
        case when i.kurs=1 then 0 else b.ndpp end as Ndppusd,
        case when i.kurs=1 then 0 else b.nppn end as NPPNusd,
        case when i.kurs=1 then 0 else b.subtotal end as totalusd,
        I.kurs,I.KODEVLS,
        Cast(Case when Case when I.IsOtorisasi1=1 then 1 else 0 end+
                      Case when I.IsOtorisasi2=1 then 1 else 0 end+
                      Case when I.IsOtorisasi3=1 then 1 else 0 end+
                      Case when I.IsOtorisasi4=1 then 1 else 0 end+
                      Case when I.IsOtorisasi5=1 then 1 else 0 end=I.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi
From  dbPODet B 
Left Outer Join dbBarang H on H.KodeBrg=B.KodeBrg
Left Outer join DBPO I on B.NOBUKTI = I.NOBUKTI
Left Outer Join DBCUSTSUPP J on I.KODESUPP = J.KODECUSTSUPP 



GO

-- View: VwReportPurchasingReq
-- Created: 2013-06-03 13:35:04.340 | Modified: 2013-06-03 13:35:04.340
-- =====================================================


CREATE view [dbo].[VwReportPurchasingReq]
as

Select 	A.NoBukti,A.Tanggal,H.KODESUPP KodeCustSupp,I.NAMACUSTSUPP, 
	B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt, B.NoSat, B.Isi Isi, B.Sat Satuan,B.Keterangan,
	 Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi

From dbPPL A
Left Outer join dbPPLDet B on B.NoBukti=a.NoBukti
Left Outer join dbBarang H on H.KodeBrg=b.KodeBrg
Left Outer Join DBCUSTSUPP I on H.KODESUPP=i.KODECUSTSUPP


GO

-- View: VwReportRBeli
-- Created: 2012-11-01 12:56:54.920 | Modified: 2012-11-01 12:56:54.920
-- =====================================================

CREATE View [dbo].[VwReportRBeli]
as
Select 	A.NoBukti+right('00000000'+cast(A.Urut as varchar(8)),8) KeyNoBukti,
        A.*, C.NamaCustSupp, T.Nama NamaTipe, ST.Nama NamaSubTipe,
        cast(left(A.NoBukti,2) as varchar(50)) Left2NoBukti
From dbRPembelian A
Left Outer Join DBCUSTSUPP C on C.KODECUSTSUPP=A.KodeCustSupp
Left Outer Join DBTIPETRANS T on T.KODETIPE=A.KodeTipe
Left Outer Join DBSUBTIPETRANS ST on ST.KODETIPE=A.KodeTipe and ST.KODESUBTIPE=A.KodeSubTipe

GO

-- View: VwReportRevisiPO
-- Created: 2013-01-07 10:16:15.090 | Modified: 2013-01-07 10:16:15.090
-- =====================================================
CREATE View [dbo].[VwReportRevisiPO]
as
Select 	B.NoBukti,I.TANGGAL,I.KODESUPP KodeCustSupp,J.NAMACUSTSUPP, '' NoSPP, 0 UrutSPP,
	B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt, B.NoSat, B.Isi, B.Satuan,
        0.00 Qnt2, '' SatuanRoll, B.Harga,
        B.DiscP DiscP1, B.DiscTot DiscRp1, B.DiscTot,
        B.SubTotal TotalUSD, B.SubTotal TotalIDR, B.NDPP NDPP,
        B.NPPN NPPN, B.BYAngkut Beban, B.SubTotal + B.BYAngkut Total
From  dbPODet B 
Left Outer Join dbBarang H on H.KodeBrg=B.KodeBrg
Left Outer join DBPO I on B.NOBUKTI = I.NOBUKTI
Left Outer Join DBCUSTSUPP J on I.KODESUPP = J.KODECUSTSUPP 
GO

-- View: VwreportRInvoice
-- Created: 2013-01-18 14:57:59.257 | Modified: 2013-01-18 14:57:59.257
-- =====================================================

CREATE View [dbo].[VwreportRInvoice]
as
Select 	B.NoBukti, B.UrutPBL,I.KODESUPP KodeCustSupp,j.NAMACUSTSUPP,I.TANGGAL,
	B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt, B.NoSat, B.Isi, B.Satuan,
        0.00 Qnt2, '' SatuanRoll, B.Harga,
        B.DiscP DiscP1, B.DiscTot DiscRp1, B.DiscTot,
        B.SubTotal TotalUSD, B.SubTotal TotalIDR, B.NDPP NDPP,
        B.NPPN NPPN, B.BYAngkut Beban, B.SubTotal + B.BYAngkut Total
        
From dbRBeliDet B
Left Outer Join dbBarang H on H.KodeBrg=B.KodeBrg 
Left Outer Join DBRBELI I on B.NOBUKTI = I.NOBUKTI
Left Outer Join DBCUSTSUPP J on I.KODESUPP = J.KODECUSTSUPP 
GO

-- View: VwReportRInvoicePenjualan
-- Created: 2013-06-03 14:14:44.973 | Modified: 2013-06-03 14:14:44.973
-- =====================================================




CREATE View [dbo].[VwReportRInvoicePenjualan]
as
select 	B.NOBUKTI,D.TANGGAL, B.URUT, B.KODEBRG, B.PPN, B.DISC, B.KURS,D.NOSPB,D.NoSPP,E.Tanggal TglSPB,F.Tanggal TglSpp,
        B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.ISI, B.HARGA, B.DiscP1, B.DiscRp1,
        B.DiscP2, B.DiscRp2, B.DiscP3, B.DiscRp3, B.DiscP4, B.DiscRp4, B.DISCTOT,
        B.BYANGKUT, B.HRGNETTO, B.NDISKON, B.SUBTOTAL, B.NDPP, B.NPPN, B.NNET, B.SUBTOTALRp,
        B.NDPPRp, B.NPPNRp, B.NNETRp, B.NOInvoice, B.URUTInvoice, B.Keterangan,
        C.NamaBrg, B.QntTukar, B.Qnt2Tukar, B.netW, B.GrossW,
        'Nama Produk : '+c.Namabrg+' '+'Nama Komersil : '+ b.namabrg NamaProduk,
        D.KODECUSTSUPP,G.NAMACUSTSUPP,
		Cast(Case when Case when D.IsOtorisasi1=1 then 1 else 0 end+
		Case when D.IsOtorisasi2=1 then 1 else 0 end+
		Case when D.IsOtorisasi3=1 then 1 else 0 end+
		Case when D.IsOtorisasi4=1 then 1 else 0 end+
		Case when D.IsOtorisasi5=1 then 1 else 0 end=D.MaxOL then 0
		else 1
		end As Bit) Needotorisasi
        
from	dbRInvoicePLDet B
left outer join dbBarang C on C.KodeBrg=B.KodeBrg
left outer join DBRInvoicePL D on B.NOBUKTI=D.NOBUKTI
Left Outer Join dbSPB E on D.NOSPB = E.NoBukti
Left Outer join dbSPP F on D.NoSPP = F.NoBukti
Left Outer join DBCUSTSUPP G on D.KODECUSTSUPP=G.KODECUSTSUPP







GO

-- View: VwReportRjual
-- Created: 2012-11-01 12:56:54.960 | Modified: 2012-11-01 12:56:54.960
-- =====================================================


Create View [dbo].[VwReportRjual]
as
Select 	A.NoBukti+right('00000000'+cast(A.Urut as varchar(8)),8) KeyNoBukti,
        A.*, C.NamaCustSupp, T.Nama NamaTipe, ST.Nama NamaSubTipe,
        cast(left(A.NoBukti,2) as varchar(50)) Left2NoBukti
From dbRPenjualan A
Left Outer Join DBCUSTSUPP C on C.KODECUSTSUPP=A.KodeCustSupp
Left Outer Join DBTIPETRANS T on T.KODETIPE=A.KodeTipe
Left Outer Join DBSUBTIPETRANS ST on ST.KODETIPE=A.KodeTipe and ST.KODESUBTIPE=A.KodeSubTipe

GO

-- View: VwReportRPembelianGDg
-- Created: 2013-06-03 13:53:00.930 | Modified: 2013-06-03 13:53:00.930
-- =====================================================


CREATE view [dbo].[VwReportRPembelianGDg]
as
Select 	A.NoBukti,A.TANGGAL, a.Nobeli, A.KODESUPP KodeCustSupp,I.NAMACUSTSUPP,
	    B.Urut, B.KodeBrg, H.NamaBrg,b.QNT as qntretur,b.SATUAN as satrbeli,
	    isnull(B.Qnt1,0) as qnt, h.SAT1 as satuan,
        isnull(b.Qnt2,0) as Qnt2,h.SAT2 As satuan2,
        B.Harga, B.HrgNetto,B.DiscP,B.DiscTot,
        case when a.KODEVLS<>'IDR' then b.NDPP else 0 end as ndpp,B.NDPPRp,b.NPPNRp,b.NNETRp,
        A.KODEVLS,A.KURS,A.FAKTURSUPP,
        Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi
        
From dbRBeliDet B
Left Outer Join dbBarang H on H.KodeBrg=B.KodeBrg 
left Outer Join DBRBELI A on B.NOBUKTI=A.NOBUKTI
Left Outer Join DBCUSTSUPP I on A.KODESUPP = I.KODECUSTSUPP





GO

-- View: VwReportRPenyerahanBahan
-- Created: 2013-06-03 14:27:09.800 | Modified: 2013-06-03 14:27:09.800
-- =====================================================
CREATE View [dbo].[VwReportRPenyerahanBahan]
as
Select 	A.NoBukti, 
B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt, B.NoSat, B.Isi Isi, B.Sat Satuan,A.Tanggal,
Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi 
From dbRPenyerahanBhn A
Left Outer join  dbRPenyerahanBhnDet B on B.NoBukti=a.NoBukti
Left Outer join dbBarang H on H.KodeBrg=b.KodeBrg  



GO

-- View: VwReportRPLInvoice
-- Created: 2013-02-01 14:18:16.590 | Modified: 2013-02-01 14:25:05.233
-- =====================================================
CREATE View VwReportRPLInvoice
as
select 	B.NOBUKTI,D.TANGGAL, B.URUT, B.KODEBRG, B.PPN, B.DISC, B.KURS,D.NOSPB,D.NoSPP,E.Tanggal TglSPB,F.Tanggal TglSpp,
        B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.ISI, B.HARGA, B.DiscP1, B.DiscRp1,
        B.DiscP2, B.DiscRp2, B.DiscP3, B.DiscRp3, B.DiscP4, B.DiscRp4, B.DISCTOT,
        B.BYANGKUT, B.HRGNETTO, B.NDISKON, B.SUBTOTAL, B.NDPP, B.NPPN, B.NNET, B.SUBTOTALRp,
        B.NDPPRp, B.NPPNRp, B.NNETRp, B.NOInvoice, B.URUTInvoice, B.Keterangan,
        C.NamaBrg, B.QntTukar, B.Qnt2Tukar, B.netW, B.GrossW,
        'Nama Produk : '+c.Namabrg+' '+'Nama Komersil : '+ b.namabrg NamaProduk,
        D.KODECUSTSUPP,G.NAMACUSTSUPP
from	dbRInvoicePLDet B
left outer join dbBarang C on C.KodeBrg=B.KodeBrg
left outer join DBRInvoicePL D on B.NOBUKTI=D.NOBUKTI
Left Outer Join dbSPB E on D.NOSPB = E.NoBukti
Left Outer join dbSPP F on D.NoSPP = F.NoBukti
Left Outer join DBCUSTSUPP G on D.KODECUSTSUPP=G.KODECUSTSUPP



GO

-- View: VwReportSO
-- Created: 2013-06-03 13:59:19.797 | Modified: 2013-06-03 13:59:19.797
-- =====================================================
CREATE View [dbo].[VwReportSO]
as
Select 	A.NoBukti, A.NoSPB, B.UrutSPB,A.TANGGAL,I.KODECUSTSUPP,I.NAMACUSTSUPP,
	A.NoBukti+right('0000000000'+cast(B.Urut as varchar(10)),10) NoBuktiUrut,
        B.Urut, B.KodeBrg, H.NamaBrg,
        case when b.NOSAT=1 then B.Qnt else b.QNT2 end as qntjual,b.QNT, B.NoSat, B.Isi, H.Sat1 Satuan,
        B.Qnt2, H.Sat2 Satuan2, B.Harga,
        B.DiscP1,B.DiscTot,B.NDPP,a.KURS,a.KODEVLS,B.NDPPRp,B.NPPNRp,B.NNETRp,
        Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi 
From dbSO A
Left Outer join dbSODet B on B.NoBukti=a.NoBukti
Left Outer Join vwSatuanBrg H on H.KodeBrg=B.KodeBrg --and H.NoSat=B.NoSat
Left Outer join DBCUSTSUPP I on a.KODECUST = I.KODECUSTSUPP





GO

-- View: vwreportSOx
-- Created: 2013-01-18 16:28:26.957 | Modified: 2013-01-31 09:06:04.520
-- =====================================================


CREATE View [dbo].[vwreportSOx]
as
Select  A.NoBukti+right('00000'+cast(A.Urut as varchar(5)),5) KeyNoBukti, A.Nobukti, 
P.Tanggal, P.Kodecust KodeCustSupp, S.NamaCust NamaCustSupp,
A.urut, A.kodebrg, B.NamaBrg, A.Satuan, A.Isi,
A.Qnt, A.Qnt2, A.QntSPP, A.Qnt2SPP,
A.QntSisa, A.Qnt2Sisa,P.MasaBerlaku,P.NoPesanan,P.TglKirim,P.TGLJATUHTEMPO
From    vwBrowsOutSO_SPP A
Left Outer Join DBSO P on P.NoBukti=A.NoBukti
Left Outer Join vwBrowsCustomer S on S.KodeCust=P.KodeCust and S.Sales=P.KODESLS
Left Outer Join dbBarang B on B.KodeBrg=A.KodeBrg
where A.islengkap=0


GO

-- View: VwreportSPB
-- Created: 2013-06-03 14:10:02.747 | Modified: 2013-06-03 14:10:02.747
-- =====================================================


CREATE View [dbo].[VwreportSPB]
as
select 	B.NOBUKTI, B.URUT, B.NoSPP NoSC, B.UrutSPP UrutSC, B.KODEBRG, C.NAMABRG, '' Jns_Kertas, ''Ukr_Kertas,
        B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.ISI, B.NetW, B.GrossW, '' KetDetail,
        A.Tanggal,a.KodeCustSupp,D.NAMACUSTSUPP, 
		Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
		Case when A.IsOtorisasi2=1 then 1 else 0 end+
		Case when A.IsOtorisasi3=1 then 1 else 0 end+
		Case when A.IsOtorisasi4=1 then 1 else 0 end+
		Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
		else 1
		end As Bit)NeedOtorisasi
from	dbSPBDet B
left outer join dbBarang C on C.KodeBrg=B.KodeBrg
Left Outer join dbSPB A on B.NoBukti = A.NoBukti
Left Outer Join DBCUSTSUPP D on A.KodeCustSupp = D.KODECUSTSUPP



GO

-- View: VwreportSPBACC
-- Created: 2013-06-24 10:36:50.300 | Modified: 2013-06-24 14:54:37.000
-- =====================================================



CREATE View [dbo].[VwreportSPBACC]
as
select 	B.NOBUKTI, B.URUT, B.NoSPP NoSC, B.UrutSPP UrutSC, B.KODEBRG, C.NAMABRG, '' Jns_Kertas, ''Ukr_Kertas,
        B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.ISI, B.NetW, B.GrossW, '' KetDetail,
        A.Tanggal,a.KodeCustSupp,D.NAMACUSTSUPP, 
		Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
		Case when A.IsOtorisasi2=1 then 1 else 0 end+
		Case when A.IsOtorisasi3=1 then 1 else 0 end+
		Case when A.IsOtorisasi4=1 then 1 else 0 end+
		Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
		else 1
		end As Bit)NeedOtorisasi, B.HPP, B.HPP*B.QNT Total
from	dbSPBDet B
left outer join dbBarang C on C.KodeBrg=B.KodeBrg
Left Outer join dbSPB A on B.NoBukti = A.NoBukti
Left Outer Join DBCUSTSUPP D on A.KodeCustSupp = D.KODECUSTSUPP



GO

-- View: VwReportSPBRJual
-- Created: 2015-03-09 15:28:01.037 | Modified: 2015-03-11 09:53:07.033
-- =====================================================



CREATE View [dbo].[VwReportSPBRJual]
as
select 	B.NOBUKTI,D.TANGGAL, B.URUT, B.KODEBRG,D.Tanggal TglSPB,
        B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.ISI,
        'Nama Produk : '+c.Namabrg+' '+'Nama Komersil : '+ b.namabrg NamaProduk,
        D.KODECUSTSUPP,G.NAMACUSTSUPP,
		Cast(Case when Case when D.IsOtorisasi1=1 then 1 else 0 end+
		Case when D.IsOtorisasi2=1 then 1 else 0 end+
		Case when D.IsOtorisasi3=1 then 1 else 0 end+
		Case when D.IsOtorisasi4=1 then 1 else 0 end+
		Case when D.IsOtorisasi5=1 then 1 else 0 end=D.MaxOL then 0
		else 1
		end As Bit) Needotorisasi
        
from	dbSPBRJualDet B
left outer join dbBarang C on C.KodeBrg=B.KodeBrg
left outer join dbSPBRJual D on B.NOBUKTI=D.NOBUKTI
Left Outer join DBCUSTSUPP G on D.KODECUSTSUPP=G.KODECUSTSUPP


GO

-- View: VwReportSPP
-- Created: 2013-06-03 14:07:29.153 | Modified: 2013-06-03 14:07:29.153
-- =====================================================
CREATE View [dbo].[VwReportSPP]
as
select 	B.NOBUKTI, B.URUT, B.NoSO, B.UrutSO, B.KODEBRG, C.NAMABRG,D.Tanggal,D.KodeCustSupp,E.NAMACUSTSUPP,
        B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.ISI, B.NetW, B.GrossW, B.KetDetail,
        B.Nobukti+Cast(B.urut As Varchar(5)) MyKey,
        B.NamaBrg+Char(13)+'('+C.NamaBrg+')' NamaBrgKom,
        B.ShippingMark, Case when B.Nosat=1 then B.Sat_1 when B.nosat=2 then B.Sat_2 else '' end Satuan,
        D.NoPesan,D.TglKirim,B.Kodegdg,       
	Cast(Case when Case when D.IsOtorisasi1=1 then 1 else 0 end+
    Case when D.IsOtorisasi2=1 then 1 else 0 end+
    Case when D.IsOtorisasi3=1 then 1 else 0 end+
    Case when D.IsOtorisasi4=1 then 1 else 0 end+
    Case when D.IsOtorisasi5=1 then 1 else 0 end=D.MaxOL then 0
    else 1
    end As Bit) NeeDOtorisasi
from	dbSPPDet B
left outer join dbBarang C on C.KodeBrg=B.KodeBrg
Left Outer join dbSPP D on B.NoBukti = D.NoBukti
Left Outer join DBCUSTSUPP E on D.KodeCustSupp = E.KODECUSTSUPP





GO

-- View: VwreportSPPB
-- Created: 2013-01-30 15:52:51.043 | Modified: 2013-02-01 11:31:09.150
-- =====================================================

CREATE View [dbo].[VwreportSPPB]
as
Select A.*,B.NAMABRG NamaBarang,C.Tanggal,C.kodeCustSupp,D.NAMACUSTSUPP,
           A.Nobukti+Cast(A.Urut as varchar(5)) MyKey,Z.NOBUKTI Noso,Z.TANGGAL TanggalSO
from dbSPBDet A
     left outer join DBBARANG B on B.KODEBRG=A.Kodebrg
     Left Outer join dbSPB C on A.NoBukti = C.NoBukti
     Left Outer join DBCUSTSUPP D on c.KodeCustSupp = D.KODECUSTSUPP
     Left Outer join (Select x.NoBukti, x.NoSPP
                      from dbSPBDet x
                      group by x.NoBukti, x.NoSPP) y on y.NoBukti=C.NoBukti
     Left Outer Join (Select x.NoBukti, x.Tanggal,y.NoSO, x.TglKirim
                      from DBSPP x 
                        left outer join dbSPPDet y on y.NoBukti=x.NoBukti
                      Group by x.NoBukti, x.Tanggal,y.NoSO, x.TglKirim) v On v.NoBukti=y.NoSPP 
    left outer join DBSO Z on Z.NOBUKTI=v.NoSO
     


GO

-- View: VwReportSppx
-- Created: 2013-01-30 14:00:03.827 | Modified: 2013-01-31 11:09:43.957
-- =====================================================

CREATE View [dbo].[VwReportSppx]
as
Select  A.NoBukti+right('00000'+cast(A.Urut as varchar(5)),5) KeyNoBukti, A.Nobukti, P.Tanggal, P.KodeCustSupp, S.Namacust NamaCustSupp,
        A.urut, A.kodebrg, B.NamaBrg, '' Jns_Kertas, '' Ukr_Kertas, A.Sat_1, A.Sat_2, A.Isi,
        Case when A.NoSat=1 then A.Qnt
             when A.NoSat=2 then A.Qnt2
             else 0
        end Qnt, A.Qnt2,
        Case when A.NoSat=1 then A.QntSPB
             when A.NoSat=2 then A.Qnt2SPB
             else 0
        end QntSPB, A.Qnt2SPB,
        Case when A.NoSat=1 then A.QntSisa
             when A.NoSat=2 then A.Qnt2Sisa
             else 0
        end QntSisa, A.Qnt2Sisa,
        Case when A.NOSAT=1 then A.SAT_1
             when A.NOSAT=2 then A.SAT_2
             else ''
        end Satuan, P.Tglkirim,
        P.NoPesan
From    vwBrowsOutSPP A
Left Outer Join dbSPP P on P.NoBukti=A.NoBukti
left Outer join DBSO SO on SO.NOBUKTI=A.noso
Left Outer Join vwBrowsCustomer S on S.KodeCust=P.KodeCustSupp and s.Sales=SO.KODESLS
Left Outer Join dbBarang B on B.KodeBrg=A.KodeBrg
where A.isclose=0 
    


GO

-- View: VwReportSpRk
-- Created: 2013-06-03 14:17:57.390 | Modified: 2013-06-03 14:17:57.390
-- =====================================================


CREATE View [dbo].[VwReportSpRk]
as
Select 	A.Tanggal,B.NoBukti,A.KODEBRG KodeBrgJadi,i.NAMABRG NmBrgjadi,
	B.Urut, B.KodeBrg, H.NamaBrg, B.Qnt, B.NoSat, B.Isi Isi, B.Satuan Satuan
	 ,Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                      Case when A.IsOtorisasi2=1 then 1 else 0 end+
                      Case when A.IsOtorisasi3=1 then 1 else 0 end+
                      Case when A.IsOtorisasi4=1 then 1 else 0 end+
                      Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                 else 1
            end As Bit) NeedOtorisasi 
From dbSPKDet B 
Left Outer Join DbSPK A on  B.nobukti = A.nobukti
Left Outer join dbBarang H on H.KodeBrg=b.KodeBrg
Left Outer Join DBBARANG I on A.KODEBRG = I.KODEBRG


GO

-- View: vwReportStockBrg
-- Created: 2013-07-11 17:38:52.523 | Modified: 2013-07-11 17:38:52.523
-- =====================================================
CREATE view [dbo].[vwReportStockBrg]
as
Select  a.BULAN, a.TAHUN, a.KODEBRG, a.KODEGDG, a.QNTAWAL, a.HRGAWAL, 
	a.QNTPBL, a.QNT2PBL, a.HRGPBL, a.QNTRPB, a.QNT2RPB, a.HRGRPB, 
	a.QNTPNJ, a.QNT2PNJ, a.HRGPNJ, a.QNTRPJ, a.QNT2RPJ, a.HRGRPJ, 
	a.QNTADI, a.QNT2ADI, a.HRGADI, a.QNTADO, a.QNT2ADO, a.HRGADO, 
	a.QNTUKI, a.QNT2UKI, a.HRGUKI, a.QNTUKO, a.QNT2UKO, a.HRGUKO, 
	a.QNTTRI, a.QNT2TRI, a.HRGTRI, a.QNTTRO, a.QNT2TRO, a.HRGTRO,
	a.QNTPMK, a.QNT2PMK, a.HRGPMK, a.QNTRPK, a.QNT2RPK, a.HRGRPK,
	a.QntHPrd, a.Qnt2HPrd, a.HRGHPrd, 
	a.HRGRATA, a.QNTIN, a.QNT2IN, a.RPIN, a.QNTOUT, a.QNT2OUT, a.RPOUT, 
	a.SALDOQNT, a.SALDO2QNT, a.SALDORP, a.SaldoAV, a.Saldo2AV, 
	B.QntMin,B.QntMax,
    b.NAMABRG, c.NAMA Namagdg, b.SAT1, b.Sat2,B.ISI1,B.ISI2,B.ISI3,
    b.KODEGRP, b.KODESUBGRP
from DBSTOCKBRG a
     left outer join DBBARANG b on b.KODEBRG=a.KODEBRG --and b.Kodegdg=a.KODEGDG
     left outer join DBGUDANG c on c.KODEGDG=a.KODEGDG




GO

-- View: VwReporttransfer
-- Created: 2013-06-10 11:36:28.560 | Modified: 2013-06-10 11:36:28.560
-- =====================================================

Create View [dbo].[VwReporttransfer]
as
Select A.nobukti, a.NoUrut, a.Tanggal,  A.Note Keterangan, A.NoPenyerahan,
	 B.URUT,  B.KODEBRG, C.NAMABRG, '' Jns_Kertas, '' Ukr_Kertas,
    B.QNT, B.QNT2, B.SAT_1, B.SAT_2, B.ISI, B.GdgAsal, B.GdgTujuan, D.Nama+' ('+B.gdgAsal+')' NamagdgAsal,
    E.Nama+' ('+B.GdgTujuan+')' NamagdgTujuan,
    A.IsOtorisasi1, A.OtoUser1, A.TglOto1, A.IsOtorisasi2, A.OtoUser2, A.TglOto2,
	A.IsOtorisasi3, A.OtoUser3, A.TglOto3, A.IsOtorisasi4, A.OtoUser4, A.TglOto4,
	A.IsOtorisasi5, A.OtoUser5, A.TglOto5,
        Cast(Case when Case when A.IsOtorisasi1=1 then 1 else 0 end+
                       Case when A.IsOtorisasi2=1 then 1 else 0 end+
                       Case when A.IsOtorisasi3=1 then 1 else 0 end+
                       Case when A.IsOtorisasi4=1 then 1 else 0 end+
                       Case when A.IsOtorisasi5=1 then 1 else 0 end=A.MaxOL then 0
                  else 1
             end As Bit) NeedOtorisasi
from dbTransfer a
Left Outer JOin DBTRANSFERDET B on A.NOBUKTI=B.NOBUKTI
left outer join dbBarang C on C.KodeBrg=B.KodeBrg
left outer join dbGudang D on d.Kodegdg=B.GdgAsal
left outer join dbgudang E on E.kodegdg=B.GdgTujuan






--select * from VwReporttransfer

GO

-- View: VwReportUbahKemasanBahan
-- Created: 2013-01-21 13:31:31.560 | Modified: 2013-01-21 13:31:31.560
-- =====================================================

create view [dbo].[VwReportUbahKemasanBahan]
as
Select * from vwDetailUbahKemasan where NoBukti Like '%KMS%'

GO

-- =====================================================
-- ALL DATABASE VIEWS
-- =====================================================

