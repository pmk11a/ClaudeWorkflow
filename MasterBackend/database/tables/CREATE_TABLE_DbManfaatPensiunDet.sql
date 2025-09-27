-- =============================================
-- Table: DbManfaatPensiunDet
-- Description: Tabel detail untuk menyimpan data manfaat pensiun per peserta
-- Compatible with: SQL Server 2008
-- Created: $(Date)
-- Parent Table: DbManfaatPensiun
-- =============================================

-- Drop table if exists (optional, uncomment if needed)
-- IF OBJECT_ID('dbo.DbManfaatPensiunDet', 'U') IS NOT NULL
--     DROP TABLE [dbo].[DbManfaatPensiunDet]
-- GO

CREATE TABLE [dbo].[DbManfaatPensiunDet](
    [NoMP] [varchar](25) NOT NULL,
    [Urut] [int] NOT NULL,
    [NIK] [varchar](20) NULL,
    [NoPensiun] [varchar](20) NULL,
    [KodeJabatan] [varchar](5) NULL,
    [GajiPokok] [numeric](18, 2) NULL,
    [PhDP] [float] NULL,
    [MasaKerja] [numeric](18, 2) NULL,
    [PersenMP] [numeric](18, 2) NULL,
    [RpMP] [numeric](18, 2) NULL,
    [RpMP20] [numeric](18, 2) NULL,
    [RpTotalMP] [numeric](18, 2) NULL,
    
    -- Composite Primary Key
    CONSTRAINT [PK_DbManfaatPensiunDet] PRIMARY KEY CLUSTERED 
    (
        [NoMP] ASC,
        [Urut] ASC
    ) WITH (
        PAD_INDEX = OFF, 
        STATISTICS_NORECOMPUTE = OFF, 
        IGNORE_DUP_KEY = OFF, 
        ALLOW_ROW_LOCKS = ON, 
        ALLOW_PAGE_LOCKS = ON
    ) ON [PRIMARY]
) ON [PRIMARY]

GO

-- =============================================
-- Add Foreign Key Constraint with CASCADE
-- =============================================

ALTER TABLE [dbo].[DbManfaatPensiunDet] WITH CHECK ADD CONSTRAINT [FK_DbManfaatPensiunDet_DbManfaatPensiun] 
    FOREIGN KEY([NoMP])
    REFERENCES [dbo].[DbManfaatPensiun] ([NoMP])
    ON UPDATE CASCADE
    ON DELETE CASCADE
GO

ALTER TABLE [dbo].[DbManfaatPensiunDet] CHECK CONSTRAINT [FK_DbManfaatPensiunDet_DbManfaatPensiun]
GO

-- =============================================
-- Add Default Constraints
-- =============================================

-- Default untuk NoMP
ALTER TABLE [dbo].[DbManfaatPensiunDet] ADD CONSTRAINT [DF_DbManfaatPensiunDet_NoMP] 
    DEFAULT ('') FOR [NoMP]
GO

-- Default untuk NIK
ALTER TABLE [dbo].[DbManfaatPensiunDet] ADD CONSTRAINT [DF_DbManfaatPensiunDet_NIK] 
    DEFAULT ('') FOR [NIK]
GO

-- Default untuk NoPensiun
ALTER TABLE [dbo].[DbManfaatPensiunDet] ADD CONSTRAINT [DF_DbManfaatPensiunDet_NoPensiun] 
    DEFAULT ('') FOR [NoPensiun]
GO

-- Default untuk KodeJabatan
ALTER TABLE [dbo].[DbManfaatPensiunDet] ADD CONSTRAINT [DF_DbManfaatPensiunDet_KodeJabatan] 
    DEFAULT ('') FOR [KodeJabatan]
GO

-- Default untuk GajiPokok
ALTER TABLE [dbo].[DbManfaatPensiunDet] ADD CONSTRAINT [DF_DbManfaatPensiunDet_GajiPokok] 
    DEFAULT ((0)) FOR [GajiPokok]
GO

-- Default untuk PhDP
ALTER TABLE [dbo].[DbManfaatPensiunDet] ADD CONSTRAINT [DF_DbManfaatPensiunDet_PhDP] 
    DEFAULT ((0)) FOR [PhDP]
GO

-- Default untuk MasaKerja
ALTER TABLE [dbo].[DbManfaatPensiunDet] ADD CONSTRAINT [DF_DbManfaatPensiunDet_MasaKerja] 
    DEFAULT ((0)) FOR [MasaKerja]
GO

-- Default untuk PersenMP
ALTER TABLE [dbo].[DbManfaatPensiunDet] ADD CONSTRAINT [DF_DbManfaatPensiunDet_PersenMP] 
    DEFAULT ((0)) FOR [PersenMP]
GO

-- Default untuk RpMP (sesuai permintaan)
ALTER TABLE [dbo].[DbManfaatPensiunDet] ADD CONSTRAINT [DF_DbManfaatPensiunDet_RpMP] 
    DEFAULT ((0)) FOR [RpMP]
GO

-- Default untuk RpMP20 (sesuai permintaan)
ALTER TABLE [dbo].[DbManfaatPensiunDet] ADD CONSTRAINT [DF_DbManfaatPensiunDet_RpMP20] 
    DEFAULT ((0)) FOR [RpMP20]
GO

-- Default untuk RpTotalMP (sesuai permintaan)
ALTER TABLE [dbo].[DbManfaatPensiunDet] ADD CONSTRAINT [DF_DbManfaatPensiunDet_RpTotalMP] 
    DEFAULT ((0)) FOR [RpTotalMP]
GO

