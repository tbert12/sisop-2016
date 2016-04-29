#! /bin/bash

#Cosas a revisar:
# Todas los llamados a GrabarBitacora, LanzarProceso y DetenerProceso.
# Ver todos los ####REVISAR y demas comentarios.

###################################################################
#################### FUNCIONES AUXILIARES #########################
###################################################################

# En las funciones auxiliares, los valores de retorno son:
# 0 = False
# 1 = True

#Arreglar instalacion de scripts o maestros:
repararInstalacion() {
	NOMBRE_ARCHIVO=$1
	TIPO=$2 #BINDIR o MAEDIR
	
	tar -xvzf "$GRUPO""source/source.tar.gz"
	bash MoverArchivos.sh "$GRUPO""source/source/$TIPO/$NOMBRE_ARCHIVO" "${!TIPO}"
	rm -rf "$GRUPO""source/source/" #####REVISAR: Borra todo o solo los archivos?
}

#Verificar la disponibilidad de los scripts necesarios para la ejecucion del programa:
verificarScript() {
	NOMBRE_ARCHIVO=$1
	
	SCRIPT_DISPONIBLE=1
	
	if [ ! -f "$BINDIR/$NOMBRE_ARCHIVO" ]; then	
		bash GrabarBitacora.sh PrepararAmbiente "El archivo $NOMBRE_ARCHIVO esta mal ubicado o no existe. Se procede a reparar instalacion" 1
		echo "WARNING: el archivo $NOMBRE_ARCHIVO esta mal ubicado o no existe."
		echo "Se procede a reparar la instalacion."
		repararInstalacion "$NOMBRE_ARCHIVO" "BINDIR"
		
		if [ ! -f "$BINDIR/$NOMBRE_ARCHIVO" ]; then
			bash GrabarBitacora.sh PrepararAmbiente "Imposible reparar instalacion." 2
			Echo "No fue posible reparar la instalacion. Debe realizarlo el administrador del sistema." # MAS INDICACIONES AL ADMIN?
			SCRIPT_DISPONIBLE=0
		fi
	fi
	
	return $SCRIPT_DISPONIBLE
}

#Verificar la disponibilidad de los archivos maestros necesario para la ejecucion del programa:
verificarArchivoMaestro() {
	NOMBRE_ARCHIVO=$1
	
	MAESTRO_DISPONIBLE=1
	
	if [ ! -f "$MAEDIR/$NOMBRE_ARCHIVO" ]; then	
		bash GrabarBitacora.sh PrepararAmbiente "El archivo $NOMBRE_ARCHIVO esta mal ubicado o no existe. Se procede a reparar instalacion" 1
		echo "WARNING: el archivo $NOMBRE_ARCHIVO esta mal ubicado o no existe."
		echo "Se procede a reparar la instalacion."
		repararInstalacion "$NOMBRE_ARCHIVO" "MAEDIR"
		
		if [ ! -f "$MAEDIR/$NOMBRE_ARCHIVO" ]; then
			bash GrabarBitacora.sh PrepararAmbiente "Imposible reparar instalacion." 2
			Echo "No fue posible reparar la instalacion. Debe realizarlo el administrador del sistema" # MAS INDICACIONES? IDEM SCRIPTS
			MAESTRO_DISPONIBLE=0
		fi
	fi
	
	return $MAESTRO_DISPONIBLE
}

verificarScripts() {
	SCRIPT_OK=1
	
	verificarScript "MoverArchivos.sh"
	if [ $? -eq 0 ]; then
		SCRIPT_OK=0
	fi
	verificarScript "LanzarProceso.sh"
	if [ $? -eq 0 ]; then
		SCRIPT_OK=0
	fi
	verificarScript "DetenerProceso.sh"
	if [ $? -eq 0 ]; then
		SCRIPT_OK=0
	fi
	verificarScript "GrabarBitacora.sh"
	if [ $? -eq 0 ]; then
		SCRIPT_OK=0
	fi
	verificarScript "MostrarBitacora.pl"
	if [ $? -eq 0 ]; then
		SCRIPT_OK=0
	fi
	verificarScript "RecibirOfertas.sh"
	if [ $? -eq 0 ]; then
		SCRIPT_OK=0
	fi
	verificarScript "ProcesarOfertas.sh"
	if [ $? -eq 0 ]; then
		SCRIPT_OK=0
	fi
	verificarScript "GenerarSorteo.sh"
	if [ $? -eq 0 ]; then
		SCRIPT_OK=0
	fi
		
	return $SCRIPT_OK
}

