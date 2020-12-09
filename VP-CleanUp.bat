@ECHO OFF
echo Starting VP Fix > c:\temp\TrendMicroVPFix.txt 2>&1


goto check_Permissions

:check_Permissions
    echo Detecting Admin permissions...

    net session >nul 2>&1
    if %errorLevel% == 0 (
        echo Success: Administrative permissions confirmed.
		echo Success: Administrative permissions confirmed. >> c:\temp\TrendMicroVPFix.txt 2>&1
    ) else (
        echo Failure: Current permissions inadequate. >> c:\temp\TrendMicroVPFix.txt 2>&1
		echo Failure: Current permissions inadequate - Run as Administrator. 
		exit /b
    )	

echo ---------------------- Vulnerability Protection Removal Starting ---------------------- >> c:\temp\TrendMicroVPFix.txt 2>&1
echo ---------------------- Vulnerability Protection Removal Starting ----------------------
"%programfiles(x86)%\Trend Micro\Vulnerability Protection Agent\dsa_control" -r
echo ---- Stopping Services ---- >> c:\temp\TrendMicroVPFix.txt 2>&1
echo ---- Stopping Services ----
sc stop ds_agent >> c:\temp\TrendMicroVPFix.txt 2>&1
PING localhost -n 10 >NUL
sc stop tbimdsa >> c:\temp\TrendMicroVPFix.txt 2>&1
PING localhost -n 10 >NUL
sc stop iVPAgent >> c:\temp\TrendMicroVPFix.txt 2>&1
PING localhost -n 20 >NUL
echo ---- OK - Stopped All Services ---- >> c:\temp\TrendMicroVPFix.txt 2>&1
echo ---- OK - Stopped All Services ----

echo ---- Removing Services ---- >> c:\temp\TrendMicroVPFix.txt 2>&1
echo ---- Removing Services ----
sc delete ds_agent >> c:\temp\TrendMicroVPFix.txt 2>&1
sc delete tbimdsa >> c:\temp\TrendMicroVPFix.txt 2>&1
sc delete iVPAgent >> c:\temp\TrendMicroVPFix.txt 2>&1
PING localhost -n 10 >NUL
sc delete ds_agent >> c:\temp\TrendMicroVPFix.txt 2>&1
sc delete tbimdsa >> c:\temp\TrendMicroVPFix.txt 2>&1
sc delete iVPAgent >> c:\temp\TrendMicroVPFix.txt 2>&1
PING localhost -n 5 >NUL
echo ---- OK - Removed All Services ---- >> c:\temp\TrendMicroVPFix.txt 2>&1
echo ---- OK - Removed All Services  ----

echo ---- Removing Drivers ---- >> c:\temp\TrendMicroVPFix.txt 2>&1
echo ---- Removing Drivers ----
del /F/Q "C:\Windows\System32\DriverStore\FileRepository\nettbimdsa.inf_amd64_neutral_7bf92935b96598b1\tbimdsa.sys" >> c:\temp\TrendMicroVPFix.txt 2>&1
del /F/Q "C:\Windows\System32\DriverStore\FileRepository\nettbimdsa.inf_amd64_neutral_7bf92935b96598b1\tbimdsa.cat" >> c:\temp\TrendMicroVPFix.txt 2>&1
del /F/Q "C:\Windows\System32\DriverStore\FileRepository\nettbimdsa.inf_amd64_neutral_7bf92935b96598b1\nettbimdsa.PNF" >> c:\temp\TrendMicroVPFix.txt 2>&1
del /F/Q "C:\Windows\System32\DriverStore\FileRepository\nettbimdsa.inf_amd64_neutral_7bf92935b96598b1\nettbimdsa.inf" >> c:\temp\TrendMicroVPFix.txt 2>&1
PING localhost -n 5 >NUL
echo ---- OK - Removed All Drivers ---- >> c:\temp\TrendMicroVPFix.txt 2>&1
echo ---- OK - Removed All Drivers ----

echo ---- Removing Registry ---- >> c:\temp\TrendMicroVPFix.txt 2>&1
echo ---- Removing Registry ----
Reg delete HKEY_CLASSES_ROOT\Installer\Products\F9103782F03CC464BA026FD9C854064A /f >> c:\temp\TrendMicroVPFix.txt 2>&1
Reg delete HKEY_CLASSES_ROOT\Installer\UpgradeCodes\689D08D76B5A47A4FB59D97D2C4B9308 /f >> c:\temp\TrendMicroVPFix.txt 2>&1
Reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\Features\F9103782F03CC464BA026FD9C854064A /f >> c:\temp\TrendMicroVPFix.txt 2>&1
Reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\Products\F9103782F03CC464BA026FD9C854064A /f >> c:\temp\TrendMicroVPFix.txt 2>&1
Reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\UpgradeCodes\689D08D76B5A47A4FB59D97D2C4B9308 /f >> c:\temp\TrendMicroVPFix.txt 2>&1
Reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UpgradeCodes\689D08D76B5A47A4FB59D97D2C4B9308\ /f >> c:\temp\TrendMicroVPFix.txt 2>&1
Reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{2873019F-C30F-464C-AB20-F69D8C4560A4} /f >> c:\temp\TrendMicroVPFix.txt 2>&1
Reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\TrendMicro\Deep Security Agent" /f >> c:\temp\TrendMicroVPFix.txt 2>&1
Reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\TrendMicro\Vulnerability Protection Agent" /f >> c:\temp\TrendMicroVPFix.txt 2>&1
Reg delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\Root\LEGACY_TBIMDSA /f >> c:\temp\TrendMicroVPFix.txt 2>&1
Reg delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\ds_agent /f >> c:\temp\TrendMicroVPFix.txt 2>&1
Reg delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\tbimdsae /f >> c:\temp\TrendMicroVPFix.txt 2>&1
Reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\Application\Vulnerability Protection Agent" /f >> c:\temp\TrendMicroVPFix.txt 2>&1
echo ---- OK - Removed All Registry ---- >> c:\temp\TrendMicroVPFix.txt 2>&1
echo ---- OK - Removed All Registry ----

echo ---------------------- Vulnerability Protection Removal Finished ---------------------- >> c:\temp\TrendMicroVPFix.txt 2>&1
echo ---------------------- Vulnerability Protection Removal Finished ----------------------