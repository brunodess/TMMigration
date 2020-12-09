@ECHO OFF
echo Starting ES Fix > c:\temp\TrendMicroESFix.txt 2>&1


goto check_Permissions

:check_Permissions
    echo Detecting Admin permissions...

    net session >nul 2>&1
    if %errorLevel% == 0 (
        echo Success: Administrative permissions confirmed.
		echo Success: Administrative permissions confirmed. >> c:\temp\TrendMicroESFix.txt 2>&1
    ) else (
        echo Failure: Current permissions inadequate. >> c:\temp\TrendMicroESFix.txt 2>&1
		echo Failure: Current permissions inadequate - Run as Administrator. 
		exit /b
    )	

echo ---------------------- Endpoint Sensor Removal Starting ---------------------- >> c:\temp\TrendMicroESFix.txt 2>&1
echo ---------------------- Endpoint Sensor Removal Starting ----------------------
"C:\Program Files\Trend Micro\ESE\ESClient.exe" -c=Unregister >> c:\temp\TrendMicroESFix.txt 2>&1
echo ---- Stopping Services ---- >> c:\temp\TrendMicroESFix.txt 2>&1
echo ---- Stopping Services ----
sc stop ESClient >> c:\temp\TrendMicroESFix.txt 2>&1
PING localhost -n 10 >NUL
sc stop TMESC >> c:\temp\TrendMicroESFix.txt 2>&1
PING localhost -n 10 >NUL
sc stop ESE >> c:\temp\TrendMicroESFix.txt 2>&1
PING localhost -n 10 >NUL
sc stop TMESE >> c:\temp\TrendMicroESFix.txt 2>&1
PING localhost -n 10 >NUL
sc stop tmescore >> c:\temp\TrendMicroESFix.txt 2>&1
sc stop tmesflt >> c:\temp\TrendMicroESFix.txt 2>&1
sc stop tmesutil >> c:\temp\TrendMicroESFix.txt 2>&1
sc stop TMUMH >> c:\temp\TrendMicroESFix.txt 2>&1
sc stop TMUMS >> c:\temp\TrendMicroESFix.txt 2>&1
PING localhost -n 20 >NUL
echo ---- OK - Stopped All Services ---- >> c:\temp\TrendMicroESFix.txt 2>&1
echo ---- OK - Stopped All Services ----

echo ---- Removing Folders ---- >> c:\temp\TrendMicroESFix.txt 2>&1
echo ---- Removing Folders ----
rd /Q/S "C:\Program Files\Trend Micro\ESE" >> c:\temp\TrendMicroESFix.txt 2>&1
move "C:\Program Files\Trend Micro\ESE" "C:\Program Files\Trend Micro\Temp" >> c:\temp\TrendMicroESFix.txt 2>&1
PING localhost -n 10 >NUL
echo ---- OK - Removed All Folders ---- >> c:\temp\TrendMicroESFix.txt 2>&1
echo ---- OK - Removed All Folders ----

echo ---- Removing Services ---- >> c:\temp\TrendMicroESFix.txt 2>&1
echo ---- Removing Services ----
sc delete ESClient >> c:\temp\TrendMicroESFix.txt 2>&1
sc delete ESE >> c:\temp\TrendMicroESFix.txt 2>&1
sc delete TMESE >> c:\temp\TrendMicroESFix.txt 2>&1
sc delete TMESC >> c:\temp\TrendMicroESFix.txt 2>&1
sc delete tmescore >> c:\temp\TrendMicroESFix.txt 2>&1
sc delete tmesflt >> c:\temp\TrendMicroESFix.txt 2>&1
sc delete tmesutil >> c:\temp\TrendMicroESFix.txt 2>&1
sc delete TMUMH >> c:\temp\TrendMicroESFix.txt 2>&1
sc delete TMUMS >> c:\temp\TrendMicroESFix.txt 2>&1
PING localhost -n 5 >NUL
echo ---- OK - Removed All Services ---- >> c:\temp\TrendMicroESFix.txt 2>&1
echo ---- OK - Removed All Services  ----

