#! /bin/bash
#Tomas A. Bert
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Input
#	Archivos de Ofertas OKDIR/<cod_concesionario>_<aniomesdia>.csv
#	Padron de Suscriptores MAEDIR/temaK_padron.csv
#	Tabla de Fechas de adjudicacion MAEDIR/fechas_adj.csv
#	Tabla de Grupos MAEDIR/grupos.csv

# Output
#	Archivo de ofertas validas PROCDIR/validas/<fecha_de_adjudicacion >.txt
#	Archivos procesados PROCDIR/procesadas/<nombre del archivo>
#	Archivos de ofertas rechazadas PROCDIR/rechazadas/<cod_concesionario>.rech
#	Archivos rechazados (archivo completo) NOKDIR/<nombre del archivo>
#	Log del Comando LOGDIR/ProcesarOfertas.log

# Opciones y Parametros
#	A especificar por el desarrollador

# Licitar consiste en ofertar una suma de dinero a criterio de cada suscriptor 
# dentro de un monto minimo y maximo establecido por la Sociedad Administradora.
# Los montos minimos y maximos dependen del grupo, del valor de la cuota pura y de la cantidad de cuotas que restan hasta terminar el plan de ahorro.
# De acuerdo al grupo: 
#	monto_minimo = valor_de_cuota_pura * cantidad_de_cuotas_para_licitacion
#	monto_maximo = valor_de_cuota_puta * cantidad_de_cuotas_pendientes
# --PASOS-- []log

function rechazarRegistro {
	# 6. RECHAZAR REGISTRO (**ver campos)
	#	Si alguna de las validaciones da error, rechazar el registro grabandolo en Archivo de ofertas rechazadas
	#	Incrementar los contadores adecuados
	#	Continuar con el siguiente registro.
	
	#FORMATO (campos)
	# Fuente				Nombre del archivo de input
	# Motivo				Motivo por el cual se rechaza ESTA oferta
	# Registro de Oferta	Registro Original COMPLETO
	# usuario				Login del usuario que graba el registro
	# fecha					Fecha y hora de grabación del registro rechazado, en el formato que se desee
	
	MENSAJE_DE_RECHAZO=$1
	
	REGISTRO=`echo $registro | tr "$SEPARADOR" ","`
	FECHA=`date +%d/%m/%Y" "%H:%M:%S`
	
	echo "RECHAZADO funcion rechazarRegistro( '$MENSAJE_DE_RECHAZO' )"
	#echo "$archivo;$MENSAJE_DE_RECHAZO;$REGISTRO;$USER;$FECHA" ">>" "$PROCDIR/rechazadas/$CONCECIONARIO.rech"
	
	REGISTROS_RECHAZADOS=$[$REGISTROS_RECHAZADOS +1]
	
	return 0
	
}

function proximaFechaDeAdjudicacion {
	#Proxima fecha a FECHA DE ARCHIVO ( incluye el mismo dia ) 
	local ANO=${FECHA_ARCHIVO:0:4}
	local MES=${FECHA_ARCHIVO:4:2}
	local DIA=${FECHA_ARCHIVO:6:8}
	if grep -q "$DIA/$MES/$ANO" $MAEDIR/FechasAdj.csv; then
		#La fecha esta en el archiv - "es hoy la proxima adjudicacion"
		FECHA_DE_ADJUDICACION=$FECHA_ARCHIVO #ANOMESDIA
		return 0
	fi
	#Busco la mas cercana <== Ya se que no esta
	#FORMATO de FechasAdj.csv [dia/mes/ano;Lugar]
	local diferenciaMin=0
	local diferenciaActual=0
	local PROX=""
	while read fecha; do
		local FechaRow=`echo $fecha | tr ";" "\n" | head -n 1 | tr "/" "\n"`
		read fDIA fMES fANO <<< $FechaRow
		local FechaSEP=$fANO$fMES$fDIA
		if [ $FechaSEP -gt $FECHA_ARCHIVO ]; then
			#Si estoy aca -> FechaSep > FECHA_ARCHIVO
			diferenciaActual=$(( $FechaSEP-$FECHA_ARCHIVO ))
			if [  "$diferenciaActual" -lt "$diferenciaMin" ] || [ $diferenciaMin -eq 0 ]; then
				#Esta mas cerca que una fecha comparada anteriormente || Todavia no se comparo ninguna
				diferenciaMin=$diferenciaActual
				PROX=$fANO$fMES$fDIA
			fi
		fi
	done <$MAEDIR/FechasAdj.csv
	
	#Aigno a la global
	FECHA_DE_ADJUDICACION=$PROX #ANOMESDIA
	
	return 0
}


