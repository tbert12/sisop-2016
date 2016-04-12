sub imprimirLinea {
	my ($linea) = @_;
        if (defined $ARGV[2] && length $ARGV[2] > 0) {
                open (SALIDA, ">>$ARGV[2]") or die "ERROR: No se pudo abrir el archivo de salida.";
                print SALIDA $linea;
        } else {
                print "$linea";
        }
}

$comando = $ARGV[0];	# Nombre del comando, obligatorio.
if (defined $ARGV[1] && length $ARGV[1] > 0) {
	$query = $ARGV[1];	# String a buscar, opcional.
}

$bitacora = $ENV{LOGDIR} . $comando . ".log";
open (BITACORA, "$bitacora") || die "ERROR: No se pudo abrir la bitacora $bitacora. Es probable que el archivo o el directorio sean incorrectos.";

while ($linea=<BITACORA>) {
	if (defined $query) {
		if ($linea =~ /$query/) {	# Busca coincidencias de regex.
			&imprimirLinea ($linea);
		}
	} else {
		&imprimirLinea ($linea);
	}
}

if (defined $ARGV[2] && length $ARGV[2] > 0) {
	close (SALIDA);
}
close (BITACORA);
