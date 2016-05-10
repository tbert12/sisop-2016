#!/usr/bin/perl
use Fcntl ':flock';
use Data::Dumper;
# Universidad de Buenos Aires
# Facultad de Ingenieria
#
# 75.08 Sistemas Operativos
# Trabajo Practico
# Autor: Grupo 5
#
#INPUTS:
#	Padron de suscriptores: $MAEDIR/temaK_padron.csv
#	Tabla de grupos: $MAEDIR/grupos.csv
#	Archivo de ofertas válidas: $PROCDIR/validas/<fecha_adjudicacion>.txt
#	Archivos de sorteo: $PROCDIR/sorteos/<sorteo_id>_<fecha_adjudicacion>.srt
#OUTPUT:
# En primer instancia se imprime por pantalla la consulta. En caso de recibir el comando -g, se crearán los siguientes archivos:
# Resultado general del sorteo: INFODIR/<sorteoid>_<fecha_adjudicacion>.txt
# Ganadores por Sorteo : INFODIR/<sorteoid>_GrdXXXX-GrhYYYY_<fecha_adjudicacion>.txt
# Ganadores por Licitación: INFODIR/<sorteoid>_GrdXXXX-GrhYYYY_<fecha_adj>_licitacion.txt
# Ganadores del grupo : INFODIR/<sorteoid>_GrupoXXXX_<fecha_adjudicacion>.txt


sub recibir_parametros{
	#Es la función principal del determinarGanadores,se encarga de inicializar
	#el script. Recibe un solo parámetro por ARGV, y ese es el
	#modo en el que se ejecutará
	#Si es -g, graba en los archivos de output descritos
	#Si es -a, ejecuta la ayuda correspondiente
	#Si es vacío, sólo se mostrarán las consultas pedidas por pantalla
	$modo = $ARGV[0];
	if ($modo =~ /-a/){
		ejecutar_ayuda();
		exit 0;
	}else{
		print "Bienvenido al CIPAK.\nPara consultar por un sorteo, ingrese A\n";
		print "Para consultar por los ganadores de un sorteo dentro de uno o varios grupos, ingrese B\n";
		print "Para consultar los ganadores por licitacion dentro de uno o varios grupos, ingrese C\n";
		print "Para consultar los ganadores por licitacion y sorteo dentro de un grupo, ingrese D\n";
		print "Para salir, presione enter\n";
	
		if (@ARGV eq 0){
			$modo = '';
			hacer_consulta();
	 	}
		if ($modo =~ /-g/){
			print "Script ejecutado con opción de grabado de archivos\n";
			hacer_consulta();
		} 
	}
}


sub hacer_consulta{
	#Subrutina que se encarga de imprimir por pantalla
	#Un menu amigable para el usuario de manera de
	#poder elegir la opción correcta y
	#en base a lo ingresado responder con la consulta adecuada
	#o salir del script
	print "Seleccione el tipo de consulta que quiera realizar\n";
	my $tipo_consulta = <STDIN>;
	chomp($tipo_consulta);
	$tipo_consulta =uc($tipo_consulta);
	if ($tipo_consulta eq "A"){
		resultado_general();
	} elsif ($tipo_consulta eq "B"){
		ganadores_por_sorteo();
	} elsif ($tipo_consulta eq "C"){
		ganadores_por_licitacion();
	} elsif ($tipo_consulta eq "D"){
		resultados_grupo();
	} else{
		print "Gracias por utilizar el módulo CIPAK. Saliendo de la aplicación \n";
		exit 0;
	}
}