SELF=`basename ${0%.*}`
OKDIR="datos/OKDIR"
PROCDIR="datos/PROCDIR"
MAEDIR="datos/MAEDIR"

#SON PARAMETROS ??
CANT_CAMPOS_ARCHIVO=2
SEPARADOR=";"

# 1. Procesar todos los archivos que se encuentran en OKDIR
#	El orden de procesamiento de los archivos debe hacerse cronologico desde el antiguo al mas 
#	reciente segun sea la fecha que figura en el nombre del archivo 
#		[Inicio de ProcesarOfertas]
#		[Cantidad de archivos a procesar:<cantidad>]

#sh GrabarBitacora.sh "$SELF" "Inicio de ProcesarOfertas" "INFO"
echo "Inicio de ProcesarOfertas"

FILES=(`ls -1p $OKDIR/ | grep -v "/\$" | sort -n -t _ -k 2`) #Ordeno por fecha -n (numerico), -t (split con _), -k split[2]

#sh GrabarBitacora.sh "$SELF" "Cantidad de archivos a procesar:  ${#FILES[@]}" "INFO"
printf "Cantidad de archivos a procesar: ${GREEN}${#FILES[@]}${NC}\n"

ARCHIVOS_ACEPTADOS=0
ARCHIVOS_RECHAZADOS=0

