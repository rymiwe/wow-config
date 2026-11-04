@echo off
REM Double-click to install the WoW: Forever kit (bars + binds + CVars + ElvUI
REM profile + ElvUI/Questie/BadBoy/OPie). No SetupCore/class addons on Forever.
echo.
echo === wow-config: WoW Forever kit ===
echo Make sure WoW is closed and you have launched WoW: Forever once.
echo.
pause
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "& ([scriptblock]::Create((iwr 'https://raw.githubusercontent.com/rymiwe/wow-config/main/install.ps1' -UseBasicParsing).Content)) -Flavor _forever_"
echo.
echo === Done === Launch WoW: Forever. Close the ElvUI wizard with the X if it appears.
echo.
pause
