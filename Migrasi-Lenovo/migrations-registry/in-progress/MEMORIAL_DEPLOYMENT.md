# Memorial Module - Deployment Guide (Phase 1)

**Version**: 1.0.0-P1
**Date**: 2026-01-17
**Environment**: Testing
**Module**: Memorial (Journal Entry) - 03017

---

## 📋 Pre-Deployment Checklist

### ✅ Code Quality
- [x] PSR-12 formatted (Laravel Pint)
- [x] PHP syntax validated
- [x] No SQL injection vulnerabilities
- [x] Type hints on all methods
- [x] PHPDoc comments with Delphi references
- [x] Database transactions used
- [x] Exception handling implemented

### ✅ Routes
- [x] 46 Memorial routes registered
- [x] API routes: GET, POST, PUT, DELETE
- [x] Web routes: index, create, edit, show
- [x] Authorization routes
- [x] Hutang/Piutang, Giro, Aktiva sub-routes

### ✅ Database
- [x] Tables exist (no migrations needed):
  - dbTransaksi (master)
  - dbTrans (details)
  - dbGiro
  - dbAktiva, dbAktivadet
  - dbHutPiut
  - dbTempHutPiut
  - dbPerkiraan
  - dbValas, dbValasdet
  - dbDevisi
  - dbMenu, dbFlMenu

### ✅ Permissions
- [x] MemorialPolicy registered in AuthServiceProvider
- [x] Menu code: 03017
- [x] Permissions mapped:
  - IsTambah → ADD_FL
  - IsKoreksi → EDIT_FL
  - IsHapus → DEL_FL
  - IsCetak → PRINT_FL
  - IsExcel → EXPORT_FL

---

## 📦 Deployment Package

### New Files (6)
```
app/Policies/MemorialPolicy.php
app/Http/Requests/Memorial/StoreMemorialRequest.php
app/Http/Requests/Memorial/UpdateMemorialRequest.php
app/Http/Requests/Memorial/DeleteMemorialRequest.php
migrations-registry/in-progress/MEMORIAL_GAP_ANALYSIS.md
migrations-registry/in-progress/MEMORIAL_P0_SUMMARY.md
```

### Modified Files (3)
```
app/Services/MemorialService.php
app/Http/Controllers/MemorialController.php
app/Providers/AuthServiceProvider.php
```

### Existing Files (Referenced, not changed)
```
app/Models/Memorial.php
app/Models/MemorialDetail.php
app/Models/Aktiva.php
app/Models/Giro.php
app/Models/HutangPiutang.php
app/Models/TempHutPiutang.php
app/Services/HutangPiutangMemorialService.php
app/Services/OtorisasiService.php
```

---

## 🚀 Deployment Steps

### 1. Backup (5 minutes)
```bash
# Backup database
mysqldump -u sa -p dbwbcp2 > backup_memorial_$(date +%Y%m%d_%H%M%S).sql

# Backup code (if deploying to existing server)
cp -r app/Services/MemorialService.php app/Services/MemorialService.php.bak.$(date +%Y%m%d)
cp -r app/Http/Controllers/MemorialController.php app/Http/Controllers/MemorialController.php.bak.$(date +%Y%m%d)
```

### 2. Deploy Code (2 minutes)
```bash
# Pull from git or copy files
git pull origin feature/memorial-phase1

# Or manually copy files to server
# scp -r app/Policies/MemorialPolicy.php user@server:/path/to/app/Policies/
# scp -r app/Http/Requests/Memorial/ user@server:/path/to/app/Http/Requests/
# ... (copy all files)
```

### 3. Clear Caches (1 minute)
```bash
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
composer dump-autoload
```

### 4. Verify Deployment (2 minutes)
```bash
# Check routes
php artisan route:list --name=memorial

# Check Policy is registered
php artisan tinker
>>> app()->make('Illuminate\Contracts\Auth\Access\Gate')->policies();
# Should show Memorial => MemorialPolicy

# PHP syntax check
php -l app/Services/MemorialService.php
php -l app/Http/Controllers/MemorialController.php
php -l app/Policies/MemorialPolicy.php
```

---

## 🧪 Testing Checklist

### Manual Testing Required

