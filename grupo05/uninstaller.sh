#
if [ $(($AMBIENTE_INICIALIZADO)) -eq 0 ]
  then
	GRUPO="$PWD/../"
fi
#

echo
echo "DESINSTALADOR ~ Está usted TOTAL E IRREVOCABLEMENTE SEGURO de querer eliminar el sistema con toda la carpeta $GRUPO, los registros, reportes, configuración y demases?"
echo
printf "Esta es su última oportunidad ... (y/n) ~ "
read respuesta

if [ "$respuesta" != "y" -a "$respuesta" != "yes" ]
  then
	echo "Cancelado"
	exit 1
fi

start-stop-daemon --stop --name "RecibirOfertas." > /dev/null
### ¿Qué otros scripts haría falta asegurarse de matar?

echo
echo "Recreando instalador..."

cd "$GRUPO"

mv "source/*" "$GRUPO.." 2> /dev/null
mv "source/Readme.md" "$GRUPO.." 2> /dev/null
mv "source/installer.sh" "$GRUPO.." 2> /dev/null
mv "source/source.tar.gz" "$GRUPO.." 2> /dev/null


if [ "$(ls -A 'source/')" ]
  then
	echo "Este desinstalador no ha logrado mover todos los archivos fuente"
	echo "Por favor, mover manualmente los archivos de la carpeta $GRUPO""source/ a algún lugar seguro, por si quisiera instalar nuevamente el sistema"
	echo "Una vez hecho eso, vuelva a correr este desinstalador"

	exit 1
fi

echo "Desinstalando sistema CIPAK..."

GRUPO="$PWD"
cd ..
rm -rf "$GRUPO"

echo
echo "¡Desinstalación completada!"
echo

return 0