sub resultado_general{
	#Consulta que se invoca ingresando el caracter A por <STDIN>. Esta funcion toma como input
	#un id de sorteo y una fecha de adjudicación, verifica que las mismas sean válidas
	#En caso de ser validas procede a trabajar el archivo de sorteo
	#Se calcula el ganador del sorteo haciendo un ordenamiento
	#por valor de hash de sorteo
	#para obtener al ganador del mismo
	print "Se le presentara un listado de adjudicaciones válidas.\n";
	print "-------------------\n";
	listar_archivos($ENV{'PROCDIR'}."sorteos/");
	print "-------------------\n";
	recibir_idsorteo_fecha();
	
	my $nombre_archivo_sorteo = $ENV{'PROCDIR'}."sorteos/".$sorteo_a_mostrar ."_".$fecha_sorteo.".srt";
	my @lineas_a_grabar;
	my %hash_datos;
	if(open(my $fh,'<',$nombre_archivo_sorteo)){  
	while (my $linea = <$fh>){
		chomp $linea;
		my @campos = split(/;/,$linea);
		$hash_datos{$campos[0]}[0] = $campos[1];
		}
	close $fh;
	}else{
		print "No se encuentra el archivo $nombre_archivo_sorteo [$!]\n";
		hacer_consulta();
	}
	foreach my $numero_orden (sort {$hash_datos{$a}[0] <=> $hash_datos{$b}[0] } keys %hash_datos){
		$linea_a_guardar =sprintf "Nro de Sorteo %.3d le correspondió al número de orden %.3d \n",$hash_datos{$numero_orden}[0],$numero_orden;
		 push @lineas_a_grabar,$linea_a_guardar;
		print $linea_a_guardar;
	}
	
	if ($modo ne ""){
		my $nombre_archivo_res_gral =$ENV{'INFODIR'}. $sorteo_a_mostrar . "_" . $fecha_sorteo . ".txt";
		grabar_a_archivo($nombre_archivo_res_gral,@lineas_a_grabar);
	}
}


sub grabar_a_archivo{
	#funcion auxiliar utilizada en caso de recibir el parámetro -g
	#para grabar el archivo con el nombre correspondiente
	#espera por parámetro el nombre del archivo
	#y luego todas las lineas a guardar en el mismo
	my $nombre_archivo = shift;
	open(my $fh,'>',$nombre_archivo) or die ("No se puede grabar la consulta [$!]\n");
	foreach $linea_a_guardar (@_){
		print $fh $linea_a_guardar;	
	}
	close $fh;
}


sub ganadores_por_sorteo{
	#Imagino que los sorteos son por Grupos, por lo cual voy a tomar el grupo, o rango de grupos que me pidan, y voy a ordenar
	#en ese grupo, tomando los numeros del archivo de sorteos para una fecha.
	#Voy a generar un hash por grupos del archivo que me pidan, de ofertas, y en base a eso busco lo que me piden
	#Recibo: el id del sorteo a ver, uno o varios grupos (para marcar un rango usar delimitador "-"). Si no recibo
	#un grupo, se va a proceder a mostrar los ganadores de TODOS los grupos.
	#
	my $hash_datos = {};
	my $hash_sorteo = {};
	my @grupos;
	print "-------------------\n";
	listar_archivos($ENV{'PROCDIR'}."sorteos/");
	print "-------------------\n";
	recibir_idsorteo_fecha();
	recibir_grupo();
	
	my @lineas_a_grabar;
	my $nombre_archivo = $fecha_sorteo.".txt";
	generar_hash_datos_sorteo($hash_datos);
	generar_hash_sorteo($hash_sorteo);
	push @lineas_a_grabar,"Ganadores del sorteo ".$sorteo_a_mostrar." de fecha ".$fecha_sorteo ."\n";
	print $lineas_a_grabar[0];
	if ($modo_comando eq "t"){
		@grupos = (keys %$hash_datos);
	
	}
	if ($modo_comando eq "r"){
		@grupos = split(/-/,$grupo_recibido_parametro);
		
		@grupos = ($grupos[0]..$grupos[-1]);
	}
	if ($modo_comando eq "v"){
		@grupos = split(/,/,$grupo_recibido_parametro);
	}
	if ($modo_comando eq "u"){
		@grupos = ($grupo_recibido_parametro);
	}
	@grupos = sort {$a <=> $b} @grupos;
	my $nombre_archivo_a_guardar = $ENV{'INFODIR'}.$sorteo_a_mostrar."_Grd".$grupos[0]."-Grh".$grupos[-1]."_".$fecha_sorteo.".txt";
	foreach my $num_grupo (@grupos){
		my $linea_a_guardar;
		if (!exists($hash_datos->{$num_grupo})){
			$linea_a_guardar = sprintf "No existe el grupo $num_grupo en los datos. \n";
			print $linea_a_guardar;
			push(@lineas_a_grabar,$linea_a_guardar);
			next;
		}
		my $nro_ordenes_a_ordenar = $hash_datos->{$num_grupo};
		my @keys_a_ordenar = (keys %$nro_ordenes_a_ordenar);
		if (@keys_a_ordenar < 1){
			$linea_a_guardar = sprintf "Para el grupo $num_grupo no hay suficientes participantes validos \n";
			push @lineas_a_grabar,$linea_a_guardar;
			next;
		}
		@keys_a_ordenar = sort{$hash_sorteo->{$a} <=> $hash_sorteo->{$b}  } @keys_a_ordenar;
		$linea_a_guardar = sprintf "Ganador por sorteo del grupo %.3d : Nro de orden %.3d , ".$hash_datos->{$num_grupo}->{$keys_a_ordenar[0]}[2] . "(Numero de sorteo %.3d)\n",$num_grupo,$keys_a_ordenar[0],$hash_sorteo->{$keys_a_ordenar[0]};
		print $linea_a_guardar;
		push @lineas_a_grabar,$linea_a_guardar;
	}

	if ($modo ne "" && @lineas_a_grabar >= 1){
		grabar_a_archivo($nombre_archivo_a_guardar,@lineas_a_grabar);
	}
}

