@echo off

SET "ok=FALSE"

IF "%1"=="" IF "%2"=="" IF "%3"=="" IF "%4"=="" SET "ok=TRUE"

IF "%ok%"=="TRUE" (
    GOTO PARAMETROS
) ELSE (
    IF "%1"=="" GOTO ERRO
    IF "%2"=="" GOTO ERRO
    IF "%3"=="" GOTO ERRO
    IF "%4"=="" GOTO ERRO
)

SET "host=%1"
SET "porta=%2"
SET "usuario=%3"
SET "bd=%4"
SET "senha=%5"

GOTO CONTINUE

:CONTINUE

SET "ok=TRUE"
IF "%host%"=="" IF "%porta%"=="" IF "%usuario%"=="" IF "%bd%"=="" SET ok=FALSE

IF "%ok%"=="FALSE" (
    GOTO ERRO
)

echo Criando script do banco de dados, aguarde...
echo --------------------------------------------

SET GREP_01=utils\egrep.exe -v "^-- Host:"
SET GREP_02=utils\egrep.exe -v "^-- Dump completed"
SET SED_01=utils\sed.exe "s/AUTO_INCREMENT=[0-9]*//g" 
SET SED_02=utils\sed.exe "s/MyISAM  DEFAULT/MyISAM DEFAULT/g"

SET ESTRUTURA=Banco de dados\BD-estrutura.sql

ECHO .
ECHO Estrutura...
mysqldump.exe -h "%host%" -P "%porta%" -u "%usuario%" "%senha%" -R -d -C --default-character-set=latin1 "%bd%" | %GREP_01% | %GREP_02% | %SED_01% | %SED_02% > "%ESTRUTURA%"

IF %ERRORLEVEL% == 0 (
    echo Estrutura inicial.........................Ok
) ELSE (
    PAUSE
)

SET DADOS=Banco de dados\BD-dadosiniciais.sql
SET TABELAS=aliquotasecf atendimentomotivo atendimentoorigem atendimentoposicao atendimentoprioridade bancos camposformulario cfop ipienquadramento
SET TABELAS=%TABELAS% configcampos configformularios csticms cstcofins cstipi cstpis cstservico cstsimplesnacional ctrccomponentesfrete
SET TABELAS=%TABELAS% efdobslanctofiscal efdtabelaajustesinfdoctofiscal formaspagamento itensformacaoctrccontaspagar
SET TABELAS=%TABELAS% layoutsdetalhes layoutsestruturas moddocfiscal municipios municipiosdipam municipiosdipj ncmnbs ibpttributos ocorrencias
SET TABELAS=%TABELAS% paises produtositensformacaopreco proprietariotipo servicoslistalc116 sittributaria situacaoboleto
SET TABELAS=%TABELAS% tipodependente tipodocumento tipoorigem tiporecebidopago unidadesmedida variaveis
SET TABELAS=%TABELAS% veiculotipo vencimentostiposituacao impostos impostoslista ctrctipo formularios ufs cfemitidosmsgs ctetiposocorrencias

ECHO .
ECHO Dados iniciais...
mysqldump.exe -h "%host%" -P "%porta%" -u "%usuario%" "%senha%" -e -t -C "%bd%" %TABELAS% | %GREP_01% | %GREP_02% > "%DADOS%"

IF %ERRORLEVEL% == 0 (
    echo Dados iniciais............................Ok
) ELSE (
    PAUSE
)

GOTO END

:ERRO
echo Exata Software
echo ---------------------------------------------------------
echo Parametros informados incorretamente...
echo Forma de utilizacao do bat "BDdump.bat" com parametros:
echo BDdump.bat host porta usuario nome_banco_dados [-psenha]
echo Exemplo: BDdump.bat localhost 3304 root exata -proot
echo ""
echo ""
echo O "BDdump.bat" pode ser executado sem parametros.
echo ---------------------------------------------------------
GOTO END

:PARAMETROS
SET /p host=Host do SGBD [localhost]: 
IF "%host%" == "" (
    SET "host=localhost"
)

SET /p porta=Porta do SGBD [3306]: 
IF "%porta%" == "" (
    SET "porta=3306"
)

SET /p usuario=Usuario [root]: 
IF "%usuario%" == "" (
    SET "usuario=root"
)

SET /p senha=Senha (nao e obrigatorio):
IF "%senha%" NEQ "" (
    SET "senha=-p%senha%"
)

SET /p bd=Nome do BD [exata]: 
IF "%bd%" == "" (
    SET "bd=exata"
)

GOTO CONTINUE

:END