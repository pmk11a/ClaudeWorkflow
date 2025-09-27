-- =====================================================
-- STORED PROCEDURE sp_AmbilNilaiPasar FOR 418 DATABASES
-- =====================================================
-- This script creates the sp_AmbilNilaiPasar procedure 
-- which extracts market value data from investment tables

CREATE PROCEDURE [dbo].[sp_AmbilNilaiPasar]
    @Bulan INT,
    @Tahun INT,
    @Devisi VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Clear existing data from xlsNilaiPasar table
    DELETE FROM xlsNilaiPasar;
    
    -- Insert investment market value data
    INSERT INTO xlsNilaiPasar (
        Urut,
        Perkiraan,
        Tahun,
        Bulan,
        Keterangan,
        NilaiPerolehan,
        NilaiPasar
    )
    SELECT 
        CAST(ROW_NUMBER() OVER(PARTITION BY a.Bulan ORDER BY a.Perkiraan) AS INT) AS Urut,
        a.Perkiraan,
        a.Tahun,
        a.Bulan,
        b.Keterangan,
        a.Awal AS NilaiPerolehan,
        0 AS NilaiPasar
    FROM DBINVESTASIDET a
    LEFT OUTER JOIN DBINVESTASI b ON b.Perkiraan = a.Perkiraan 
    WHERE a.Bulan = @Bulan 
      AND a.Tahun = @Tahun 
      AND a.Akhir > 0
      AND (@Devisi IS NULL OR a.Devisi = @Devisi);
      
END
GO

-- =====================================================
-- EXTENDED VERSION WITH ADDITIONAL FEATURES
-- =====================================================

-- Enhanced version with more parameters and features
CREATE PROCEDURE [dbo].[sp_AmbilNilaiPasar_Extended]
    @Bulan INT,
    @Tahun INT,
    @Devisi VARCHAR(10) = NULL,
    @JenisInvestasi VARCHAR(20) = NULL,
    @MinimalNilai DECIMAL(18,2) = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Parameter validation
    IF @Bulan NOT BETWEEN 1 AND 12
    BEGIN
        RAISERROR('Invalid month parameter. Must be between 1 and 12.', 16, 1);
        RETURN;
    END
    
    IF @Tahun < 1900 OR @Tahun > YEAR(GETDATE()) + 10
    BEGIN
        RAISERROR('Invalid year parameter.', 16, 1);
        RETURN;
    END
    
    -- Clear existing data for specific parameters
    DELETE FROM xlsNilaiPasar 
    WHERE Bulan = @Bulan 
      AND Tahun = @Tahun
      AND (@Devisi IS NULL OR Devisi = @Devisi);
    
    -- Insert enhanced investment data
    INSERT INTO xlsNilaiPasar (
        Urut,
        Perkiraan,
        Tahun,
        Bulan,
        Devisi,
        Keterangan,
        NilaiPerolehan,
        NilaiPasar,
        JenisInvestasi,
        TanggalUpdate
    )
    SELECT 
        CAST(ROW_NUMBER() OVER(PARTITION BY a.Bulan, a.Devisi ORDER BY a.Perkiraan) AS INT) AS Urut,
        a.Perkiraan,
        a.Tahun,
        a.Bulan,
        ISNULL(a.Devisi, 'ALL') AS Devisi,
        ISNULL(b.Keterangan, 'No Description') AS Keterangan,
        ISNULL(a.Awal, 0) AS NilaiPerolehan,
        0 AS NilaiPasar,
        ISNULL(b.JenisInvestasi, 'GENERAL') AS JenisInvestasi,
        GETDATE() AS TanggalUpdate
    FROM DBINVESTASIDET a
    LEFT OUTER JOIN DBINVESTASI b ON b.Perkiraan = a.Perkiraan 
    WHERE a.Bulan = @Bulan 
      AND a.Tahun = @Tahun 
      AND ISNULL(a.Akhir, 0) > @MinimalNilai
      AND (@Devisi IS NULL OR ISNULL(a.Devisi, 'ALL') = @Devisi)
      AND (@JenisInvestasi IS NULL OR ISNULL(b.JenisInvestasi, 'GENERAL') = @JenisInvestasi);
      
    -- Return summary information
    SELECT 
        COUNT(*) AS TotalRecords,
        SUM(NilaiPerolehan) AS TotalNilaiPerolehan,
        AVG(NilaiPerolehan) AS RataNilaiPerolehan,
        MIN(NilaiPerolehan) AS MinNilaiPerolehan,
        MAX(NilaiPerolehan) AS MaxNilaiPerolehan
    FROM xlsNilaiPasar
    WHERE Bulan = @Bulan AND Tahun = @Tahun;
      
