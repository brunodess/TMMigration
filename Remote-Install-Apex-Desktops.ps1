########################################################################################################
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
########################################################################################################
<#
    Script para execucao remota de script de migracao OSCE/Apex em lote de estacoes. Aceita arquivo de entrada com lista de maquinas
    uma a cada linha. Este verifica conectividade com cada endpoint, copia o pacote CUT e script de migracao e entao executa via psexec
    o script de migracao.
    
    
    [INSTRUCOES]
    Alterar [caminhoPsexec] para indicar onde encontrar o psexec local, caso esteja no Path, preencher somente com psexec.exe
    Alterar [caminhoPacote] apontando para o diretorio onde esta o script para instalacao do agente e o pacote com CUT e instaladores
    Alterar [caminhoRemoto] para o local no destino onde sera copiado o script para instalacao
    Alterar [caminhoInput] com o caminho completo do arquivo de entrada com a lista de maquinas a receber o agente
    Alterar [caminhoOutput] queira salvar a saida em outro local
    Alterar [IPPrefix] para Prefixo de IP para resolver endereco da subnet correta (Para endpoints com muitos IPs ou em VPN)
        Inserir apenas os valores de prefixo, sem wildcard ou mascara


    O Pacote deve conter os seguintes arquivos:
        CUT_Silent.exe
        CUT_Silent.exe.config
        CUT.ini
        Apex-Desktop-Migration.ps1
        osce_client_x32.exe
        osce_client_x32.exe.config
        osce_client_x64.exe
        osce_client_x64.exe.config

#>

########################################################################################################

<#
    Codigos de saida:
    0 - OK
    100 - Caminho para output invalido
    400 - Lista invalida
    403 - PsExec nao encontrado
    404 - Arquivo de entrada nao encontrado
    405 - Pacote CUT incompleto - pacote deve incluir CUT_silent, ini, config e 4 palceholder osce_client
        
    
#>

########################################################################################################

<# ---------------------------------------- Parametros de inicializacao ---------------------------------------- #>

<#
    Caminho psexec, incluindo psexec.exe
    Caso esteja definido em variavel de ambiente, eh possivel incluir apenas psexec.exe
#>
    $caminhoPsexec = 'psexec.exe'

<#
    Caminho do Diretorio para obter script de instalacao Local - conferir caminho do pacote no Script
    Exemplo: \\HOST\public_share\Script_Apex_Saas
#>
    $caminhoPacote = ''
    
<#
    Caminho nos endpoints de destino para copia do Script (nao incluir \\nome_do_endpoint, apenas share ou drive$ e pasta)
    Exemplos:
        c$\temp\
        share_de_rede\
        share_de_rede\temp\
        share_oculto$\
        e$\
#>
    $caminhoRemoto = 'c$\temp\'

<#
    Caminho completo da Lista de input - Hostnames ou IPs, um a cada linha
#> 
    $caminhoInput = 'C:\input\Script Final\Input.txt'

<#
    Caminho para salvar as saidas
    (Default) = Nulo para o mesmo de $caminhoInput + \output\
#>
    $caminhoOutput = $null

<#
    IPPrefix - Prefixo de IP para resolver endereco da subnet correta (Para endpoints com muitos IPs ou em VPN)
    Inserir apenas os valores de prefixo, sem wildcard ou mascara
    Exemplo: 
        10.
            para qualquer rede 10.0.0.0 ate 10.255.255.255 (10.0.0.0/8)
        192.168.
            para qualquer rede 192.168.0.0 ate 192.168.255.255 (192.168.0.0/16)
        192.168.1.
            para qualquer rede 192.168.1.0 ate 192.168.1.255 (192.168.0.0/24)

#>
    $IPPrefix = '10.'

<#

<# ---------------------------------------- --------------------------- ---------------------------------------- #>



