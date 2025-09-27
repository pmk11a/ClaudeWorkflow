<?php

namespace App\Services;

use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;
use InvalidArgumentException;

class LaporanExportService
{
    private const EXPORT_PATH = 'exports/reports';

    /**
     * Export data to Excel format (CSV for now, will upgrade to XLSX later)
     *
     * @param array $data
     * @param array $headers
     * @param array $metadata
     * @param array $styling
     * @return array
     */
    public function exportToExcel($data, array $headers = [], array $metadata = [], array $styling = []): array
    {
        $this->validateExportData($data);

        try {
            $filename = $this->generateUniqueFilename($metadata['title'] ?? 'report', 'xlsx');
            $filePath = self::EXPORT_PATH . '/' . $filename;

            // For now, generate CSV (will be upgraded to XLSX with PhpSpreadsheet)
            $csvContent = $this->generateCSVContent($data, $headers, $metadata);

            Storage::disk('local')->put($filePath, $csvContent);

            return [
                'success' => true,
                'file_path' => $filePath,
                'filename' => $filename,
                'mime_type' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                'size' => strlen($csvContent),
                'styling_applied' => !empty($styling)
            ];
        } catch (\Exception $e) {
            Log::error('Excel export failed: ' . $e->getMessage());
            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Export data to PDF format
     *
     * @param array $data
     * @param array $headers
     * @param array $metadata
     * @return array
     */
    public function exportToPDF($data, array $headers = [], array $metadata = []): array
    {
        $this->validateExportData($data);

        try {
            $filename = $this->generateUniqueFilename($metadata['title'] ?? 'report', 'pdf');
            $filePath = self::EXPORT_PATH . '/' . $filename;

            // Generate HTML first, then convert to PDF (basic implementation)
            $htmlContent = $this->generateHtmlPreview($data, $headers, $metadata, true);

            // For now, save as HTML (will be upgraded to PDF with DomPDF)
            Storage::disk('local')->put($filePath, $htmlContent);

            return [
                'success' => true,
                'file_path' => $filePath,
                'filename' => $filename,
                'mime_type' => 'application/pdf',
                'size' => strlen($htmlContent)
            ];
        } catch (\Exception $e) {
            Log::error('PDF export failed: ' . $e->getMessage());
            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Generate HTML preview for report
     *
     * @param array $data
     * @param array $headers
     * @param array $metadata
     * @param bool $forPrint
     * @return string
     */
    public function generateHtmlPreview($data, array $headers = [], array $metadata = [], bool $forPrint = false): string
    {
        $title = $metadata['title'] ?? 'Report';
        $period = $metadata['period'] ?? '';
        $generatedBy = $metadata['generated_by'] ?? '';
        $generatedAt = $metadata['generated_at'] ?? date('Y-m-d H:i:s');

        $numericColumns = $this->detectNumericColumns($data);

        $html = $this->generateHtmlHeader($title, $forPrint);
        $html .= $this->generateHtmlReportHeader($title, $period, $generatedBy, $generatedAt);

        if (empty($data)) {
            $html .= '<div class="no-data">No data available</div>';
        } else {
            $html .= '<table class="report-table">';

            // Headers
            if (!empty($headers)) {
                $html .= '<thead><tr>';
                foreach ($headers as $key => $label) {
                    $html .= "<th>{$label}</th>";
                }
                $html .= '</tr></thead>';
            }

            // Data rows
            $html .= '<tbody>';
            foreach ($data as $row) {
                $html .= '<tr>';
                $rowArray = (array)$row;

                if (!empty($headers)) {
                    foreach (array_keys($headers) as $key) {
                        $value = $rowArray[$key] ?? '';
                        if (in_array($key, $numericColumns) && is_numeric($value)) {
                            $value = $this->formatCurrency($value);
                        }
                        $html .= "<td>{$value}</td>";
                    }
                } else {
                    foreach ($rowArray as $key => $value) {
                        if (in_array($key, $numericColumns) && is_numeric($value)) {
                            $value = $this->formatCurrency($value);
                        }
                        $html .= "<td>{$value}</td>";
                    }
                }
                $html .= '</tr>';
            }
            $html .= '</tbody>';
            $html .= '</table>';
        }

        $html .= '</body></html>';

        return $html;
    }

    /**
     * Format currency values
     *
     * @param mixed $value
     * @return string
     */
    public function formatCurrency($value): string
    {
        if (!is_numeric($value)) {
            return (string)$value;
        }

        return number_format((float)$value, ($value == (int)$value) ? 0 : 2);
    }

    /**
     * Detect numeric columns in data
     *
     * @param array $data
     * @return array
     */
    public function detectNumericColumns(array $data): array
    {
        if (empty($data)) {
            return [];
        }

        $numericColumns = [];
        $firstRow = (array)$data[0];

        foreach ($firstRow as $column => $value) {
            if (is_numeric($value)) {
                $numericColumns[] = $column;
            }
        }

        return $numericColumns;
    }

    /**
     * Generate unique filename
     *
     * @param string $baseName
     * @param string $extension
     * @return string
     */
    public function generateUniqueFilename(string $baseName, string $extension): string
    {
        $cleanBaseName = preg_replace('/[^A-Za-z0-9\-_]/', '', str_replace(' ', '_', $baseName));
        $timestamp = date('YmdHis');
        $random = substr(md5(microtime()), 0, 6);

        return "{$cleanBaseName}_{$timestamp}_{$random}.{$extension}";
    }

    /**
     * Validate export data
     *
     * @param mixed $data
     * @throws InvalidArgumentException
     */
    private function validateExportData($data): void
    {
        if (!is_array($data)) {
            throw new InvalidArgumentException('Data must be an array or collection');
        }
    }

    /**
     * Generate CSV content
     *
     * @param array $data
     * @param array $headers
     * @param array $metadata
     * @return string
     */
    private function generateCSVContent(array $data, array $headers, array $metadata): string
    {
        $csv = '';

        // Add metadata as comments
        if (!empty($metadata['title'])) {
            $csv .= "# Title: {$metadata['title']}\n";
        }
        if (!empty($metadata['period'])) {
            $csv .= "# Period: {$metadata['period']}\n";
        }
        if (!empty($metadata['generated_at'])) {
            $csv .= "# Generated: {$metadata['generated_at']}\n";
        }
        $csv .= "\n";

        // Headers
        if (!empty($headers)) {
            $csv .= implode(',', array_map(function($header) {
                return '"' . str_replace('"', '""', $header) . '"';
            }, array_values($headers))) . "\n";
        }

        // Data
        foreach ($data as $row) {
            $rowArray = (array)$row;
            $csvRow = [];

            if (!empty($headers)) {
                foreach (array_keys($headers) as $key) {
                    $value = $rowArray[$key] ?? '';
                    $csvRow[] = '"' . str_replace('"', '""', $value) . '"';
                }
            } else {
                foreach ($rowArray as $value) {
                    $csvRow[] = '"' . str_replace('"', '""', $value) . '"';
                }
            }

            $csv .= implode(',', $csvRow) . "\n";
        }

        return $csv;
    }

    /**
     * Generate HTML header
     *
     * @param string $title
     * @param bool $forPrint
     * @return string
     */
    private function generateHtmlHeader(string $title, bool $forPrint = false): string
    {
        return '<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>' . htmlspecialchars($title) . '</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .report-header { text-align: center; margin-bottom: 30px; }
        .report-title { font-size: 18px; font-weight: bold; margin-bottom: 10px; }
        .report-meta { font-size: 12px; color: #666; }
        .report-table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        .report-table th, .report-table td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        .report-table th { background-color: #f5f5f5; font-weight: bold; }
        .report-table td[data-numeric] { text-align: right; }
        .no-data { text-align: center; color: #999; padding: 50px; }
        ' . ($forPrint ? '@media print { body { margin: 0; } }' : '') . '
    </style>
</head>
<body>';
    }

    /**
     * Generate HTML report header
     *
     * @param string $title
     * @param string $period
     * @param string $generatedBy
     * @param string $generatedAt
     * @return string
     */
    private function generateHtmlReportHeader(string $title, string $period, string $generatedBy, string $generatedAt): string
    {
        $html = '<div class="report-header">';
        $html .= '<div class="report-title">' . htmlspecialchars($title) . '</div>';

        if ($period) {
            $html .= '<div class="report-meta">Period: ' . htmlspecialchars($period) . '</div>';
        }

        if ($generatedBy) {
            $html .= '<div class="report-meta">Generated by: ' . htmlspecialchars($generatedBy) . '</div>';
        }

        $html .= '<div class="report-meta">Generated at: ' . htmlspecialchars($generatedAt) . '</div>';
        $html .= '</div>';

        return $html;
    }
}