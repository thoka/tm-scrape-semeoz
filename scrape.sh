# get data
# https://discourse.transformap.co/t/semeoz-inventory-of-maps/916/16

DATA_URL=http://semeoz.info/download/semeozinfo.maps.xml

curl $DATA_URL > data.xml

coffee convert.coffee | json2csv > data.csv







