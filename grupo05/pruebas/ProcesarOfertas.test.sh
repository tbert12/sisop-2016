#! /bin/bash
#Test de ProcesarOfertas
CURRENTPATH=`pwd`
TESTFOLDER="$CURRENTPATH/ProcesarOfertas.test.tmp"
mkdir -p "$TESTFOLDER"

export PROCDIR="$TESTFOLDER/PROCDIR/"
mkdir -p "$PROCDIR"

export OKDIR="$TESTFOLDER/OKDIR/"
mkdir -p "$OKDIR"

export LOGDIR="$TESTFOLDER/"

export MAEDIR="$TESTFOLDER/MAEDIR/"
mkdir -p "$MAEDIR"

export LOGSIZE=500000

ECHO_NORMAL="\e[21m"
ECHO_BOLD="\e[1m"
ECHO_RED="\e[31m"
ECHO_GREEN="\e[32m"
ECHO_COLOR_DEFAULT="\e[39m"

OFERTAS_DEFAULT_FILE="$OKDIR"1234_20160527.csv

source ../funcionesDeChequeo.sh

CleanPlease () {
	rm -r -f "$MAEDIR"* "$OKDIR"* "$PROCDIR"*
}

agregarPadron () {
	local registro=$1
	echo "$registro" >> "$MAEDIR"temaK_padron.csv

}

agregarGrupo () {
	local registro=$1
	echo "$registro" >> "$MAEDIR"grupos.csv
}

agregarFechaAdj () {
	local registro=$1
	echo "$registro" >> "$MAEDIR"FechasAdj.csv
}

agregarRegistro () {
	local registro=$1
	local ofertas=$2
	echo "$registro" >> $ofertas
}


inicializarDatos () {
	#Datos Comuenes que inicio en varios lados
	agregarRegistro "1234567;1500" "$OFERTAS_DEFAULT_FILE"
    agregarPadron "1234;567;ALFONSO,MARIANA ;1615;10550;2;FT;000000;00;00000000;00;0000000000;01852969"
    agregarGrupo "1234;ABIERTO;84;1393,9;2;1"
    agregarFechaAdj "28/05/2016;Concecionaria Bert"
}

hacerGrep () {
	local forgrep=$1
	local file=$2
	if [ ! -f "$file" ]; then
		CORRECTO=0
    	echo "  ERROR FILE:: El archivo $file no existe"
    	return 0
	fi
	if ! grep -q "$forgrep" "$file"
		then
			CORRECTO=0
			echo ""
			echo -e "	"$ECHO_RED"NOT FIND"$ECHO_COLOR_DEFAULT ":: '$forgrep' in $file"
			cat $file
	fi
}


imprimirResultado (){
	local result=$ECHO_RED"ERROR"
	if [ $1 -eq 1 ]; then
		result=$ECHO_GREEN"OK"
	fi
	echo -e "$ECHO_BOLD"$result"$ECHO_COLOR_DEFAULT"$ECHO_NORMAL::"$2"
	rm -f "$LOGDIR"ProcesarOfertas.log
}

runProcesarOfertas () {
	cd ..
	bash ProcesarOfertas.sh
	cd pruebas
}

test_NoExistenLosInputs () {
	runProcesarOfertas
	CORRECTO=1
	
	hacerGrep "No se puede procesar ofertas, verificar los INPUTS" "$LOGDIR"ProcesarOfertas.log
	
	imprimirResultado $CORRECTO ${FUNCNAME[0]}

	CleanPlease
}

test_NoleeNingunArchivo () {
	touch "$MAEDIR"temaK_padron.csv
	touch "$MAEDIR"FechasAdj.csv
	touch "$MAEDIR"grupos.csv
	runProcesarOfertas
	CORRECTO=1
	
	hacerGrep "Cantidad de archivos a procesar: 0" "$LOGDIR"ProcesarOfertas.log
	
	imprimirResultado $CORRECTO ${FUNCNAME[0]}
	
	CleanPlease
}