#### Test 1: Create Memorial (IsTambah Permission)
**User**: User with IsTambah=T for menu 03017

1. Navigate to `/memorial/create`
2. Fill form:
   - No. Bukti: TEST001
   - Tanggal: Today
   - Divisi: 01
   - Detail line 1:
     - Perkiraan: 1101 (Cash)
     - Lawan: 3101 (Modal)
     - Debet: 1000000
     - Kredit: 0
     - Valas: IDR
     - Kurs: 1
   - Detail line 2:
     - Perkiraan: 3101 (Modal)
     - Lawan: 1101 (Cash)
     - Debet: 0
     - Kredit: 1000000
     - Valas: IDR
     - Kurs: 1
3. Click Save
4. **Expected**: Success, transaction created, NoBukti = TEST001

**Validations to Test**:
- ✅ VAL1: Required fields (try empty NoBukti → should error)
- ✅ VAL4: Perkiraan = Lawan (try same account → should error)
- ✅ VAL6: Debit != Credit (try 1000000 vs 900000 → should error)
- ✅ VAL7: IDR with Kurs != 1 (try Kurs=14000 → should error)

---

#### Test 2: Update Memorial (IsKoreksi Permission)
**User**: User with IsKoreksi=T

1. Navigate to `/memorial/TEST001/edit`
2. Modify detail line 1 amount: 1500000
3. Modify detail line 2 amount: 1500000
4. Click Update
5. **Expected**: Success, changes saved

**Validations**:
- ✅ Same validations as Create
- ✅ Period lock (if period locked → should error)

---

#### Test 3: Delete Memorial (IsHapus Permission)
**User**: User with IsHapus=T

**Test 3A: Delete WITHOUT Giro**
1. Create test transaction TEST002 (no Giro)
2. Click Delete on TEST002
3. **Expected**: Success, transaction deleted

**Test 3B: Delete WITH Cleared Giro** (VAL5)
1. Create test transaction TEST003 with Giro
2. Manually update dbGiro: SET TglCair = GETDATE() WHERE BuktiBuka = 'TEST003'
3. Try to delete TEST003
4. **Expected**: Error message showing:
   - "Bank XXX No. Giro YYY Tgl Giro ZZZ telah ada Pencairan pada No Transaksi: AAA Tanggal BBB"

---

#### Test 4: Permissions (Authorization)
**Test 4A: No IsTambah**
1. Login as user with IsTambah=F
2. Navigate to `/memorial/create`
3. Try to create
4. **Expected**: 403 Forbidden

**Test 4B: No IsKoreksi**
1. Login as user with IsKoreksi=F
2. Navigate to `/memorial/TEST001/edit`
3. Try to update
4. **Expected**: 403 Forbidden

**Test 4C: No IsHapus**
1. Login as user with IsHapus=F
2. Try to delete TEST001
3. **Expected**: 403 Forbidden

---

#### Test 5: Multi-Currency (VAL7)
1. Create transaction with USD detail:
   - Perkiraan: 1102 (Bank USD)
   - Lawan: 4101 (Revenue)
   - Debet: 1000
   - Kredit: 0
   - Valas: USD
   - Kurs: 15000
2. Create opposite line:
   - Perkiraan: 4101
   - Lawan: 1102
   - Debet: 0
   - Kredit: 1000
   - Valas: USD
   - Kurs: 15000
3. **Expected**: Success

**Test 5B: Invalid Kurs**
1. Same as above but set Kurs=1 for USD
2. **Expected**: Error "Kurs untuk valas non-IDR harus > 0"

---

#### Test 6: Period Lock (VAL3)
1. Lock current period:
   ```sql
   INSERT INTO DBLOCKPERIODE (BULAN, TAHUN) VALUES (1, 2026)
   ```
2. Try to create/update/delete memorial with Tanggal in January 2026
3. **Expected**: Error "Periode telah terkunci !"

---

## 🐛 Known Issues / Limitations (Phase 1)

### ⚠️ Not Implemented Yet (Phase 2)
1. **VAL2**: HutPiut balance validation
   - **Impact**: Can create HutPiut transactions without matching invoice totals
   - **Workaround**: Manual verification required
   - **Fix**: Phase 2 (P1)

