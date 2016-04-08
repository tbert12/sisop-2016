#!/bin/bash

# Input
#	Archivos de Ofertas OKDIR/<cod_concesionario>_<aniomesdia>.csv
#	Padr�n de Suscriptores MAEDIR/temaK_padron.csv
#	Tabla de Fechas de adjudicacion MAEDIR/fechas_adj.csv
#	Tabla de Grupos MAEDIR/grupos.csv

# Output
#	Archivo de ofertas validas PROCDIR/validas/<fecha_de_adjudicaci�n >.txt
#	Archivos procesados PROCDIR/procesadas/<nombre del archivo>
#	Archivos de ofertas rechazadas PROCDIR/rechazadas/<cod_concesionario>.rech
#	Archivos rechazados (archivo completo) NOKDIR/<nombre del archivo>
#	Log del Comando LOGDIR/ProcesarOfertas.log

# Opciones y Par�metros
#	A especificar por el desarrollador
	

# Licitar consiste en ofertar una suma de dinero a criterio de cada suscriptor dentro de un monto m�nimo y m�ximo establecido por la Sociedad Administradora.
# Los montos m�nimos y m�ximos dependen del grupo, del valor de la cuota pura y de la cantidad de cuotas que restan hasta terminar el plan de ahorro.
# De acuerdo al grupo: 
#	monto_m�nimo = valor_de_cuota_pura * cantidad_de_cuotas_para_licitaci�n
#	monto_m�ximo = valor_de_cuota_puta * cantidad_de_cuotas_pendientes

# --PASOS-- []log

# 1. Procesar todos los archivos que se encuentran en OKDIR
#	El orden de procesamiento de los archivos debe hacerse cronol�gico desde el antiguo al m�s reciente seg�n sea la fecha que figura en el nombre del archivo 
#		[Inicio de ProcesarOfertas]
#		[Cantidad de archivos a procesar:<cantidad>]

# 2. Procesar Un Archivo
#	Procesar un archivo es procesar todos los registros que contiene ese archivo
#	excepto cuando el archivo ya fue procesado o bien no posee la estructura interna adecuada.

# 2.1 Verificar que no sea un archivo duplicado
#	Cada vez que se procesa un archivo, se lo mueve tal cual fue recibido y con el mismo nombre a PROCDIR/procesadas
#	Desde el directorio se puede verificar si ya existe, si existe moverlo a NOKDIR
#		[Se rechaza el archivo por estar DUPLICADO]

# 2.2 Verificar la cantidad de campos del primer registro
#	Si la cantidad de campos del primer registro no se corresponde con el formato establecido, asumir que el archivo est� da�ado
#	Si no cumple mover a NOKDIR
#		[Se rechaza el archivo porque su estructura no se corresponde con el formato esperado]

# 3. Si se puede procesar el archivo (pasa el 2)
#		[Archivo a procesar: <nombre del archivo a procesar>]

# 4. Validar oferta (si no pasa los campos rechazar)
# 	CAMPOS:
#		-Contrato Fusionado [7]: Se debe validar contra el padr�n de suscriptores MAEDIR/temaK_padron.csv (existe o no existe)
#			Numero de grupo [4]: Se debe validar contra el archivo de Grupos: MAEDIR/Grupos.csv (Estado del grupo ABIERTO o NUEVO) 
#			Numero de orden del suscriptor dentro del grupo [3]
#		-Importe:
#			monto_minimo <= IMPORTE <= monto_maximo
#		-Participa?:
#			Si en el padr�n de suscriptores el suscriptor tiene la marca de participaci�n en 1 o 2 puede participar. 
#			Si esta en blanco, no puede participar.
#	MOTIVOS DE RECHAZO:
#		-Contrato no encontrado
#		-No alcanza el monto M�nimo
#		-Supera el monto m�ximo
#		-Suscriptor no puede participar
#		-Grupo CERRADO	
	
# 5. GRABAR oferta valida (**ver cuadro de campos)
#	-La fecha de adjudicaci�n del nombre del archivo a grabar se obtiene de la Tabla de Fechas de adjudicacion MAEDIR/fechas_adj.csv
#	corresponde con la fecha del pr�ximo acto de adjudicaci�n
#	-Incrementar los contadores adecuados
#	-Continuar con el siguiente registro.

# 6. RECHAZAR REGISTRO (**ver campos)
#	Si alguna de las validaciones da error, rechazar el registro grab�ndolo en Archivo de ofertas rechazadas
#	Incrementar los contadores adecuados
#	Continuar con el siguiente registro.

# 7. Fin de Archivo
#	Para evitar el reprocesamiento de un mismo archivo, mover el archivo procesado a: PROCDIR/procesadas
#	[Registros le�dos = aaa: cantidad de ofertas validas bbb cantidad de ofertas rechazadas = ccc]

# 8. Llevar a cero todos los contadores de registros

# 9. Continuar con el siguiente archivo

# 10. Repetir hasta que se terminen todos los archivos.

# 11. Fin Proceso
#	[cantidad de archivos procesados]
#	[cantidad de archivos rechazados]
#	[Fin de ProcesarOfertas]