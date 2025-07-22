#!/bin/bash

set -e

echo "Criando diretórios..."
mkdir -p prometheus grafana loki

echo "Criando arquivo prometheus.yml..."
cat <<EOF > prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']
  - job_name: 'otel-collector'
    static_configs:
      - targets: ['otel-collector:8888']
EOF

echo "Criando arquivo loki-config.yaml..."
cat <<EOF > loki/loki-config.yaml
auth_enabled: false

server:
  http_listen_port: 3100

ingester:
  lifecycler:
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
  chunk_idle_period: 5m
  max_chunk_age: 1h
  chunk_target_size: 1048576

schema_config:
  configs:
    - from: 2024-01-01
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h

storage_config:
  boltdb_shipper:
    active_index_directory: /loki/index
    cache_location: /loki/boltdb-cache
    shared_store: filesystem
  filesystem:
    directory: /loki/chunks

limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h
  max_entries_limit_per_query: 10000

chunk_store_config:
  max_look_back_period: 0s

table_manager:
  retention_deletes_enabled: true
  retention_period: 120h
EOF

echo "Criando arquivo otel-config.yaml..."
cat <<EOF > otel-config.yaml
receivers:
  otlp:
    protocols:
      grpc:
      http:

exporters:
  logging:
    loglevel: debug
  prometheus:
    endpoint: "0.0.0.0:8888"
  loki:
    endpoint: "http://loki:3100/loki/api/v1/push"

service:
  pipelines:
    metrics:
      receivers: [otlp]
      exporters: [logging, prometheus]
    traces:
      receivers: [otlp]
      exporters: [logging]
    logs:
      receivers: [otlp]
      exporters: [loki]
EOF

echo "Criando docker-compose.yml..."
cat <<EOF > docker-compose.yml
version: "3.8"

services:
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana-enterprise
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
    depends_on:
      - prometheus
      - loki

  loki:
    image: grafana/loki:2.9.3
    ports:
      - "3100:3100"
    volumes:
      - ./loki/loki-config.yaml:/etc/loki/loki-config.yaml
    command: -config.file=/etc/loki/loki-config.yaml

  node-exporter:
    image: prom/node-exporter
    ports:
      - "9100:9100"

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    ports:
      - "8081:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /dev/disk/:/dev/disk:ro
    read_only: false
    security_opt:
      - no-new-privileges:true

  otel-collector:
    image: ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib:0.98.0
    command: ["--config=/etc/otel-collector/config.yaml"]
    volumes:
      - ./otel-config.yaml:/etc/otel-collector/config.yaml:ro
    ports:
      - "4317:4317"
      - "4318:4318"
      - "8888:8888"

volumes:
  grafana_data:
EOF

echo "Stack criada com sucesso!"
echo "Subindo containers com docker compose..."
docker compose up -d