sub ganadores_por_licitacion{
	#Funcion que calcula al ganador por licitación. Se entiende como ganador por licitacion 
	#a aquel del grupo que, LUEGO del sorteo, ofreció el mayor monto. En caso de empatarse
	#la licitacion (esto es, dos montos iguales), se desempata con el numero de sorteo correspondiente
	#a la fecha de adjudicación.
	#Para hacerlo, voy a calcular primero un hash de ganadores por sorteo
	#Al calcular los de licitacion, si coincide con el de hash de sorteo
	#busco el siguiente, usando como criterio el numero de sorteo asignado a cada uno de haber empate.
	#COMO LO ENCARE: Primero ordeno todo, por precio, y defino una politica de empate donde si oferta1 = oferta2, desempato con el num
	#de sorteo. De esa forma, lo unico que falta es chequear si el que gano el sorteo de ese grupo coincide con este, y en todo caso tomo el segundo
	#del arreglo que genere.
	#Despues me fijo si ese ganador coincide con el del sorteo.
	#Por ahora..
	$hash_sorteo = {};
	$hash_datos = {};
	$hash_datos_sorteo = {};
	print "-------------------\n";
	listar_archivos($ENV{'PROCDIR'}."sorteos/");
	print "-------------------\n";
	recibir_idsorteo_fecha();
	recibir_grupo();
	my @lineas_a_grabar;
	push @lineas_a_grabar,"Ganadores por Licitacion ". $sorteo_a_mostrar . " de fecha $fecha_sorteo .\n";
	my $nombre_archivo_a_guardar = $ENV{'INFODIR'}.$sorteo_a_mostrar."_Grd".$grupos[0]."-Grh".$grupos[-1]."_".$fecha_sorteo."_licitacion.txt";
	my @grupos;
	
	print $lineas_a_grabar[0];
	my $nombre_archivo = $fecha_sorteo .".txt";
	generar_hash_sorteo($hash_sorteo);
	generar_hash_datos($hash_datos,$nombre_archivo);
	generar_hash_datos_sorteo($hash_datos_sorteo);
	if ($modo_comando eq "t"){
		@grupos = (keys %$hash_datos);
	
	}
	if ($modo_comando eq "r"){
		@grupos = split(/-/,$grupo_recibido_parametro);
		
		@grupos = ($grupos[0]..$grupos[-1]);
	}
	if ($modo_comando eq "v"){
		@grupos = split(/,/,$grupo_recibido_parametro);
	}
	if ($modo_comando eq "u"){
		@grupos = ($grupo_recibido_parametro);
	}
	@grupos = sort {$a <=> $b} @grupos;
	my $nombre_archivo_a_guardar = $ENV{'INFODIR'}.$sorteo_a_mostrar."_Grd".$grupos[0]."-Grh".$grupos[-1]."_".$fecha_sorteo."_licitacion.txt";
	@grupos = sort {$a <=> $b} @grupos;
	foreach my $num_grupo (@grupos){
		if (exists($hash_datos_sorteo->{$num_grupo})){
			if (!exists($hash_datos->{$num_grupo})){
				$linea_a_guardar = sprintf "El grupo $num_grupo no ha presentado ofertas válidas. \n";
				print $linea_a_guardar;
				push(@lineas_a_grabar,$linea_a_guardar);
				next;
			}
		} else{
			$linea_a_guardar = sprintf "El grupo $num_grupo no existe en los datos. \n";
			print $linea_a_guardar;
			push(@lineas_a_grabar,$linea_a_guardar);
			next;
		}
		my $nro_ordenes_a_ordenar = $hash_datos->{$num_grupo};
		my $nro_ordenes_sorteo_a_ordenar = $hash_datos_sorteo->{$num_grupo};
		my @las_keys_licitacion = (keys %$nro_ordenes_a_ordenar);
		my @las_keys_sorteo = (keys %$nro_ordenes_sorteo_a_ordenar);
		my @ordenes_ordenadas_por_licitacion = sort {$hash_datos->{$num_grupo}->{$b}[5] <=> $hash_datos->{$num_grupo}->{$a}[5] or $hash_sorteo->{$a} <=> $hash_sorteo->{$b}} @las_keys_licitacion;
		my @ordenes_ordenadas_por_sorteo = sort {$hash_sorteo->{$a} <=> $hash_sorteo->{$b} } @las_keys_sorteo;
		my $tam_array = @ordenes_ordenadas_por_licitacion;
		if ($ordenes_ordenadas_por_sorteo[0] eq $ordenes_ordenadas_por_licitacion[0] && $tam_array >= 2){
			 $i = 1;
		}else{
			 $i = 0;
		}
		$linea_a_guardar = sprintf "Ganador por licitación del grupo %.3d : Número de orden %.3d, " . $hash_datos->{$num_grupo}->{$ordenes_ordenadas_por_licitacion[$i]}[6] . " con ".chr(36)." $hash_datos->{$num_grupo}->{$ordenes_ordenadas_por_licitacion[$i]}[5]   (Nro de Sorteo %.3d) \n",$num_grupo,$ordenes_ordenadas_por_licitacion[$i],$hash_sorteo->{$ordenes_ordenadas_por_licitacion[$i]};
		print $linea_a_guardar;
		push(@lineas_a_grabar,$linea_a_guardar);
	}
	$tam_array = @lineas_a_grabar;
	if ($modo ne "" && $tam_array >= 1){
		grabar_a_archivo($nombre_archivo_a_guardar,@lineas_a_grabar)
	}
}

