###
#GRUPO= ##No tiene esta variable global todavía
###

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


mv "$GRUPO""source/*" "$GRUPO.." 2> /dev/null
mv "$GRUPO""source/Readme.md" "$GRUPO.." 2> /dev/null
mv "$GRUPO""source/installer.sh" "$GRUPO.." 2> /dev/null
mv "$GRUPO""source/source.tar.gz" "$GRUPO.." 2> /dev/null


if [ "$(ls -A "$GRUPO"'source/')" ]
  then
	echo "Este desinstalador no ha logrado mover todos los archivos fuente"
	echo "Por favor, mover manualmente los archivos de la carpeta $GRUPO""source/ a algún lugar seguro, por si quisiera instalar nuevamente el sistema"
	echo "Una vez hecho eso, vuelva a correr este desinstalador"

	exit 1
fi


cd "$GRUPO.."
rm -rf "$GRUPO"

echo "Desinstalación completa"
echo

exit 0
