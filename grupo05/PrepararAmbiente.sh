#! /bin/bash

#Cosas a revisar:
# Todas los llamados a GrabarBitacora, LanzarProceso y DetenerProceso.
# Obtener PID del proceso RecibirOfertas cuando se lanza el proceso.
# Falta setear variable PATH pedida por enunciado.
# Ver todos los ####REVISAR y demas comentarios.

###################################################################
#################### FUNCIONES AUXILIARES #########################
###################################################################

#Arreglar instalacion de scripts o maestros:
repararInstalacion() {
	NOMBRE_ARCHIVO=$1
	TIPO=$2 #BINDIR o MAEDIR
	
	tar -xvzf "$GRUPO""source/source.tar.gz"
	sh MoverArchivos.sh "$GRUPO""source/source/$TIPO/$NOMBRE_ARCHIVO" "${!TIPO}"
	rm -rf "$GRUPO""source/source/" #####REVISAR: Borra todo o solo los archivos?
}

#Verificar la disponibilidad de los scripts necesarios para la ejecucion del programa:
verificarScript() {
	NOMBRE_ARCHIVO=$1
	
	SCRIPT_DISPONIBLE=true
	
	if [ ! -f "$BINDIR/$NOMBRE_ARCHIVO" ]; then	
		sh GrabarBitacora PrepararAmbiente WAR "El archivo $NOMBRE_ARCHIVO esta mal ubicado o no existe. Se procede a reparar instalacion"
		echo "WARNING: el archivo $NOMBRE_ARCHIVO esta mal ubicado o no existe."
		echo "Se procede a reparar la instalacion."
		repararInstalacion "$NOMBRE_ARCHIVO" "BINDIR"
		
		if [ ! -f "$BINDIR/$NOMBRE_ARCHIVO" ]; then
			sh GrabarBitacora PrepararAmbiente ERR "Imposible reparar instalacion."
			Echo "No fue posible reparar la instalacion. Debe realizarlo el administrador del sistema." # MAS INDICACIONES AL ADMIN?
			SCRIPT_DISPONIBLE=false
		fi
	fi
	
	return $SCRIPT_DISPONIBLE
}

#Verificar la disponibilidad de los archivos maestros necesario para la ejecucion del programa:
verificarArchivoMaestro() {
	NOMBRE_ARCHIVO=$1
	
	MAESTRO_DISPONIBLE=true
	
	if [ ! -f "$MAEDIR/$NOMBRE_ARCHIVO" ]; then	
		sh GrabarBitacora PrepararAmbiente WAR "El archivo $NOMBRE_ARCHIVO esta mal ubicado o no existe. Se procede a reparar instalacion"
		echo "WARNING: el archivo $NOMBRE_ARCHIVO esta mal ubicado o no existe."
		echo "Se procede a reparar la instalacion."
		repararInstalacion "$NOMBRE_ARCHIVO" "MAEDIR"
		
		if [ ! -f "$MAEDIR/$NOMBRE_ARCHIVO" ]; then
			sh GrabarBitacora PrepararAmbiente ERR "Imposible reparar instalacion."
			Echo "No fue posible reparar la instalacion. Debe realizarlo el administrador del sistema" # MAS INDICACIONES? IDEM SCRIPTS
			MAESTRO_DISPONIBLE=false
		fi
	fi
	
	return $MAESTRO_DISPONIBLE
}

verificarScripts() {
	SCRIPT_OK=true
	
	verificarScript "MoverArchivos.sh"
	if [ $? = "false" ]; then
		SCRIPT_OK=false
	fi
	verificarScript "LanzarProceso.sh"
	if [ $? = "false" ]; then
		SCRIPT_OK=false
	fi
	verificarScript "DetenerProceso.sh"
	if [ $? = "false" ]; then
		SCRIPT_OK=false
	fi
	verificarScript "GrabarBitacora.sh"
	if [ $? = "false" ]; then
		SCRIPT_OK=false
	fi
	verificarScript "MostrarBitacora.pl"
	if [ $? = "false" ]; then
		SCRIPT_OK=false
	fi
	verificarScript "RecibirOfertas.sh"
	if [ $? = "false" ]; then
		SCRIPT_OK=false
	fi
	verificarScript "ProcesarOfertas.sh"
	if [ $? = "false" ]; then
		SCRIPT_OK=false
	fi
	verificarScript "GenerarSorteo.sh"
	if [ $? = "false" ]; then
		SCRIPT_OK=false
	fi
		
	return $SCRIPT_OK
}

