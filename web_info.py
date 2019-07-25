#!/usr/bin/env python
import web
import json

urls = (
    '/info', 'info'
)

app = web.application(urls, globals())

json_file = open('/service_info.json')
service_info = json.load(json_file)
json_file.close()
out = ''
for port_mapping in service_info['data']['attributes']['port-mappings'][0]:
    if port_mapping['container-port'] == 22 or port_mapping['container-port'] == 8080:
        continue
    out += '{}/{} --> {}:{}<br>'.format(port_mapping['container-port'], port_mapping['protocol'], port_mapping['host'], port_mapping['service-port'])

class info:
    def GET(self):
        return out

if __name__ == "__main__":
    app.run()