sub resultados_grupo{
	#Es la función encargada de mostrar todos los resultados de un grupo en particular
	#Utiliza, por ende, las reglas planteadas para el sorteo y para la licitación
	#Exhibe por pantalla los resultados acordes, siendo indicados en pantalla adoptando
	#la convención propuesta.
	#Nota: Sólo permite el ingreso de un grupo en particular, se ha decidido
	#No aceptar rangos de grupos para esta función, dado que se plantea como
	#una función para consultar un grupo en particular y obtener los detalles.
	
	print "-------------------\n";
	listar_archivos($ENV{'PROCDIR'}."sorteos/");
	print "-------------------\n";
	recibir_idsorteo_fecha();
	recibir_grupo();
	my $hash_datos = {};
	my $hash_sorteo = {};
	my $hash_datos_sorteo = {};
	my $nombre_archivo = $fecha_sorteo .".txt";
	generar_hash_sorteo($hash_sorteo);
	generar_hash_datos_sorteo($hash_datos_sorteo);
	generar_hash_datos($hash_datos,$nombre_archivo);
	my @lineas_a_grabar;
	if ($modo_comando ne "u"){
		print "Debe ingresar un solo grupo, intente otra vez por favor\n";
		recibir_grupo();
	}
	$nombre_archivo_a_guardar = $ENV{'INFODIR'}.$sorteo_a_mostrar . "_Grupo".$grupo_recibido_parametro."_".$fecha_sorteo.".txt";
	my $num_grupo = $grupo_recibido_parametro;
	
	if (!exists($hash_datos->{$num_grupo}) && (!exists($hash_datos_sorteo->{$num_grupo}))){
			$linea_a_guardar = sprintf "El grupo $num_grupo no existe en los datos \n";
			print $linea_a_guardar;
			push @lineas_a_grabar,$linea_a_guardar;
		}else{
			my $nro_ordenes_a_ordenar = $hash_datos->{$num_grupo};
			my $nro_ordenes_sorteo_a_ordenar = $hash_datos_sorteo->{$num_grupo};
			@las_keys = (keys %$nro_ordenes_a_ordenar);
			@las_keys_sorteo = (keys %$nro_ordenes_sorteo_a_ordenar);
			@ordenes_ordenadas_por_licitacion = sort {$hash_datos->{$num_grupo}->{$b}[5] <=> $hash_datos->{$num_grupo}->{$a}[5] or $hash_sorteo->{$a} <=> $hash_sorteo->{$b}} @las_keys;
			@ordenes_ordenadas_por_sorteo = sort {$hash_sorteo->{$a} <=> $hash_sorteo->{$b} } @las_keys_sorteo;
			my $tam_array = @ordenes_ordenadas_por_licitacion;
			if ($ordenes_ordenadas_por_sorteo[0] eq $ordenes_ordenadas_por_licitacion[0] && $tam_array >= 2){
				 $i = 1;
			}else{
			 	$i = 0;
			}
			$linea_a_guardar = sprintf "%.3d - %.3d S (".$hash_datos_sorteo->{$num_grupo}->{$ordenes_ordenadas_por_sorteo[0]}[2].") \n",$num_grupo,$ordenes_ordenadas_por_sorteo[0];
			print $linea_a_guardar;
			push(@lineas_a_grabar,$linea_a_guardar);
			if (@ordenes_ordenadas_por_licitacion < 1){
				$linea_a_guardar = sprintf "Para el grupo $num_grupo no hubieron ofertas válidas \n";
			}else{
				$linea_a_guardar = sprintf "%.3d - %.3d L (".$hash_datos->{$num_grupo}->{$ordenes_ordenadas_por_licitacion[$i]}[6].") \n",$num_grupo,$ordenes_ordenadas_por_licitacion[$i];
			}
			
			print $linea_a_guardar;
			push(@lineas_a_grabar,$linea_a_guardar);
		}
	$tam_array = @lineas_a_grabar;
	if ($modo ne "" && $tam_array >= 1){
		grabar_a_archivo($nombre_archivo_a_guardar,@lineas_a_grabar)
	}
}
sub recibir_grupo{
	#Esta funcion se encarga de indicarle al script que tipo de dato de grupo se ha ingresado
	#El programa debe aceptar un grupo solo, varios grupos delimitados por coma
	#Un rango de grupos delimitado por -
	#Todos los grupos si se ingresa espacio en blanco
	print "Ingrese el o los grupos que quiera consultar. De querer un rango, ingrese xxxx-yyyy\n";
	print "ATENCION: Si usted está consultando la opción D, debe ingresar uno solo\n";
	$grupo_recibido_parametro = <STDIN>;
	chomp($grupo_recibido_parametro);
	if ($grupo_recibido_parametro =~ /.+-.+/){
		
		$modo_comando = "r";
		}	
	if ($grupo_recibido_parametro =~ /.+,.+/){
		
		$modo_comando = "v";
		}
		
	if ($grupo_recibido_parametro eq ""){

		$modo_comando = "t";
		}	
	if ($grupo_recibido_parametro =~ /^\b[a-zA-Z0-9_]+\b$/){
		
		$modo_comando = "u"; 
	}
	print "\n";
	}
