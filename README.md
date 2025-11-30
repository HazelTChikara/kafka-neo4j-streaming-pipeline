# Kafka-Neo4j Streaming Pipeline

A scalable, real-time data processing pipeline built with Kubernetes, Apache Kafka, and Neo4j for streaming graph analytics. This distributed system ingests NYC taxi trip data through Kafka message queues, processes events in real-time using Kafka Connect, and stores relationships in a Neo4j graph database for advanced analytics.

## Key Features
- 🚀 **Microservices Architecture**: Deployed on Kubernetes (Minikube) with separate pods for Zookeeper, Kafka, Neo4j, and Kafka Connect
- 📊 **Real-Time Data Ingestion**: Kafka-based streaming pipeline with automatic topic creation and message processing
- 🔗 **Graph Data Storage**: Neo4j graph database with GDS (Graph Data Science) library for PageRank and BFS analytics
- ⚡ **High Availability**: Containerized services with health probes, resource management, and automatic recovery
- 🔧 **Production-Ready**: Configured with proper networking, persistent storage, and service discovery

## Tech Stack
- **Orchestration**: Kubernetes, Minikube, Helm
- **Messaging**: Apache Kafka 7.3.3, Zookeeper
- **Database**: Neo4j 2025.10.1 with Graph Data Science plugin
- **Integration**: Kafka Connect with Neo4j Sink Connector
- **Data Processing**: Python (Confluent-Kafka, Pandas, PyArrow)

## Use Case
Processes streaming NYC taxi trip data to build location-based trip graphs, enabling spatial analytics, route optimization, and demand forecasting.

## Architecture
```
Data Producer → Kafka → Kafka Connect → Neo4j Graph Database
                 ↑
            Zookeeper
```

## Deployment
The system consists of 4 main components deployed via YAML configurations:
1. `zookeeper-setup.yaml` - Coordination service
2. `kafka-setup.yaml` - Message broker
3. `neo4j-values.yaml` - Graph database (Helm)
4. `kafka-neo4j-connector.yaml` - Stream processor

## Getting Started

### Prerequisites
- Docker Desktop
- Minikube
- kubectl
- Helm
- Python 3.x

### Deploy
```bash
# Start Minikube
minikube start

# Deploy components
kubectl apply -f zookeeper-setup.yaml
kubectl apply -f kafka-setup.yaml
helm repo add neo4j https://helm.neo4j.com/neo4j
helm install my-neo4j-release neo4j/neo4j -f neo4j-values.yaml
kubectl apply -f kafka-neo4j-connector.yaml

# Port forwarding
kubectl port-forward svc/kafka-service 9092:9092 &
kubectl port-forward svc/my-neo4j-release 7474:7474 7687:7687 &
```

### Test
```bash
python3 tester.py
```

## Project Structure
```
.
├── zookeeper-setup.yaml          # Zookeeper deployment
├── kafka-setup.yaml               # Kafka broker deployment
├── neo4j-values.yaml              # Neo4j Helm values
├── kafka-neo4j-connector.yaml     # Kafka Connect deployment
├── data_producer.py               # Stream data producer
├── tester.py                      # Integration test suite
└── README.md
```

## License
Academic project for CSE 511 - Data Processing at Scale
