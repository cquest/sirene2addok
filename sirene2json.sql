-- transformation des sigles utilisant des initiales: S.A.R.L -> SARL
with u as (select lib, trim(ini[1]) as ini, format('%s (%s)',trim(ini[1]),trim(replace(ini[1],'.',''))) as court
		from (select nomen_long as lib, regexp_matches(nomen_long,'(([A-Z]\.){3,10})','g') as ini from geo_sirene) as l)
	update geo_sirene set nomen_long = replace(nomen_long, ini, court) from u where nomen_long = lib;
with u as (select lib, trim(ini[1]) as ini, format('%s (%s)',trim(ini[1]),trim(replace(ini[1],'.',''))) as court
		from (select nomen_long as lib, regexp_matches(nomen_long,'(([A-Z]\.){2,10}[A-Z] )','g') as ini from geo_sirene) as l)
	update geo_sirene set nomen_long = replace(nomen_long, ini, court) from u where nomen_long = lib;
with u as (select lib, trim(ini[1]) as ini, format('%s (%s)',trim(ini[1]),trim(replace(ini[1],'.',''))) as court
		from (select nomen_long as lib, regexp_matches(nomen_long,'(([A-Z]\.){2,10}[A-Z]$)','g') as ini from geo_sirene) as l)
	update geo_sirene set nomen_long = replace(nomen_long, ini, court) from u where nomen_long = lib;

-- export json pour addok
\copy (select row_to_json(poi.*) from ( select siren||nic as id, nomen_long || coalesce(' - '||enseigne,'') as name,
		format('%s - %s - %s', libelle_naf, l4_normalisee,l6_normalisee) as context, depet||comet as citycode,
		latitude as lat, longitude as lon, 'sirene 2018-04' as source, 'siret' as poi
	from geo_sirene s where nj !~ '^(2|65|8|9)' group by 1,2,3,4,5,6,7) as poi) to sirene.json

-- export avec filtrage et dédoublonnage
\copy (select row_to_json(poi.*) from (select siren||nic as id,
		string_to_array(case	when enseigne is not null and nomen_long != enseigne and nomen_long NOT LIKE '%*%' then format('%s,%s',enseigne,nomen_long)
			when enseigne is not null then enseigne when nomen_long not like '%*%' then nomen_long
			else '' end || coalesce(','||regexp_replace(sigle,'[^A-Z0-9]','','g'),'') || ',' || libapet,',') as name,
		format('%s, %s (%s)',l4_normalisee, l6_normalisee, libapet) as context, depet||comet as citycode, c.nom as city,
		latitude as lat, longitude as lon, 'siret' as type, apen700 as poi,
		format('%s, %s',nomdep, nomreg) as context,
		replace(tefen,'NN','00')::numeric /1000 as importance,
		'sirene 2018-04' as source
	from geo_sirene_geo g
	join osm_communes_2017 c on (insee=depet||comet)
	join cog on (depcom=depet||comet)
	where latitude is not null and longitude is not null and depet='75') as poi)
to sirene_poi.json;
