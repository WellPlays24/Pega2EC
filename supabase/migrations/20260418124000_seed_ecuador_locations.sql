with provinces_seed as (
  select
    province ->> 'code' as code,
    province ->> 'name' as name,
    province -> 'cantons' as cantons
  from jsonb_array_elements(
    $$[
      {"code":"ec-a","name":"Azuay","cantons":["Camilo Ponce Enríquez","Chordeleg","Cuenca","El Pan","Girón","Guachapala","Gualaceo","Nabón","Oña","Paute","Pucará","San Fernando","Santa Isabel","Sevilla de Oro","Sígsig"]},
      {"code":"ec-b","name":"Bolívar","cantons":["Caluma","Chillanes","Chimbo","Echeandía","Guaranda","Las Naves","San Miguel"]},
      {"code":"ec-f","name":"Cañar","cantons":["Azogues","Biblián","Cañar","Déleg","El Tambo","La Troncal","Suscal"]},
      {"code":"ec-c","name":"Carchi","cantons":["Bolívar","Espejo","Mira","Montúfar","San Pedro de Huaca","Tulcán"]},
      {"code":"ec-h","name":"Chimborazo","cantons":["Alausí","Chambo","Chunchi","Colta","Cumandá","Guamote","Guano","Pallatanga","Penipe","Riobamba"]},
      {"code":"ec-x","name":"Cotopaxi","cantons":["La Maná","Latacunga","Pangua","Pujilí","Salcedo","Saquisilí","Sigchos"]},
      {"code":"ec-o","name":"El Oro","cantons":["Arenillas","Atahualpa","Balsas","Chilla","El Guabo","Huaquillas","Las Lajas","Machala","Marcabelí","Pasaje","Piñas","Portovelo","Santa Rosa","Zaruma"]},
      {"code":"ec-e","name":"Esmeraldas","cantons":["Atacames","Eloy Alfaro","Esmeraldas","Muisne","Quinindé","Rioverde","San Lorenzo"]},
      {"code":"ec-w","name":"Galápagos","cantons":["Isabela","San Cristóbal","Santa Cruz"]},
      {"code":"ec-g","name":"Guayas","cantons":["Alfredo Baquerizo Moreno","Balao","Balzar","Colimes","Coronel Marcelino Maridueña","Daule","Durán","El Empalme","El Triunfo","General Antonio Elizalde","Guayaquil","Isidro Ayora","Lomas de Sargentillo","Milagro","Naranjal","Naranjito","Nobol","Palestina","Pedro Carbo","Playas","Salitre","Samborondón","San Jacinto de Yaguachi","Santa Lucía","Simón Bolívar"]},
      {"code":"ec-i","name":"Imbabura","cantons":["Antonio Ante","Cotacachi","Ibarra","Otavalo","Pimampiro","San Miguel de Urcuquí"]},
      {"code":"ec-l","name":"Loja","cantons":["Calvas","Catamayo","Celica","Chaguarpamba","Espíndola","Gonzanamá","Loja","Macará","Olmedo","Paltas","Pindal","Puyango","Quilanga","Saraguro","Sozoranga","Zapotillo"]},
      {"code":"ec-r","name":"Los Ríos","cantons":["Baba","Babahoyo","Buena Fe","Mocache","Montalvo","Palenque","Puebloviejo","Quevedo","Quinsaloma","Urdaneta","Valencia","Ventanas","Vinces"]},
      {"code":"ec-m","name":"Manabí","cantons":["Bolívar","Chone","El Carmen","Flavio Alfaro","Jama","Jaramijó","Jipijapa","Junín","Manta","Montecristi","Olmedo","Paján","Pedernales","Pichincha","Portoviejo","Puerto López","Rocafuerte","San Vicente","Santa Ana","Sucre","Tosagua","Veinticuatro de Mayo"]},
      {"code":"ec-s","name":"Morona Santiago","cantons":["Gualaquiza","Huamboya","Limón Indanza","Logroño","Morona","Pablo Sexto","Palora","San Juan Bosco","Santiago","Sevilla Don Bosco","Sucúa","Taisha","Tiwintza"]},
      {"code":"ec-n","name":"Napo","cantons":["Archidona","Carlos Julio Arosemena Tola","El Chaco","Quijos","Tena"]},
      {"code":"ec-d","name":"Orellana","cantons":["Aguarico","Francisco de Orellana","La Joya de los Sachas","Loreto"]},
      {"code":"ec-y","name":"Pastaza","cantons":["Arajuno","Mera","Pastaza","Santa Clara"]},
      {"code":"ec-p","name":"Pichincha","cantons":["Cayambe","Mejía","Pedro Moncayo","Pedro Vicente Maldonado","Puerto Quito","Quito","Rumiñahui","San Miguel de los Bancos"]},
      {"code":"ec-se","name":"Santa Elena","cantons":["La Libertad","Salinas","Santa Elena"]},
      {"code":"ec-sd","name":"Santo Domingo de los Tsáchilas","cantons":["La Concordia","Santo Domingo"]},
      {"code":"ec-u","name":"Sucumbíos","cantons":["Cascales","Cuyabeno","Gonzalo Pizarro","Lago Agrio","Putumayo","Shushufindi","Sucumbíos"]},
      {"code":"ec-t","name":"Tungurahua","cantons":["Ambato","Baños de Agua Santa","Cevallos","Mocha","Patate","Quero","San Pedro de Pelileo","Santiago de Píllaro","Tisaleo"]},
      {"code":"ec-z","name":"Zamora Chinchipe","cantons":["Centinela del Cóndor","Chinchipe","El Pangui","Nangaritza","Palanda","Paquisha","Yacuambi","Yantzaza","Zamora"]}
    ]$$::jsonb
  ) as province
),
inserted_provinces as (
  insert into public.provinces (code, name)
  select code, name
  from provinces_seed
  on conflict (code) do update
  set name = excluded.name
  returning id, code
)
insert into public.cantons (province_id, code, name)
select
  p.id,
  ps.code || '-' || lpad(c.ordinality::text, 3, '0') as code,
  c.canton_name
from provinces_seed ps
join public.provinces p on p.code = ps.code
cross join lateral jsonb_array_elements_text(ps.cantons) with ordinality as c(canton_name, ordinality)
on conflict (code) do update
set
  province_id = excluded.province_id,
  name = excluded.name;
