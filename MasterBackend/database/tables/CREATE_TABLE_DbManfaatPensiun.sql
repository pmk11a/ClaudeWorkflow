-- =============================================
-- Table: DbManfaatPensiun
-- Description: Tabel untuk menyimpan data manfaat pensiun
-- Compatible with: SQL Server 2008
-- Created: $(Date)
-- =============================================

-- Drop table if exists (optional, uncomment if needed)
-- IF OBJECT_ID('dbo.DbManfaatPensiun', 'U') IS NOT NULL
--     DROP TABLE [dbo].[DbManfaatPensiun]
-- GO

CREATE TABLE [dbo].[DbManfaatPensiun](
    [NoMP] [varchar](25) NOT NULL,
    [NoUrut] [varchar](10) NULL,
    [TANGGAL] [datetime] NULL,
    [Keterangan] [varchar](500) NULL,
    [Perkiraan] [varchar](30) NULL,
    [Lawan] [varchar](30) NULL,
    [IK] [numeric](18, 2) NULL,
    [PersenPerusahaan] [numeric](18, 2) NULL,
    [PersenPeserta] [numeric](18, 2) NULL,
    
    -- Primary Key Constraint
    CONSTRAINT [PK_DbManfaatPensiun] PRIMARY KEY CLUSTERED 
    (
        [NoMP] ASC
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
-- Add Default Constraints (Optional)
-- =============================================

-- Default untuk NoMP (jika diperlukan)
ALTER TABLE [dbo].[DbManfaatPensiun] ADD CONSTRAINT [DF_DbManfaatPensiun_NoMP] 
    DEFAULT ('') FOR [NoMP]
GO

-- Default untuk NoUrut
ALTER TABLE [dbo].[DbManfaatPensiun] ADD CONSTRAINT [DF_DbManfaatPensiun_NoUrut] 
    DEFAULT ('') FOR [NoUrut]
GO

-- Default untuk Keterangan
ALTER TABLE [dbo].[DbManfaatPensiun] ADD CONSTRAINT [DF_DbManfaatPensiun_Keterangan] 
    DEFAULT ('') FOR [Keterangan]
GO

-- Default untuk Perkiraan
ALTER TABLE [dbo].[DbManfaatPensiun] ADD CONSTRAINT [DF_DbManfaatPensiun_Perkiraan] 
    DEFAULT ('') FOR [Perkiraan]
GO

-- Default untuk Lawan
ALTER TABLE [dbo].[DbManfaatPensiun] ADD CONSTRAINT [DF_DbManfaatPensiun_Lawan] 
    DEFAULT ('') FOR [Lawan]
GO

-- Default untuk IK
ALTER TABLE [dbo].[DbManfaatPensiun] ADD CONSTRAINT [DF_DbManfaatPensiun_IK] 
    DEFAULT ((0)) FOR [IK]
GO

-- Default untuk PersenPerusahaan
ALTER TABLE [dbo].[DbManfaatPensiun] ADD CONSTRAINT [DF_DbManfaatPensiun_PersenPerusahaan] 
    DEFAULT ((0)) FOR [PersenPerusahaan]
GO

-- Default untuk PersenPeserta
ALTER TABLE [dbo].[DbManfaatPensiun] ADD CONSTRAINT [DF_DbManfaatPensiun_PersenPeserta] 
    DEFAULT ((0)) FOR [PersenPeserta]
GO

-- =============================================
-- Add Check Constraints (Optional)
-- =============================================

-- Check constraint untuk memastikan persentase tidak negatif
ALTER TABLE [dbo].[DbManfaatPensiun] ADD CONSTRAINT [CK_DbManfaatPensiun_PersenPerusahaan] 
    CHECK ([PersenPerusahaan] >= 0 AND [PersenPerusahaan] <= 100)
GO

ALTER TABLE [dbo].[DbManfaatPensiun] ADD CONSTRAINT [CK_DbManfaatPensiun_PersenPeserta] 
    CHECK ([PersenPeserta] >= 0 AND [PersenPeserta] <= 100)
GO

-- Check constraint untuk memastikan IK tidak negatif
ALTER TABLE [dbo].[DbManfaatPensiun] ADD CONSTRAINT [CK_DbManfaatPensiun_IK] 
    CHECK ([IK] >= 0)
GO

-- =============================================
-- Create Indexes (Optional untuk performance)
-- =============================================

-- Index untuk TANGGAL (sering digunakan untuk filter tanggal)
CREATE NONCLUSTERED INDEX [IX_DbManfaatPensiun_Tanggal] ON [dbo].[DbManfaatPensiun]
(
    [TANGGAL] ASC
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

-- Index untuk Perkiraan (jika sering digunakan untuk JOIN atau filter)
CREATE NONCLUSTERED INDEX [IX_DbManfaatPensiun_Perkiraan] ON [dbo].[DbManfaatPensiun]
(
    [Perkiraan] ASC
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
-- Contoh INSERT data
INSERT INTO [dbo].[DbManfaatPensiun] (
    [NoMP], [NoUrut], [TANGGAL], [Keterangan], [Perkiraan], 
    [Lawan], [IK], [PersenPerusahaan], [PersenPeserta]
) VALUES (
    'MP001', '001', GETDATE(), 'Manfaat Pensiun Normal', 
    'PKR001', 'LW001', 1000000.00, 70.00, 30.00
);

-- Contoh SELECT
SELECT * FROM [dbo].[DbManfaatPensiun] WHERE [NoMP] = 'MP001';
*/

PRINT 'Table DbManfaatPensiun created successfully!'
PRINT 'Primary Key: NoMP'
PRINT 'Indexes: TANGGAL, Perkiraan'
PRINT 'Constraints: Percentage validation, IK non-negative'
