#!/usr/bin/env python
import datetime
import json
import os

import requests
import web

ttl = datetime.timedelta(minutes=5)


class ServiceInfo:
    def __init__(self, url):
        self.data = []
        self.url = url
        self.expir = datetime.datetime(1, 1, 1, 0, 0, 0, 0)

    def update(self):
        try:
            r = requests.get(self.url)
        except requests.exceptions.RequestException as e:
            print(e)
        else:
            if r.status_code != requests.codes.ok:
                return
            data = r.json()
            try:
                data = data['data']['attributes']['port-mappings']
            except Exception as e:
                print(type(e).__name__ + ': ' + str(e))
            else:  # if no error
                if data is not None:
                    self.data = []
                    self.expir = datetime.datetime.now() + ttl
                    for instance in data:
                        for port_mapping in instance:
                            if port_mapping['container-port'] == 22 or port_mapping['container-port'] == 8080:
                                continue
                            self.data.append(port_mapping)

    def get_data(self):
        if self.expir < datetime.datetime.now():
            self.update()
        return self.data


class info:
    def GET(self):
        web.header('Content-Type', 'application/json; charset=utf-8')
        web.header('Cache-Control', 'no-cache, max-age=0, must-revalidate, no-store')
        data = service_info.get_data()
        return json.dumps(data, separators=(',', ':'))


urls = (
    '/info', 'info'
)
app = web.application(urls, {'info': info})
url = os.getenv('API_URL')
service_info = ServiceInfo(url)

if __name__ == "__main__":
    app.run()
