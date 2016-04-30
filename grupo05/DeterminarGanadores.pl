#!/usr/bin/perl
use Data::Dumper;
use warnings;
#definicion subrutinas
sub recibir_parametros{
	#print "Bienvenido al CIPAK.\nPara ayuda, ingrese -a\n";
	#print "Para habilitar la opcion de grabado, ingrese -g\n";
	#print "Para proseguir con la consulta, presione enter\n";
	if (@ARGV eq 0){
		$modo = '';
		hacer_consulta();
 	}
	$modo = $ARGV[0];
	if ($modo =~ /-g/){
		$sorteo_a_mostrar = $ARGV[1];
		$grupo_recibido_parametro = $ARGV[2];
		hacer_consulta($modo);
	} elsif ($modo =~ /-a/){
		ejecutar_ayuda();
	}
	
}

sub hacer_consulta{

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
sub recibir_idsorteo_fecha{
	print "Especifique el ID del sorteo que quiere mostrar por pantalla \n";
	 $sorteo_a_mostrar = <STDIN>;
	chomp($sorteo_a_mostrar);
	print "Especifique la fecha, en formato AAAAMMDD\n";
	 $fecha_sorteo = <STDIN>;
	chomp($fecha_sorteo);
}

sub listar_archivos{
	my $dir = $_[0];
	opendir(my $dh, $dir) or die "No es válido el directorio [$!] \n";
	while (my $file = readdir($dh)){
		if ($file =~ /\d_.+/){
			print "$file \n";	
		
		}
			
		
	}
}
sub resultado_general{
	print "Se le presentara un listado de adjudicaciones válidas.\n";
	print "\n";
	listar_archivos($ENV{'PROCDIR'}."sorteos/");
	recibir_idsorteo_fecha();
	my $nombre_archivo_sorteo = $ENV{'PROCDIR'}."sorteos/".$sorteo_a_mostrar ."_".$fecha_sorteo.".srt";
	my @datos_sorteo;
	my %hash_datos;
	open(my $fh,'<',$nombre_archivo_sorteo) or die "No se encuentra el archivo $nombre_archivo_sorteo [$!]\n";
	while (my $linea = <$fh>){
		chomp $linea;
		my @campos = split(/;/,$linea);
		$hash_datos{$campos[0]}[0] = $campos[1];
	}
	close $fh;
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

sub generar_hash_sorteo{
	my $hash_sorteo = shift;
	open(my $fh,'<',$ENV{'PROCDIR'}."sorteos/".$sorteo_a_mostrar."_".$fecha_sorteo.".srt") or die "No se encontro el archivo de sorteo especificado";
	while (my $linea =<$fh>){
		chomp $linea;
		my @campos = split(/;/,$linea);
		$hash_sorteo->{$campos[0]} = $campos[1];
	}
	close $fh;
}
sub generar_hash_datos{
	my $hash_datos = shift;
	my $nombre_archivo = shift;
	open(my $fh,'<',$ENV{'PROCDIR'}."validas/".$nombre_archivo) or die ("No existe el archivo correspondiente a la fecha de adjudicación [$!]\n");
	while (my $linea = <$fh>){
		chomp $linea;
		#print $linea."\n";
		my @campos = split(/;/,$linea);
		if (not defined($hash_datos->{$campos[3]})){
			$campos[4] =~ s/0*(\d+)/$1/; #normalizo el formato de orden
			$hash_datos->{$campos[3]} = {$campos[4] => [@campos]};
		}
		$campos[4] =~ s/0*(\d+)/$1/;
		$hash_datos->{$campos[3]}->{$campos[4]} = [@campos];
		}
	close $fh;
}

sub grabar_a_archivo{
	my $nombre_archivo = shift;
	open(my $fh,'>',$nombre_archivo) or die ("No se puede grabar la consulta [$!]\n");
	foreach $linea_a_guardar (@_){
		print $fh $linea_a_guardar;	
	}
	close $fh;
}

sub ganadores_por_sorteo{
	#Imagino que los sorteos son por Grupos, por lo cual voy a tomar el grupo, o rango de grupos que me pidan, y voy a sortear
	#en ese grupo, tomando los numeros del archivo de sorteos para una fecha.
	#Voy a generar un hash por grupos del archivo que me pidan, de ofertas, y en base a eso busco lo que me piden
	#Recibo: el id del sorteo a ver, uno o varios grupos (para marcar un rango usar delimitador "-"). Si no recibo
	#un grupo, se va a proceder a mostrar los ganadores de TODOS los grupos.
	listar_archivos($ENV{'PROCDIR'}."sorteos/");
	recibir_idsorteo_fecha();
	recibir_grupo();
	my $hash_datos = {};
	my $hash_sorteo = {};
	my @lineas_a_grabar;
	push @lineas_a_grabar,"Ganadores del sorteo".$sorteo_a_mostrar." de fecha ".$fecha_sorteo ."\n";
	my $nombre_archivo = $fecha_sorteo.".txt";
	generar_hash_datos($hash_datos,$nombre_archivo);
	generar_hash_sorteo($hash_sorteo);
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
				my $linea_a_guardar = "No se encontro el numero de grupo $num_grupo en los datos.\n";
				push @lineas_a_grabar,$linea_a_guardar;
				next;
			}
			
			foreach my $num_orden_del_grupo (@ordenados){
				$linea_a_guardar =sprintf "Ganador por sorteo del grupo %.3d: Número de orden %.3d ,".$hash_datos->{$num_grupo}->{$num_orden_del_grupo}[6]."(Numero de sorteo %.3d) \n",$num_grupo,$num_orden_del_grupo,$sorteo_a_mostrar;
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
			print "No existe el grupo en los datos. Por favor ingrese un grupo válido \n";
			recibir_grupo();	
		}
		my $ordenes_a_ordenar = $hash_datos->{$grupo};
		$nombre_archivo_a_guardar = $sorteo_a_mostrar. "_Grd".$grupo."- Gr".$grupo . ".txt";
		@ordenados = sort {$hash_sorteo->{$a} <=> $hash_sorteo->{$b} }keys %$ordenes_a_ordenar;
		foreach my $num_orden_del_grupo (@ordenados){
			$linea_a_guardar =sprintf "Ganador por sorteo del grupo %.3d: Número de orden %.3d ,".$hash_datos->{$num_grupo}->{$num_orden_del_grupo}[6]."(Numero de sorteo %.3d) \n",$num_grupo,$num_orden_del_grupo,$sorteo_a_mostrar;
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
				my $linea_a_guardar = sprintf "No se encontro el numero de grupo $num_grupo en los datos.\n";
				push @lineas_a_grabar, $linea_a_guardar;
				next;
			}
			
			foreach my $num_orden_del_grupo (@ordenados){
				$linea_a_guardar =sprintf "Ganador por sorteo del grupo %.3d: Número de orden %.3d ,".$hash_datos->{$num_grupo}->{$num_orden_del_grupo}[6]."(Numero de sorteo %.3d) \n",$num_grupo,$num_orden_del_grupo,$sorteo_a_mostrar;
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
				$linea_a_guardar =sprintf "Ganador por sorteo del grupo %.3d: Número de orden %.3d ,".$hash_datos->{$num_grupo}->{$num_orden_del_grupo}[6]."(Numero de sorteo %.3d) \n",$num_grupo,$num_orden_del_grupo,$sorteo_a_mostrar;
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
	my @lineas_a_grabar;
	push @lineas_a_grabar,"Ganadores por Licitacion". $sorteo_a_mostrar . "de fecha $fecha_sorteo .\n";
	my @grupos;
	listar_archivos($ENV{'PROCDIR'}."sorteos");
	recibir_idsorteo_fecha();
	recibir_grupo();
	my $nombre_archivo = $fecha_sorteo .".txt";
	generar_hash_datos($hash_datos,$nombre_archivo);
	generar_hash_sorteo($hash_sorteo);
	if ($modo_comando eq "t"){
		@grupos = (keys %$hash_datos);	
	}
	if ($modo_comando eq "r"){
		@grupos = split(/-/,$grupo_recibido_parametro);
		@grupos = ($grupos[0]..$grupos[-1])
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
			$linea_a_guardar = sprintf "El grupo $num_grupo no existe en los datos \n";
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
		$linea_a_guardar = sprintf "Ganador por licitación del grupo %.3d : Número de orden %.3d \n",$num_grupo,$ordenes_ordenadas_por_licitacion[$i];
		print $linea_a_guardar;
		push(@lineas_a_grabar,$linea_a_guardar);
	}
	$tam_array = @lineas_a_grabar;
	if ($modo ne "" && $tam_array >= 1){
		grabar_a_archivo($nombre_archivo_a_guardar,@lineas_a_grabar)
	}
}

sub resultados_grupo{
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
		$linea_a_guardar = sprintf "%.3d - %.3d S (".$hash_datos->{$num_grupo}->{$ordenes_ordenadas_por_sorteo[0]}[6].") \n",$num_grupo,$ordenes_ordenadas_por_sorteo[0];
		print $linea_a_guardar;
		push(@lineas_a_grabar,$linea_a_guardar);
		$linea_a_guardar = sprintf "%.3d - %.3d L (".$hash_datos->{$num_grupo}->{$ordenes_ordenadas_por_licitacion[$i]}[6].") \n",$num_grupo,$ordenes_ordenadas_por_licitacion[$i];
		print $linea_a_guardar;
		push(@lineas_a_grabar,$linea_a_guardar);
	
	$tam_array = @lineas_a_grabar;
	if ($modo ne "" && $tam_array >= 1){
		grabar_a_archivo($nombre_archivo_a_guardar,@lineas_a_grabar)
	}
}
sub recibir_grupo{
	print "Ingrese el o los grupos que quiera consultar. De querer un rango, ingrese xxxx-yyyy\n";
	print "ATENCION: Si usted está consultando un grupo en particular, debe ingresar uno solo\n";
	$grupo_recibido_parametro = <STDIN>;
	chomp($grupo_recibido_parametro);
	if ($grupo_recibido_parametro =~ /.+-.+/){
		
		$modo_comando = "r";
		}	
	if ($grupo_recibido_parametro =~ /.+,.+/){
		
		$modo_comando = "v";
		}
		
	if ($grupo_recibido_parametro == ""){

		$modo_comando = "t";
		}	
	if ($grupo_recibido_parametro =~ /^\b[a-zA-Z0-9_]+\b$/){
		#uno solo
		#print "ENTRA AL MODO COMANDO U \n";
		$modo_comando = "u"; 
	}
	}
sub ejecutar_ayuda(){
	print "Esta es la ayuda del comando determinarGanador. \n";
	print "Toma mis 10 maquinola \n";

}
while( 1){
recibir_parametros();
}