sub ejecutar_ayuda(){
	#Comando de ayuda que se ejecuta pasando por ARGV los caracteres "-a"
	#Contiene información sobre cómo operar el script para obtener las consultas.
	print "Esta es la ayuda del comando DeterminarGanador del módulo CIPAK. \n";
	print "Previo a ejecutarse este comando, debe inicializarse correspondientemente el ambiente \n";
	print "Para saber cómo iniciar correctamente el ambiente, diríjase a la documentación proporcionada\n";
	print "El módulo puede ejecutarse con los siguientes argumentos: \n";
	print " './DeterminarGanadores.pl -g' graba las consultas en el directorio $ENV{'INFODIR'}\n";
	print "'./DeterminarGanadores.pl' sólo se muestran las consultas en pantalla\n";
	print "Una vez ejecutado el comando, se presentará la pantalla de bienvenida\n";
	print "La misma le pedirá que ingrese una opción para acceder a una consulta\n";
	print "Se tienen las siguientes consultas disponibles:\n";
	print "A entrega el numero ganador del sorteo correspondiente a la fecha de adjudicación indicada por parámetro\n";
	print "B indica, dentro de los grupos especificados por el usuario, qué numero de orden resulto ganador del sorteo \n";
	print "C indica, dentro de los grupos especificados por el usuario, qué numero de orden resulto ganador de la licitación, tomando en cuenta al ganador del sorteo\n";
	print "D indica, para un grupo en particular, los ganadores por sorteo y licitación\n";
	print "El ingreso de cualquier otro caracter diferente a los mencionados, causará el término de ejecución del módulo\n";
	print "\n";
	print "Posibles Errores del módulo (cualquiera de estos errores provoca el paro en la ejecucion del comando):\n";
	print "1. No se inicializó el ambiente. Primero inicialicelo\n";
	print "Causa del error: No se ejecutó el comando PrepararAmbiente, por lo cual el módulo no puede ser ejecutado\n";
	print "2. Ya se está corriendo una instancia de DeterminarGanadores \n";
	print "Causa del error: Se intenta ejecutar, otra vez y en otra ventana, el módulo cuando el mismo ya está siendo ejecutado \n";
	print "3. No es válido el directorio de sorteos.\n";
	print "Causa del error: No se corrió el comando GenerarSorteo. Recuerde que debe correrlo primero para utilizar este comando.\n";
	print "\n";
	print "Para más información, recurrir a la documentación adjunta con el CIPAK.\n";
}

