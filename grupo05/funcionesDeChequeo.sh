#! /bin/bash
# 
# Universidad de Buenos Aires
# Facultad de Ingenieria
#
# 75.08 Sistemas Operativos
# Trabajo Practico
# Autor: Grupo 5
#
# Funciones de chequeo
# retornan 0 si está todo OK, distinto de 0 en caso de error.


chequearSuscriptorDelPadron () {
	local LINE=$1
	local CALLER=$2
	#Grupo 4 caracteres 	Numero de Grupo
	#Orden 3 caracteres 	Numero de orden del suscriptor dentro del grupo
	#Nombre del Suscriptor 	N caracteres, Apellido y Nombre del suscriptor
	#Concesionario 			4 caracteres, Código del concesionario
	#Coeficiente 			Valor numérico coeficiente de conversión
	#Participa? 			1 carácter, Marca de participación. Valores posibles: 1 si participa, 2. Condicional, blanco no participa
	#Motivo 2 caracteres 	Motivo de la no participación, puede ser blanco
	#Cuotas de recupero 	Puede ser 000000
	#Cuotas de deuda 		Puede ser 00
	#Fecha 1er venc		 	Puede ser 00000000
	#Primer cuota con deuda Puede ser 00
	#Deuda total de Deuda 	puede ser 0000000000
	#Id suscripción 		Numero de suscripción

	#[^;]* puede fallar en si el archivo es iso y estamos utilizando utf
	#Si falla hay que realizar un 
	# iconv -f iso-8859-1 -t utf-8 $MAEDIR/temaK_padron.csv > $MAEDIR/temaK_padron.fix_charset.csv

	
	local EGREP_PATTERN="^[0-9]{4};[0-9]{3};[^;]*;[0-9]{4};[0-9]+;[0-2 ]?;.{2}?;[0-9]{6};[0-9]{2};[0-9]{8};[0-9]{2};[0-9]{10};[0-9]+$"
	if echo "$LINE" | egrep -a -q "$EGREP_PATTERN"
		then
			echo 0
	else
		#Fuerzo con el utf8 (se que el archivo es iso [file -i "$MAEDIR/temaK_padron.csv"])
		if echo "$LINE" | iconv -f iso-8859-1 -t utf-8 | egrep -a -q "$EGREP_PATTERN"
			then
				echo 0
		else
			local NRO_LINEA=`grep -nr -a "$LINE" "$MAEDIR/temaK_padron.csv" | tr ":" "\n" | head -n 1`
			bash GrabarBitacora.sh "$CALLER" "('$LINE')" 2
			bash GrabarBitacora.sh "$CALLER" "Padron invalido en el archivo de Padrones. Linea: $NRO_LINEA" 2
			
			echo 1
		fi
	fi
}

chequearGrupo () {
	local LINE=$1
	local CALLER=$2

	#Nro de Grupo 4 Caracteres. Identifica al Grupo
	#Estado del Grupo N caracteres, valores posibles NUEVO, ABIERTO, CERRADO
	#Cantidad de Cuotas Numérico. Cantidad total de Cuotas de Plan de Ahorro previo
	#Cuota Pura Importe. Representa el Valor de una cuota
	#Cantidad de cuotas pendientes Numérico. Nos indica la cantidad de cuotas pendientes del Plan
	#Cantidad de cuotas para licitación Numérico. Representa el mínimo de cuotas necesarias para licitar

	local EGREP_PATTERN="^[0-9]{4};(NUEVO|ABIERTO|CERRADO);[0-9]+;[0-9]+,?[0-9]+;[0-9]+;[0-9]+$"
	if echo "$LINE" | egrep -a -q "$EGREP_PATTERN"  
		then
			echo 0
	else
		local NRO_LINEA=`grep -nr "$LINE" "$MAEDIR/grupos.csv" | tr ":" "\n" | head -n 1`
		bash GrabarBitacora.sh "$CALLER" "('$LINE')" 2
		bash GrabarBitacora.sh "$CALLER" "Padron invalido en el archivo de Grupos. Linea: $NRO_LINEA" 2
		echo 1
	fi
}

fechaEnCalendarioEsInvalida () {
	date -d "$1" "+%m/%d/%Y" > /dev/null 2>&1
	res=$?
	echo "$res"
}

#Chequea una string y verifica que contenga una fecha válida.
chequearFechaAdjudicacion() {
	local LINEA=$1
	local CALLER=$2

	#chequeo que no esté vacia
	if [ -n "$LINEA" ]
		then
			#corto y reformateo en YYYYMMDD
			local arrayFecha=($(echo "$LINEA" | tr ";" "\n" | head -n 1 | tr "/" "\n"))
			local fecha=${arrayFecha[2]}${arrayFecha[1]}${arrayFecha[0]}
			#lo formateado es un numero
			if [[ $fecha =~ ^[0-9]+$ ]]
				then
					#el dia es un número entre 1 y 31 
					local dia=${arrayFecha[0]}
					if [[ 10#$dia -ge 1 && 10#$dia -le 31 ]]
						then
						local mes=${arrayFecha[1]}
						#el mes es un número entre 1 y 12
						if [[ 10#$mes -ge 1 && 10#$mes -le 12 ]]
							then
							#Cheque existencia en el calendario 
							#Nota > Toda la funcion podria ser esto, pero esta bueno informar que esta mal
							FECHA_FO="$mes/$dia/${arrayFecha[2]}"
							if [[ $(fechaEnCalendarioEsInvalida $FECHA_FO) -eq 0 ]]
								then
									#La es valida (en el calendario)
									echo 0
								else
									bash GrabarBitacora.sh "$CALLER" "La fecha no se valida con el calendario, se omitirá la fecha: $fecha" 2
									echo 1
							fi 
						else
							bash GrabarBitacora.sh "$CALLER" "El mes: $mes está fuera del rango 1-12, se omitirá la fecha: $fecha" 2
							echo 1
						fi	
					else
						bash GrabarBitacora.sh "$CALLER" "El día: $dia está fuera del rango 1-31, se omitirá la fecha: $fecha" 2
						echo 1
					fi
			else
				bash GrabarBitacora.sh "$CALLER" "Fecha no es número, se omitirá: $fecha" 2
				echo 1
			fi
	else
		bash GrabarBitacora.sh GenerarSorteo "Linea vacía o invalida en FechasAdj.csv, se omitirá" 2
		echo 1
	fi

}

chequearAmbienteInicializado() {
	TRUE=1
	FALSE=0

	AMBIENTE_INICIALIZADO=${AMBIENTE_INICIALIZADO:-$FALSE}
	if [ "$AMBIENTE_INICIALIZADO" -ne $FALSE ]; then # Variable de entorno booleana.
		return 0	# OK
	else
		return 1	# AMBIENTE NO INICIALIZADO
	fi
}

export -f chequearFechaAdjudicacion
export -f chequearSuscriptorDelPadron
export -f chequearGrupo
export -f chequearAmbienteInicializado
