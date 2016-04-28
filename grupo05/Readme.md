#Tareas

### 1) Preparar Ambiente (shell) => `Gruido`

### 2) Recibir ofertas (shell) => `Martin`
### 3) Procesar Ofertas (shell) => `Tomi`
####Input
- Concesionarios **MAEDIR/concesionarios.csv**
- Fechas de Adjudicacion **MAEDIR/FechasAdj.csv**
- Archivos de Input **ARRIDIR/<cod-concesionario>_<aniomesdia>.csv**

####Output
- Archivos Aceptados **OKDIR/<nombre del archivo>**
- Archivos Rechazados **NOKDIR/<nombre del archivo>**
- Log del Comando **LOGDIR/RecibirOfertas.log**
 

### 4) Generar sorteo (shell) => `Facu`
### 5) Determinar ganadores (perl) => `Octa`
### 6) Complementarias y Documentacion => `Bubi`
* Mover Archivo (shell | perl)
* Grabar Bitacora (shell | perl)
* Mostrar Bitacora (shell | perl)
* Detener procesos (shell | perl)
* Lanzar Proceso (shell | perl)

#Datos
[Drive con todos los csv](https://drive.google.com/open?id=0B5miVOLotTY5Mm1md2xTS3AydjQ)

-----------------------------------------------------------------------------------------
# README FINAL

### Instalar

Para instalar el sistema CIPAK en su computadora, elija un directorio y descomprima allí
el archivo CIPAK-G5.tgz (puede hacerlo mediante clic derecho, y la opción "Extract here"),
y corra el instalador dentro de la carpeta, mediante la siguiente línea de comando:
`(...)/CIPAK-G5$ bash installer.sh`


### Desinstalar

Para desinstalar el sistema, vaya a la carpeta de binarios (por default, Grupo05/binarios/)
y corra el uninstaller.sh, lo cual puede hacer mediante:
`(...)/Grupo05/binarios/$ bash uninstaller.sh`


### [SEGUIR]
