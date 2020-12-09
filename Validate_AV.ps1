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
    Script para consultar se uma lista de endpoints possui SEP, OfficeScan ou Apex One instalado.
    Aceita lista de entrada com hostnames ou IPs um a cada linha, verifica a existencia de um
    dos 3 produtos e como saida, um arquivo com lista de maquinas para cada produto e um quarto
    com o consolidado de todos em CSV.

    
    
    [INSTRUCOES]
    Em [Parametro de inicializacao] preencha o valor da variavel $caminhoInput com o caminho completo
    do arquivo de entrada com a lista de maquinas a serem validadas - Exemplo: C:\temp\input.txt
    Este arquivo de entrada deve conter a lista de Endpoints onde sera feita a verificacao, uma a cada
    linha. Pode ser pelo HostName ou IP, apenas estes dados, um a cada linha.

    Preencher a variavel $caminhoOutput com o caminho do Diretorio de saida desejado. Deixar nulo ($null)
    para caminho de saida padrao - igual a entrada + \output. Exemplo: c:\temp\output\


#>

########################################################################################################

<#
    Codigos de saida:
    0 - OK
    100 - Caminho de saida invalido, corrija para um diretorio existente ou $null para saida padrao
    110-119 - Nao foi possivel criar arquivo de saida
    400 - Lista Invalida
    404 - Arquivo de entrada nao encontrado
#>

########################################################################################################

<# ---------------------------------------- Parametros de inicializacao ---------------------------------------- #>

<#
    Caminho completo da Lista de input - Hostnames ou IPs, um a cada linha
#> 
    $caminhoInput = 'c:\temp\inputlist.txt'

<#
    Caminho para salvar as saidas
    (Default) = Nulo para o mesmo de $caminhoInput + \output\
#>
    $caminhoOutput = $null

<#
    Servicos para verificar
    ServiceName precisa ser preenchido
    Display Name pode ser nulo ($null)
    Lista eh o nome do arquivo de saida para este servico se encontrado, pode ser nulo para ignorar criacao desta lista
#>
    $sepServiceName = 'SepMasterService'
    $sepServiceDisplay = $null
    $sepLista = 'ListaSEP.txt'

    $apexServiceName = 'tmlisten'
    $apexServiceDisplay = 'Apex One NT Listener'
    $apexLista = 'ListaAPEX.txt'

    $osceServiceName = 'tmlisten'
    $osceServiceDisplay = 'Officescan NT Listener'
    $osceLista = 'ListaOSCE.txt'

<# ---------------------------------------- --------------------------- ---------------------------------------- #>




<# ---- Inicio Script - Validacao ---- #>
    
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



    # Arquivos output
    $onlineLista = (New-Item -Path "$caminhoOutput\online.txt" -ItemType File -Force).FullName
    $offlineLista = (New-Item -Path "$caminhoOutput\offline.txt" -ItemType File -Force).FullName
    $sepLista = (New-Item -Path "$caminhoOutput\$sepLista" -ItemType File -Force).FullName
    $osceLista = (New-Item -Path "$caminhoOutput\$osceLista" -ItemType File -Force).FullName
    $apexLista = (New-Item -Path "$caminhoOutput\$apexLista" -ItemType File -Force).FullName
    
    if (-not (test-path $onlineLista -PathType Leaf) ) {
        throw '[ERRO] [110] - Nao foi possivel criar arquivo de saida'
        #exit 110
    }
    if (-not (test-path $offlineLista -PathType Leaf) ) {
        throw '[ERRO] [111] - Nao foi possivel criar arquivo de saida'
        #exit 111
    }
    if (-not (test-path $sepLista -PathType Leaf) ) {
        throw '[ERRO] [112] - Nao foi possivel criar arquivo de saida'
        #exit 112
    }    
    if (-not (test-path $osceLista -PathType Leaf) ) {
        throw '[ERRO] [113] - Nao foi possivel criar arquivo de saida'
        #exit 113
    }
    if (-not (test-path $apexLista -PathType Leaf) ) {
        throw '[ERRO] [114] - Nao foi possivel criar arquivo de saida'
        #exit 114
    }
    
    Out-File -FilePath "$onlineLista" -InputObject "Hostname,Service,Status" -Append
    
    


    

<# ---- Execucao Script ---- #>

    foreach ($endpoint in $listaInput) {
        If(Test-Connection -Count 1 -ComputerName $endpoint -Quiet) {
            
            #Limpa variaveis de serviços e consulta no destino existencia
            $TMService = $null
            $SEPService = $null
            $TMService = Get-Service -Name $apexServiceName -ComputerName $endpoint -ErrorAction SilentlyContinue -ErrorVariable NoService
            $SEPService = Get-Service -Name $sepServiceName -ComputerName $endpoint -ErrorAction SilentlyContinue -ErrorVariable NoService
            
            #Tratativa para caso servico Apex diferente de servico Osce
            if (-not $TMService) {
                Get-Service -Name $osceServiceName -ComputerName $endpoint -ErrorAction SilentlyContinue -ErrorVariable NoService
            }
            
                    
            #Se existe servico TM e Display Name igual APex
            if ($TMService -and $TMService.DisplayName -eq $apexServiceDisplay) {
                Out-File -FilePath "$onlineLista" -InputObject "$endpoint,APEX,$($TMService.Status)" -Append
                Out-File -FilePath "$apexLista" -InputObject "$endpoint" -Append
            }

            #Se existe servico TM e Display Name igual Osce
            if ($TMService -and $TMService.DisplayName -eq $osceServiceDisplay) {
                Out-File -FilePath "$onlineLista" -InputObject "$endpoint,OSCE,$($TMService.Status)" -Append
                Out-File -FilePath "$osceLista" -InputObject "$endpoint" -Append
            }

            #Se existe servico SEP
            if ($SEPService) {
                Out-File -FilePath "$onlineLista" -InputObject "$endpoint,SEP,$($TMService.Status)" -Append
                Out-File -FilePath "$sepLista" -InputObject "$endpoint" -Append
            }

            #Se nao existe nenhum
            if ( (-not $TMService) -and (-not $SEPService) ) {
                Out-File -FilePath "$onlineLista" -InputObject "$endpoint,," -Append
            }

            

        } else {
            
            Out-File -FilePath "$offlineLista" -InputObject "$endpoint" -Append

        }

        #exit 0
    }