2. **BL5**: HutPiut integration
   - **Impact**: HutPiut matching UI not connected to Memorial save
   - **Workaround**: Manual data entry
   - **Fix**: Phase 2 (P1)

3. **BL6**: Exchange rate auto-lookup
   - **Impact**: Must manually enter Kurs (doesn't auto-fetch from dbValasdet)
   - **Workaround**: Lookup manually from dbValasdet table
   - **Fix**: Phase 2 (P1)

4. **BL3**: Aktiva integration
   - **Impact**: Aktiva UI exists but not fully integrated with Memorial save
   - **Workaround**: Use existing Aktiva module separately
   - **Fix**: Phase 3 (P2)

5. **BL4**: Giro integration
   - **Impact**: Giro UI exists but not fully integrated with Memorial save
   - **Workaround**: Use existing Giro module separately
   - **Fix**: Phase 3 (P2)

### ✅ What Works
- Basic CRUD (Create, Read, Update, Delete)
- All permissions (IsTambah, IsKoreksi, IsHapus, IsCetak, IsExcel)
- Period locking
- Debit=Credit balance validation
- Multi-currency validation
- Giro clearing check on delete
- Perkiraan != Lawan validation

---

## 📊 Monitoring

### Logs to Watch
```bash
# Application logs
tail -f storage/logs/laravel.log | grep Memorial

# Database query logs (if enabled)
tail -f storage/logs/query.log | grep "dbTransaksi\|dbTrans"
```

### Key Events to Monitor
- `Memorial created` - Successful creation
- `Memorial updated` - Successful update
- `Memorial deleted` - Successful deletion
- `Memorial creation failed` - Error during creation
- `Memorial deletion failed` - Error during deletion (check for Giro clearing)

---

## 🔄 Rollback Plan (If Issues Found)

### Option 1: Quick Rollback (Restore Backup)
```bash
# Restore code
cp app/Services/MemorialService.php.bak.YYYYMMDD app/Services/MemorialService.php
cp app/Http/Controllers/MemorialController.php.bak.YYYYMMDD app/Http/Controllers/MemorialController.php

# Remove new files
rm -r app/Policies/MemorialPolicy.php
rm -r app/Http/Requests/Memorial/

# Clear caches
php artisan cache:clear
php artisan route:clear
composer dump-autoload
```

### Option 2: Disable Policy (Keep Code, Disable Permissions)
```php
// In app/Providers/AuthServiceProvider.php
// Comment out:
// \App\Models\Memorial::class => \App\Policies\MemorialPolicy::class,
```

### Option 3: Database Rollback (If Data Corrupted)
```bash
# Restore database from backup
mysql -u sa -p dbwbcp2 < backup_memorial_YYYYMMDD_HHMMSS.sql
```

---

## 📞 Support Contacts

**If Issues Found**:
1. Check logs: `storage/logs/laravel.log`
2. Check database: Verify data in dbTransaksi, dbTrans
3. Check permissions: Verify DBFLMENU table for menu 03017
4. Contact: [Your support contact]

---

## 📝 Post-Deployment Tasks

### After 24 Hours
- [ ] Review logs for errors
- [ ] Collect user feedback
- [ ] Verify no data corruption in dbTransaksi/dbTrans
- [ ] Check for any permission issues
- [ ] Document any issues found

### After 1 Week
- [ ] Decide on Phase 2 (P1) implementation
- [ ] Prioritize: HutPiut integration vs Exchange rate vs Aktiva/Giro
- [ ] Plan automated testing

---

## ✅ Deployment Sign-Off

**Deployed By**: _________________
**Date**: _________________
**Environment**: Testing
**Version**: 1.0.0-P1
**Status**: ☐ Success  ☐ Issues Found  ☐ Rolled Back

**Notes**:
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

---

**References**:
- Gap Analysis: `migrations-registry/in-progress/MEMORIAL_GAP_ANALYSIS.md`
- Summary: `migrations-registry/in-progress/MEMORIAL_P0_SUMMARY.md`
- Specification: `migrations-registry/in-progress/MEMORIAL_SPEC.md`

**Next Phase**: Phase 2 (P1) - HutPiut Integration (5 hours estimated)
