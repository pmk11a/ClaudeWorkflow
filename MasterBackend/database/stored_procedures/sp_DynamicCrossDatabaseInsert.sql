-- =============================================
-- Author: System Generated
-- Create date: $(Date)
-- Description: Dynamic Cross-Database INSERT Procedure - SQL Server 2008 Compatible
-- Procedure ini dapat digunakan untuk INSERT data dari satu database ke database lain
-- dengan otomatis menganalisis struktur tabel dan mengisi field required dengan default values
-- Compatible with SQL Server 2008
-- =============================================

CREATE PROCEDURE [dbo].[sp_DynamicCrossDatabaseInsert]
    @SourceDatabase NVARCHAR(128),      -- Database sumber (misal: dbykka24)
    @TargetDatabase NVARCHAR(128),      -- Database tujuan (misal: DbDapenka2)
    @TableName NVARCHAR(128),           -- Nama tabel (misal: DBCUSTSUPP)
    @SourceFields NVARCHAR(4000),       -- Field yang ingin di-copy (misal: 'Kodecustsupp,namacustsupp') - MAX tidak support di 2008 untuk parameter
    @WhereCondition NVARCHAR(4000) = '', -- Optional WHERE condition untuk filter data
    @ExecuteQuery BIT = 1,              -- 1 = Execute, 0 = Show Query Only
    @Debug BIT = 0                      -- 1 = Show debug info, 0 = Normal execution
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @FieldList NVARCHAR(MAX);
    DECLARE @ValuesList NVARCHAR(MAX);
    DECLARE @ErrorMsg NVARCHAR(500);
    
    -- Initialize variables (SQL 2008 doesn't support DECLARE with assignment in one line)
    SET @SQL = '';
    SET @FieldList = '';
    SET @ValuesList = '';
    
    BEGIN TRY
        -- Validasi parameter
        IF @SourceDatabase = '' OR @TargetDatabase = '' OR @TableName = '' OR @SourceFields = ''
        BEGIN
            RAISERROR('Parameter SourceDatabase, TargetDatabase, TableName, dan SourceFields harus diisi!', 16, 1);
            RETURN;
        END
        
        -- Buat temporary table untuk menyimpan informasi kolom
        IF OBJECT_ID('tempdb..#TableColumns') IS NOT NULL DROP TABLE #TableColumns;
        
        CREATE TABLE #TableColumns (
            COLUMN_NAME NVARCHAR(128),
            DATA_TYPE NVARCHAR(128),
            IS_NULLABLE VARCHAR(3),
            COLUMN_DEFAULT NVARCHAR(4000),  -- MAX not fully supported in temp tables in SQL 2008
            CHARACTER_MAXIMUM_LENGTH INT,
            NUMERIC_PRECISION TINYINT,
            NUMERIC_SCALE INT,
            IS_REQUIRED BIT,
            IS_SOURCE_FIELD BIT,
            DEFAULT_VALUE NVARCHAR(4000)    -- MAX not fully supported in temp tables in SQL 2008
        );
        
        -- Initialize BIT fields (DEFAULT not supported in temp table CREATE in SQL 2008)
        -- We'll set defaults after INSERT
        
        -- Ambil informasi kolom dari target table
        SET @SQL = '
        INSERT INTO #TableColumns (COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, NUMERIC_SCALE, IS_REQUIRED, IS_SOURCE_FIELD)
        SELECT 
            COLUMN_NAME,
            DATA_TYPE,
            IS_NULLABLE,
            COLUMN_DEFAULT,
            CHARACTER_MAXIMUM_LENGTH,
            NUMERIC_PRECISION,
            NUMERIC_SCALE,
            0, -- IS_REQUIRED default
            0  -- IS_SOURCE_FIELD default
        FROM ' + @TargetDatabase + '.INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_NAME = ''' + @TableName + '''
        ORDER BY ORDINAL_POSITION';
        
        IF @Debug = 1 PRINT 'Getting table structure: ' + @SQL;
        EXEC sp_executesql @SQL;
        
        -- Mark required fields (NOT NULL without default)
        UPDATE #TableColumns 
        SET IS_REQUIRED = 1
        WHERE IS_NULLABLE = 'NO' 
        AND (COLUMN_DEFAULT IS NULL OR COLUMN_DEFAULT = '');
        
        -- Mark source fields yang akan di-copy
        DECLARE @Field NVARCHAR(128);
        DECLARE @Pos INT;
        DECLARE @SourceFieldsClean NVARCHAR(4000);
        
        -- Initialize variables
        SET @Pos = 1;
        SET @SourceFieldsClean = LTRIM(RTRIM(@SourceFields)) + ',';
        
        WHILE @Pos <= LEN(@SourceFieldsClean)
        BEGIN
            SET @Field = LTRIM(RTRIM(SUBSTRING(@SourceFieldsClean, @Pos, CHARINDEX(',', @SourceFieldsClean, @Pos) - @Pos)));
            IF @Field <> ''
            BEGIN
                UPDATE #TableColumns 
                SET IS_SOURCE_FIELD = 1 
                WHERE UPPER(COLUMN_NAME) = UPPER(@Field);
            END
            SET @Pos = CHARINDEX(',', @SourceFieldsClean, @Pos) + 1;
        END
        
        -- Generate default values untuk required fields
        UPDATE #TableColumns 
        SET DEFAULT_VALUE = 
            CASE 
                WHEN DATA_TYPE IN ('varchar', 'nvarchar', 'char', 'nchar', 'text', 'ntext') THEN '''''' 
                WHEN DATA_TYPE IN ('int', 'bigint', 'smallint', 'tinyint', 'numeric', 'decimal', 'float', 'real', 'money', 'smallmoney') THEN '0'
                WHEN DATA_TYPE IN ('bit') THEN '0'
                WHEN DATA_TYPE IN ('datetime', 'smalldatetime') THEN 'GETDATE()'  -- datetime2, date, time not in SQL 2008
                WHEN DATA_TYPE IN ('uniqueidentifier') THEN 'NEWID()'
                ELSE 'NULL'
            END
        WHERE IS_REQUIRED = 1 AND IS_SOURCE_FIELD = 0;
        
        -- Build field list untuk INSERT using CURSOR (SQL 2008 compatible way)
        DECLARE field_cursor CURSOR FOR
        SELECT COLUMN_NAME
        FROM #TableColumns 
        WHERE IS_SOURCE_FIELD = 1 OR IS_REQUIRED = 1
        ORDER BY CASE WHEN IS_SOURCE_FIELD = 1 THEN 1 ELSE 2 END;
        
        DECLARE @CurrentField NVARCHAR(128);
        OPEN field_cursor;
        FETCH NEXT FROM field_cursor INTO @CurrentField;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF @FieldList = ''
                SET @FieldList = '[' + @CurrentField + ']';
            ELSE
                SET @FieldList = @FieldList + ', [' + @CurrentField + ']';
            
            FETCH NEXT FROM field_cursor INTO @CurrentField;
        END
        
        CLOSE field_cursor;
        DEALLOCATE field_cursor;
        
        -- Build values list untuk SELECT using CURSOR
        DECLARE values_cursor CURSOR FOR
        SELECT COLUMN_NAME, IS_SOURCE_FIELD, DEFAULT_VALUE
        FROM #TableColumns 
        WHERE IS_SOURCE_FIELD = 1 OR IS_REQUIRED = 1
        ORDER BY CASE WHEN IS_SOURCE_FIELD = 1 THEN 1 ELSE 2 END;
        
        DECLARE @IsSourceField BIT, @DefaultVal NVARCHAR(4000);
        OPEN values_cursor;
        FETCH NEXT FROM values_cursor INTO @CurrentField, @IsSourceField, @DefaultVal;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            DECLARE @ValuePart NVARCHAR(4000);
            IF @IsSourceField = 1
                SET @ValuePart = '[' + @CurrentField + ']';
            ELSE
                SET @ValuePart = ISNULL(@DefaultVal, 'NULL') + ' AS [' + @CurrentField + ']';
            
            IF @ValuesList = ''
                SET @ValuesList = @ValuePart;
            ELSE
                SET @ValuesList = @ValuesList + ', ' + @ValuePart;
            
            FETCH NEXT FROM values_cursor INTO @CurrentField, @IsSourceField, @DefaultVal;
        END
        
        CLOSE values_cursor;
        DEALLOCATE values_cursor;
        
        -- Build final INSERT statement
        SET @SQL = 'INSERT INTO ' + @TargetDatabase + '..' + @TableName + ' (' + @FieldList + ')' + CHAR(13) +
                   'SELECT ' + @ValuesList + CHAR(13) +
                   'FROM ' + @SourceDatabase + '..' + @TableName;
                   
        IF @WhereCondition <> ''
            SET @SQL = @SQL + CHAR(13) + 'WHERE ' + @WhereCondition;
        
        -- Show debug info jika diminta
        IF @Debug = 1
        BEGIN
            PRINT '=== TABLE STRUCTURE ANALYSIS ===';
            SELECT * FROM #TableColumns ORDER BY IS_SOURCE_FIELD DESC, COLUMN_NAME;
            
            PRINT '=== GENERATED QUERY ===';
            PRINT @SQL;
        END
        
        -- Execute atau show query
        IF @ExecuteQuery = 1
        BEGIN
            PRINT 'Executing query...';
            EXEC sp_executesql @SQL;
            PRINT 'Query executed successfully!';
        END
        ELSE
        BEGIN
            PRINT '=== GENERATED QUERY (NOT EXECUTED) ===';
            PRINT @SQL;
        END
        
    END TRY
    BEGIN CATCH
        SET @ErrorMsg = ERROR_MESSAGE();
        PRINT 'Error: ' + @ErrorMsg;
        
        IF @Debug = 1
        BEGIN
            PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR(10));
            PRINT 'Error Procedure: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
        END
        
        RAISERROR(@ErrorMsg, 16, 1);
    END CATCH
    
    -- Cleanup
    IF OBJECT_ID('tempdb..#TableColumns') IS NOT NULL DROP TABLE #TableColumns;
