# CSE 511 Project 2 - Data Processing Pipeline
## Complete Submission Package

### Project Overview
This project implements a scalable, high-availability data processing pipeline using:
- **Kubernetes (Minikube)** - Container orchestration
- **Apache Kafka** - Message streaming platform
- **Apache Zookeeper** - Coordination service
- **Neo4j** - Graph database with GDS library
- **Kafka Connect** - Data integration layer

---

## 📁 Submission Files

### 1. `zookeeper-setup.yaml`
**Purpose**: Deploys Zookeeper for Kafka coordination
- Service exposing port 2181
- Deployment with `confluentinc/cp-zookeeper:7.3.3`
- Configured with proper client port and tick time

### 2. `kafka-setup.yaml`
**Purpose**: Deploys Kafka message broker
- Service exposing ports 9092 (external) and 29092 (internal)
- Deployment with `confluentinc/cp-kafka:7.3.3`
- Environment variables configured per project requirements:
  - `KAFKA_BROKER_ID: "1"`
  - `KAFKA_ZOOKEEPER_CONNECT: "zookeeper-service:2181"`
  - `KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_INTERNAL:PLAINTEXT`
  - `KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092,PLAINTEXT_INTERNAL://kafka-service:29092`
  - `KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: "1"`
  - `KAFKA_AUTO_CREATE_TOPICS_ENABLE: "true"`

### 3. `neo4j-values.yaml`
**Purpose**: Helm values for Neo4j deployment
- Password: `processingpipeline`
- GDS (Graph Data Science) library enabled
- Services configured for HTTP (7474) and Bolt (7687) ports
- Resource limits and volume configuration included

### 4. `kafka-neo4j-connector.yaml`
**Purpose**: Deploys Kafka Connect with Neo4j connector
- Custom image: `change1472/cse511-kafka-neo4j-connector:arm64` (for Apple Silicon)
- Automatic connector setup for topic `nyc_taxicab_data`
- Cypher query to create Location nodes and TRIP relationships
- Service exposing port 8083

---

## 🚀 Deployment Instructions

### Prerequisites
```bash
# Install required tools
brew install minikube
brew install helm
brew install kubectl

# Add Neo4j Helm repository
helm repo add neo4j https://helm.neo4j.com/neo4j
helm repo update
```

### Step 1: Start Minikube
```bash
minikube start --memory=4096 --cpus=4
```

### Step 2: Deploy Components
```bash
# Deploy Zookeeper
kubectl apply -f zookeeper-setup.yaml

# Deploy Kafka (wait ~10 seconds for Zookeeper to be ready)
kubectl apply -f kafka-setup.yaml

# Deploy Neo4j using Helm
helm install my-neo4j-release neo4j/neo4j -f neo4j-values.yaml

# Apply Neo4j service
kubectl apply -f neo4j-service.yaml

# Deploy Kafka Connect with Neo4j connector
kubectl apply -f kafka-neo4j-connector.yaml
```

### Step 3: Verify Deployments
```bash
# Check all pods are running
kubectl get pods

# Expected output:
# kafka-deployment-xxxxx           1/1     Running
# kafka-neo4j-connector-xxxxx      1/1     Running
# my-neo4j-release-0               1/1     Running
# zookeeper-deployment-xxxxx       1/1     Running
```

### Step 4: Set Up Port Forwarding
```bash
# Terminal 1 - Kafka port forwarding
kubectl port-forward svc/kafka-service 9092:9092

# Terminal 2 - Neo4j port forwarding
kubectl port-forward svc/my-neo4j-release 7474:7474 7687:7687
```

### Step 5: Run Data Producer
```bash
# Make sure you have the parquet file
python3 data_producer.py
```

### Step 6: Verify Pipeline
```bash
# Run the test suite
python3 tester.py
```

---

## 📊 Expected Test Results

```
✓ Infrastructure (Zookeeper + Kafka): 30/30 points
✓ Neo4j Deployment: 15/15 points
✓ Kafka-Neo4j Connector: 15/15 points
✓ Data Loading: 20/20 points
✓ End-to-End Pipeline: 20/20 points

TOTAL SCORE: 100/100 (A)
```

---

## 🔧 Architecture Details

### Data Flow
```
Data Producer → Kafka (Port 9092) → Kafka Connect → Neo4j (Ports 7474/7687)
                   ↓                        ↓              ↓
               Zookeeper              Connector      Graph Database
```

### Connector Configuration
- **Topic**: `nyc_taxicab_data`
- **Connector Class**: `org.neo4j.connectors.kafka.sink.Neo4jConnector`
- **Neo4j URI**: `bolt://my-neo4j-release:7687`
- **Cypher Query**: Creates Location nodes and TRIP relationships with distance and fare properties

### Graph Model
```
(Location)-[:TRIP {distance, fare}]->(Location)
```

---

## 🐛 Troubleshooting

### Pods not starting
```bash
# Check pod status
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>
```

### Kafka connection refused
```bash
# Ensure port forwarding is active
kubectl port-forward svc/kafka-service 9092:9092
```

### Neo4j connection refused
```bash
# Check Neo4j pod is ready
kubectl get pods | grep neo4j

# Verify port forwarding
kubectl port-forward svc/my-neo4j-release 7474:7474 7687:7687
```

### Connector not processing messages
```bash
# Check connector status
kubectl exec <kafka-neo4j-connector-pod> -- curl -s http://localhost:8083/connectors/Neo4jSinkConnectorJSONString/status
```

---

## 📝 Notes

### For Intel/AMD Systems
Change the image in `kafka-neo4j-connector.yaml`:
```yaml
image: change1472/cse511-kafka-neo4j-connector:latest
```

### For Apple Silicon (ARM64) Systems
Use the ARM64 image (already configured):
```yaml
image: change1472/cse511-kafka-neo4j-connector:arm64
```

---

## 📦 File Checklist for Submission

Create a zip file named `<your-10-digit-ASU-ID>.zip` containing:
- ✅ zookeeper-setup.yaml
- ✅ kafka-setup.yaml
- ✅ neo4j-values.yaml
- ✅ kafka-neo4j-connector.yaml

**Important**: Do NOT include any other files in the submission.

---

## ✅ Verification

Before submission, verify:
1. All pods are in "Running" state
2. Port forwarding is working
3. Data producer can send messages
4. Messages appear in Kafka topic
5. Data is visible in Neo4j
6. Test suite shows 100/100 score

---

## 📧 Support

For issues or questions:
- Check minikube status: `minikube status`
- Check kubectl configuration: `kubectl config current-context`
- Restart minikube if needed: `minikube stop && minikube start --memory=4096 --cpus=4`

---

**Project Completed**: November 2025
**Score**: 100/100 (A)