#Recorro archivos
for archivo in ${FILES[@]}
do
	ARCHIVO_NAME=`basename $archivo`
	FILE_PATH=$OKDIR/$archivo
	
	# 2. Procesar Un Archivo
	#	Procesar un archivo es procesar todos los registros que contiene ese archivo
	#	excepto cuando el archivo ya fue procesado o bien no posee la estructura interna adecuada.

	# 2.1 Verificar que no sea un archivo duplicado
	#	Cada vez que se procesa un archivo, se lo mueve tal cual fue recibido y con el mismo nombre a PROCDIR/procesadas
	#	Desde el directorio se puede verificar si ya existe, si existe moverlo a NOKDIR
	#		[Se rechaza el archivo por estar DUPLICADO]
	if [ -f "$PROCDIR/procesadas/$ARCHIVO_NAME" ]; then
		echo "El archivo [$ARCHIVO_NAME] se rechaza porque ya esta en procesadas" 
		ARCHIVOS_RECHAZADOS=$[$ARCHIVOS_RECHAZADOS +1]
		#sh GrabarBitacora.sh "$SELF" "Se rechaza el archivo $ARCHIVO_NAME por estar DUPLICADO" "WAR"
		#sh MoverArchivos.sh "$FILE_PATH" "$NOKDIR" "$SELF"
		continue
	fi
	
	# 2.2 Verificar la cantidad de campos del primer registro
	#	Si la cantidad de campos del primer registro no se corresponde con el formato establecido, 
	#	asumir que el archivo esta daniado
	#	Si no cumple mover a NOKDIR
	#		[Se rechaza el archivo porque su estructura no se corresponde con el formato esperado]
	NUMERO_CAMPOS=`head -n 1 $FILE_PATH | tr "$SEPARADOR" "\n" | wc -l`

	if [ "$NUMERO_CAMPOS" -ne "$CANT_CAMPOS_ARCHIVO" ]; then
		echo "Se rechaza el archivo $ARCHIVO_NAME porque su estructura no se corresponde con el formato esperado"
		ARCHIVOS_RECHAZADOS=$[$ARCHIVOS_RECHAZADOS +1]
		#sh MoverArchivos.sh "$FILE_PATH" "$NOKDIR" "$SELF"
		#sh GrabarBitacora.sh "$SELF" "Se rechaza el archivo $ARCHIVO_NAME porque su estructura no se corresponde con el formato esperado" "WAR" 
		continue
	fi

	# 3. Si se puede procesar el archivo (pasa el 2)
	#		[Archivo a procesar: <nombre del archivo a procesar>]
	printf "Archivo a procesar: ${GREEN}$ARCHIVO_NAME${NC}\n"
	#sh GrabarBitacora.sh "$SELF" "Archivo a procesar: $ARCHIVO_NAME" "INFO"
	ARCHIVOS_ACEPTADOS=$[$ARCHIVOS_ACEPTADOS +1]
	
	#Me ahorro y defino ahora la proxima fecha de adjudicacion para el archivo que estoy haciendo
	FECHA_ARCHIVO=`echo ${ARCHIVO_NAME/.*} | tr "_" "\n" | tail -n 1` #Me quedo con el aniomesdia del nombre del archivo 
	proximaFechaDeAdjudicacion
	
	REGISTROS_LEIDOS=0
	REGISTROS_ACEPTADOS=0
	REGISTROS_RECHAZADOS=0
	
	#RECORRO REGISTROS
	while read registro; do
		REGISTROS_LEIDOS=$[$REGISTROS_LEIDOS +1]
		# Espero 2 campos (Contrato fusionado, Importe de la Oferta)
		CAMPOS=(`echo $registro | tr "$SEPARADOR" "\n"`) 
		#TODO: Verifico que sean 2 ?
		
		# 4. Validar oferta (si no pasa los campos rechazar)
		# MOTIVOS DE RECHAZO:
		#	4.1 Contrato no encontrado.
		#	4.2 Grupo CERRADO.
		#	4.3 No alcanza el monto Minimo.
		#	4.4 Supera el monto maximo.
		#	4.5 Suscriptor no puede participar.
		
		CONTRATO_FUSIONADO=${CAMPOS[0]}
		# 4.1 Contrato Fusionado [7] = Grupo[4];Orden[3] 
		# Se debe validar contra el padron de suscriptores MAEDIR/temaK_padron.csv (existe o no existe)
		GRUPO=${CONTRATO_FUSIONADO:0:4}
		ORDEN=${CONTRATO_FUSIONADO:4:3}

		SUSCRIPTOR=(`grep "^$GRUPO;$ORDEN" $MAEDIR/temaK_padron.csv | tr ";" "\n"`)
		CONCECIONARIO=${SUSCRIPTOR[3]}

		if [ "${#SUSCRIPTOR[@]}" -eq 0 ]; then 
			# Contrato no encontrado Grupo+Orden
			rechazarRegistro "Contrato no encontrado"
			continue
		fi
		
		# Si llego aca, el grupo existe (esta en temaK_padron.csv).

		# Numero de grupo [4]: Se debe validar contra el archivo de Grupos: MAEDIR/Grupos.csv (Estado del grupo ABIERTO o NUEVO) 
		GRUPO=(`grep "^$GRUPO" $MAEDIR/grupos.csv | tr "$SEPARADOR" "\n"`)
		
		# 4.2 Estado es GRUPO[1] - ver tabla
		if [ "${GRUPO[1]}" == "CERRADO" ]; then
			# El grupo esta cerrado
			rechazarRegistro "El grupo esta cerrado"
			continue
		fi
		
		
		# Importe (2do Campo)
		IMPORTE=`echo ${CAMPOS[1]} | tr "," "."`

		VALOR_CUOTA_PURA=`echo ${GRUPO[3]} | tr "," "."` #Reemplazo comma por punto (en distros de EEUU se usa punto)
		CANTIDAD_CUOTAS_PARA_LICITACION=`echo ${GRUPO[5]} | tr "," "."`
		CANTIDAD_CUOTAS_PENDIENTES=`echo ${GRUPO[4]} | tr "," "."`
		
		MONTO_MINIMO=`bc -l <<< "$VALOR_CUOTA_PURA*$CANTIDAD_CUOTAS_PARA_LICITACION"`
		
		# 4.3 monto_minimo (valor de cuota pura * cantidad de cuotas para licitación) <= IMPORTE
		if [ `echo $MONTO_MINIMO'>'$IMPORTE | bc -l` -eq 1 ]; then
			# No alcanza el monto Minimo
			rechazarRegistro "No alcanza el monto Minimo"
			continue
		fi
		
		# 4.4 IMPORTE <= monto_maximo (valor de cuota pura * cantidad de cuotas pendientes)
		MONTO_MAXIMO=`bc -l <<< "$VALOR_CUOTA_PURA*$CANTIDAD_CUOTAS_PENDIENTES"`
		if [ `echo $IMPORTE'>'$MONTO_MAXIMO | bc -l` -eq 1 ]; then
			# Supera el monto maximo
			rechazarRegistro "Supera el monto maximo"
			continue
		fi
		
		# 4.5 Participa?: Si esta en blanco, no puede participar.
		if [ ! ${SUSCRIPTOR[5]} == 1 ] && [ ! ${SUSCRIPTOR[5]} == 2 ]; then
			# Suscriptor no puede participar
			rechazarRegistro "Suscriptor no puede participar"
			continue
		fi	
		
		# 5. GRABAR oferta valida (**ver cuadro de campos)
		#	-La fecha de adjudicacion del nombre del archivo a grabar se obtiene de la Tabla de Fechas de adjudicacion MAEDIR/fechas_adj.csv
		#	corresponde con la fecha del proximo acto de adjudicacion
		#	-Incrementar los contadores adecuados
		#	-Continuar con el siguiente registro.
		
		#Formato
		# Código de Concesionario	Código de concesionario proveniente del nombre del archivo
		# Fecha del archivo			Fecha del nombre del archivo, formato a elección
		# Contrato Fusionado		proveniente del archivo de ofertas
		# Grupo						Primeros 4 caracteres del Contrato
		# Nro de Orden				Últimos 3 caracteres del Contrato
		# Importe Ofertado			Importe proveniente del archivo de ofertas
		# Nombre del Suscriptor		Apellido y nombre del suscriptor, proveniente del padrón de suscriptores
		# usuario					Login del usuario que graba el registro
		# fecha						Fecha y hora de grabación del registro, en el formato que se desee
		
		NOMBRE=${SUSCRIPTOR[2]}
		FECHA=`date +%d/%m/%Y" "%H:%M:%S`
		echo "ACEPTADA"
		#echo "$CONCECIONARIO;$FECHA_ARCHIVO;$CONTRATO_FUSIONADO;$GRUPO;$ORDEN;$IMPORTE;$NOMBRE;$USER;$FECHA" ">>" $PROCDIR/validas/$FECHA_DE_ADJUDICACION.txt
		
		# Si llego aca, esta aceptado
		REGISTROS_ACEPTADOS=$[$REGISTROS_ACEPTADOS +1]
		
	done <$FILE_PATH
	# 7. Fin de Archivo
	#	Para evitar el reprocesamiento de un mismo archivo, mover el archivo procesado a: PROCDIR/procesadas
	#sh MoverArchivos.sh "$FILE_PATH" "$PROCDIR/procesadas" "$SELF"
	
	#	[Registros leidos = aaa: cantidad de ofertas validas bbb cantidad de ofertas rechazadas = ccc]
	#sh GrabarBitacora.sh "$SELF" "Registros leidos = $REGISTROS_LEIDOS: cantidad de ofertas validas $REGISTROS_VALIDOS cantidad de ofertas rechazadas = $REGISTROS_RECHAZADOS" "INFO"
	echo Registros leidos = $REGISTROS_LEIDOS: cantidad de ofertas validas = $REGISTROS_ACEPTADOS cantidad de ofertas rechazadas = $REGISTROS_RECHAZADOS
					
	# 8. Llevar a cero todos los contadores de registros
	REGISTROS_LEIDOS=0
	REGISTROS_ACEPTADOS=0
	REGISTROS_RECHAZADOS=0
		
	# 9. Continuar con el siguiente archivo
	# 10. Repetir hasta que se terminen todos los archivos.
done

# 11. Fin Proceso
#	[cantidad de archivos procesados]
#	[cantidad de archivos rechazados]
echo cantidad de archivos procesados $ARCHIVOS_ACEPTADOS
echo cantidad de archivos rechazados $ARCHIVOS_RECHAZADOS
echo Fin de ProcesarOfertas
#sh GrabarBitacora.sh "$SELF" "cantidad de archivos procesados $ARCHIVOS_ACEPTADOS" "INFO"
#sh GrabarBitacora.sh "$SELF" "cantidad de archivos rechazados $ARCHIVOS_RECHAZADOS" "INFO"
#sh GrabarBitacora.sh "$SELF" "Fin de ProcesarOfertas" "INFO"