END
GO

-- =====================================================
-- BULK VERSION FOR MULTIPLE PERIODS
-- =====================================================

-- Procedure to process multiple months/years at once
CREATE PROCEDURE [dbo].[sp_AmbilNilaiPasar_Bulk]
    @TanggalMulai DATE,
    @TanggalSelesai DATE,
    @Devisi VARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Bulan INT, @Tahun INT;
    DECLARE @CurrentDate DATE = @TanggalMulai;
    
    -- Process each month in the date range
    WHILE @CurrentDate <= @TanggalSelesai
    BEGIN
        SET @Bulan = MONTH(@CurrentDate);
        SET @Tahun = YEAR(@CurrentDate);
        
        -- Call the main procedure for each month
        EXEC sp_AmbilNilaiPasar @Bulan, @Tahun, @Devisi;
        
        -- Move to next month
        SET @CurrentDate = DATEADD(MONTH, 1, @CurrentDate);
    END
    
    -- Return summary for the entire period
    SELECT 
        'BULK_SUMMARY' AS ProcessType,
        COUNT(*) AS TotalRecords,
        COUNT(DISTINCT CAST(Tahun AS VARCHAR) + '-' + CAST(Bulan AS VARCHAR)) AS TotalPeriods,
        SUM(NilaiPerolehan) AS TotalNilaiPerolehan,
        MIN(Tahun) AS TahunMulai,
        MAX(Tahun) AS TahunSelesai
    FROM xlsNilaiPasar
    WHERE (Tahun * 100 + Bulan) BETWEEN (YEAR(@TanggalMulai) * 100 + MONTH(@TanggalMulai)) 
                                    AND (YEAR(@TanggalSelesai) * 100 + MONTH(@TanggalSelesai));
END
GO

-- =====================================================
-- ANALYSIS VERSION WITH COMPARATIVE DATA
-- =====================================================

-- Procedure for comparative analysis between periods
CREATE PROCEDURE [dbo].[sp_AmbilNilaiPasar_Analysis]
    @BulanCurrent INT,
    @TahunCurrent INT,
    @BulanPrevious INT,
    @TahunPrevious INT,
    @Devisi VARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Create temporary table for analysis
    CREATE TABLE #TempAnalysis (
        Perkiraan NVARCHAR(50),
        Keterangan NVARCHAR(200),
        NilaiCurrent DECIMAL(18,2),
        NilaiPrevious DECIMAL(18,2),
        Variance DECIMAL(18,2),
        VariancePercent DECIMAL(10,2)
    );
    
    -- Insert comparative data
    INSERT INTO #TempAnalysis
    SELECT 
        ISNULL(curr.Perkiraan, prev.Perkiraan) AS Perkiraan,
        ISNULL(curr.Keterangan, prev.Keterangan) AS Keterangan,
        ISNULL(curr.Awal, 0) AS NilaiCurrent,
        ISNULL(prev.Awal, 0) AS NilaiPrevious,
        ISNULL(curr.Awal, 0) - ISNULL(prev.Awal, 0) AS Variance,
        CASE 
            WHEN ISNULL(prev.Awal, 0) = 0 THEN 0
            ELSE ((ISNULL(curr.Awal, 0) - ISNULL(prev.Awal, 0)) / prev.Awal) * 100
        END AS VariancePercent
    FROM (
        SELECT a.Perkiraan, a.Awal, b.Keterangan
        FROM DBINVESTASIDET a
        LEFT JOIN DBINVESTASI b ON a.Perkiraan = b.Perkiraan
        WHERE a.Bulan = @BulanCurrent AND a.Tahun = @TahunCurrent
          AND (@Devisi IS NULL OR a.Devisi = @Devisi)
    ) curr
    FULL OUTER JOIN (
        SELECT a.Perkiraan, a.Awal, b.Keterangan
        FROM DBINVESTASIDET a
        LEFT JOIN DBINVESTASI b ON a.Perkiraan = b.Perkiraan
        WHERE a.Bulan = @BulanPrevious AND a.Tahun = @TahunPrevious
          AND (@Devisi IS NULL OR a.Devisi = @Devisi)
    ) prev ON curr.Perkiraan = prev.Perkiraan;
    
    -- Return analysis results
    SELECT * FROM #TempAnalysis
    ORDER BY ABS(Variance) DESC;
    
    -- Summary statistics
    SELECT 
        'ANALYSIS_SUMMARY' AS ReportType,
        COUNT(*) AS TotalItems,
        SUM(NilaiCurrent) AS TotalCurrent,
        SUM(NilaiPrevious) AS TotalPrevious,
        SUM(Variance) AS TotalVariance,
        AVG(VariancePercent) AS AvgVariancePercent,
        COUNT(CASE WHEN Variance > 0 THEN 1 END) AS ItemsIncreased,
        COUNT(CASE WHEN Variance < 0 THEN 1 END) AS ItemsDecreased,
        COUNT(CASE WHEN Variance = 0 THEN 1 END) AS ItemsUnchanged
    FROM #TempAnalysis;
    
    DROP TABLE #TempAnalysis;
