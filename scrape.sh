# get data
# https://discourse.transformap.co/t/semeoz-inventory-of-maps/916/16

DATA_URL=http://semeoz.info/bdd/semeozinfo.wordpress.2016-04-04.xml

curl $DATA_URL > data.xml

coffee convert.coffee | json2csv > data.csv







