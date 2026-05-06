@echo off
REM Double-click this file to install wow-config.
REM Wraps install.ps1 — handles ExecutionPolicy and shows output.
echo.
echo === wow-config installer ===
echo.
echo This will:
echo   1. Find your WoW Anniversary install
echo   2. Copy custom addons (SetupCore, ChatAnchor, ShamanSetup, DruidSetup)
echo   3. Install bindings + recommended CVar defaults
echo   4. Set up auto-config-on-first-login
echo.
echo Make sure WoW is closed before continuing.
echo.
pause
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "iex (iwr 'https://raw.githubusercontent.com/rymiwe/wow-config/main/install.ps1').Content"
echo.
echo === Install complete ===
echo Launch WoW and log in. Spells will auto-place via /setupbars on first login.
echo.
pause
