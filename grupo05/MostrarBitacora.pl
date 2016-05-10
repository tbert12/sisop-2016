sub imprimirLinea {
	my ($linea) = @_;
        if (defined $ARGV[2] && length $ARGV[2] > 0) {
                open (SALIDA, ">>$ARGV[2]") 
			or (print "No se pudo abrir archivo de salida de MostrarBitacora." and return (2));
                print SALIDA $linea;
        } else {
                print "$linea";
        }
	return (0);
}

sub main {
	$bitacora = $ARGV[0];	# Nombre del comando, obligatorio.
	if (defined $ARGV[1] && length $ARGV[1] > 0) {
		$query = $ARGV[1];	# String a buscar, opcional.
	}

	open (BITACORA, "$bitacora") 
		or (print "No se pudo abrir el archivo de bitacora sobre el que se va a realizar la consulta de MostrarBitacora." and return (1));

	while ($linea=<BITACORA>) {
		if (defined $query) {
			if ($linea =~ /$query/) {	# Busca coincidencias de regex.
				&imprimirLinea ($linea) == 0
					or return (2);
			}
		} else {
			&imprimirLinea ($linea) == 0
				or return (2);
		}
	}

	if (defined $ARGV[2] && length $ARGV[2] > 0) {
		close (SALIDA);
	}
	close (BITACORA);
	return (0);
}

exit (&main);

