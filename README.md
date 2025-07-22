# Centralizador de Logs e Monitoramento com Docker

Este projeto tem como objetivo criar uma stack completa e funcional para **monitoramento, visualização de métricas e centralização de logs**, utilizando contêineres Docker e ferramentas open-source consolidadas no mercado.

---

## 💡 Propósito

A proposta principal é fornecer um ambiente simples, reprodutível e funcional para **observabilidade** em ambientes Linux. Ele permite monitorar servidores, containers, serviços e coletar logs e métricas para análise em tempo real com visualizações no Grafana.

O foco está em facilitar a implantação e o uso de uma stack de observabilidade **sem necessidade de configurações complexas**, permitindo que profissionais de infraestrutura, DevOps e desenvolvedores tenham visibilidade do ambiente.

---

## 📦 Ferramentas Utilizadas

A stack inclui os seguintes serviços:

| Ferramenta         | Finalidade |
|--------------------|-----------|
| **Prometheus**     | Coleta de métricas dos serviços monitorados (como Node Exporter e cAdvisor). |
| **Grafana**        | Visualização de dashboards com métricas e logs centralizados. |
| **Loki**           | Armazenamento e consulta de logs. Funciona em conjunto com Promtail. |
| **Promtail**       | Leitor de arquivos de log do sistema e envio ao Loki. |
| **Node Exporter**  | Exporta métricas de hardware e do sistema operacional. |
| **cAdvisor**       | Exporta métricas de containers Docker em execução. |
| **OpenTelemetry Collector** | Agente para recebimento, transformação e exportação de métricas, logs e traces. |

---

## 📁 Estrutura do Projeto

```bash
.
├── docker-compose.yml
├── centralizador_observabilidade.sh
├── prometheus/
│   └── prometheus.yml
├── loki/
│   └── loki-config.yaml
├── otel-config.yaml
├── promtail-config.yaml

🚀 Como Utilizar
git clone https://github.com/marcospaulopitta/logs_e_monitoracao.git
cd logs_e_monitoracao
chmod +x centralizador_observabilidade.sh
./centralizador_observabilidade.sh

Acessar os serviços
Serviço	Endereço padrão
Grafana	http://localhost:3000
Prometheus	http://localhost:9090
Loki API	http://localhost:3100
cAdvisor	http://localhost:8081
Node Exporter	http://localhost:9100

Login padrão do Grafana:

usuário: admin
senha: admin

🔄 Referências e Inspirações
Este projeto foi inspirado e adaptado a partir de implementações de código aberto, com agradecimento especial aos seguintes repositórios:
wlcamargo/opentelemetry
EsleyLeal/monitoring-server-setup

📌 Observações
Os arquivos .yaml já estão configurados com targets básicos para os serviços.
O OpenTelemetry Collector está preparado para receber métricas, logs e traces por OTLP (gRPC/HTTP).
O projeto não depende de recursos pagos ou ferramentas proprietárias.

