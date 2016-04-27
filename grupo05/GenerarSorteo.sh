#! /bin/bash
# 
# Universidad de Buenos Aires
# Facultad de Ingenieria
#
# 75.08 Sistemas Operativos
# Trabajo Practico
# Autor: Grupo 5
#
# No recibe parametros
#
# Input:
#		Tabla de Fechas de adj. MAEDIR/FechasAdj.csv
# Ouput:
#		Archivos de sorteos PROCDIR/sorteos/<sorteoId>_<fecha de adjudicación>
# 		Log del Comando LOGDIR/GenerarSorteo.log
#
#Entorno -> hay que ver como lo definimos ?
MAEDIR="MAEDIR/"
PROCDIR="PROCDIR/"
#FIN Entorni

#funcion que genera un sorteo para una fecha y un ID

generarSorteo() {
	
	#Fecha de adjudicacion
	FECHAADJ=$1
	#SorteoID
	SORTEOID=$2

	#Inicio el log grabando "Inicio de Sorteo"
	sh GrabarBitacora GenerarSorteo "Inicio de Sorteo Numero: $SORTEOID de la fecha: $FECHAADJ"

	#genera en NUMEROS_SORTEO un array con la secuencia de 1 a 168 random
	NUMEROS_SORTEO=($(seq 168 | shuf))

	#Archivo a guardar
	FILE="$PROCDIR""sorteos/$SORTEOID""_""$FECHAADJ.csv"

	#si el directorio PROCDIR/sorteos no existe lo creo
	if [ ! -d $PROCDIR"sorteos" ]
		then
			mkdir -p $PROCDIR"sorteos"
	fi

	#Verifico si el archivo ya esta creado
	if [ -w $FILE ]
		then
		#Si ya esta creado lo renombra con .backup
		mv $FILE $FILE".backup"
	fi

	#for guardando en sorteo y logueando.
	for i in $(seq 1 168)
	do
	    #Log con numero de sorteo y numero de orden
		sh GrabarBitacora GenerarSorteo "Numero de orden: $i le corresponde el numero de sorteo: ${NUMEROS_SORTEO[$i]}"

		#Guardo en archivo
		echo $i","${NUMEROS_SORTEO[$((i-1))]} >> $FILE
	done

	#Finalizo el log grabando "Fin de Sorteo"
	sh GrabarBitacora GenerarSorteo "Fin de Sorteo"
}

#genera el id correspondiente para la fecha
generarId() {
	FECHA=$1

	if [ -f *_$FECHA".csv" ] #hay un archivo nn_FECHA -> ID = nn + 1
		then
			ARCHIVOS=(`ls *_$FECHA".csv" | sort -r`)
			ULT=${ARCHIVOS:0:1}
			ID=$(expr $ULT + 1)
			echo $ID
	else
		#no hay ningun archivo -> ID = 1
		echo 1
	fi
}

# Inicializacion de Variables
#Tabla de fechas de adj
ARCH_FECHAS_ADJ="$MAEDIR""FechasAdj.csv"


#For de las fechas de adjudicacion
if [ -r "$ARCH_FECHAS_ADJ" ]
	then
		while read -r linea_adj
		do
			if [ -n "$linea_adj" ]
			  then
				# Extraigo la fecha y reformateo a YYYYMMDD
				fecha_adj=$(echo "$linea_adj" | cut -c7-10)$(echo "$linea_adj" | cut -c4-5)$(echo "$linea_adj" | cut -c1-2)
				
				generarSorteo $fecha_adj $(generarId "$fecha_adj")
			fi
		done < $ARCH_FECHAS_ADJ  # Leo el archivo de abajo para arriba hasta encontrar la primera adjudicacion anterior o igual a hoy
else
	sh GrabarBitacora.sh "GenerarSorteo" '1' "No hay archivo de adjudicacion"
fi