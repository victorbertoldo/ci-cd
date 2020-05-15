@echo off && SETLOCAL ENABLEDELAYEDEXPANSION
:: Script para backup do QliK


:: Pegar dia da semana e coloca na variavel SEMANA
for /F "tokens=2 delims='=' " %%D in ('WMIC Path Win32_LocalTime Get DayOfWeek /Format:list ^| findstr "="') do set SEMANA=%%D

:: Variaveis do script
set ORIGEMLOCAL=E:\Qlik
set BACKUPLOCAL=E:\Backup\Qlik
set BACKUPREMOTO=\\<servidorRemoto>\BACKUP\QLIK
set LOGSCRIPT="E:\Backup\Log_Backup\backup-%SEMANA%.log"
set LOGROBO=E:\Backup\Log_Backup\robocopy-%SEMANA%.log


echo ####  INÍCIO BACKUP QLIKSENSE  #### > %LOGSCRIPT%
date /t >> %LOGSCRIPT%
time /t >> %LOGSCRIPT%
echo -------------------------------------------------------- >> %LOGSCRIPT%
echo - Parando os serviços... >> %LOGSCRIPT%

powershell "E:\Backup\stop.ps1" >> %LOGSCRIPT%
taskkill -f -im Engine.exe /T

sc stop likSenseRepositoryDatabase >> %LOGSCRIPT%
sc stop QlikLoggingService >> %LOGSCRIPT%
sc stop QlikSenseEngineService >> %LOGSCRIPT%
sc stop QlikSensePrintingService >> %LOGSCRIPT%
sc stop QlikSenseProxyService >> %LOGSCRIPT%
sc stop QlikSenseSchedulerService >> %LOGSCRIPT%
sc stop QlikSenseServiceDispatcher >> %LOGSCRIPT%

echo - Fazendo backup do postgres... >> %LOGSCRIPT%
SET PGPASSWORD=<SenhaRepositorioQlik>
"C:\Program Files\Qlik\Sense\Repository\PostgreSQL\9.6\bin\pg_dump.exe" -h localhost -p 4432 -U postgres -b -F t -f "E:\Backup\QSR_backup.tar" QSR  >> %LOGSCRIPT%
"C:\Program Files\Qlik\Sense\Repository\PostgreSQL\9.6\bin\pg_dump.exe" -h localhost -p 4432 -U postgres -b -F t -f "E:\Backup\QLogs_backup.tar" QLogs  >> %LOGSCRIPT%

echo - Fazendo backup da pasta Qlik_Shared... >> %LOGSCRIPT%
robocopy %ORIGEMLOCAL% %BACKUPLOCAL% /MIR /FFT /R:3 /W:10 /Z /NP /NDL /XJD /MT:2 /LOG:%LOGROBO% >> %LOGSCRIPT%


echo - Iniciando os Serviços... >> %LOGSCRIPT%
powershell "E:\Backup\start.ps1"

sc start QlikSenseEngineService >> %LOGSCRIPT%
sc start QlikSenseEngineService >> %LOGSCRIPT%
sc start QlikSensePrintingService >> %LOGSCRIPT%
sc start QlikSenseProxyService >> %LOGSCRIPT%
sc start QlikSenseSchedulerService >> %LOGSCRIPT%
sc start QlikSenseServiceDispatcher >> %LOGSCRIPT%
sc start QlikLoggingService >> %LOGSCRIPT%


echo - Fazendo backup da pasta local para ArcServe Share... >> %LOGSCRIPT%
robocopy %BACKUPLOCAL% %BACKUPREMOTO% /MIR /FFT /R:3 /W:10 /Z /NP /NDL /XJD /MT:2 /LOG+:%LOGROBO% >> %LOGSCRIPT%


echo ----------------------Finalizado------------------------------\n\n >> %LOGSCRIPT%

exit