verificarArchivosMaestros() {
	MAESTRO_OK=1
	
	verificarArchivoMaestro "concesionarios.csv"
	if [ $? -eq 0 ]; then
		MAESTRO_OK=0
	fi
	verificarArchivoMaestro "grupos.csv"
	if [ $? -eq 0 ]; then
		MAESTRO_OK=0
	fi
	verificarArchivoMaestro "FechasAdj.csv"
	if [ $? -eq 0 ]; then
		MAESTRO_OK=0
	fi
	verificarArchivoMaestro "temaK_padron.csv"
	if [ $? -eq 0 ]; then
		MAESTRO_OK=0
	fi
		
	return $MAESTRO_OK
}

#Verificar permisos de ejecucion de los scripts en BINDIR:
verificarPermisosScripts() {
	PERMISOS_SCRIPTS=1
	
	#Ingreso al path de los scripts:
	cd $BINDIR
	
	#Recorro scripts y chequeo permisos:
	for SCRIPT in *
	do
		if [ ! -x $SCRIPT ]; then
			bash GrabarBitacora.sh PrepararAmbiente "El script $SCRIPT no tiene permiso de ejecucion. Se intenta modificarlo." 1
			echo "WARNING: El script $SCRIPT no tiene permiso de ejecucion. Se intenta modificarlo."
			chmod +x $SCRIPT
		fi
		if [ ! -x $SCRIPT ]; then
			bash GrabarBitacora.sh PrepararAmbiente "El script $SCRIPT no tiene permiso de ejecucion y no fue posible modificarlo." 2
			echo "ERROR: No fue posible modificar el permiso."
			PERMISOS_SCRIPTS=0
		fi
	done	
	cd ..
	
	return $PERMISOS_SCRIPTS
}

#Verificar permisos de lectura de los archivos maestros en MAEDIR:
verificarPermisosMaestros() {
	PERMISOS_MAESTROS=1
	
	#Ingreso al path de los archivos maestros:
	cd $MAEDIR
	
	#Recorro archivos maestros y chequeo permisos:
	for MAESTRO in *
	do
		if [ ! -r $MAESTRO ]; then
			bash GrabarBitacora.sh PrepararAmbiente "El archivo $MAESTRO no tiene permiso de lectura. Se intenta modificarlo." 1
			echo "WARNING: El archivo $MAESTRO no tiene permiso de lectura. Se intenta modificarlo."
			chmod +r $MAESTRO
		fi
		if [ ! -r $MAESTRO ]; then
			bash GrabarBitacora.sh PrepararAmbiente "El archivo $MAESTRO no tiene permiso de lectura y no fue posible modificarlo." 2
			echo "ERROR: No fue posible modificar el permiso."
			PERMISOS_MAESTROS=0
		fi
	done
	cd ..
	
	return $PERMISOS_MAESTROS
}

#Chequeo existencia del archivo de configuracion:
verificarArchivoConfiguracion() {
	CONFIG_EXISTE=1
	
	if [ ! -f "config/CIPAK.cnf" ]; then
		bash GrabarBitacora.sh PrepararAmbiente "El archivo de configuracion CIPAK.cnf no existe." 2
		echo "ERROR: El archivo de configuracion CIPAK.cnf no existe. Debe instalar nuevamente el sistema."
		CONFIG_EXISTE=0
	fi
	
	return $CONFIG_EXISTE
}

#Chequeo si ya se inicializo el ambiente en esta sesion.
verificarAmbienteSinInicializar(){
	AMBIENTE_SIN_INICIALIZAR=1
	
	#AMBIENTE_INICIALIZADO es la variable global.
	if [ ${AMBIENTE_INICIALIZADO-0} -eq 1 ]; then
		bash GrabarBitacora.sh PrepararAmbiente "Ambiente ya inicializado, para reiniciar termine la sesión e ingrese nuevamente" 2
		echo "ERROR: El ambiente ya se encuentra inicializado en esta sesion."
		AMBIENTE_SIN_INICIALIZAR=0
	fi
	return $AMBIENTE_SIN_INICIALIZAR
}

setearVariablesAmbiente() {	
	SETEO_CORRECTO=1
	
	# Chequeo que el ambiente no se encuentre inicializado:
	verificarAmbienteSinInicializar
	if [ $? -eq 0 ]; then
		SETEO_CORRECTO=0
		return $SETEO_CORRECTO
	fi
	
	#Parseo el archivo config para setear las variables:
	echo "Arrancando la inicializacion del sistema. A continuacion se muestran y setean las variables de ambiente:"
	echo	
	IFS_original=$IFS 
	IFS="="
	while read VARIABLE VALOR USUARIO FECHA
	do
		export $VARIABLE=$VALOR
		bash GrabarBitacora.sh PrepararAmbiente "Nombre de variable: $VARIABLE - Valor: $VALOR"
		echo "Nombre de variable: $VARIABLE - Valor: $VALOR"
	done <../config/CIPAK.cnf ######REVISAR: Chequear si accedo bien
	IFS=$IFS_original
	
	#Otra variables necesarias (agregar mas de ser necesario):
	AMBIENTE_INICIALIZADO=1
	bash GrabarBitacora.sh PrepararAmbiente "Nombre de variable: AMBIENTE_INICIALIZADO - Valor: $AMBIENTE_INICIALIZADO"
	echo "Nombre de variable: AMBIENTE_INICIALIZADO - Valor: $AMBIENTE_INICIALIZADO"
	export AMBIENTE_INICIALIZADO

	PATH="$PATH:$BINDIR"
	bash GrabarBitacora.sh PrepararAmbiente "Nombre de variable: PATH - Valor: $PATH"
	echo "Nombre de variable: PATH - Valor: $PATH"
	export PATH
	
	#Confirmo sistema inicializado correctamente:
	bash GrabarBitacora.sh PrepararAmbiente "Estado del Sistema: INICIALIZADO CORRECTAMENTE."
	echo "Estado del Sistema: INICIALIZADO CORRECTAMENTE."
	echo
	
	return $SETEO_CORRECTO
}

