whois = require("whois-ux").whois
YAML = require "yamljs"
url_parse = require "url-parse"


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