test_EncuentraUnArchivoPeroLoRechazaPorqueNoCumpleConLosCampos () {
	touch "$OFERTAS_DEFAULT_FILE"
	touch "$MAEDIR"temaK_padron.csv
	touch "$MAEDIR"FechasAdj.csv
	touch "$MAEDIR"grupos.csv
	runProcesarOfertas
	CORRECTO=1
	
	hacerGrep "Cantidad de archivos a procesar: 1" "$LOGDIR"ProcesarOfertas.log
	
	hacerGrep "Se rechaza el archivo `basename $OFERTAS_DEFAULT_FILE` porque su estructura no se corresponde con el formato esperado" "$LOGDIR"ProcesarOfertas.log
	
	imprimirResultado $CORRECTO ${FUNCNAME[0]}

	CleanPlease
	
}

test_RechazaUnArchivoPorQueYaLoProceso () {
	touch "$OFERTAS_DEFAULT_FILE"
	touch "$MAEDIR"temaK_padron.csv
	touch "$MAEDIR"FechasAdj.csv
	touch "$MAEDIR"grupos.csv
	mkdir "$PROCDIR"procesadas
	touch "$PROCDIR"procesadas/`basename $OFERTAS_DEFAULT_FILE`
	runProcesarOfertas
	CORRECTO=1
	hacerGrep "Se rechaza el archivo `basename $OFERTAS_DEFAULT_FILE` por estar DUPLICADO" "$LOGDIR"ProcesarOfertas.log
	
	imprimirResultado $CORRECTO ${FUNCNAME[0]}
	
	CleanPlease
}

test_ProcesaUnRegistro () {
	inicializarDatos
	runProcesarOfertas
	CORRECTO=1
	
	hacerGrep "Registros leidos = 1: cantidad de ofertas validas = 1" "$LOGDIR"ProcesarOfertas.log
	
	local FECHA=`date +%d/%m/%Y" "%H:%M`
	hacerGrep "^1234;20160527;1234567;1234;567;1500;ALFONSO,MARIANA;tomi;$FECHA*" "$PROCDIR"validas/20160528.txt

	imprimirResultado $CORRECTO ${FUNCNAME[0]}

	CleanPlease
}

test_RechazaNoAlcanzaElMontoMinimo () {
	inicializarDatos
	agregarRegistro "1234567;100" "$OFERTAS_DEFAULT_FILE"
	runProcesarOfertas
	CORRECTO=1
	
	hacerGrep "Registros leidos = 2: cantidad de ofertas validas = 1" "$LOGDIR"ProcesarOfertas.log
	hacerGrep "No alcanza el monto Minimo" "$PROCDIR"rechazadas/1234.rech
	
	imprimirResultado $CORRECTO ${FUNCNAME[0]}
	
	CleanPlease
}


test_ElRegistroTieneMasDeDosCampo() {
	inicializarDatos
	agregarRegistro "4321567;456562;r1wd" "$OFERTAS_DEFAULT_FILE"  #Es valido pero tiene algo de mas (lo rechazo)
    runProcesarOfertas
    CORRECTO=1
	
	hacerGrep "Registros leidos = 2: cantidad de ofertas validas = 1" "$LOGDIR"ProcesarOfertas.log
	hacerGrep "Formato del registro invalido (tiene mas de 2 campos)" "$PROCDIR"rechazadas/1234.rech

	imprimirResultado $CORRECTO ${FUNCNAME[0]}

	CleanPlease

		
}

test_YaHayUnaOfertaEnEsaFechaDeAdjudiCacion_SeQuedaConLaQueMasAporteDio (){
	CORRECTO=1
	imprimirResultado $CORRECTO ${FUNCNAME[0]}
}

test_ElCampoContratoFusionadoEsInvalido () {
	CORRECTO=1
	inicializarDatos
	agregarRegistro "43215671;456562" "$OFERTAS_DEFAULT_FILE"
	agregarRegistro "123456a;456562" "$OFERTAS_DEFAULT_FILE"
    runProcesarOfertas

    hacerGrep "El campo Contrato fusionado tiene un tamano invalido" "$PROCDIR"rechazadas/1234.rech

    hacerGrep "El campo Contrato fusionado tiene un formato invalido (deben ser 7 digitos)" "$PROCDIR"rechazadas/1234.rech
    

	imprimirResultado $CORRECTO ${FUNCNAME[0]}

	CleanPlease
}


