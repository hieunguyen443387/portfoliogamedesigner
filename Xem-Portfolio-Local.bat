@echo off
chcp 65001 >nul
title Portfolio local - http://localhost:8765
echo.
echo  ============================================================
echo    PORTFOLIO CHAY LOCAL - KHONG CAN DEPLOY LEN GIT
echo    Dia chi: http://localhost:8765/index.html
echo    YouTube se phat ngay trong web (het loi 153).
echo.
echo    Giua cua so nay de server chay. Nhan Ctrl+C de tat.
echo  ============================================================
echo.
start "" "http://localhost:8765/index.html"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0serve-local.ps1"