END
GO

-- =====================================================
-- EXPORT VERSION FOR REPORTING
-- =====================================================

-- Procedure optimized for report generation
CREATE PROCEDURE [dbo].[sp_AmbilNilaiPasar_Export]
    @Bulan INT,
    @Tahun INT,
    @Devisi VARCHAR(10) = NULL,
    @FormatOutput VARCHAR(10) = 'DETAIL' -- 'DETAIL', 'SUMMARY', 'PIVOT'
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @FormatOutput = 'DETAIL'
    BEGIN
        -- Detailed export format
        SELECT 
            ROW_NUMBER() OVER(ORDER BY a.Perkiraan) AS No,
            a.Perkiraan AS [Account Code],
            ISNULL(b.Keterangan, '') AS [Description],
            a.Bulan AS [Month],
            a.Tahun AS [Year],
            ISNULL(a.Devisi, 'ALL') AS [Division],
            FORMAT(ISNULL(a.Awal, 0), '#,##0.00') AS [Acquisition Value],
            FORMAT(0, '#,##0.00') AS [Market Value],
            FORMAT(ISNULL(a.Akhir, 0), '#,##0.00') AS [Ending Balance],
            CONVERT(VARCHAR, GETDATE(), 120) AS [Report Date]
        FROM DBINVESTASIDET a
        LEFT OUTER JOIN DBINVESTASI b ON b.Perkiraan = a.Perkiraan 
        WHERE a.Bulan = @Bulan 
          AND a.Tahun = @Tahun 
          AND ISNULL(a.Akhir, 0) > 0
          AND (@Devisi IS NULL OR ISNULL(a.Devisi, 'ALL') = @Devisi)
        ORDER BY a.Perkiraan;
    END
    ELSE IF @FormatOutput = 'SUMMARY'
    BEGIN
        -- Summary export format
        SELECT 
            ISNULL(a.Devisi, 'ALL') AS [Division],
            COUNT(*) AS [Total Accounts],
            FORMAT(SUM(ISNULL(a.Awal, 0)), '#,##0.00') AS [Total Acquisition],
            FORMAT(SUM(ISNULL(a.Akhir, 0)), '#,##0.00') AS [Total Ending Balance],
            FORMAT(AVG(ISNULL(a.Awal, 0)), '#,##0.00') AS [Avg Acquisition],
            @Bulan AS [Month],
            @Tahun AS [Year]
        FROM DBINVESTASIDET a
        WHERE a.Bulan = @Bulan 
          AND a.Tahun = @Tahun 
          AND ISNULL(a.Akhir, 0) > 0
          AND (@Devisi IS NULL OR ISNULL(a.Devisi, 'ALL') = @Devisi)
        GROUP BY ISNULL(a.Devisi, 'ALL')
        ORDER BY ISNULL(a.Devisi, 'ALL');
    END
    ELSE IF @FormatOutput = 'PIVOT'
    BEGIN
        -- Pivot format showing multiple months
        SELECT 
            a.Perkiraan,
            MAX(b.Keterangan) AS Keterangan,
            SUM(CASE WHEN a.Bulan = 1 THEN ISNULL(a.Awal, 0) ELSE 0 END) AS Jan,
            SUM(CASE WHEN a.Bulan = 2 THEN ISNULL(a.Awal, 0) ELSE 0 END) AS Feb,
            SUM(CASE WHEN a.Bulan = 3 THEN ISNULL(a.Awal, 0) ELSE 0 END) AS Mar,
            SUM(CASE WHEN a.Bulan = 4 THEN ISNULL(a.Awal, 0) ELSE 0 END) AS Apr,
            SUM(CASE WHEN a.Bulan = 5 THEN ISNULL(a.Awal, 0) ELSE 0 END) AS May,
            SUM(CASE WHEN a.Bulan = 6 THEN ISNULL(a.Awal, 0) ELSE 0 END) AS Jun,
            SUM(CASE WHEN a.Bulan = 7 THEN ISNULL(a.Awal, 0) ELSE 0 END) AS Jul,
            SUM(CASE WHEN a.Bulan = 8 THEN ISNULL(a.Awal, 0) ELSE 0 END) AS Aug,
            SUM(CASE WHEN a.Bulan = 9 THEN ISNULL(a.Awal, 0) ELSE 0 END) AS Sep,
            SUM(CASE WHEN a.Bulan = 10 THEN ISNULL(a.Awal, 0) ELSE 0 END) AS Oct,
            SUM(CASE WHEN a.Bulan = 11 THEN ISNULL(a.Awal, 0) ELSE 0 END) AS Nov,
            SUM(CASE WHEN a.Bulan = 12 THEN ISNULL(a.Awal, 0) ELSE 0 END) AS Dec
        FROM DBINVESTASIDET a
        LEFT OUTER JOIN DBINVESTASI b ON b.Perkiraan = a.Perkiraan 
        WHERE a.Tahun = @Tahun 
          AND ISNULL(a.Akhir, 0) > 0
          AND (@Devisi IS NULL OR ISNULL(a.Devisi, 'ALL') = @Devisi)
        GROUP BY a.Perkiraan
        ORDER BY a.Perkiraan;
    END