<# ---- Inicio Script - Validacao ---- #>
    
    #PsExec - Confere se var ja esta correta, senao confere env var path
    if (-not (Test-Path $caminhoPsexec -PathType Leaf)) {
        foreach ($path in $env:Path.Split(';')) {
            if (Test-Path "$path\$caminhoPsexec" -PathType Leaf) {
                $caminhoPsexec = "$path\$caminhoPsexec"
            }
        }        
    }
    if (-not (Test-Path $caminhoPsexec -PathType Leaf)) {
        throw '[ERRO] [403] PsExec nao encontrado'
        #exit 403
    }    

    #Arquivo Input
    if (-not (test-path $caminhoInput -PathType Leaf) ) {
        throw '[ERRO] [404] - Arquivo de entrada nao encontrado'
        #exit 404
    }

    $listaInput = Get-Content -Path $caminhoInput

    if ( (-not ($listaInput)) -or ($listaInput.Length -lt 1) ) {
        throw '[ERRO] [400] Lista invalida'
        #exit 400
    }

    # Caminho Output
    if ( ([string]::IsNullOrEmpty($caminhoOutput)) -and (test-path $caminhoInput -PathType Container) ) {
        $caminhoOutput = "$caminhoInput\output\"

    } elseif ( ([string]::IsNullOrEmpty($caminhoOutput)) -and (test-path $caminhoInput -PathType Leaf) ) {
        $caminhoOutput = "$((Get-Item $caminhoInput).DirectoryName)\output\" 

    }
    
    if (-not (test-path $caminhoOutput -PathType Container) -and (-not (New-Item -Path $caminhoOutput -ItemType Container) ) ) {
        throw '[ERRO] [100] - Caminho de saida inserido invalido'
        #exit 100
    }

    #PAcote
    if (
        -not (test-path -Path "$caminhoPacote\CUT_Silent.exe") -or
        -not (test-path -Path "$caminhoPacote\CUT.ini") -or
        -not (test-path -Path "$caminhoPacote\CUT_Silent.exe.config") -or
        -not (test-path -Path "$caminhoPacote\Apex-Desktop-Migration.ps1") -or
        -not (test-path -Path "$caminhoPacote\osce_client_x32.exe") -or
        -not (test-path -Path "$caminhoPacote\osce_client_x32.exe.config") -or
        -not (test-path -Path "$caminhoPacote\osce_client_x64.exe") -or
        -not (test-path -Path "$caminhoPacote\osce_client_x64.exe.config")
    ) {
        throw "[ERRO] [405] Pacote CUT incompleto"
        #exit 405
    }
    $listaResultado = (New-Item -Path "$caminhoOutput\resultado.txt" -ItemType File -Force).FullName
    Out-File -FilePath "$listaResultado" -InputObject "Item,IP,Resultado" -Append