sub recibir_idsorteo_fecha{
	#Funcion auxiliar utilizada para recibir por entrada estandar
	#el ID y la fecha de adjudicación a consultar.
	print "Especifique el ID del sorteo que quiere mostrar por pantalla \n";
	 $sorteo_a_mostrar = <STDIN>;
	chomp($sorteo_a_mostrar);
	print "Especifique la fecha, en formato AAAAMMDD\n";
	 $fecha_sorteo = <STDIN>;
	chomp($fecha_sorteo);
	print "\n";
}

sub listar_archivos{
	#Funcion auxiliar utilizada para mostrar por pantalla los sorteos disponibles
	#En caso de no hallar el directorio correspondiente
	#Aborta la ejecución del script
	my $dir = $_[0];
	opendir(my $dh, $dir) or die "No es válido el directorio de sorteos. [$!] \n";
	while (my $file = readdir($dh)){
		if ($file =~ /\d_.+\.srt$/){
			print "$file \n";	
		
		}
			
		
	}
}




sub generar_hash_datos_sorteo{
	#función auxiliar utilizada para generar el hash de datos para
	#la funcion de ganadores por sorteo.
	#En esta función se verifica que el usuario participante del padrón
	#cumpla con la restricción de que el campo PARTICIPA esté en 
	#1 o 2. De otra forma, no puede participar en el sorteo
	my $hash_datos = shift;
	if (open(my $fh,"<",$ENV{'MAEDIR'}.'temaK_padron.csv'))	{
	while (my $linea = <$fh>){
		chomp $linea;
		my @campos = split(/;/,$linea);
		if ($campos[5] eq 1 || $campos[5] eq 2){
			$campos[1] =~ s/0*(\d+)/$1/;
			if (not defined $hash_datos->{$campos[0]}){
				$hash_datos->{$campos[0]} = {$campos[1] => [@campos]};
			}
			$hash_datos->{$campos[0]}->{$campos[1]} = [@campos];	
		}else{
			next;
		}
		
	}

	}else{
		print "No se encontró el archivo de padrón [$!]\n";
		print "Revise su instalación\n";
		hacer_consulta();
	}
	close $fh;
}


