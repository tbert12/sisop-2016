# CIPAK | Sistemas Operativos (75.08)| 1er Cuatrimestre 2016 | FIUBA

## Descripción del sistema


### Instalar

Para instalar el sistema **CIPAK** en su computadora, elija un directorio y descomprima allí
el archivo `CIPAK-G5.tgz` (puede hacerlo mediante clic derecho, y la opción *Extract here*),
y corra el instalador dentro de la carpeta, mediante la siguiente línea de comando:
`.../CIPAK-G5$ . installer.sh`
El instalador debe estar en el mismo directorio que el fichero comprimido `source.tar.gz` para poder realizar la instalación con éxito.


### Desinstalar

Para desinstalar el sistema, vaya a la carpeta de binarios (por default, *Grupo05/binarios/*)
y corra el **uninstaller.sh**, lo cual puede hacer mediante:
`.../Grupo05/binarios/$ . uninstaller.sh`


### Preparar el ambiente

Una vez instalado **CIPAK** ejecute en una terminal en la dirección *Grupo05/binarios* el comando
`.../Grupo05/binarios/$ . PrepararAmbiente.sh`
Mediante esto usted tendrá todo preparado para poder ejecutar los programas del sistema.


### Recibir ofertas

Una vez iniciado el ambiente, puede en cualquier momento (el paso anterior ofrece hacerlo automáticamente) iniciar el *daemon* receptor mediante
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

## Modo de uso de scripts


### installer.sh

Si recibió el paquete **CIPAK_G5.tgz**, el primer paso es descomprimirlo. Esto se puede hacer mediante clic derecho y eligiendo la opción de descompresión en la carpeta actual, o con:
`tar -xzf CIPAK_G5.tgz`<br />

Tras esto, dispondrá de una carpeta del mismo nombre con todo los archivos que necesita la instalación, junto con esta documentación.<br />
El instalador no requiere ningún parámetro para su funcionamiento. Para ejecutarlo, se recomienda que se utilice el siguiente comando, con la notación de `.` para que la instalación se realice en el mismo proceso que la terminal, y con el *working directory* posicionado en la carpeta del mismo, de forma que pueda funcionar totalmente:
`. installer.sh`<br />

Opcionalmente, se puede utilizar el flag `-d` para predefinir que se utilicen todas las variables de ambiente por default:
`. installer.sh -d`<br />


### uninstaller.sh

El desinstalador no utiliza ningún parámetro. Para ejecutarlo, se recomienda que se utilice el siguiente comando, con la notación de `.` para que la desinstalación se realice en el mismo proceso que la terminal, y, más importante, con el *working directory* posicionado en la carpeta del script, de forma que pueda garantizarse su total funcionamiento:
`. uninstaller.sh`


### PrepararAmbiente.sh

No requiere ningún parámetro.<br />
El script necesita imperiosamente de los siguientes archivos para lograr su cometido:
* Archivo de Configuración: *CONFDIR/CIPAK.cnf*
* Scripts ejecutables: *BINDIR/{script}.sh/.pl*
* Archivos maestros: *MAEDIR/{maestro}.csv*
* Directorio de resguardo: A definir por el instalador.

El script define las siguientes variables de ambiente:
* Por enunciado:
··* GRUPO
··* MAEDIR
··* ARRIDIR
··* OKDIR
··* PROCDIR
··* INFODIR
··* LOGDIR
··* NOKDIR
··* LOGSIZE
··* SLEEPTIME
··* PATH
* Agregadas:
··* REGSDIR: Donde se encuentra el repositorio de resguardo.
··* AMBIENTE_INICIALIZADO: flag para informar que el ambiente fue inicializado correctamente.

El script devuelve alguno de los siguientes valores:
* 0: Éxito. El usuario decide no continuar la ejecución del sistema con **RecibirOfertas**.
* 1: Error. No se inicializó el sistema (falta el archivo de configuración o ya se encuentra inicializado).
* 2: Error. No se poseen todos los scripts obligatorios.
* 3: Error. No se poseen todos los archivos maestros obligatorios.
* 4: Error. No se poseen todos los permisos necesarios en los scripts o los archivos maestros.


### RecibirOfertas.sh

No requiere ningún parámetro.<br />
Se lo ejecuta opcionalmente tras el proceso de **PrepararAmbiente** o bien independientemente.<br />
Si el ambiente no había sido inicializado, de cualquier manera, el programa no correrá.<br />

El script necesita imperiosamente de los siguientes archivos para lograr su cometido:
* Archivos de oferta: *ARRIDIR/<cod_concesionario>_<aniomesdia>.csv*
* Tabla de fechas de adjudicación: *MAEDIR/FechasAdj.csv*
* Registro de concesionarios: *MAEDIR/concesionarios.csv*
El resultado de un ciclo del programa es la separación de los archivos de oferta de *input* en aquellos válidos e inválidos según una serie de criterios:
* Archivos de oferta válidos: *OKDIR/<cod_concesionario>_<aniomesdia>.csv*
* Archivos de oferta inválidos: *NOKDIR/<cod_concesionario>_<aniomesdia>.csv*


### ProcesarOfertas.sh

No requiere ningún parámetro.<br />

El script necesita imperiosamente de los siguientes archivos para lograr su cometido:
* Archivo de Ofertas: *OKDIR/<cod_concesionario>_<aniomesdia>.csv*
* Padrón de Suscriptores: *MAEDIR/temaK_padron.csv*
* Tabla de Fechas de adjudicación: *MAEDIR/fechas_adj.csv*
* Tabla de Grupos: *MAEDIR/grupos.csv*
Desde estos input genera como resultado-output:
* Archivo de ofertas válidas: *PROCDIR/validas/<fecha_de_adjudicacion >.txt*
* Archivos procesados: *PROCDIR/procesadas/<nombre del archivo>*
* Archivos de ofertas rechazadas: *PROCDIR/rechazadas/<cod_concesionario>.rech*
* Archivos rechazados (archivo completo): *NOKDIR/<nombre del archivo>*


### GenerarSorteo.sh

No recibe parámetros.<br />

El script necesita imperiosamente del siguiente archivo para lograr su cometido:
* Tabla de Fechas de adjudicación: *MAEDIR/FechasAdj.csv*
Desde este input genera como resultado-output:
* Archivos de sorteos: *PROCDIR/sorteos/<sorteoId><fecha_de_adjudicacion>.csv*, donde se indica para cada una de las 168 órdenes el número aleatorio que se le asignó.

En caso de realizarse un flow completo del script, es decir que llegue al final de su ejecución sin ningún inconveniente, generará un archivo SRT para la fecha más próxima alojada en la Tabla de Fechas de adjudicación.


### DeterminarGanadores.pl


### MoverArchivos.sh

El script acepta hasta 3 argumentos distintos:
1. **ORIGEN** *(Requerido)*. Nombre del archivo a mover.
2. **DESTINO** *(Requerido)*. Nombre del directorio adonde se quiere mover el archivo origen.
3. **COMANDO** *(Opcional)*. Indica el nombre del comando invocador, utilizado dentro del script para loggear en la bitácora correspondiente la información pertinente. Si no se especifica, la información de ejecución se imprime por *STDOUT*.

El script devuelve alguno de los siguientes valores:
* 0: Éxito. El archivo fue movida del origen al destino sin necesidad de realizar duplicados o colocarlo en una carpeta auxiliar.
* 1: Éxito. El archivo pudo ser movido exitosamente pero debió guardarse como copia en la carpeta auxiliar *dpl/*.
* 2: Error. El destino corresponde al mismo directorio donde se halla actualmente el archivo origen y por lo tanto no se puede mover el archivo.
* 3: Error. El archivo origen no se encuentra en el directorio específicado.
* 4: Error. El directorio destino no existe.

### GrabarBitacora.sh

El script acepta hasta 3 argumentos distintos:
1. **COMANDO** *(Requerido)*. Nombre del comando invocador del script. El archivo de bitácora donde se plasmarán los registros se llamará *<COMANDO>.log*.
2. **MENSAJE** *(Requerido)*. El mensaje a registrar en la bitácora.
3. **TIPO DE MENSAJE** *(Opcional)*. Indica la categoría del mensaje a registrar en la bitácora. Puede ser INFO, WARNING o ERROR. Si no se define este parámetro, el valor por defecto es INFO.

Se utilizan las siguientes variables de ambiente:
* *LOGDIR*: Directorio donde se crearán los archivos de log.
* *USER*: Usuario actual que escribe el registro en la bitácora.
* *LOGSIZE*: Tamaño máximo de los archivos de log en KBytes.


### MostrarBitacora.pl






