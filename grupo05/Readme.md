# CIPAK | Sistemas Operativos (75.08)| 1er Cuatrimestre 2016 | FIUBA

Descripción del sistema


### Instalar

Para instalar el sistema CIPAK en su computadora, elija un directorio y descomprima allí
el archivo CIPAK-G5.tgz (puede hacerlo mediante clic derecho, y la opción "Extract here"),
y corra el instalador dentro de la carpeta, mediante la siguiente línea de comando:
`(...)/CIPAK-G5$ bash installer.sh`


### Desinstalar

Para desinstalar el sistema, vaya a la carpeta de binarios (por default, Grupo05/binarios/)
y corra el uninstaller.sh, lo cual puede hacer mediante:
`(...)/Grupo05/binarios/$ bash uninstaller.sh`


### Preparar el Ambiente

Una vez instalado CIPAK ejecute en una terminal en la direccion "Grupo05/binarios" el comando `(...)/Grupo05/binarios/$ . PrepararAmbiente.sh`.
Mediante esto usted tendra todo preparado para poder ejecutar los comandos.

### Generar sorteo

Una vez que el ambiente esta listo podra generar el sorteo mediante `(...)/Grupo05/binarios/$ bash LanzarProceso.sh "bash GenerarSorteo.sh"`. Esto genera los archivos necesarios para poder determinar los ganadores.

### Determinar Ganadores
