sub logError {
	my ($msg, $comando) = @_;
	print "$msg";
	system ("sh", "GrabarBitacora.sh", "$comando", "$msg", "2") == 0
		or die "No se pudo loggear el error en la bitacora del comando invocador.";
	return (0);	
}

sub imprimirLinea {
	my ($linea, $comando) = @_;
        if (defined $ARGV[2] && length $ARGV[2] > 0) {
                open (SALIDA, ">>$ARGV[2]") 
			or &logError ("No se pudo abrir archivo de salida.", $comando);
                print SALIDA $linea;
        } else {
                print "$linea";
        }
	return (0);
}

sub main {
	$comando = $ARGV[0];	# Nombre del comando, obligatorio.
	if (defined $ARGV[1] && length $ARGV[1] > 0) {
		$query = $ARGV[1];	# String a buscar, opcional.
	}

	$bitacora = $ENV{LOGDIR} . $comando . ".log";
	open (BITACORA, "$bitacora") 
		or &logError("No se pudo abrir el archivo de bitacora sobre el que se va a realizar la consulta.", $comando);

	while ($linea=<BITACORA>) {
		if (defined $query) {
			if ($linea =~ /$query/) {	# Busca coincidencias de regex.
				&imprimirLinea ($linea, $comando);
			}
		} else {
			&imprimirLinea ($linea, $comando);
		}
	}

	if (defined $ARGV[2] && length $ARGV[2] > 0) {
		close (SALIDA);
	}
	close (BITACORA);
	return (0);
}

&main;
