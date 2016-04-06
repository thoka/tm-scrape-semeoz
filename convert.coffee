# convert wp dump to json

fs = require 'fs',
xml2js = require 'xml2js'
query = require "json-query"

parser = new xml2js.Parser()


map_obj = (f,obj) ->
    res = {}
    for key,value of obj
        #console.log "change ",key, typeof value, value  
        value = f value      
        res[key] = value unless value == ""
        #console.log "  to ", res[key]

    return res


simplify_arrays = (obj) ->    
    if obj instanceof Array 
        return simplify_arrays obj[0] if obj.length == 1
        return obj.map simplify_arrays
    return map_obj(simplify_arrays,obj) if typeof obj is 'object'
    return obj


main = () ->

    fs.readFile __dirname + '/data.xml', (err, data) ->
      parser.parseString data, (err, result) ->
        #result = JSON.parse JSON.stringify result

        result = simplify_arrays result

        items = result.rss.channel.item #.channel.items 

        #res = []

        for item in items
            item.categories = ( "#{c.$.domain}/#{c.$.nicename}" for c in item.category ).join " "
            delete item.category
 

            for meta in item["wp:postmeta"]
                key = meta["wp:meta_key"]
                value =  meta["wp:meta_value"]
                item["wp:postmeta:"+key] = value
            delete item["wp:postmeta"]
 
            delete item.guid


            #res.push item

        console.log JSON.stringify items, null, 2 

#test()

main()

            