sub generar_hash_sorteo{
	#funcion auxiliar utilizada para generar el hash de sorteo
	#Respetando la estructura del programa para encontrar los archivos
	#En caso de no poder hallarlo, reinicia la ejecución del script
	my $hash_sorteo = shift;
	if (open(my $fh,'<',$ENV{'PROCDIR'}."sorteos/".$sorteo_a_mostrar."_".$fecha_sorteo.".srt")){


	while (my $linea =<$fh>){
		chomp $linea;
		my @campos = split(/;/,$linea);
		$hash_sorteo->{$campos[0]} = $campos[1];
	}
	close $fh;
	}else{
		print "No se encuentra el archivo de sorteo indicado. [$!]\n";
		hacer_consulta();
	}
}

sub generar_hash_datos{
	#funcion auxiliar utilizada para generar el hash de los datos de las personas
	#en el padrón dado
	#Respetando la estructura del programa para encontrar los archivos
	#En caso de no poder hallarlo, reinicia la ejecución del script
	my $hash_datos = shift;
	my $nombre_archivo = shift;
	if (open(my $fh,'<',$ENV{'PROCDIR'}."validas/".$nombre_archivo)){ 
	while (my $linea = <$fh>){
		chomp $linea;
		my @campos = split(/;/,$linea);
		if (not defined($hash_datos->{$campos[3]})){
			$campos[4] =~ s/0*(\d+)/$1/; #normalizo el formato de orden
			$hash_datos->{$campos[3]} = {$campos[4] => [@campos]};
		}
		$campos[4] =~ s/0*(\d+)/$1/;
		$hash_datos->{$campos[3]}->{$campos[4]} = [@campos];
		}
	close $fh;
	}else{
		print"No existe el archivo correspondiente a la fecha de adjudicación [$!]\n";
		hacer_consulta();
	}
}
open my $scripth, '<', $0 or die "No pudo abrirse el handler: $!";
flock $scripth, LOCK_EX | LOCK_NB or die "Ya se está corriendo una instancia de DeterminarGanadores \n";
if ($ENV{'AMBIENTE_INICIALIZADO'} eq 1){

	while( 1){
	recibir_parametros();
	print "\n";
	print "Presione cualquier tecla para realizar otra consulta.\n";
	<STDIN>;
	system $^O eq 'MSWin32' ? 'cls' : 'clear';
	}
}else {
	print "No se inicializo el ambiente. Primero inicialicelo, ABORTANDO SCRIPT \n";
	sleep 3;
	exit 1;
}
exit 0;
