-- Insert Report Menu Items for SQL Server 2008
-- Compatible with SQL Server 2008 syntax

PRINT '📋 Starting report menu setup...'

-- Check and insert group menu "Laporan-laporan"
IF NOT EXISTS (SELECT KODEMENU FROM DBMENU WHERE KODEMENU = '9000')
BEGIN
    INSERT INTO DBMENU (KODEMENU, Keterangan, L0, ACCESS)
    VALUES ('9000', 'Laporan-laporan', 0, 1)

    PRINT '✅ Inserted group menu: Laporan-laporan (9000)'
END
ELSE
BEGIN
    PRINT 'ℹ️ Group menu already exists: Laporan-laporan (9000)'
END

-- Check and insert submenu "Laporan"
IF NOT EXISTS (SELECT KODEMENU FROM DBMENU WHERE KODEMENU = '9001')
BEGIN
    INSERT INTO DBMENU (KODEMENU, Keterangan, L0, ACCESS)
    VALUES ('9001', 'Laporan', 1, 1)

    PRINT '✅ Inserted submenu: Laporan (9001)'
END
ELSE
BEGIN
    PRINT 'ℹ️ Submenu already exists: Laporan (9001)'
END

-- Add permissions for ADMIN user
IF NOT EXISTS (SELECT USERID FROM DBFLMENU WHERE USERID = 'ADMIN' AND L1 = '9001')
BEGIN
    INSERT INTO DBFLMENU (USERID, L1, HASACCESS, ISTAMBAH, ISKOREKSI, ISHAPUS, ISCETAK, ISEXPORT, TIPE)
    VALUES ('ADMIN', '9001', 1, 0, 0, 0, 1, 1, 'MENU')

    PRINT '✅ Added report permissions for user: ADMIN'
END
ELSE
BEGIN
    PRINT 'ℹ️ Report permissions already exist for user: ADMIN'
END

-- Add permissions for SA user
IF NOT EXISTS (SELECT USERID FROM DBFLMENU WHERE USERID = 'SA' AND L1 = '9001')
BEGIN
    INSERT INTO DBFLMENU (USERID, L1, HASACCESS, ISTAMBAH, ISKOREKSI, ISHAPUS, ISCETAK, ISEXPORT, TIPE)
    VALUES ('SA', '9001', 1, 0, 0, 0, 1, 1, 'MENU')

    PRINT '✅ Added report permissions for user: SA'
END
ELSE
BEGIN
    PRINT 'ℹ️ Report permissions already exist for user: SA'
END

-- Verify the menu structure
PRINT '📊 Current menu structure:'
SELECT
    KODEMENU,
    Keterangan,
    L0,
    ACCESS
FROM DBMENU
WHERE KODEMENU IN ('9000', '9001')
ORDER BY L0, KODEMENU

-- Verify permissions
PRINT '👥 Current permissions:'
SELECT
    USERID,
    L1,
    HASACCESS,
    ISCETAK,
    ISEXPORT
FROM DBFLMENU
WHERE L1 = '9001'
ORDER BY USERID

PRINT '🎉 Report menu setup completed successfully!'
PRINT '📋 Menu structure:'
PRINT '   📁 Laporan-laporan (9000, L0=0) - Group'
PRINT '   📊 Laporan (9001, L0=1) - Menu Item'
PRINT '👥 Users with access: ADMIN, SA'
PRINT '✅ Ready for frontend integration testing!'