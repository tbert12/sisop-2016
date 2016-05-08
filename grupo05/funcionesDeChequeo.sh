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


#Chequea una string y verifica que contenga una fecha válida.
chequearFechaAdjudicacion() {
	local LINEA=$1

	#chequeo que no esté vacia
	if [ -n "$LINEA" ]
		then
			#corto y reformateo en YYYYMMDD
			local fecha=$(echo "$LINEA" | cut -c7-10)$(echo "$LINEA" | cut -c4-5)$(echo "$LINEA" | cut -c1-2)
			
			#lo formateado es un numero
			if [[ $fecha =~ ^[0-9]+$ ]]
				then
					#el dia es un número entre 1 y 31 
					local dia=${fecha:6:2}
					if [[ 10#$dia -ge 1 && 10#$dia -le 31 ]]
						then
						local mes=${fecha:4:2}
						#el mes es un número entre 1 y 12
						if [[ 10#$mes -ge 1 && 10#$mes -le 12 ]]
							then
							#todo bien
							echo 0
						else
							bash GrabarBitacora.sh GenerarSorteo "El mes: $mes está fuera del rango 1-12, se omitirá la fecha: $fecha" 2
							echo 1
						fi	
					else
						bash GrabarBitacora.sh GenerarSorteo "El día: $dia está fuera del rango 1-31, se omitirá la fecha: $fecha" 2
						echo 1
					fi
			else
				bash GrabarBitacora.sh GenerarSorteo "Fecha no es número, se omitirá: $fecha" 2
				echo 1
			fi
	else
		bash GrabarBitacora.sh GenerarSorteo "Linea vacía en FechasAdj.csv, se omitirá" 2
		echo 1
	fi

}

export -f chequearFechaAdjudicacion