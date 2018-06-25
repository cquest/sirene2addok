# liste des départements à traiter
DEPTS="75101 75102 75103 75104 75105 75106 75107 75108 75109 75110 75111 75112 75113 75114 75115 75116 75117 75118 75119 75120 77 78 91 92 93 94 95"

cd data
for d in $DEPTS
do
  wget -nc "http://212.47.238.202/geo_sirene/last/geo-sirene_$d.csv.7z"
  7z e -y geo-sirene_$d.csv.7z &
done

for d in $DEPTS
do
cd ..

done


# codes NAF
wget -nc https://www.insee.fr/fr/statistiques/fichier/2120875/naf2008_liste_n5.xls
in2csv naf2008_liste_n5.xls | tail -n +3 > naf.csv
psql -c "CREATE TABLE  IF NOT EXISTS sirene_naf (code_naf text,libelle_naf text); TRUNCATE sirene_naf;"
psql -c "\copy sirene_naf from naf.csv with (format csv, header true)"
psql -c "UPDATE sirene_naf SET code_naf = replace(code_naf,'.','');"

# nettoyage libellés et export json pour addok
psql < sirene2json.sql