echo ---- Removing Drivers ---- >> c:\temp\TrendMicroESFix.txt 2>&1
echo ---- Removing Drivers ----
del /F/Q "C:\Windows\System32\drivers\tmescore.sys" >> c:\temp\TrendMicroESFix.txt 2>&1
del /F/Q "C:\Windows\System32\drivers\tmesflt.sys" >> c:\temp\TrendMicroESFix.txt 2>&1
del /F/Q "C:\Windows\System32\drivers\tmesutil.sys" >> c:\temp\TrendMicroESFix.txt 2>&1
del /F/Q "C:\Windows\System32\drivers\TMUMH.sys" >> c:\temp\TrendMicroESFix.txt 2>&1
del /F/Q "C:\Windows\System32\drivers\TMUMS.sys" >> c:\temp\TrendMicroESFix.txt 2>&1
PING localhost -n 5 >NUL
echo ---- OK - Removed All Drivers ---- >> c:\temp\TrendMicroESFix.txt 2>&1
echo ---- OK - Removed All Drivers ----

echo ---- Removing Registry ---- >> c:\temp\TrendMicroESFix.txt 2>&1
echo ---- Removing Registry ----
Reg delete HKLM\SOFTWARE\TrendMicro\ESC /f >> c:\temp\TrendMicroESFix.txt 2>&1
Reg delete HKLM\SOFTWARE\TrendMicro\ESE /f >> c:\temp\TrendMicroESFix.txt 2>&1
Reg delete HKLM\SOFTWARE\TrendMicro\ESEStatus /f >> c:\temp\TrendMicroESFix.txt 2>&1
Reg delete HKLM\SOFTWARE\TrendMicro\TMESD /f >> c:\temp\TrendMicroESFix.txt 2>&1
Reg delete HKLM\SOFTWARE\TrendMicro\WL /f >> c:\temp\TrendMicroESFix.txt 2>&1
Reg delete HKLM\SYSTEM\CurrentControlSet\services\ESE /f >> c:\temp\TrendMicroESFix.txt 2>&1
Reg delete HKLM\SYSTEM\CurrentControlSet\services\ESClient /f >> c:\temp\TrendMicroESFix.txt 2>&1
Reg delete HKLM\SYSTEM\CurrentControlSet\services\TMESC /f >> c:\temp\TrendMicroESFix.txt 2>&1
Reg delete HKLM\SYSTEM\CurrentControlSet\services\TMESE /f >> c:\temp\TrendMicroESFix.txt 2>&1
Reg delete HKCR\Installer\Products\18D25D934BA918243BEAEF94B543BA71 /f >> c:\temp\TrendMicroESFix.txt 2>&1
Reg delete HKLM\SOFTWARE\Classes\Installer\Products\18D25D934BA918243BEAEF94B543BA71 /f >> c:\temp\TrendMicroESFix.txt 2>&1
Reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\6CA07BA236710B54E9B14748FBB06294 /f >> c:\temp\TrendMicroESFix.txt 2>&1
Reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\18D25D934BA918243BEAEF94B543BA71 /f >> c:\temp\TrendMicroESFix.txt 2>&1
Reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall{39D52D81-9AB4-4281-B3AE-FE495B34AB17} /f >> c:\temp\TrendMicroESFix.txt 2>&1
Reg delete HKCR\Installer\Products\2D1CB2D6B8C10FA43ACA77698976AC49 /f >> c:\temp\TrendMicroESFix.txt 2>&1
Reg delete HKLM\SOFTWARE\Classes\Installer\Products\2D1CB2D6B8C10FA43ACA77698976AC49 /f >> c:\temp\TrendMicroESFix.txt 2>&1
Reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\6CA07BA236710B54E9B14748FBB06294 /f >> c:\temp\TrendMicroESFix.txt 2>&1
Reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\2D1CB2D6B8C10FA43ACA77698976AC49 /f >> c:\temp\TrendMicroESFix.txt 2>&1
Reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall{6D2BC1D2-1C8B-4AF0-A3AC-77969867CA94} /f >> c:\temp\TrendMicroESFix.txt 2>&1
echo ---- OK - Removed All Registry ---- >> c:\temp\TrendMicroESFix.txt 2>&1
echo ---- OK - Removed All Registry ----

echo ---------------------- Endpoint Sensor Removal Finished ---------------------- >> c:\temp\TrendMicroESFix.txt 2>&1
echo ---------------------- Endpoint Sensor Removal Finished ----------------------