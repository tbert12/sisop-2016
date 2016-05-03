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
	print "\n";
	listar_archivos($ENV{'PROCDIR'}."sorteos/");
	recibir_idsorteo_fecha();
	my $nombre_archivo_sorteo = $ENV{'PROCDIR'}."sorteos/".$sorteo_a_mostrar ."_".$fecha_sorteo.".srt";
	my @datos_sorteo;
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
		$linea_a_guardar =sprintf "Nro de Sorteo %.3d le correspondió al número de orden %.3d \n",$sorteo_a_mostrar,$numero_orden;
		last;
	}
	print $linea_a_guardar;
	if ($modo ne ""){
		my $nombre_archivo_res_gral =$ENV{'INFODIR'}. $sorteo_a_mostrar . "_" . $fecha_sorteo . ".txt";
		grabar_a_archivo($nombre_archivo_res_gral,$linea_a_guardar);
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
	listar_archivos($ENV{'PROCDIR'}."sorteos/");
	recibir_idsorteo_fecha();
	recibir_grupo();
	
	my @lineas_a_grabar;
	my $nombre_archivo = $fecha_sorteo.".txt";
	generar_hash_datos($hash_datos,$nombre_archivo);
	generar_hash_sorteo($hash_sorteo);
	push @lineas_a_grabar,"Ganadores del sorteo ".$sorteo_a_mostrar." de fecha ".$fecha_sorteo ."\n";
	print $lineas_a_grabar[0];
	if ($modo_comando eq "r"){
		my @rango_de_grupos = split(/-/,$grupo_recibido_parametro);
		@rango_de_grupos = ($rango_de_grupos[0]..$rango_de_grupos[1]);
		$nombre_archivo_a_guardar = $sorteo_a_mostrar . "_Grd".$rango_de_grupos[0]."- Gr".$rango_de_grupos[-1]  . ".txt";
		foreach my $num_grupo (@rango_de_grupos){
			my $nro_ordenes_a_ordenar = $hash_datos->{$num_grupo};
			if (exists $hash_datos->{$num_grupo}){
				@laskeys = (keys %$nro_ordenes_a_ordenar);
				@ordenados = sort { $hash_sorteo->{$a} <=> $hash_sorteo->{$b} } @laskeys;	
			}else{
				my $linea_a_guardar = "No existe el grupo $num_grupo en los datos.\n";
				print $linea_a_guardar;
				push @lineas_a_grabar,$linea_a_guardar;
				next;
			}
			
			foreach my $num_orden_del_grupo (@ordenados){
				$linea_a_guardar =sprintf "Ganador por sorteo del grupo %.3d: Número de orden %.3d ,". $hash_datos->{$num_grupo}->{$num_orden_del_grupo}[6] ."(Numero de sorteo %.3d) \n",$num_grupo,$num_orden_del_grupo,$sorteo_a_mostrar;
				print $linea_a_guardar;
				push @lineas_a_grabar,$linea_a_guardar;
				last;
			}
		}
		if ($modo ne ""){
		grabar_a_archivo($nombre_archivo_a_guardar,@lineas_a_grabar);
		
		}
		
	}
	if ($modo_comando eq "u"){
		my $linea_a_guardar;
		my $grupo = $grupo_recibido_parametro;
		if (!exists$hash_datos->{$grupo}){
			print "No existe el grupo $grupo en los datos.\n";
			hacer_consulta();	
		}
		my $ordenes_a_ordenar = $hash_datos->{$grupo};
		$nombre_archivo_a_guardar = $sorteo_a_mostrar. "_Grd".$grupo."- Gr".$grupo . ".txt";
		@ordenados = sort {$hash_sorteo->{$a} <=> $hash_sorteo->{$b} }keys %$ordenes_a_ordenar;
		foreach my $num_orden_del_grupo (@ordenados){
			$linea_a_guardar =sprintf "Ganador por sorteo del grupo %.3d: Número de orden %.3d ,". $hash_datos->{$grupo}->{$num_orden_del_grupo}[6] ."(Numero de sorteo %.3d) \n",$grupo,$num_orden_del_grupo,$sorteo_a_mostrar;
			print $linea_a_guardar;
			last;
		}
		if ($modo ne ""){
		grabar_a_archivo($nombre_archivo_a_guardar,$linea_a_guardar);
		}
	}
	if ($modo_comando eq "v"){
		my @grupos = split(/,/,$grupo_recibido_parametro);
		@grupos = sort{ $a > $b } @grupos;
		$nombre_archivo_a_guardar = $sorteo_a_mostrar . "_Grd".$grupos[0]."- Gr".$grupos[-1]  . ".txt";
		foreach my $num_grupo (@grupos){
			my $nro_ordenes_a_ordenar = $hash_datos->{$num_grupo};
			if (exists $hash_datos->{$num_grupo} ){
				@laskeys = (keys %$nro_ordenes_a_ordenar);
				@ordenados = sort { $hash_sorteo->{$a} <=> $hash_sorteo->{$b} } @laskeys;
			} else{
				my $linea_a_guardar = sprintf "No existe el grupo $num_grupo en los datos.\n";
				print $linea_a_guardar;
				push @lineas_a_grabar, $linea_a_guardar;
				next;
			}
			
			foreach my $num_orden_del_grupo (@ordenados){
				$linea_a_guardar =sprintf "Ganador por sorteo del grupo %.3d: Número de orden %.3d ,". $hash_datos->{$num_grupo}->{$num_orden_del_grupo}[6] ."(Numero de sorteo %.3d) \n",$num_grupo,$num_orden_del_grupo,$sorteo_a_mostrar;
				print $linea_a_guardar;
				push @lineas_a_grabar,$linea_a_guardar;
				last;
			}
		}
			if ($modo ne "" && (@lineas_a_grabar) >= 1){
			grabar_a_archivo($nombre_archivo_a_guardar,@lineas_a_grabar);
			}
	
	}
	if ($modo_comando eq "t"){
		
		
		@grupos = (keys %$hash_datos);
		@grupos = sort {$a > $b} @grupos;
		$nombre_archivo_a_guardar = $sorteo_a_mostrar."_Gr".$grupos[0]."_Gr".$grupos[-1]. "_sorteo.txt";
		foreach my $num_grupo (@grupos){
			my $nro_ordenes_a_ordenar = $hash_datos->{$num_grupo}; #obtengo ref al primer hash
			@las_keys = (keys %$nro_ordenes_a_ordenar); #obtengo keys del segundo hash
			@ordenados = sort { $hash_sorteo->{$a} <=> $hash_sorteo->{$b} } @las_keys ; #ordeno el segundo hash
			#print Dumper(@ordenados);
			foreach my $num_orden_del_grupo (@ordenados){
				$linea_a_guardar =sprintf "Ganador por sorteo del grupo %.3d: Número de orden %.3d ,". $hash_datos->{$num_grupo}->{$num_orden_del_grupo}[6] ."(Numero de sorteo %.3d) \n",$num_grupo,$num_orden_del_grupo,$sorteo_a_mostrar;
				print $linea_a_guardar;
				push @lineas_a_grabar,$linea_a_guardar;
				last;
			}
		}
		my $tam_array = @lineas_a_grabar;
		if ($modo ne "" && $tam_array >=2){
			grabar_a_archivo($nombre_archivo_a_guardar,@lineas_a_grabar);
			}
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
	listar_archivos($ENV{'PROCDIR'}."sorteos");
	recibir_idsorteo_fecha();
	recibir_grupo();
	my @lineas_a_grabar;
	push @lineas_a_grabar,"Ganadores por Licitacion ". $sorteo_a_mostrar . " de fecha $fecha_sorteo .\n";
	
	my @grupos;
	
	print $lineas_a_grabar[0];
	my $nombre_archivo = $fecha_sorteo .".txt";
	generar_hash_sorteo($hash_sorteo);
	generar_hash_datos($hash_datos,$nombre_archivo);
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
	my $nombre_archivo_a_guardar = $sorteo_a_mostrar."_Grd".$grupos[0]."-Grh".$grupos[-1]."_".$fecha_sorteo."_licitacion.txt";
	@grupos = sort {$a <=> $b} @grupos;
	foreach my $num_grupo (@grupos){
		if (!exists($hash_datos->{$num_grupo})){
			$linea_a_guardar = sprintf "No existe el grupo $num_grupo en los datos. \n";
			print $linea_a_guardar;
			push(@lineas_a_grabar,$linea_a_guardar);
			next;
		}
		my $nro_ordenes_a_ordenar = $hash_datos->{$num_grupo};
		@las_keys = (keys %$nro_ordenes_a_ordenar);
		@ordenes_ordenadas_por_licitacion = sort {$hash_datos->{$num_grupo}->{$b}[5] <=> $hash_datos->{$num_grupo}->{$a}[5] or $hash_sorteo->{$a} <=> $hash_sorteo->{$b}} @las_keys;
		@ordenes_ordenadas_por_sorteo = sort {$hash_sorteo->{$a} <=> $hash_sorteo->{$b} } @las_keys;
		my $tam_array = @ordenes_ordenadas_por_licitacion;
		if ($ordenes_ordenadas_por_sorteo[0] eq $ordenes_ordenadas_por_licitacion[0] && $tam_array >= 2){
			 $i = 1;
		}else{
			 $i = 0;
		}
		$linea_a_guardar = sprintf "Ganador por licitación del grupo %.3d : Número de orden %.3d." . $hash_datos->{$num_grupo}->{$ordenes_ordenadas_por_licitacion[$i]}[6] . " con ".chr(36)." $hash_datos->{$num_grupo}->{$ordenes_ordenadas_por_licitacion[$i]}[5]   (Nro de Sorteo %.3d) \n",$num_grupo,$ordenes_ordenadas_por_licitacion[$i],$sorteo_a_mostrar;
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
	listar_archivos($ENV{'PROCDIR'}."sorteos/");
	recibir_idsorteo_fecha();
	recibir_grupo();
	my $hash_datos = {};
	my $hash_sorteo = {};
	my $nombre_archivo = $fecha_sorteo .".txt";
	generar_hash_sorteo($hash_sorteo);
	generar_hash_datos($hash_datos,$nombre_archivo);
	my @lineas_a_grabar;
	if ($modo_comando ne "u"){
		print "Debe ingresar un solo grupo, intente otra vez por favor\n";
		recibir_grupo();
	}
	$nombre_archivo_a_guardar = $ENV{'INFODIR'}.$sorteo_a_mostrar . "_Grupo".$grupo_recibido_parametro."_".$fecha_sorteo.".txt";
	my $num_grupo = $grupo_recibido_parametro;
	if (!exists($hash_datos->{$num_grupo})){
			$linea_a_guardar = sprintf "El grupo $num_grupo no existe en los datos \n";
			print $linea_a_guardar;
			push @lineas_a_grabar,$linea_a_guardar;
		}else{
			my $nro_ordenes_a_ordenar = $hash_datos->{$num_grupo};
			@las_keys = (keys %$nro_ordenes_a_ordenar);
			@ordenes_ordenadas_por_licitacion = sort {$hash_datos->{$num_grupo}->{$b}[5] <=> $hash_datos->{$num_grupo}->{$a}[5] or $hash_sorteo->{$a} <=> $hash_sorteo->{$b}} @las_keys;
			@ordenes_ordenadas_por_sorteo = sort {$hash_sorteo->{$a} <=> $hash_sorteo->{$b} } @las_keys;
			my $tam_array = @ordenes_ordenadas_por_licitacion;
			if ($ordenes_ordenadas_por_sorteo[0] eq $ordenes_ordenadas_por_licitacion[0] && $tam_array >= 2){
				 $i = 1;
			}else{
			 	$i = 0;
			}
			$linea_a_guardar = sprintf "%.3d - %.3d S (".$hash_datos->{$num_grupo}->{$ordenes_ordenadas_por_sorteo[0]}[6].") \n",$num_grupo,$ordenes_ordenadas_por_sorteo[0];
			print $linea_a_guardar;
			push(@lineas_a_grabar,$linea_a_guardar);
			$linea_a_guardar = sprintf "%.3d - %.3d L (".$hash_datos->{$num_grupo}->{$ordenes_ordenadas_por_licitacion[$i]}[6].") \n",$num_grupo,$ordenes_ordenadas_por_licitacion[$i];
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
	}
sub ejecutar_ayuda(){
	#Comando de ayuda que se ejecuta pasando por ARGV los caracteres "-a"
	#Contiene información sobre cómo operar el script para obtener las consultas.
	print "Esta es la ayuda del comando DeterminarGanador. \n";
	print "Ejecutando el script pasando por argumento la opción '-g' se graban los resultados en el directorio $ENV{'INFODIR'}\n";
	print "Se tienen las siguientes consultas disponibles:\n";
	print "A entrega el numero ganador del sorteo correspondiente a la fecha de adjudicación indicada por parámetro\n";
	print "B indica, dentro de los grupos especificados por el usuario, qué numero de orden resulto ganador del sorteo \n";
	print "C indica, dentro de los grupos especificados por el usuario, qué numero de orden resulto ganador de la licitación, tomando en cuenta al ganador del sorteo\n";
	print "D indica, para un grupo en particular, los ganadores por sorteo y licitación\n";
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
}

sub listar_archivos{
	#Funcion auxiliar utilizada para mostrar por pantalla los sorteos disponibles
	#En caso de no hallar el directorio correspondiente
	#Aborta la ejecución del script
	my $dir = $_[0];
	opendir(my $dh, $dir) or die "No es válido el directorio [$!] \n";
	while (my $file = readdir($dh)){
		if ($file =~ /\d_.+\.srt$/){
			print "$file \n";	
		
		}
			
		
	}
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
	sleep 6;
	}
}else {
	print "No se inicializo el ambiente. Primero inicialicelo, ABORTANDO SCRIPT \n";
	sleep 3;
	exit 1;
}
exit 0;
