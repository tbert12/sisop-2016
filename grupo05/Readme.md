# CIPAK | Sistemas Operativos (75.08)| 1er Cuatrimestre 2016 | FIUBA

Descripción del sistema


### Instalar

Para instalar el sistema CIPAK en su computadora, elija un directorio y descomprima allí
el archivo CIPAK-G5.tgz (puede hacerlo mediante clic derecho, y la opción "Extract here"),
y corra el instalador dentro de la carpeta, mediante la siguiente línea de comando:
`.../CIPAK-G5$ . installer.sh`


### Desinstalar

Para desinstalar el sistema, vaya a la carpeta de binarios (por default, Grupo05/binarios/)
y corra el uninstaller.sh, lo cual puede hacer mediante:
`.../Grupo05/binarios/$ . uninstaller.sh`


### Preparar el ambiente

Una vez instalado CIPAK ejecute en una terminal en la dirección "Grupo05/binarios" el comando
`.../Grupo05/binarios/$ . PrepararAmbiente.sh`
Mediante esto usted tendrá todo preparado para poder ejecutar los programas del sistema.


### Recibir ofertas

Una vez iniciado el ambiente, puede en cualquier momento (el paso anterior ofrece hacerlo por usted) iniciar el daemon receptor mediante
`.../Grupo05/binarios/$ LanzarProceso.sh RecibirOfertas.sh`
con lo cual se iniciará en un segundo plano el proceso que medie la recepción de archivos de oferta. Para frenarlo, utilice el mismo formato pero con el comando `DetenerProceso.sh`.


### Procesar ofertas

ProcesarOfertas es llamado por RecibirOfertas cuando hay novedades.
Una vez finalizado se pueden ver los resultados en los outputs correspondientes referenciados en la documentación.



### Generar sorteo

Una vez que el ambiente esté listo podrá generar el sorteo mediante
`.../Grupo05/binarios/$ bash LanzarProceso.sh "bash GenerarSorteo.sh"`
Esto genera los archivos necesarios para poder determinar los ganadores.


### Determinar ganadores

Habiendo preparado el ambiente, y posteriormente generado el sorteo correspondiente<br />
Posicionarse en `.../Grupo05/binarios/` y ejecutar el comando mediante la sentencia
`$ ./DeterminarGanadores.pl`. Se accederá entonces al menu correspondiente a las consultas.<br />
Dentro de las opciones del comando, usted puede utilizar:<br />
`-g` para grabar las consultas realizadas en un archivo de texto. `$ ./DeterminarGanadores.pl -g`<br />
`-a` para acceder a la ayuda correspondiente al comando. `$ ./DeterminarGanadores.pl -a`<br />


