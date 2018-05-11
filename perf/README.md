# Recording data

Use [psrecord](https://github.com/astrofrog/psrecord) to collect and graph the data e.g.

```psrecord 92467 --interval 1 --duration 60 --plot read.png``` 

# x86 performance tests


## InfluxDB

Includes Influx config file and commands to run Apache Benchmark tool. Connect to Influx and create a database called 'db1' before running the tests.

## ZestDB

Includes Zest commands to run the test client. Make sure debugging is turned off on the server.


# pi3 performance tests

Reduce the iteration (loop count) by a factor of 10 in the included scripts.

## InfluxDB

Run via Hypriot (aarch64)

```docker run -d -p 8086:8086 hypriot/rpi-influxdb```

## ZestDB

Running the server

```docker run -p 5555:5555 -p 5556:5556 -d --name zest --rm jptmoore/zestdb:aarch64 /home/databox/server.exe --secret-key-file example-server-key```

Writing data

```time docker run --network host -it jptmoore/zestdb:aarch64 /home/databox/client.exe --server-key 'vl6wu0A@XP?}Or/&BR#LSxn>A+}L)p44/W[wXL3<' --path '/ts/sensor' --mode post --payload '{"value": 42}' --loop 10000 --freq 0.0```

Reading data

```time docker run --network host -it jptmoore/zestdb:aarch64 /home/databox/client.exe --server-key 'vl6wu0A@XP?}Or/&BR#LSxn>A+}L)p44/W[wXL3<' --path '/ts/sensor/last/100' --mode get --loop 1000 --freq 0.0```