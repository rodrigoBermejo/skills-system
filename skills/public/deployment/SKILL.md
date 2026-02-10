# Deployment - Production Deployment Strategies

**Scope:** workflow  
**Trigger:** cuando se despliegue a producción, se configure hosting, Docker, Kubernetes, o cloud deployment  
**Tools:** view, file_create, str_replace, bash_tool  
**Version:** 1.0.0  

---

## 🎯 Propósito

Esta skill te guía para desplegar aplicaciones a producción. Cubre Docker, Kubernetes, cloud providers (AWS, Azure, GCP), serverless, static hosting, databases, monitoring y mejores prácticas para deployments confiables y escalables.

## 🔧 Cuándo Usar Esta Skill

- Deploy inicial a producción
- Configurar infraestructura cloud
- Dockerizar aplicaciones
- Orquestar con Kubernetes
- Configurar CDN y caching
- Setup de monitoring y logs
- Implementar auto-scaling
- Disaster recovery planning

## 🐳 Docker

### Dockerfile para Node.js

```dockerfile
# Multi-stage build
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source
COPY . .

# Build
RUN npm run build

# Production stage
FROM node:20-alpine

WORKDIR /app

# Copy only necessary files
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001
USER nodejs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js

# Start app
CMD ["node", "dist/main.js"]
```

### Dockerfile para Python

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app
COPY . .

# Non-root user
RUN useradd -m -u 1000 appuser && chown -R appuser /app
USER appuser

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### docker-compose.yml

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://postgres:password@db:5432/myapp
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped
  
  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
  
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

### Commands

```bash
# Build image
docker build -t myapp:latest .

# Run container
docker run -d -p 3000:3000 --name myapp myapp:latest

# View logs
docker logs -f myapp

# Execute command in container
docker exec -it myapp sh

# Stop and remove
docker stop myapp && docker rm myapp

# Docker compose
docker-compose up -d
docker-compose logs -f
docker-compose down
```

## ☸️ Kubernetes

### Deployment

```yaml
# deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  labels:
    app: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myregistry/myapp:v1.2.3
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: production
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: myapp-secrets
              key: database-url
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
```

### Service

```yaml
# service.yml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
  type: LoadBalancer
```

### Ingress

```yaml
# ingress.yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - myapp.example.com
    secretName: myapp-tls
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp-service
            port:
              number: 80
```

### ConfigMap & Secret

```yaml
# configmap.yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapp-config
data:
  LOG_LEVEL: "info"
  MAX_CONNECTIONS: "100"

---
# secret.yml
apiVersion: v1
kind: Secret
metadata:
  name: myapp-secrets
type: Opaque
stringData:
  database-url: "postgresql://user:pass@host:5432/db"
  api-key: "secret-api-key"
```

### HorizontalPodAutoscaler

```yaml
# hpa.yml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

### Commands

```bash
# Apply configurations
kubectl apply -f deployment.yml
kubectl apply -f service.yml
kubectl apply -f ingress.yml

# Get resources
kubectl get pods
kubectl get services
kubectl get deployments

# Logs
kubectl logs -f <pod-name>
kubectl logs -f deployment/myapp

# Execute command
kubectl exec -it <pod-name> -- sh

# Scale
kubectl scale deployment myapp --replicas=5

# Rollout
kubectl rollout status deployment/myapp
kubectl rollout history deployment/myapp
kubectl rollout undo deployment/myapp
```

## ☁️ Cloud Providers

### AWS (Amazon Web Services)

**Services:**
- **EC2** - Virtual machines
- **ECS/Fargate** - Container orchestration
- **Lambda** - Serverless functions
- **RDS** - Managed databases
- **S3** - Object storage
- **CloudFront** - CDN
- **Route 53** - DNS

**Deploy Node.js to Elastic Beanstalk:**
```bash
# Install EB CLI
pip install awsebcli

# Initialize
eb init

# Create environment
eb create production

# Deploy
eb deploy

# Open app
eb open
```

### Vercel (Frontend/Next.js)

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel

# Production
vercel --prod

# Environment variables
vercel env add DATABASE_URL production
```

**vercel.json:**
```json
{
  "builds": [
    {
      "src": "package.json",
      "use": "@vercel/node"
    }
  ],
  "routes": [
    {
      "src": "/api/(.*)",
      "dest": "/api/$1"
    }
  ],
  "env": {
    "NODE_ENV": "production"
  }
}
```

### Netlify (Static/JAMstack)

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Login
netlify login

# Deploy
netlify deploy

# Production
netlify deploy --prod
```

**netlify.toml:**
```toml
[build]
  command = "npm run build"
  publish = "dist"

[[redirects]]
  from = "/api/*"
  to = "https://api.example.com/:splat"
  status = 200

