# convert wordpress dump to json

fs = require 'fs',
async = require 'async'

xml2js = require 'xml2js'
parser = new xml2js.Parser()


# map function f to obj recursively
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


flatten = (obj) ->

    data = {}

    collect_key_value_pairs = (path,obj) ->
        if obj instanceof Array
            if path.length > 0 
                path += "."
            for value,index in obj
                collect_key_value_pairs  path+index, value
            return
        if typeof obj is 'object'
            if path.length > 0 
                path += "."
            for key,value of obj
                collect_key_value_pairs path+key, value, 
            return
        data[path]=obj

    collect_key_value_pairs '',obj

    return data


l = (a...) -> console.log a

convert_xml_file_to_array = (filename,cb) ->
    fs.readFile filename, (err, data) ->
      parser.parseString data, (err, result) ->

        return cb err, null if err

        result = simplify_arrays result
        items = result.rss.channel.item 

        res = []

        for item in items

            item.categories = ( "#{c.$.domain}/#{c.$.nicename}" for c in item.category ).join " "
            delete item.category
 
            for meta in item["wp:postmeta"]
                key = meta["wp:meta_key"]
                value =  meta["wp:meta_value"]
                item["wp:postmeta:"+key] = value
            delete item["wp:postmeta"]
 
            # delete item.guid

            # delete item["wp:postmeta:_url_crea"]

            res.push flatten item

        cb null, res


main = () ->
    convert_xml_file_to_array __dirname + '/data.xml', (err,items) ->

        #  add_whois items, "wp:postmeta:_url_crea", (err,items) -> 

        console.log JSON.stringify items, null, 2

 
main()
            