#Ofrecer continuar la ejecucion con RECIBIR OFERTAS.
continuarEjecucion() {
	RESPUESTA=""
	while [ "$RESPUESTA" != "Si" -a "$RESPUESTA" != "No" ]
	do
		echo "¿Desea efectuar la activacion de RecibirOfertas? Si - No"
		read RESPUESTA
		if [ "$RESPUESTA" = "Si" ]; then
			#Lanzo el comando recibirOferta:
			bash LanzarProceso.sh "RecibirOfertas.sh" PrepararAmbiente
			
			#Chequeo si ya se estaba ejecutando anteriormente:
			#1 = Ya se estaba ejecutando
			retornoLanzarProceso=$?
			if [ $retornoLanzarProceso -eq 1 ]; then
				bash GrabarBitacora.sh PrepararAmbiente "El comando RecibirOferta ya se encontraba activado y corriendo." 1
				echo "El comando RecibirOferta fue activado anteriormente y se encuentra corriendo."
			#2 = No se pudo ejecutar por algun error
			elif [ $retornoLanzarProceso -eq 2 ]; then
				bash GrabarBitacora.sh PrepararAmbiente "El comando RecibirOferta no puede ejecutarse." 2
				echo "El comando RecibirOferta no puede ejecutarse."
			#0 = Se ejecuto correctamente
			elif [ $retornoLanzarProceso -eq 0 ]; then
				bash GrabarBitacora.sh PrepararAmbiente "El comando RecibirOferta fue activado."
				PID=$(pgrep "RecibirOfertas.sh")
				echo
				echo "El comando RecibirOferta fue activado. RecibirOfertas esta corriendo bajo el No: $PID"
				echo "Para detenerlo utilizar la siguiente linea:"
				echo "bash DetenerProceso xxxxxxxxxxxxx" ######### REVISAR
			fi
		elif [ "$RESPUESTA" = "No" ]; then
			echo "Para efectuar la activacion de RecibirOfertas debera hacerlo a traves del comando LanzarProceso."
			echo "Dicho comando se ejecuta utilizando la siguiente linea:"
			echo "bash LanzarProceso.sh bash RecibirOfertas.sh otroComando" ######## REVISAR que pongo en otrocomando?
			return 0
		fi
	done
}

#Para limpiar todas las variables en caso de errores.
borrarVariablesAmbiente() {
	unset AMBIENTE_INICIALIZADO
	unset GRUPO
	unset BINDIR
	unset MAEDIR
	unset ARRIDIR
	unset INFODIR
	unset LOGDIR
	unset NOKDIR
	unset LOGSIZE
	unset SLEEPTIME
	PATH=$(echo $PATH | sed 's-^\(.*\):.*$-\1-g')
}

###################################################################
#################### EJECUCION DEL PROGRAMA #######################
###################################################################

####### REVISAR: Chequear en que path estoy parado ######

main() {
	setearVariablesAmbiente

	# Return 1 = Error: Ambiente ya inicializado
	if [ $? -eq 0 ]; then
		return 1
	fi

	# Return 2 = Error: No se poseen todos los scripts
	verificarScripts
	if [ $? -eq 0 ]; then
		borrarVariablesAmbiente
		return 2
	fi
	
	# Return 3 = Error: No se poseen todos los archivos maestros
	verificarArchivosMaestros
	if [ $? -eq 0 ]; then
		borrarVariablesAmbiente
		return 3
	fi

	# Return 4 = Error: No se tienen los permisos necesarios en los scripts o archivos maestros
	verificarPermisosScripts
	retornoScripts=$?
	verificarPermisosMaestros
	retornoMaestros=$?
	
	if [ $retornoScripts -eq 0 -o $retornoMaestros -eq 0 ]; then
		borrarVariablesAmbiente
		return 4
	fi

	continuarEjecucion
}

main
