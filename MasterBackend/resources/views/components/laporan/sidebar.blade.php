{{-- Laporan Dashboard Sidebar Component --}}
<div class="sidebar" id="sidebar">
    <div class="sidebar-header">
        <h3>
            <span>📊</span>
            <span>Daftar Laporan</span>
        </h3>
    </div>

    <div class="search-box">
        <input type="text" placeholder="Cari laporan..." onkeyup="searchReports(this.value)">
    </div>

    <div class="menu-sections">
        @foreach($reports as $categoryKey => $category)
            {{-- Show top-level category (Master Accounting, Accounting) --}}
            <div class="menu-section">
                <div class="menu-category menu-parent" onclick="toggleSubmenu('{{ $categoryKey }}')">
                    <div class="icon">📁</div>
                    <span>{{ $category['title'] }}</span>
                </div>

                {{-- Show children of top-level category --}}
                <div class="submenu" id="submenu-{{ $categoryKey }}">
                    @if(isset($category['children']))
                        @foreach($category['children'] as $subCategoryKey => $subCategory)
                            @if($subCategory['is_report'])
                                {{-- Direct report item --}}
                                <div class="submenu-item" onclick="selectReport('{{ $subCategory['code'] }}', '{{ $subCategory['title'] }}')">
                                    {{ $subCategory['title'] }}
                                </div>
                            @else
                                {{-- Sub-category with its own children --}}
                                <div class="submenu-category" onclick="toggleSubmenu('{{ $subCategoryKey }}')">
                                    <div class="icon">📁</div>
                                    <span>{{ $subCategory['title'] }}</span>
                                </div>
                                <div class="submenu nested" id="submenu-{{ $subCategoryKey }}">
                                    @if(isset($subCategory['children']))
                                        @foreach($subCategory['children'] as $childCode => $child)
                                            @if($child['is_report'])
                                                <div class="submenu-item" onclick="selectReport('{{ $child['code'] }}', '{{ $child['title'] }}')">
                                                    {{ $child['title'] }}
                                                </div>
                                            @else
                                                @if(!empty($child['children']))
                                                    <div class="submenu-category" style="font-weight: 600; color: #444; margin: 8px 0 5px 0; font-size: 0.95em; border-bottom: 1px solid #eee;">
                                                        📂 {{ $child['title'] }}
                                                    </div>
                                                    @foreach($child['children'] as $grandChildCode => $grandChild)
                                                        @if($grandChild['is_report'])
                                                            <div class="submenu-item" onclick="selectReport('{{ $grandChild['code'] }}', '{{ $grandChild['title'] }}')" style="padding-left: 20px;">
                                                                {{ $grandChild['title'] }}
                                                            </div>
                                                        @endif
                                                    @endforeach
                                                @endif
                                            @endif
                                        @endforeach
                                    @endif
                                </div>
                            @endif
                        @endforeach
                    @endif
                </div>
            </div>
        @endforeach
    </div>
</div>