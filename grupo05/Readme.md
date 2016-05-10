# CIPAK | Sistemas Operativos (75.08) | 1er Cuatrimestre 2016 | FIUBA

## Descripción del sistema


### Instalar

Para instalar el sistema **CIPAK** en su computadora, coloque un dispositivo USB con el archivo `CIPAK-G5.tgz`, luego elija un directorio donde descomprimirlo, realice la descompresión del mismo (puede hacerlo mediante clic derecho, y la opción *Extract here*),
y corra el instalador dentro de la carpeta, mediante la siguiente línea de comando:
`.../CIPAK-G5$ . installer.sh`<br />
El instalador debe estar en el mismo directorio que el fichero comprimido `source.tar.gz` para poder realizar la instalación con éxito.


### Desinstalar

Para desinstalar el sistema, vaya a la carpeta de binarios (por default, *Grupo05/binarios/*)
y corra el desinstalador **uninstaller.sh**, lo cual puede hacer mediante:
`.../Grupo05/binarios$ . uninstaller.sh`<br />


### Preparar el ambiente

Una vez instalado **CIPAK** ejecute en una terminal en la dirección *Grupo05/binarios* el comando
`.../Grupo05/binarios$ . PrepararAmbiente.sh`
Mediante esto usted tendrá todo preparado para poder ejecutar los programas del sistema.<br />


### Recibir ofertas

Una vez iniciado el ambiente, puede en cualquier momento (el paso anterior ofrece hacerlo automáticamente) iniciar el *daemon* receptor mediante
`.../Grupo05/binarios$ bash LanzarProceso.sh RecibirOfertas.sh`
con lo cual se iniciará en un segundo plano el proceso que medie la recepción de archivos de oferta. Para frenarlo, utilice el mismo formato pero con el comando `DetenerProceso.sh`.<br />


### Procesar ofertas

ProcesarOfertas es llamado por RecibirOfertas cuando hay novedades.
Una vez finalizado se pueden ver los resultados en los outputs correspondientes referenciados en la documentación.<br />


### Generar sorteo

Una vez que el ambiente esté listo podrá generar el sorteo mediante
`.../Grupo05/binarios$ bash LanzarProceso.sh "bash GenerarSorteo.sh"`
Esto genera los archivos necesarios para poder determinar los ganadores.<br />


### Determinar ganadores

Habiendo preparado el ambiente, y posteriormente generado el sorteo correspondiente<br />
Posicionarse en `.../Grupo05/binarios/` y ejecutar el comando mediante la sentencia
`$ ./DeterminarGanadores.pl`. Se accederá entonces al menu correspondiente a las consultas.<br />
Dentro de las opciones del comando, usted puede utilizar:<br />
`-g` para grabar las consultas realizadas en un archivo de texto. `$ ./DeterminarGanadores.pl -g`<br />
`-a` para acceder a la ayuda correspondiente al comando. `$ ./DeterminarGanadores.pl -a`<br />

### Lanzar y detener procesos

Toda la lógica de ejecución de procesos está centralizada en las funciones **LanzarProceso** y **DetenerProceso**. Los procesos son ejecutados en background, demonizados. La única excepción en la que no DEBE llamarse a **LanzarProceso** para ejecutar otro proceso es en el caso de la función de **PrepararAmbiente** pues, por requerimiento, un proceso no puede ser lanzado sin estar inicializado el ambiente.<br />



## Modo de uso de scripts


### installer.sh

Si recibió el paquete **CIPAK_G5.tgz**, el primer paso es descomprimirlo. Esto se puede hacer mediante clic derecho y eligiendo la opción de descompresión en la carpeta actual, o con:
`tar -xzf CIPAK_G5.tgz`<br />

Tras esto, dispondrá de una carpeta del mismo nombre con todo los archivos que necesita la instalación, junto con esta documentación.<br />
El instalador no requiere ningún parámetro para su funcionamiento. Para ejecutarlo, se recomienda que se utilice el siguiente comando, con la notación de `.` para que la instalación se realice en el mismo proceso que la terminal, y con el *working directory* posicionado en la carpeta del mismo, de forma que pueda funcionar totalmente:
`. installer.sh`<br />

Opcionalmente, se puede utilizar el flag `-d` para definir todas las variables de ambiente diferentes de aquellas por default:
`. installer.sh -d`<br />


### uninstaller.sh

El desinstalador no utiliza ningún parámetro. Para ejecutarlo, se recomienda que se utilice el siguiente comando, con la notación de `.` para que la desinstalación se realice en el mismo proceso que la terminal y con el *working directory* posicionado en la carpeta del script, de forma que pueda garantizarse su total funcionamiento:
`. uninstaller.sh`<br />


### PrepararAmbiente.sh

No requiere ningún parámetro.<br />
El script necesita imperiosamente de los siguientes archivos para lograr su cometido:<br />
* Archivo de Configuración: *CONFDIR/CIPAK.cnf*
* Scripts ejecutables: *BINDIR/{script}.sh/.pl*
* Archivos maestros: *MAEDIR/{maestro}.csv*
* Directorio de resguardo: A definir por el instalador.<br />

El script define las siguientes variables de ambiente:
* Por enunciado:
	* GRUPO
	* MAEDIR
	* ARRIDIR
	* OKDIR
	* PROCDIR
	* INFODIR
	* LOGDIR
	* NOKDIR
	* LOGSIZE
	* SLEEPTIME
	* PATH
* Agregadas:
	* REGSDIR: Donde se encuentra el repositorio de resguardo.
	* AMBIENTE_INICIALIZADO: flag para informar que el ambiente fue inicializado correctamente.<br />

El script devuelve alguno de los siguientes valores:
* **0**: Éxito. El usuario decide no continuar la ejecución del sistema con **RecibirOfertas**.
* **1**: Error. No se inicializó el sistema (falta el archivo de configuración o ya se encuentra inicializado).
* **2**: Error. No se poseen todos los scripts obligatorios.
* **3**: Error. No se poseen todos los archivos maestros obligatorios.
* **4**: Error. No se poseen todos los permisos necesarios en los scripts o los archivos maestros.<br />


### RecibirOfertas.sh

No requiere ningún parámetro.<br />
Se lo ejecuta opcionalmente tras el proceso de **PrepararAmbiente** o bien independientemente.<br />
Si el ambiente no había sido inicializado, de cualquier manera, el programa no correrá.<br />

El script necesita imperiosamente de los siguientes archivos para lograr su cometido:
* Archivos de oferta: *ARRIDIR/{cod_concesionario}_{aniomesdia}.csv*
* Tabla de fechas de adjudicación: *MAEDIR/FechasAdj.csv*
* Registro de concesionarios: *MAEDIR/concesionarios.csv*<br />

El resultado de un ciclo del programa es la separación de los archivos de oferta de *input* en aquellos válidos e inválidos según una serie de criterios, con lo que el *output* será:
* Archivos de oferta válidos: *OKDIR/{cod_concesionario}_{aniomesdia}.csv*
* Archivos de oferta inválidos: *NOKDIR/{cod_concesionario}_{aniomesdia}.csv*<br />


### ProcesarOfertas.sh

No requiere ningún parámetro.<br />

El script necesita imperiosamente de los siguientes archivos para lograr su cometido:
* Archivo de Ofertas: *OKDIR/{cod_concesionario}_{aniomesdia}.csv*
* Padrón de Suscriptores: *MAEDIR/temaK_padron.csv*
* Tabla de Fechas de adjudicación: *MAEDIR/fechas_adj.csv*
* Tabla de Grupos: *MAEDIR/grupos.csv*<br />

Desde estos input genera como resultado-output:
* Archivo de ofertas válidas: *PROCDIR/validas/{fecha_de_adjudicacion}.txt*
* Archivos procesados: *PROCDIR/procesadas/{nombre del archivo}*
* Archivos de ofertas rechazadas: *PROCDIR/rechazadas/{cod_concesionario}.rech*
* Archivos rechazados (archivo completo): *NOKDIR/{nombre del archivo}*<br />


### GenerarSorteo.sh

No recibe parámetros.<br />

El script necesita imperiosamente del siguiente archivo para lograr su cometido:
* Tabla de Fechas de adjudicación: *MAEDIR/FechasAdj.csv*<br />

Desde este input genera como resultado-output:
* Archivos de sorteos: *PROCDIR/sorteos/{sorteoId}{fecha_de_adjudicacion}.csv*, donde se indica para cada una de las 168 órdenes el número aleatorio que se le asignó.<br />

En caso de realizarse un flow completo del script, es decir que llegue al final de su ejecución sin ningún inconveniente, generará un archivo SRT para la fecha más próxima alojada en la Tabla de Fechas de adjudicación.<br />


### DeterminarGanadores.pl

El script acepta 2 flags diferentes:<br />
1. `-a`: Ayuda. Se imprime en pantalla la ayuda del comando, esto es qué significa cada opción y cómo navegar a través del script.<br />
2. `-g`: Modo grabar. Es la opción para grabar los resultados de las consultas en archivos, cuyos nombres son representativos de las consultas realizadas. Por salida estándar se avisará que las consultas se están grabando en disco.<br />
En caso de llamarse sin argumentos al comando, se realizan consultas de tipo provisorias, es decir sólo se ven en pantalla y no persisten en el disco.<br />

El script necesita imperiosamente de los siguientes archivos para funcionar correctamente:
* Padrón de Suscriptores: *MAEDIR/temaK_padron.csv*
* Tabla de Grupos: *MAEDIR/grupos.csv*
* Archivo de ofertas válidas: *PROCDIR/validas/{fecha_de_adjudicacion}.txt*
* Archivos de sorteos: *PROCDIR/sorteos/{sorteoId}_{fecha_de_adjudicacion}.srt*<br />

Si se corre en modo grabar (`-g`), desde estos input se genera como resultado-output:
* Resultado general del sorteo: *INFODIR/{sorteoId}_{fecha_de_adjudicacion}.txt*
* Ganadores por Sorteo: *INFODIR/{sorteoId}_Grdxxxx-Grhyyyy_{fecha_de_adjudicacion}*
* Ganadores por Licitación: *INFODIR/{sorteoId}_Grdxxxx-Grhyyyy_{fecha_de_adjudicacion}*
* Resultados por grupo: *INFODIR/{sorteoId}_Grupoxxxx_{fecha_de_adjudicacion}*<br />


### MoverArchivos.sh

El script acepta hasta 3 argumentos distintos:<br />
1. **ORIGEN** *(Requerido)*. Nombre del archivo a mover.
2. **DESTINO** *(Requerido)*. Nombre del directorio adonde se quiere mover el archivo origen.<br />
3. **COMANDO** *(Opcional)*. Indica el nombre del comando invocador, utilizado dentro del script para loggear en la bitácora correspondiente la información pertinente. Si no se especifica, la información de ejecución se imprime por *STDOUT*.<br />

El script devuelve alguno de los siguientes valores:
* **0**: Éxito. El archivo fue movida del origen al destino sin necesidad de realizar duplicados o colocarlo en una carpeta auxiliar.
* **1**: Éxito. El archivo pudo ser movido exitosamente pero debió guardarse como copia en la carpeta auxiliar *dpl/*.
* **2**: Error. El destino corresponde al mismo directorio donde se halla actualmente el archivo origen y por lo tanto no se puede mover el archivo.
* **3**: Error. El archivo origen no se encuentra en el directorio específicado.
* **4**: Error. El directorio destino no existe.<br />

### GrabarBitacora.sh

El script acepta hasta 3 argumentos distintos:<br />
1. **COMANDO** *(Requerido)*. Nombre del comando invocador del script. El archivo de bitácora donde se plasmarán los registros se llamará *{COMANDO}.log*.<br />
2. **MENSAJE** *(Requerido)*. El mensaje a registrar en la bitácora.<br />
3. **TIPO DE MENSAJE** *(Opcional)*. Indica la categoría del mensaje a registrar en la bitácora. Puede ser INFO, WARNING o ERROR. Si no se define este parámetro, el valor por defecto es INFO.<br />

Se utilizan las siguientes variables de ambiente:
* *LOGDIR*: Directorio donde se crearán los archivos de log.
* *USER*: Usuario actual que escribe el registro en la bitácora.
* *LOGSIZE*: Tamaño máximo de los archivos de log en KBytes.<br />


### MostrarBitacora.pl

El script acepta hasta 3 argumentos distintos:<br />
1. **BITACORA** *(Requerido)*. Nombre del archivo bitácora sobre el cual se va a realizar la consulta. Debe especificarse ruta relativa y extensión del archivo.<br />
2. **QUERY** *(Opcional)*. Puede ser tanto una cadena de texto normal como una expresión regular. Funciona como filtro puesto que se mostrarán sólo las líneas de la bitácora correspondiente que matcheen con la query ingresada. En caso de no indicarse este parámetro, se mostrarán todas las líneas de la bitácora.<br />
3. **ARCHIVO DE SALIDA** *(Opcional)*. Es el nombre y extensión del archivo en el cual se imprimirán las líneas de la bitácora matcheadas por la query. En caso de no indicarse, obviamente se imprimirán por *STDOUT* por defecto. El archivo tendrá ubicación relativa al directorio donde se está ejecutando el script. Si el archivo de salida especificado no existe, lo crea; si ya existe, las líneas se insertan al final del mismo, en orden.<br />

El script devuelve alguno de los siguientes valores:
* **0**: Éxito. El archivo bitácora fue abierto correctamente. No se distingue si la consulta fue *matcheada* o no en el valor de retorno.
* **1**: Error. No se pudo abrir el archivo de bitácora sobre el que se va a realizar la consulta.
* **2**: Error. No se pudo abrir o crear el archivo de salida del script.<br />


### LanzarProceso.sh

Es necesario que la variable de ambiente `AMBIENTE_INICIALIZADO` esté setteada como verdadera (1) para poder lanzar cualquier proceso.<br /> 

El script acepta hasta 2 argumentos distintos:<br />
1. **PROCESO** *(Requerido)*. Nombre completo del proceso a lanzar, incluidos todos los parámetros que este reciba. Debemos imaginar este argumento como un comando cualquiera que queramos ejecutar en una línea de shell en la terminal.<br />
2. **COMANDO** *(Opcional)*. Indica el comando desde el cual se invoca al script. En caso de no pasarse este argumento, en caso de querer registrarse algo en la bitácora no se podrá puesto que no estará especificado el comando correspondiente a la misma.<br />

El comportamiento por defecto de la función es lanzar los procesos en *background*. No obstante, se puede cambiar este comportamiento para que el proceso sea lanzado en primer plano setteando el *flag* opcional `-f` o `--foreground`.<br />

Se recomienda invocar este comando como `bash LanzarProceso.sh "{PROCESO}"` cuando se lo quiera llamar desde la línea de comandos. Por el contrario, se sugiere hacerlo *source* (alias `.`) en aquellos casos en los que se lo ejecute desde otro script: `. LanzarProceso.sh "{PROCESO}"`. El porqué de esta diferenciación tiene que ver con cómo deberá manejar el script el registro de errores e información.<br />

El script devuelve alguno de los siguientes valores:
* **0**: Éxito. El proceso especificado pudo ser lanzado correctamente.
* **1**: Error. El proceso a lanzar ya está en ejecución.
* **2**: Error. Ante cualquier otro error al querer lanzar el proceso en background.
* **3**: Error. El ambiente no fue inicializado.
* **4**: Error. La función no recibió parámetros, es decir que no se especificó el proceso a lanzar.<br />


### DetenerProceso.sh

El script acepta hasta 3 argumentos distintos:<br />
1. **PROCESO** *(Requerido)*. Nombre completo del proceso a detener.<br />
2. **COMANDO** *(Requerido)*. Nombre del comando desde donde se invoca esta función. Este argumento sirve para registrar en la bitácora correspondiente a dicho comando todo lo referente a la ejecución del script.<br />
3. **PID** *(Opcional)*. Indica el PID del proceso a detener. En caso de no especificarse, se busca el PID entre los procesos en ejecución de acuerdo al nombre del proceso. Cabe aclarar que, por cómo se manejan los procesos en el sistema y en UNIX en general, el nombre del proceso puede matchear con varios procesos con PIDs distintos; en ese caso, se selecciona el primer PID de la lista.<br />

El script devuelve alguno de los siguientes valores:
* **0**: Éxito. El proceso se estaba ejecutando y fue detenido con éxito. En realidad, el valor de retorno que se devuelve es el correspondiente al comando `kill {PID}`.
* **1**: Error. El proceso a detener no estaba ejecutándose.
* **2**: Error. La función no recibió parámetros, es decir que no se especificó el proceso a detener.<br />


