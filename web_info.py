#!/usr/bin/env python
import datetime
import json
import os

import requests
import web

ttl = datetime.timedelta(minutes=5)


class ServiceInfo:
    def __init__(self, url):
        self.data = None
        self.url = url
        self.expir = datetime.datetime(1, 1, 1, 0, 0, 0, 0)

    def update(self):
        try:
            r = requests.get(self.url)
        except requests.exceptions.RequestException as e:
            print(e)
        else:
            if r.status_code == requests.codes.ok:
                self.data = r.json()
                self.expir = datetime.datetime.now() + ttl

    def get_data(self):
        if self.expir < datetime.datetime.now():
            self.update()
        return self.data

    def get_portmapping(self):
        portmappings = []
        data = self.get_data()
        if data is not None:  # if no error
            for instance in data['data']['attributes']['port-mappings']:
                for port_mapping in instance:
                    if port_mapping['container-port'] == 22 or port_mapping['container-port'] == 8080:
                        continue
                    portmappings.append(port_mapping)
        return portmappings


class info:
    def GET(self):
        web.header('Content-Type', 'application/json; charset=utf-8')
        portmapping = service_info.get_portmapping()
        return json.dumps(portmapping, separators=(',', ':'))


urls = (
    '/info', 'info'
)
app = web.application(urls, {'info': info})
url = os.getenv('API_URL')
service_info = ServiceInfo(url)

if __name__ == "__main__":
    app.run()