[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-XSS-Protection = "1; mode=block"
```

### Heroku

```bash
# Login
heroku login

# Create app
heroku create myapp

# Add buildpack
heroku buildpacks:set heroku/nodejs

# Set environment variables
heroku config:set NODE_ENV=production
heroku config:set DATABASE_URL=postgres://...

# Deploy
git push heroku main

# Logs
heroku logs --tail

# Scale
heroku ps:scale web=3
```

**Procfile:**
```
web: node dist/main.js
worker: node dist/worker.js
```

### DigitalOcean

**App Platform:**
```yaml
# .do/app.yaml
name: myapp
services:
- name: web
  github:
    repo: username/myapp
    branch: main
    deploy_on_push: true
  build_command: npm run build
  run_command: npm start
  environment_slug: node-js
  instance_count: 2
  instance_size_slug: basic-xs
  envs:
  - key: NODE_ENV
    value: production
  - key: DATABASE_URL
    value: ${db.DATABASE_URL}
databases:
- name: db
  engine: PG
  version: "14"
```

## 🗄️ Database Deployment

### PostgreSQL on AWS RDS

```bash
# Create RDS instance
aws rds create-db-instance \
  --db-instance-identifier myapp-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username admin \
  --master-user-password $DB_PASSWORD \
  --allocated-storage 20

# Get connection string
aws rds describe-db-instances \
  --db-instance-identifier myapp-db \
  --query 'DBInstances[0].Endpoint'
```

### MongoDB Atlas

```javascript
// Connection string
const uri = "mongodb+srv://user:pass@cluster.mongodb.net/mydb?retryWrites=true&w=majority";

// Environment variable
DATABASE_URL=mongodb+srv://...
```

### Migrations in Production

```bash
# ✅ Safe approach
# 1. Backup database
pg_dump -h host -U user dbname > backup.sql

# 2. Test migrations in staging
npm run migrate:staging

# 3. Apply to production
npm run migrate:production

# 4. Verify
psql -h host -U user -d dbname -c "SELECT version FROM migrations"
```

## 📊 Monitoring & Logging

### Prometheus + Grafana

```yaml
# docker-compose.monitoring.yml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
  
  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana

volumes:
  prometheus_data:
  grafana_data:
```

### Application Metrics

```javascript
// Express + Prometheus
const promClient = require('prom-client');
const express = require('express');

// Create metrics
const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code']
});

// Middleware
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    httpRequestDuration.labels(req.method, req.route?.path, res.statusCode).observe(duration);
  });
  next();
});

// Metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', promClient.register.contentType);
  res.end(await promClient.register.metrics());
});
```

### Structured Logging

```javascript
// Winston
const winston = require('winston');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' }),
  ],
});

if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.simple(),
  }));
}

// Usage
logger.info('User logged in', { userId: 123, ip: req.ip });
logger.error('Database connection failed', { error: err.message });
```

## 🔐 Security Best Practices

### Environment Variables

```bash
# ❌ DON'T commit .env files
# ✅ Use secret management

# AWS Secrets Manager
aws secretsmanager get-secret-value --secret-id myapp/prod

# Kubernetes Secrets
kubectl create secret generic myapp-secrets \
  --from-literal=DATABASE_URL='postgres://...' \
  --from-literal=API_KEY='secret'

# Docker secrets
echo "secret_value" | docker secret create api_key -
```

### SSL/TLS

```nginx
# nginx.conf
server {
    listen 443 ssl http2;
    server_name example.com;
    
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
    
    # Strong SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    location / {
        proxy_pass http://app:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 🚨 Rollback Strategy

```bash
# Kubernetes
# Rollback to previous version
kubectl rollout undo deployment/myapp

# Rollback to specific revision
kubectl rollout undo deployment/myapp --to-revision=2

# Docker Swarm
docker service update --rollback myapp

# Heroku
heroku releases:rollback v123
```

## 📋 Deployment Checklist

**Pre-deployment:**
- [ ] All tests passing
- [ ] Code review approved
- [ ] Environment variables configured
- [ ] Database migrations tested
- [ ] Backup created
- [ ] Rollback plan documented

**Deployment:**
- [ ] Deploy to staging first
- [ ] Run smoke tests
- [ ] Monitor logs and metrics
- [ ] Gradual rollout (canary)
- [ ] Verify health checks

**Post-deployment:**
- [ ] Monitor error rates
- [ ] Check application metrics
- [ ] Verify critical flows
- [ ] Update documentation
- [ ] Notify team

## 🎓 Best Practices

1. **Immutable Infrastructure** - Never modify running servers
2. **Blue-Green Deployments** - Zero-downtime updates
3. **Health Checks** - Automated health monitoring
4. **Auto-scaling** - Scale based on metrics
5. **Monitoring** - Logs, metrics, alerts
6. **Security** - Secrets management, SSL/TLS
7. **Backups** - Automated and tested
8. **Disaster Recovery** - Plan and practice
9. **Documentation** - Runbooks for common issues
10. **Cost Optimization** - Monitor and optimize spend

---

**Última actualización:** Fase 6 - DevOps & Workflow  
**Mantenedor:** Sistema de Skills  
**¡SISTEMA COMPLETO!** 🎉
