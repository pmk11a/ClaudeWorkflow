{{--
    Period Selector Modal Component

    Modal for selecting work period (month/year)
--}}

<!-- Period Selection Modal -->
<div class="modal fade" id="periodModal" tabindex="-1" aria-labelledby="periodModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="periodModalLabel">
                    <i class="fas fa-calendar-alt me-2"></i>
                    Pilih Periode Kerja
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="periodForm">
                    <div class="mb-3">
                        <label for="periodMonth" class="form-label">Bulan</label>
                        <select class="form-select" id="periodMonth" name="month">
                            @for($m = 1; $m <= 12; $m++)
                                <option value="{{ sprintf('%02d', $m) }}" {{ $m == date('n') ? 'selected' : '' }}>
                                    {{ sprintf('%02d', $m) }} - {{ DateTime::createFromFormat('!m', $m)->format('F') }}
                                </option>
                            @endfor
                        </select>
                    </div>
                    <div class="mb-3">
                        <label for="periodYear" class="form-label">Tahun</label>
                        <select class="form-select" id="periodYear" name="year">
                            @for($y = date('Y') - 5; $y <= date('Y') + 1; $y++)
                                <option value="{{ $y }}" {{ $y == date('Y') ? 'selected' : '' }}>{{ $y }}</option>
                            @endfor
                        </select>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
                <button type="button" class="btn btn-primary" id="savePeriod">
                    <i class="fas fa-save me-1"></i>
                    Simpan
                </button>
            </div>
        </div>
    </div>
</div>