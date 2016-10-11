DATA_URL=http://semeoz.info/download/semeozinfo.maps.xml

curl $DATA_URL > data.xml

coffee wpXML2json.coffee  > data.json
cat data.json | json2csv > data.csv

cat data.json | jq -r '[ .[] | .categories |  split(" ") ] | add | unique |  .[] ' > tags.txt






