# convert semeoz wp dump to json

fs = require 'fs',
async = require 'async'

xml2js = require 'xml2js'
parser = new xml2js.Parser()

whois = require("whois-ux").whois

YAML = require "yamljs"

url_parse = require "url-parse"


map_obj = (f,obj) ->
    res = {}
    for key,value of obj
        value = f value      
        res[key] = value unless value == ""
    return res


simplify_arrays = (obj) ->    
    if obj instanceof Array 
        return simplify_arrays obj[0] if obj.length == 1
        return obj.map simplify_arrays
    return map_obj(simplify_arrays,obj) if typeof obj is 'object'
    return obj


#whois_attributes_to_delete = "Status Nserver CountryCode PostalCode City".split " "

spawn = require('child_process').spawn

whois_skip_urls = [
    "www.google.com"
]

whois = (url,cb) ->

    hostname = url_parse(url,true).hostname
    if hostname in whois_skip_urls
        return cb null, "SKIPPED:"+hostname

    prc = spawn "whois", ["-H",hostname]
    prc.stdout.setEncoding 'utf8'
    res = []

    prc.stdout.on 'data', (data) ->
        data = data.toString().split "\n"
        for line in data
            continue if line[0] == "%"
            #break if line[0] == ">"
            res.push line

    prc.stdout.on 'close', (code) ->
        res = res.join "\n"   
        cb null, res


add_whois = (items,url_attr, cb) ->

    _add_whois = (item,cb) ->

        whois item[url_attr], (err,res) ->
            item.whois = res
            cb null,item

    async.mapLimit items, 5, _add_whois, cb


main = () ->

    fs.readFile __dirname + '/data.xml', (err, data) ->
      parser.parseString data, (err, result) ->

        result = simplify_arrays result

        items = result.rss.channel.item 

        for item in items
            item.categories = ( "#{c.$.domain}/#{c.$.nicename}" for c in item.category ).join " "
            delete item.category
 
            for meta in item["wp:postmeta"]
                key = meta["wp:meta_key"]
                value =  meta["wp:meta_value"]
                item["wp:postmeta:"+key] = value
            delete item["wp:postmeta"]
 
            delete item.guid

            item["wp:postmeta:_url_crea"]

        add_whois items, "wp:postmeta:_url_crea", (err,items) ->
            console.log JSON.stringify items, null, 2



main()
            