verificarArchivosMaestros() {
	MAESTRO_OK=true
	
	verificarArchivoMaestro "concesionarios.csv"
	if [ $? = "false" ]; then
		MAESTRO_OK=false
	fi
	verificarArchivoMaestro "grupos.csv"
	if [ $? = "false" ]; then
		MAESTRO_OK=false
	fi
	verificarArchivoMaestro "FechasAdj.csv"
	if [ $? = "false" ]; then
		MAESTRO_OK=false
	fi
	verificarArchivoMaestro "temaK_padron.csv"
	if [ $? = "false" ]; then
		MAESTRO_OK=false
	fi
		
	return $MAESTRO_OK
}

#Verificar permisos de ejecucion de los scripts en BINDIR:
verificarPermisosScripts() {
	PERMISOS_SCRIPTS=true
	
	#Ingreso al path de los scripts:
	cd $BINDIR ####REVISAR: chequear que esto se haga bien
	
	#Recorro scripts y chequeo permisos:
	for SCRIPT in *
	do
		if [ ! -x $SCRIPT ]; then
			sh GrabarBitacora PrepararAmbiente WAR "El script $SCRIPT no tiene permiso de ejecucion. Se intenta modificarlo."
			echo "WARNING: El script $SCRIPT no tiene permiso de ejecucion. Se intenta modificarlo."
			chmod +x $SCRIPT
		fi
		if [ ! -x $SCRIPT ]; then
			sh GrabarBitacora PrepararAmbiente ERR "El script $SCRIPT no tiene permiso de ejecucion y no fue posible modificarlo."
			echo "ERROR: No fue posible modificar el permiso."
			PERMISOS_SCRIPTS=false
		fi
	done
	
	cd .. ###### REVISAR: Chequear esto. Vuelvo a $GRUPO.
	return $PERMISOS_SCRIPTS
}

#Verificar permisos de lectura de los archivos maestros en MAEDIR:
verificarPermisosMaestros() {
	PERMISOS_MAESTROS=true
	
	#Ingreso al path de los archivos maestros:
	cd $MAEDIR ######REVISAR: Chequear que esto se haga bien
	
	#Recorro archivos maestros y chequeo permisos:
	for MAESTRO in *
	do
		if [ ! -r $MAESTRO ]; then
			sh GrabarBitacora PrepararAmbiente WAR "El archivo $MAESTRO no tiene permiso de lectura. Se intenta modificarlo."
			echo "WARNING: El archivo $MAESTRO no tiene permiso de lectura. Se intenta modificarlo."
			chmod +r $MAESTRO
		fi
		if [ ! -r $MAESTRO ]; then
			sh GrabarBitacora PrepararAmbiente ERR "El archivo $MAESTRO no tiene permiso de lectura y no fue posible modificarlo."
			echo "ERROR: No fue posible modificar el permiso."
			PERMISOS_MAESTRO=false
		fi
	done
	
	cd .. ######REVISAR: Chequear esto. Vuelvo a $GRUPO
	return $PERMISOS_MAESTRO
}

#Chequeo existencia del archivo de configuracion:
verificarArchivoConfiguracion() {
	CONFIG_EXISTE=true
	
	if [ ! -f "config/CIPAK.cnf" ]; then ######REVISAR: chequear si accedo bien a esta direccion
		sh GrabarBitacora PrepararAmbiente ERR "El archivo de configuracion CIPAK.cnf no existe."
		echo "ERROR: El archivo de configuracion CIPAK.cnf no existe. Debe instalar nuevamente el sistema."
		CONFIG_EXISTE=false
	fi
	
	return $CONFIG_EXISTE
}

#Chequeo si ya se inicializo el ambiente en esta sesion.
verificarAmbienteSinInicializar(){
	AMBIENTE_SIN_INICIALIZAR=true
	
	#AMBIENTE_INICIALIZADO es la variable global.
	if [ ${AMBIENTE_INICIALIZADO-false} = true ]; then
		sh GrabarBitacora PrepararAmbiente ERR "Ambiente ya inicializado, para reiniciar termine la sesión e ingrese nuevamente"
		echo "ERROR: El ambiente ya se encuentra inicializado en esta sesion."
		AMBIENTE_SIN_INICIALIZAR=false
	fi
	
	return $AMBIENTE_SIN_INICIALIZAR
}

