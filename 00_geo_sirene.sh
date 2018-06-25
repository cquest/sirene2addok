COLS=$(head geo_sirene.csv -n 1 | sed 's!,! text, !g;s!.$! text!')

psql -c "DROP TABLE IF EXISTS geo_sirene; CREATE TABLE geo_sirene ($COLS);"
psql -c "\copy geo_sirene from geo_sirene.csv with (format csv, header true)"

