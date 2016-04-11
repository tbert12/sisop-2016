$comando = $ARGV[0];	# Nombre del comando, obligatorio.
if (defined $ARGV[1] && length $ARGV[1] > 0) {
	$query = $ARGV[1];	# String a buscar, opcional.
}

$bitacora = $ENV{LOGDIR} . $comando . ".log";
open (BITACORA, "$bitacora") || die "ERROR: No se pudo abrir la bitacora $bitacora. Es probable que el archivo o el directorio sean incorrectos.";

while ($linea=<BITACORA>) {
	if (defined $query) {
		if ($linea =~ /$query/) {
			print "$linea";
		}
	} else {
		print "$linea";
	}
}

close (BITACORA);