<# ---- Executa Pacote ---- #>
    $datetime = Get-Date -UFormat '%Y-%m-%d-%H%M%S'
    foreach ($endpoint in $listaInput) {
        #$copyError = $null
        $p = $null
        #$session = $null
        #$hostName = $null
        $hostIP = $null
        #$OS = $null
        $resolved = $null

        if ($endpoint.StartsWith($IPPrefix) ) {

            $hostIP = $endpoint            
            #$hostName = $endpoint
        } else {
            #$hostName = $endpoint
            $ipList = Resolve-DnsName $endpoint -Type A  -NoHostsFile
            foreach ($ip in $ipList) {
                if ($ip.IPAddress.StartsWith($IPPrefix) ) {
                    $hostIP = $ip.IPAddress
                }
            }

        }

        If(Test-Connection -Count 1 -ComputerName $hostIP -Quiet) {            
            <#
            # Verifica de endpoint eh 64 bits - Default vai ser SaaS02 64bits
            $64b = $true
            $name04 = $false
            
            $OS = Get-WmiObject -Computer $hostIP -Class Win32_OperatingSystem
            if ($OS){
                $hostName = $OS.PSComputerName
                if ($OS.OSArchitecture -ne '64-bit') {
                    $64b = $false
                }
            }

            
            if (-not $hostName){
                $hostName = $endpoint
                $resolved = Resolve-DnsName $hostIP
                if ($resolved){
                    
                    $hostName = $resolved.NameHost.Split('.')[0]
                } else {
                    $hostName = $hostIP
                }
            }
                        
            

            # Verifica se nome do endpoint termina com algarismo menor que 5 (Maior ou igual a 5 e nao algarismos sao false)
            if ( ($hostName).Substring(($hostName).Length-1) -lt 5) {
                $name04 = $true
            }

            # Escolhe pacote baseado nas informacoes de bit e hostname
            if ( ($64b) -and ($name04) ){
                $instalador = $saas01_64b
            }
            if ( ($64b) -and (-not $name04) ){
                $instalador = $saas02_64b
            }
            if ( (-not $64b) -and ($name04) ){
                $instalador = $saas01_32b
            }
            if ( (-not $64b) -and (-not $name04) ){
                $instalador = $saas02_32b
            }
            #>

            #Copia de arquivos para o destino
            
            
            New-Item -ItemType Container -Path "$caminhoRemoto\migracao_$datetime"
            $caminhoRemoto = "$caminhoRemoto\migracao_$datetime\"
            
            xcopy "$caminhoPacote\CUT_Silent.exe" "\\$hostIP\$caminhoRemoto" /d /y
            xcopy "$caminhoPacote\CUT.ini" "\\$hostIP\$caminhoRemoto" /d /y
            xcopy "$caminhoPacote\CUT_Silent.exe.config" "\\$hostIP\$caminhoRemoto" /d /y
            xcopy "$caminhoPacote\osce_client_x32.exe" "\\$hostIP\$caminhoRemoto" /d /y
            xcopy "$caminhoPacote\osce_client_x32.exe.config" "\\$hostIP\$caminhoRemoto" /d /y
            xcopy "$caminhoPacote\osce_client_x64.exe" "\\$hostIP\$caminhoRemoto" /d /y
            xcopy "$caminhoPacote\osce_client_x64.exe.config" "\\$hostIP\$caminhoRemoto" /d /y
            #xcopy "$caminhoPacote\$instalador" "\\$hostIP\$caminhoRemoto\osce_agent_xx.msi*" /Y /J
            xcopy "$caminhoPacote\Apex-Desktop-Migration.ps1" "\\$hostIP\$caminhoRemoto" /Y


            #Roda CUT via psexec no endpoint
            Start-Process -FilePath $caminhoPsexec -ArgumentList "-s \\$hostIP cmd /c `"powershell -executionpolicy bypass -noninteractive -file \\$hostIP\$caminhoRemoto\Apex-Desktop-Migration.ps1`"" -WindowStyle Hidden -PassThru
            sleep 2
            Out-File -FilePath "$listaResultado" -InputObject "$endpoint,$hostIP,SENT" -Append
            
           
           
           
            <#
            #Script de instalacao local
            if (-not (Test-Path "$caminhoScriptLocal\$nomeScript" -PathType Leaf) ) {
                throw '[ERRO] [405] Script de Instalacao Local nao encontrado'
                #exit 405
            }

            $credential = New-Object –TypeName System.Management.Automation.PSCredential –ArgumentList $user,$password
            $session = New-PSSession -ComputerName $endpoint #-Credential $credential
            Copy-Item -Path "$caminhoScriptLocal\$nomeScript" -Destination $caminhoRemoto -ToSession $session -Force -ErrorVariable copyError
            if ($copyError) {
                
                echo "[ERRO] [500] Erro na copia do script de instalacao para destino \\$endpoint\$caminhoRemoto"
                Out-File -FilePath "$listaResultado" -InputObject "$endpoint,ERRO" -Append

            } else {            

                #$p = Start-Process -FilePath $caminhoPsexec -ArgumentList "\\$endpoint -s -u $user -p $ptextpassword /accepteula cmd /c `"powershell -noninteractive -file $caminhoRemoto\$nomeScript`"" -WindowStyle Hidden -PassThru
                $p = Start-Process -FilePath $caminhoPsexec -ArgumentList "\\$endpoint -s /accepteula cmd /c `"powershell -noninteractive -file $caminhoRemoto\$nomeScript`"" -WindowStyle Hidden -PassThru
                sleep 2
                Out-File -FilePath "$listaResultado" -InputObject "$endpoint,SENT" -Append
                #$p.ExitCode
            }
            if ($p.ExitCode -eq 0) {
                echo "$endpoint,SUCCESS"
                Out-File -FilePath "$listaResultado" -InputObject "$endpoint,SUCCESS" -Append
            } else {
                echo "$endpoint,FAIL"
                Out-File -FilePath "$listaResultado" -InputObject "$endpoint,FAIL" -Append
            }#>
            
            
                        
        } else {
            Out-File -FilePath "$listaResultado" -InputObject "$endpoint,$hostIP,Offline" -Append
        }


    }

    

    