test_ErrorEnPadron () {
	CORRECTO=1
	inicializarDatos
	agregarRegistro "1234566;456562" "$OFERTAS_DEFAULT_FILE"
	agregarPadron "1234;566;CualquierCosa ;1615a;10550;2;FT;000000;00;00000000;00;0000000000;01852969"

	agregarRegistro "1234568;456562" "$OFERTAS_DEFAULT_FILE"
	agregarPadron "1234;568;CualquierCosa2 ;1615;1105502324124412421123132;;FT;000000;00;00000000;00;0000000000;01852969" #Esta Bien

	agregarRegistro "1234569;456562" "$OFERTAS_DEFAULT_FILE"
	agregarPadron "1234;569;CualquierCosa3 ;1615;10550;3;FT;000000;00;00000000;00;0000000000;01852969"

	agregarRegistro "1234560;456562" "$OFERTAS_DEFAULT_FILE"
	agregarPadron "1234;560;CualquierCosa4 ;1615;10550;2;FTS;000000;00;00000000;00;0000000000;01852969"

	agregarRegistro "1234561;456562" "$OFERTAS_DEFAULT_FILE"
	agregarPadron "1234;561;CualquierCosa5 ;1615;10550;2;FT;1000000;00;00000000;00;0000000000;01852969"

	agregarRegistro "1234562;456562" "$OFERTAS_DEFAULT_FILE"
	agregarPadron "1234;562;CualquierCosa6 ;1615;10550;2;FT;000000;100;00000000;00;0000000000;01852969"

	agregarRegistro "1234563;456562" "$OFERTAS_DEFAULT_FILE"
	agregarPadron "1234;563;CualquierCosa7 ;1615;10550;2;FT;000000;00;200000000;00;0000000000;01852969"

	agregarRegistro "1234564;456562" "$OFERTAS_DEFAULT_FILE"
	agregarPadron "1234;564;CualquierCosa8 ;1615;222;2;FT;000000;00;00000000;00;0000000000;123123101852969;"

	agregarRegistro "1234565;456562" "$OFERTAS_DEFAULT_FILE"
	agregarPadron "1234;565;;1615;10550;2;FT;000000;00;00000000;00;0000000000;01852969"


    runProcesarOfertas
	
	hacerGrep "Registros leidos = 10: cantidad de ofertas validas = 1" "$LOGDIR"ProcesarOfertas.log
	hacerGrep "Padron invalido en el archivo de Padrones. Linea: 2" "$LOGDIR"ProcesarOfertas.log
	hacerGrep "Padron invalido en el archivo de Padrones. Linea: 4" "$LOGDIR"ProcesarOfertas.log
	hacerGrep "Padron invalido en el archivo de Padrones. Linea: 5" "$LOGDIR"ProcesarOfertas.log
	hacerGrep "Padron invalido en el archivo de Padrones. Linea: 6" "$LOGDIR"ProcesarOfertas.log
	hacerGrep "Padron invalido en el archivo de Padrones. Linea: 7" "$LOGDIR"ProcesarOfertas.log
	hacerGrep "Padron invalido en el archivo de Padrones. Linea: 8" "$LOGDIR"ProcesarOfertas.log
	hacerGrep "Padron invalido en el archivo de Padrones. Linea: 9" "$LOGDIR"ProcesarOfertas.log

	imprimirResultado $CORRECTO ${FUNCNAME[0]}

	CleanPlease
}