END
GO

-- =====================================================
-- USAGE EXAMPLES AND TESTING
-- =====================================================

/*
-- Basic usage
EXEC sp_AmbilNilaiPasar @Bulan = 12, @Tahun = 2024, @Devisi = NULL;

-- Extended version with additional features
EXEC sp_AmbilNilaiPasar_Extended 
    @Bulan = 12, 
    @Tahun = 2024, 
    @Devisi = NULL,
    @JenisInvestasi = NULL,
    @MinimalNilai = 1000000;

-- Bulk processing for multiple months
EXEC sp_AmbilNilaiPasar_Bulk 
    @TanggalMulai = '2024-01-01',
    @TanggalSelesai = '2024-12-31',
    @Devisi = NULL;

-- Comparative analysis
EXEC sp_AmbilNilaiPasar_Analysis 
    @BulanCurrent = 12, @TahunCurrent = 2024,
    @BulanPrevious = 11, @TahunPrevious = 2024,
    @Devisi = NULL;

-- Export formats
EXEC sp_AmbilNilaiPasar_Export @Bulan = 12, @Tahun = 2024, @Devisi = NULL, @FormatOutput = 'DETAIL';
EXEC sp_AmbilNilaiPasar_Export @Bulan = 12, @Tahun = 2024, @Devisi = NULL, @FormatOutput = 'SUMMARY';
EXEC sp_AmbilNilaiPasar_Export @Bulan = 12, @Tahun = 2024, @Devisi = NULL, @FormatOutput = 'PIVOT';
*/

-- =====================================================
-- END OF SCRIPT
-- =====================================================