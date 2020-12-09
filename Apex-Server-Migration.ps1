<#

NOTICE: Trend Micro developed this script as a workaround or solution
          to a problem reported by customers. As such, this script has
          received limited testing and has not been certified as an
          official product update. Consequently, THIS SCRIPT IS PROVIDED
          "AS IS". TREND MICRO MAKES NO WARRANTY OR PROMISE ABOUT THE
          OPERATION OR PERFORMANCE OF THIS SCRIPT NOR DOES TREND MICRO
          WARRANT THIS SCRIPT AS ERROR FREE.TO THE FULLEST EXTENT
          PERMITTED BY LAW, TREND MICRO DISCLAIMS ALL IMPLIED AND
          STATUTORY WARRANTIES, INCLUDING BUT NOT LIMITED TO THE IMPLIED
          WARRANTIES OF MERCHANTABILITY, NONINFRINGEMENT AND FITNESS FOR
          A PARTICULAR PURPOSE. 


#>
<#

Exit Codes:
0 - Success - Apex is Installed and Running
99 - CUT File missing
666 - Apex not installed or Service not Running - Check if service is installed and not runnig or not installed
321 - Unknown Error - Please report

#>

function startScript {
    param ([Boolean]$CreatePublicFolder = $true)

    #Define os valores iniciais das variÃƒÂ¡veis globais
    #Sets the initial values of global variables
    $global:Computername = $Env:COMPUTERNAME
    $global:programfiles = "$Env:programfiles"
    $global:SoftwarePublicFolder = "C:\Users\Public\Apex"
    $global:LogFileLocal = ("c:\temp\" + $SoftwareName + "_" + $SoftwareVersion + "_" + $DataLog + ".log") #Local em C:\windows\logs\software_versao.log
    <#
    if ($CreatePublicFolder) {
        #Cria o diretorio 'C:\Users\Public\Apex' para colocar arquivos temporarios
        #Creates the director 'C:\Users\Public\Apex' to place temporary files
        If (Test-Path $SoftwarePublicFolder) {
            Remove-Item -Path $SoftwarePublicFolder -Force -Recurse -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 1
        }
        New-Item -Type Directory -Force -Path $SoftwarePublicFolder
       }#>

}



# Record Log function
# Função para log

function gravarLog ([String]$logMessage) {
    
    $dataLog = (Get-Date).tostring("dd-MM-yyyy")
    $horaLog = (Get-Date).tostring("HH:mm:ss")

    Add-Content -Path $global:LogFileLocal -Value "$dataLog - $horaLog : $logMessage" -Force -Encoding Unicode
}


##########################################

# Variables for script
# #Variáveis para Script

$Apex = Test-Path -Path "HKLM:\SOFTWARE\Classes\Installer\Products\1EFA14817AB44D447800A6FC68A0E81D\SourceList"
$Officescan = Test-Path -Path "HKLM:\SOFTWARE\Classes\Installer\Products\486CF6E934BE58E40B29D1D0431CABA4\SourceList"
#$installed = Test-Path -Path $key
$installed = $False
$Location = Split-Path ((Get-Variable MyInvocation -Scope 0).Value).MyCommand.Path
if (-not $Location) {
    $Location = 'c:\temp'
}
$CUT = "$Location\CUT_Silent.exe"
$TestCUTpath = Test-Path "$CUT"
$verifyTMES = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{6D2BC1D2-1C8B-4AF0-A3AC-77969867CA94}"
$VPInstalled = Test-Path "$Env:ProgramFiles\Trend Micro\Vulnerability Protection Agent"


if ($Apex -eq $True -or $Officescan -eq $True) {
    $installed = $True
}
# Start Script
# Início Script

startScript
gravarLog -logMessage "Begin"
gravarLog -logMessage "começar"

if($TestCUTpath -eq $False){
    gravarLog -logMessage "Problem with the package and not with script. Please place all required files in the package."
    gravarLog -logMessage "Problema com o pacote e não com script. Por favor adicione todos os arquivos no mesmo local do script"
    gravarLog -logMessage "End"
    gravarLog -logMessage "Final"
    exit 123   
}

# Check for TMES and remove if it exists
# Verifique se há TMES e remove se ele existe

$esLocation64 = Test-path -path "C:\Program Files\Trend Micro\Trend Micro Endpoint Sensor\Download\Agent\EndpointSensor_Uninstall.exe"
$esLocation86 = Test-path -path "C:\Program Files (x86)\Trend Micro\Trend Micro Endpoint Sensor\Download\Agent\EndpointSensor_Uninstall.exe"

if ($esLocation64){$esLocation = "C:\Program Files\Trend Micro\Trend Micro Endpoint Sensor\Download\Agent\EndpointSensor_Uninstall.exe"}
if ($esLocation86){$esLocation = "C:\Program Files (x86)\Trend Micro\Trend Micro Endpoint Sensor\Download\Agent\EndpointSensor_Uninstall.exe"}

if ($esLocation -and $verifyTMES){
    gravarLog -logMessage "Starting uninstall of TMES"
    gravarLog -logMessage "Iniciando a desinstalação do TMES"
    Start-Process $esLocation -Wait
    # Sets the attempt value to 1 for future logic
    $attemptedUninstallTMES = 1
}

$verifyTMES = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{6D2BC1D2-1C8B-4AF0-A3AC-77969867CA94}"

if ($attemptedUninstallTMES -eq 1 -and $verifyTMES -eq $true){
    gravarLog -logMessage "TMES Uninstall of did not work"
    gravarLog -logMessage "TMES Desinstalar não funcionou"
}

   
if ($attemptedUninstallTMES -eq 1 -and $verifyTMES -eq $False){
    gravarLog -logMessage "Uninstall of TMES complete"
    gravarLog -logMessage "Desinstalar de TMES completo"
}

# Written by someone else to remove VP agent if it exists
# Escrito por outra pessoa para remover o agente VP se ele existir

if($VPInstalled -eq $true){
    & $Env:ProgramFiles"\Trend Micro\Vulnerability Protection Agent\dsa_control" -r
    Start-Sleep -s 30
    $uninstall32 = Get-ChildItem "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | ForEach-Object { Get-ItemProperty $_.PSPath } | Where-Object { $_ -match "Vulnerability Protection Agent" } | Select-Object UninstallString
    $uninstall64 = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | ForEach-Object { Get-ItemProperty $_.PSPath } | Where-Object { $_ -match "Vulnerability Protection Agent" } | Select-Object UninstallString

    if ($uninstall64) {
        $uninstall64 = $uninstall64.UninstallString -Replace "msiexec.exe","" -Replace "/I","" -Replace "/X",""
        $uninstall64 = $uninstall64.Trim()
        gravarLog -logMessage "Uninstalling VP Agent"
        gravarLog -logMessage "Desinstalando agente vp"
        start-process "msiexec.exe" -arg "/X $uninstall64 /qn /norestart" -Wait
    }
    if ($uninstall32) {
        $uninstall32 = $uninstall32.UninstallString -Replace "msiexec.exe","" -Replace "/I","" -Replace "/X",""
        $uninstall32 = $uninstall32.Trim()
        gravarLog -logMessage "Uninstalling VP Agent"
        gravarLog -logMessage "Desinstalando agente vp"
        start-process "msiexec.exe" -arg "/X $uninstall32 /qn /norestart" -Wait
    }

    $uninstall32 = Get-ChildItem "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | ForEach-Object { Get-ItemProperty $_.PSPath } | Where-Object { $_ -match "Vulnerability Protection Agent" } | Select-Object UninstallString
    $uninstall64 = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | ForEach-Object { Get-ItemProperty $_.PSPath } | Where-Object { $_ -match "Vulnerability Protection Agent" } | Select-Object UninstallString

    if($uninstall32 -eq $true -or $uninstall64 -eq $true){
        gravarLog -logMessage "Uninstalling VP Agent Failed"
        gravarLog -logMessage "Desinstalação do agente VP falhou"
    } else{
        gravarLog -logMessage "VP agent removed successfully"
        gravarLog -logMessage "Agente VP removido com sucesso"
    }
}

# Check if Apex is installed and exit if true
# Verifique se o Apex está instalado e saia se for verdadeiro

if($Apex -eq $true){
    gravarLog -logMessage "Apex One is already installed"
    gravarLog -logMessage "Apex One já está instalado"
    gravarLog -logMessage "End"
    gravarLog -logMessage "Final" 
    exit 0 
}

# Check if an agent exists or officescan exists.
# Run CUT if either are true since CUT can install the agent too
# Verifica se agente ou Officescan existe.
# Executa CUT se qualquer um existir, pois CUT instala o agente também

if($Officescan -eq $true -or $installed -eq $false){

        
    gravarLog -logMessage "Running CUT Silent"
    gravarLog -logMessage "Executando CUT Silent"
    $p = Start-Process -FilePath $CUT -PassThru
    $p.WaitForExit()
    gravarLog -logMessage "CUT Run Complete"
    gravarLog -logMessage "EXECUÇÃO DE CUT completa"
}

# Wait for agent to load 2 minutes
Start-Sleep -Seconds 120

# Final check for install for script sucess
# Verificação final de instalação para sucesso

$Apex = Test-Path -Path "HKLM:\SOFTWARE\Classes\Installer\Products\1EFA14817AB44D447800A6FC68A0E81D\SourceList"
$Service = Get-Service -DisplayName "Apex One NT Listener" -ErrorAction SilentlyContinue -ErrorVariable NoService

if($NoService -or ($Service).Status -ne "Running"){
    gravarLog -logMessage "Something went wrong..."
    gravarLog -logMessage "Algo deu errado..."
    gravarLog -logMessage "End"
    gravarLog -logMessage "Final"
    exit 666
}

if ($Apex -and ($Service).Status -eq "Running"){
    gravarLog -logMessage "Apex One Installed Successfully"
    gravarLog -logMessage "Apex One Instalado com sucesso"
    gravarLog -logMessage "End"
    gravarLog -logMessage "Final"
    exit 0
}

# This exit should not appear. If it does please check script logic.
# Esta saída não deve aparecer. Se isso acontecer, verifique a lógica do script.
Exit 321