test_ErrorEnFechasAdj () {
	CORRECTO=1
	inicializarDatos
	agregarFechaAdj "29/02/1016; Tomi Corporation"
	agregarFechaAdj "29/02/2015; TSdsqmi Corporation" #Jiji no fue biciesto
	agregarFechaAdj "tomi/02/1016; Tomi Corporation"
	agregarFechaAdj "33/02/1994; Lazaro Baez corp."
	agregarFechaAdj "12/44/1994; Mugricio Concecinacri"
	runProcesarOfertas

	hacerGrep "La fecha no se valida con el calendario, se omitirá la fecha: 20150229" "$LOGDIR"ProcesarOfertas.log
	hacerGrep "Fecha no es número, se omitirá: 101602tomi" "$LOGDIR"ProcesarOfertas.log
	hacerGrep "El día: 33 está fuera del rango 1-31, se omitirá la fecha: 19940233" "$LOGDIR"ProcesarOfertas.log
	hacerGrep "El mes: 44 está fuera del rango 1-12, se omitirá la fecha: 19944412" "$LOGDIR"ProcesarOfertas.log

	imprimirResultado $CORRECTO ${FUNCNAME[0]}

	CleanPlease

}
test_ErrorEnGrupos () {
	CORRECTO=1
	touch "$MAEDIR"grupos.csv
	
	inicializarDatos
	
	#Con coma ya esta default y testeado

	agregarRegistro "1235567;828282" "$OFERTAS_DEFAULT_FILE"
	agregarPadron "1235;567;ALFONSO,MARIANA ;1615;10550;2;FT;000000;00;00000000;00;0000000000;01852969"
	agregarGrupo "1235a;ABIERTO;84;1048;82;1"

	agregarRegistro "1236567;828282" "$OFERTAS_DEFAULT_FILE"
	agregarPadron "1236;567;ALFONSO,MARIANA ;1615;10550;2;FT;000000;00;00000000;00;0000000000;01852969"
	agregarGrupo "1236;ABIERTO;84;1048;82;1,8284"

	agregarRegistro "1237567;828282" "$OFERTAS_DEFAULT_FILE"
	agregarPadron "1237;567;ALFONSO,MARIANA ;1615;10550;2;FT;000000;00;00000000;00;0000000000;01852969"
	agregarGrupo "1237;PAPA;84;104,8,0;82;1"

	runProcesarOfertas

	hacerGrep "Padron invalido en el archivo de Grupos. Linea: 2" "$LOGDIR"ProcesarOfertas.log
	hacerGrep "Padron invalido en el archivo de Grupos. Linea: 3" "$LOGDIR"ProcesarOfertas.log
	hacerGrep "Padron invalido en el archivo de Grupos. Linea: 4" "$LOGDIR"ProcesarOfertas.log

	imprimirResultado $CORRECTO ${FUNCNAME[0]}
	CleanPlease

}

test_SeHaceDobleOfertaSeQuedaConLaPrimera () {
	inicializarDatos #Ya hay una oferta de 1234567,1500
	agregarRegistro "1234567;1400" "$OFERTAS_DEFAULT_FILE"
	runProcesarOfertas

	hacerGrep "Registros leidos = 2: cantidad de ofertas validas = 1" "$LOGDIR"ProcesarOfertas.log

	hacerGrep "La oferta ya fue validada anteriormente con un importe mayor. Importe Nuevo: 1400,Importe Anaterior: 1500;1234567" "$PROCDIR"rechazadas/*.rech

	imprimirResultado $CORRECTO ${FUNCNAME[0]}
	CleanPlease
}

test_SeHaceDobleOfertaSeQuedaConLaSegunda () {
	inicializarDatos #Ya hay una oferta de 1234567,1500
	agregarRegistro "1234567;1510" "$OFERTAS_DEFAULT_FILE"
	runProcesarOfertas

	hacerGrep "Registros leidos = 2: cantidad de ofertas validas = 2" "$LOGDIR"ProcesarOfertas.log

	hacerGrep "Se encontró una oferta ya validada en 20160528.txt del contrato: 1234567, como el importe de la que se esta procesando actualmente es igual o mas alto (Nuevo: 1510 - Viejo: 1500), se reemplazará" "$LOGDIR"ProcesarOfertas.log
	
	hacerGrep "1234;20160527;1234567;1234;567;1510;ALFONSO,MARIANA;tomi;" "$PROCDIR"validas/*.txt

	imprimirResultado $CORRECTO ${FUNCNAME[0]}
	CleanPlease
}




echo "---------------TEST PROCESAROFERTAS-------------"
test_NoExistenLosInputs
test_NoleeNingunArchivo
test_EncuentraUnArchivoPeroLoRechazaPorqueNoCumpleConLosCampos
test_RechazaUnArchivoPorQueYaLoProceso
test_ProcesaUnRegistro
test_RechazaNoAlcanzaElMontoMinimo
test_ElRegistroTieneMasDeDosCampo
test_ElCampoContratoFusionadoEsInvalido

test_ErrorEnPadron
test_ErrorEnFechasAdj
test_ErrorEnGrupos

test_SeHaceDobleOfertaSeQuedaConLaPrimera
test_SeHaceDobleOfertaSeQuedaConLaSegunda

rm -r "$TESTFOLDER"

