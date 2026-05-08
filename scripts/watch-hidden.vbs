' Hidden launcher for the wow-config watcher. Scheduled Task uses wscript.exe
' to invoke this .vbs, which then spawns PowerShell with no console window.
'
' Why this exists: powershell.exe -WindowStyle Hidden in a Scheduled Task can
' still flash or leave a minimized console because conhost.exe attaches before
' PS evaluates the flag. VBScript via wscript.exe doesn't allocate a console
' and uses CreateProcess SW_HIDE, so the watcher is truly invisible.

Set objShell = CreateObject("WScript.Shell")
strScriptDir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
strWatchPath = strScriptDir & "\watch.ps1"

' Run params: command, windowStyle (0 = hidden), waitOnReturn (False = async)
objShell.Run "powershell.exe -ExecutionPolicy Bypass -NoProfile -NonInteractive -File """ & strWatchPath & """", 0, False