setearVariablesAmbiente() {	
	SETEO_CORRECTO=true
	
	# Chequeo que el ambiente no se encuentre inicializado:
	verificarAmbienteSinInicializar
	if [ $? = "false" ]; then
		SETEO_CORRECTO=false
		return $SETEO_CORRECTO
	fi
	
	#Inicializo sistema:
	sh GrabarBitacora PrepararAmbiente INFO "Estado del Sistema: INICIALIZADO."
	echo "Estado del Sistema: INICIALIZADO."
	echo
	echo "A continuacion se muestran las variables de ambiente:"
	
	#Parseo el archivo config para setear las variables:	
	IFS_original=$IFS 
	IFS="="
	while read VARIABLE VALOR USUARIO FECHA
	do
		export $VARIABLE=$VALOR
		sh GrabarBitacora PrepararAmbiente INFO "Nombre de variable: $VARIABLE - Valor: $VALOR"
		echo "Nombre de variable: $VARIABLE - Valor: $VALOR"
	done <../config/CIPAK.cnf ######REVISAR: Chequear si accedo bien
	IFS=$IFS_original
	
	#Otra variables necesarias (agregar mas de ser necesario):
	AMBIENTE_INICIALIZADO=true
	export $AMBIENTE_INICIALIZADO
	######REVISAR: FALTA SETEAR LA VARIABLE PATH, NO SE BIEN QUE SERIA.
	
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
			sh LanzarProceso.sh "sh RecibirOfertas.sh" PrepararAmbiente ####REVISAR LLAMADA
			
			#Chequeo si ya se estaba ejecutando anteriormente:
			#1 = Ya se estaba ejecutando
			if [ $? -eq 1 ]; then
				sh GrabarBitacora PrepararAmbiente WAR "El comando RecibirOferta ya se encontraba activado y corriendo."
				echo "El comando RecibirOferta fue activado anteriormente y se encuentra corriendo."
			#2 = No se pudo ejecutar por algun error
			elif [ $? -eq 2 ]; then
				sh GrabarBitacora PrepararAmbiente ERR "El comando RecibirOferta no puede ejecutarse."
				echo "El comando RecibirOferta no puede ejecutarse."
			else
				GrabarBitacora PrepararAmbiente INFO "El comando RecibirOferta fue activado."
				############# VER COMO RECIBIR EL PID DE RECIBIR OFERTAS ##############
				echo "El comando RecibirOferta fue activado. RecibirOfertas esta corriendo bajo el No: <Process Id de RecibirOfertas>"
				echo "Para detenerlo utilizar la siguiente linea:"
				echo "sh DetenerProceso xxxxxxxxxxxxx"######### REVISAR
			fi
		elif [ "$RESPUESTA" = "No" ]; then
			echo "Para efectuar la activacion de RecibirOfertas debera hacerlo a traves del comando LanzarProceso."
			echo "Dicho comando se ejecuta utilizando la siguiente linea:"
			echo "sh LanzarProceso.sh sh RecibirOfertas.sh otroComando" ######## REVISAR
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
}

###################################################################
#################### EJECUCION DEL PROGRAMA #######################
###################################################################

####### REVISAR: Chequear en que path estoy parado ######

main() {
	setearVariablesAmbiente

	# 1 = Error: Ambiente ya inicializado
	if [ $? = "false" ]; then
		borrarVariablesAmbiente
		return 1
	fi

	# 2 = Error: No se poseen todos los scripts
	verificarScripts
	if [ $? = "false" ]; then
		borrarVariablesAmbiente
		return 2
	fi
	
	# 3 = Error: No se poseen todos los archivos maestros
	verificarArchivosMaestros
	if [ $? = "false" ]; then
		borrarVariablesAmbiente
		return 3
	fi

	# 4 = Error: No se tienen los permisos necesarios en los scripts o archivos maestros
	verificarPermisosScripts
	retornoScripts=$?
	verificarPermisosMaestros
	retornoMaestros=$?
	if [ retornoScripts = "false" -o retornoMaestros = "false" ]; then
		borrarVariablesAmbiente
		return 4
	fi

	continuarEjecucion
}

main
