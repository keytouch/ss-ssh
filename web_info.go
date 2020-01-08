package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"time"
)

var (
	expire    = 10 * time.Second
	url       = os.Getenv("API_URL")
	fetchTime time.Time
	data      struct {
		Data struct {
			Attributes struct {
				Port_mappings [][]struct {
					Container_port int `json:"container-port"`
					Host           string
					Protocol       string
					Service_port   int `json:"service-port"`
				} `json:"port-mappings"`
			}
		}
	}
)

func update() {
	res, err := http.Get(url)
	if err != nil {
		log.Println(err)
		return
	}
	defer res.Body.Close()
	decoder := json.NewDecoder(res.Body)
	err = decoder.Decode(&data)
	if err != nil {
		log.Println(err)
		return
	}
	log.Printf("updated: %v", &data)
	fetchTime = time.Now()
	for i, instance := range data.Data.Attributes.Port_mappings { // filter
		for j, mapping := range instance {
			switch mapping.Container_port {
			case 22:
				fallthrough
			case 8080:
				data.Data.Attributes.Port_mappings[i] = append(data.Data.Attributes.Port_mappings[i][:j], data.Data.Attributes.Port_mappings[i][j+1:]...)
			}
		}
	}
}

func web_info(w http.ResponseWriter, req *http.Request) {
	log.Printf("From: %s %s", req.RemoteAddr, req.Header.Get("X-Forwarded-For"))
	if fetchTime.IsZero() || fetchTime.Add(expire).Before(time.Now()) {
		update()
	}
	buf, err := json.Marshal(&data.Data.Attributes)
	if err != nil {
		log.Println(err)
		return
	}
	log.Printf("sent: %s", buf)
	w.Write(buf)
}

func main() {
	http.HandleFunc("/web_info", web_info)
	http.ListenAndServe(":8080", nil)
}
