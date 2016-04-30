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


### Preparar el ambiente

Una vez instalado CIPAK ejecute en una terminal en la direccion "Grupo05/binarios" el comando
`(...)/Grupo05/binarios/$ . PrepararAmbiente.sh`
Mediante esto usted tendrá todo preparado para poder ejecutar los comandos.


### Generar sorteo

Una vez que el ambiente esté listo podrá generar el sorteo mediante
`(...)/Grupo05/binarios/$ bash LanzarProceso.sh "bash GenerarSorteo.sh"`
Esto genera los archivos necesarios para poder determinar los ganadores.


### Determinar ganadores

Habiendo preparado el ambiente, y posteriormente generado el sorteo correspondiente
Posicionarse en `(...)/Grupo05/binarios/` y ejecutar el comando mediante la sentencia
`$ ./DeterminarGanadores.pl`. Se accederá entonces al menu correspondiente a las consultas.
Dentro de las opciones del comando, usted puede utilizar:
`-g` para grabar las consultas realizadas en un archivo de texto. `$ ./DeterminarGanadores.pl -g`
`-a` para acceder a la ayuda correspondiente al comando. `$ ./DeterminarGanadores.pl -a`