END

GO

-- =============================================
-- CONTOH PENGGUNAAN:
-- =============================================

-- 1. BASIC USAGE - Copy specific fields
-- EXEC sp_DynamicCrossDatabaseInsert 
--     @SourceDatabase = 'dbykka24',
--     @TargetDatabase = 'DbDapenka2', 
--     @TableName = 'DBCUSTSUPP',
--     @SourceFields = 'Kodecustsupp,namacustsupp'

-- 2. WITH WHERE CONDITION - Copy dengan filter
-- EXEC sp_DynamicCrossDatabaseInsert 
--     @SourceDatabase = 'dbykka24',
--     @TargetDatabase = 'DbDapenka2', 
--     @TableName = 'DBCUSTSUPP',
--     @SourceFields = 'Kodecustsupp,namacustsupp',
--     @WhereCondition = 'IsAktif = 1'

-- 3. DEBUG MODE - Lihat analisis tabel dan query yang dibuat
-- EXEC sp_DynamicCrossDatabaseInsert 
--     @SourceDatabase = 'dbykka24',
--     @TargetDatabase = 'DbDapenka2', 
--     @TableName = 'DBCUSTSUPP',
--     @SourceFields = 'Kodecustsupp,namacustsupp',
--     @Debug = 1,
--     @ExecuteQuery = 0

-- 4. SHOW QUERY ONLY - Lihat query tanpa execute
-- EXEC sp_DynamicCrossDatabaseInsert 
--     @SourceDatabase = 'dbykka24',
--     @TargetDatabase = 'DbDapenka2', 
--     @TableName = 'DBCUSTSUPP',
--     @SourceFields = 'Kodecustsupp,namacustsupp',
--     @ExecuteQuery = 0
