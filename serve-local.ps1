# Local static server for the portfolio.
# YouTube embeds need a real HTTP origin (Referer). file:// has none -> Error 153.
# This script serves the folder on http://localhost:8765 so you can test locally
# without deploying to Git.

$root = $PSScriptRoot
$port = 8765
$url  = "http://localhost:$port/"

# Close any older server started from this folder
Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object {
    ($_.CommandLine -like '*serve-local.ps1*' -or $_.CommandLine -like '*serve.ps1*') -and
    $_.Name -like '*powershell*' -and
    $_.ProcessId -ne $PID
} | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }

$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add($url)
try {
    $listener.Start()
} catch {
    Write-Host "Khong the khoi dong server (co the port $port dang duoc su dung): $_" -ForegroundColor Red
    Write-Host "Nhan phim bat ky de thoat..."
    [void][Console]::ReadKey($true)
    exit 1
}

$mime = @{
    '.html' = 'text/html; charset=utf-8'
    '.htm'  = 'text/html; charset=utf-8'
    '.css'  = 'text/css'
    '.js'   = 'application/javascript'
    '.json' = 'application/json'
    '.svg'  = 'image/svg+xml'
    '.png'  = 'image/png'
    '.jpg'  = 'image/jpeg'
    '.jpeg' = 'image/jpeg'
    '.gif'  = 'image/gif'
    '.ico'  = 'image/x-icon'
    '.mp4'  = 'video/mp4'
    '.webm' = 'video/webm'
    '.pdf'  = 'application/pdf'
}

Write-Host ""
Write-Host "  Portfolio dang chay tai: $url" -ForegroundColor Green
Write-Host "  YouTube se PHAT TRUC TIEP tren web (khong con loi 153)." -ForegroundColor Green
Write-Host "  Giua cua so PowerShell nay de server hoat dong. Nhan Ctrl+C de tat." -ForegroundColor Yellow
Write-Host ""

try {
    while ($listener.IsListening) {
        try {
            $ctx = $listener.GetContext()
            $rel = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath.TrimStart('/'))
            if ([string]::IsNullOrEmpty($rel)) { $rel = 'index.html' }
            $rel = $rel -replace '/', [IO.Path]::DirectorySeparatorChar
            $file = [IO.Path]::GetFullPath((Join-Path $root $rel))

            if ($file.StartsWith($root, [StringComparison]::OrdinalIgnoreCase) -and [IO.File]::Exists($file)) {
                $bytes = [IO.File]::ReadAllBytes($file)
                $ext = [IO.Path]::GetExtension($file).ToLowerInvariant()
                $ctx.Response.ContentType = if ($mime.ContainsKey($ext)) { $mime[$ext] } else { 'application/octet-stream' }
                $ctx.Response.ContentLength64 = $bytes.Length
                $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
            } else {
                $ctx.Response.StatusCode = 404
            }
            $ctx.Response.Close()
        } catch {
            # Skip bad requests and keep serving
        }
    }
} finally {
    $listener.Stop()
    $listener.Close()
}