-- =============================================
-- Add Check Constraints (Optional)
-- =============================================

-- Check constraint untuk memastikan Urut tidak negatif
ALTER TABLE [dbo].[DbManfaatPensiunDet] ADD CONSTRAINT [CK_DbManfaatPensiunDet_Urut] 
    CHECK ([Urut] > 0)
GO

-- Check constraint untuk memastikan GajiPokok tidak negatif
ALTER TABLE [dbo].[DbManfaatPensiunDet] ADD CONSTRAINT [CK_DbManfaatPensiunDet_GajiPokok] 
    CHECK ([GajiPokok] >= 0)
GO

-- Check constraint untuk memastikan MasaKerja tidak negatif
ALTER TABLE [dbo].[DbManfaatPensiunDet] ADD CONSTRAINT [CK_DbManfaatPensiunDet_MasaKerja] 
    CHECK ([MasaKerja] >= 0)
GO

-- Check constraint untuk memastikan PersenMP dalam range 0-100
ALTER TABLE [dbo].[DbManfaatPensiunDet] ADD CONSTRAINT [CK_DbManfaatPensiunDet_PersenMP] 
    CHECK ([PersenMP] >= 0 AND [PersenMP] <= 100)
GO

-- Check constraint untuk memastikan nilai rupiah tidak negatif
ALTER TABLE [dbo].[DbManfaatPensiunDet] ADD CONSTRAINT [CK_DbManfaatPensiunDet_RpMP] 
    CHECK ([RpMP] >= 0)
GO

ALTER TABLE [dbo].[DbManfaatPensiunDet] ADD CONSTRAINT [CK_DbManfaatPensiunDet_RpMP20] 
    CHECK ([RpMP20] >= 0)
GO

ALTER TABLE [dbo].[DbManfaatPensiunDet] ADD CONSTRAINT [CK_DbManfaatPensiunDet_RpTotalMP] 
    CHECK ([RpTotalMP] >= 0)
GO

-- =============================================
-- Create Indexes (Optional untuk performance)
-- =============================================

-- Index untuk NIK (sering digunakan untuk pencarian karyawan)
CREATE NONCLUSTERED INDEX [IX_DbManfaatPensiunDet_NIK] ON [dbo].[DbManfaatPensiunDet]
(
    [NIK] ASC
) WITH (
    PAD_INDEX = OFF, 
    STATISTICS_NORECOMPUTE = OFF, 
    SORT_IN_TEMPDB = OFF, 
    DROP_EXISTING = OFF, 
    ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, 
    ALLOW_PAGE_LOCKS = ON
) ON [PRIMARY]
GO

-- Index untuk NoPensiun
CREATE NONCLUSTERED INDEX [IX_DbManfaatPensiunDet_NoPensiun] ON [dbo].[DbManfaatPensiunDet]
(
    [NoPensiun] ASC
) WITH (
    PAD_INDEX = OFF, 
    STATISTICS_NORECOMPUTE = OFF, 
    SORT_IN_TEMPDB = OFF, 
    DROP_EXISTING = OFF, 
    ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, 
    ALLOW_PAGE_LOCKS = ON
) ON [PRIMARY]
GO

-- Index untuk KodeJabatan (untuk grouping/filtering)
CREATE NONCLUSTERED INDEX [IX_DbManfaatPensiunDet_KodeJabatan] ON [dbo].[DbManfaatPensiunDet]
(
    [KodeJabatan] ASC
) WITH (
    PAD_INDEX = OFF, 
    STATISTICS_NORECOMPUTE = OFF, 
    SORT_IN_TEMPDB = OFF, 
    DROP_EXISTING = OFF, 
    ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, 
    ALLOW_PAGE_LOCKS = ON
) ON [PRIMARY]
GO

-- =============================================
-- Sample INSERT Statement (untuk testing)
-- =============================================

/*
-- Pastikan data master ada di DbManfaatPensiun dulu
INSERT INTO [dbo].[DbManfaatPensiun] ([NoMP], [Keterangan]) VALUES ('MP001', 'Test Manfaat Pensiun');

-- Contoh INSERT detail
INSERT INTO [dbo].[DbManfaatPensiunDet] (
    [NoMP], [Urut], [NIK], [NoPensiun], [KodeJabatan], [GajiPokok], 
    [PhDP], [MasaKerja], [PersenMP], [RpMP], [RpMP20], [RpTotalMP]
) VALUES (
    'MP001', 1, '1234567890123456', 'PN001', 'J001', 5000000.00, 
    0.02, 25.50, 80.00, 4000000.00, 800000.00, 4800000.00
);

-- Contoh SELECT dengan JOIN
SELECT 
    h.NoMP, h.Keterangan, 
    d.Urut, d.NIK, d.NoPensiun, d.GajiPokok, d.RpTotalMP
FROM [dbo].[DbManfaatPensiun] h
INNER JOIN [dbo].[DbManfaatPensiunDet] d ON h.NoMP = d.NoMP
WHERE h.NoMP = 'MP001';

-- Test CASCADE DELETE (hati-hati!)
-- DELETE FROM [dbo].[DbManfaatPensiun] WHERE NoMP = 'MP001';
-- (Ini akan menghapus semua detail yang terkait secara otomatis)
*/

PRINT 'Table DbManfaatPensiunDet created successfully!'
PRINT 'Primary Key: NoMP + Urut (Composite)'
PRINT 'Foreign Key: NoMP -> DbManfaatPensiun.NoMP (CASCADE)'
PRINT 'Indexes: NIK, NoPensiun, KodeJabatan'
PRINT 'Default Values: RpMP=0, RpMP20=0, RpTotalMP=0'
