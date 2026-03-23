# CI/CD - Continuous Integration & Deployment

**Scope:** workflow  
**Trigger:** cuando se configure CI/CD, GitHub Actions, automatización de deployments, o pipelines  
**Tools:** view, file_create, str_replace, bash_tool  
**Version:** 1.0.0  

---

## Proposito

Esta skill te guía para implementar CI/CD en proyectos. Cubre GitHub Actions, GitLab CI, Jenkins, automated testing, builds, deployments, y mejores prácticas para entregas continuas y confiables.

## Cuando Usar Esta Skill

- Configurar CI/CD desde cero
- Automatizar tests en cada PR
- Deploy automático a staging/production
- Crear release pipelines
- Configurar quality gates
- Implementar blue-green o canary deployments

## Conceptos Fundamentales

### CI vs CD vs CD

```
CI  - Continuous Integration
      Merge code frequently + automated tests

CD  - Continuous Delivery
      Code always ready to deploy (manual trigger)

CD  - Continuous Deployment
      Automatic deployment to production
```

### Pipeline Stages

```
┌──────────┐
│  Commit  │
└────┬─────┘
     │
┌────▼─────┐
│  Build   │  Compile, transpile, bundle
└────┬─────┘
     │
┌────▼─────┐
│   Test   │  Unit, integration, E2E
└────┬─────┘
     │
┌────▼─────┐
│  Quality │  Lint, coverage, security scan
└────┬─────┘
     │
┌────▼─────┐
│  Deploy  │  Staging → Production
└────┬─────┘
     │
┌────▼─────┐
│ Monitor  │  Logs, metrics, alerts
└──────────┘
```

## GitHub Actions

### Basic Workflow

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run linter
        run: npm run lint
      
      - name: Run tests
        run: npm test -- --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/coverage-final.json
```

### Matrix Strategy

```yaml
# Test en múltiples versiones
jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        node-version: [18, 20, 21]
    
    steps:
      - uses: actions/checkout@v4
      - name: Use Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
      - run: npm ci
      - run: npm test
```

### Conditional Steps

```yaml
steps:
  - name: Deploy to staging
    if: github.ref == 'refs/heads/develop'
    run: ./deploy-staging.sh
  
  - name: Deploy to production
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    run: ./deploy-production.sh
  
  - name: Notify on failure
    if: failure()
    uses: 8398a7/action-slack@v3
    with:
      status: ${{ job.status }}
      webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### Environment Secrets

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    
    steps:
      - name: Deploy
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          API_KEY: ${{ secrets.API_KEY }}
        run: |
          echo "Deploying with secrets..."
          ./deploy.sh
```

### Docker Build & Push

```yaml
jobs:
  docker:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Login to DockerHub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: user/app:latest,user/app:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

## GitLab CI/CD

### .gitlab-ci.yml

```yaml
# .gitlab-ci.yml
stages:
  - build
  - test
  - deploy

variables:
  NODE_VERSION: "20"

# Cache dependencies
cache:
  paths:
    - node_modules/

before_script:
  - node --version
  - npm ci

build:
  stage: build
  script:
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 hour

test:unit:
  stage: test
  script:
    - npm run test:unit -- --coverage
  coverage: '/All files[^|]*\|[^|]*\s+([\d\.]+)/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml

test:integration:
  stage: test
  services:
    - postgres:14
  variables:
    POSTGRES_DB: test_db
    POSTGRES_USER: test_user
    POSTGRES_PASSWORD: test_pass
  script:
    - npm run test:integration

deploy:staging:
  stage: deploy
  script:
    - npm run deploy:staging
  environment:
    name: staging
    url: https://staging.example.com
  only:
    - develop

deploy:production:
  stage: deploy
  script:
    - npm run deploy:production
  environment:
    name: production
    url: https://example.com
  only:
    - main
  when: manual  # Requires manual approval
```

## Jenkins Pipeline

### Jenkinsfile

```groovy
// Jenkinsfile
pipeline {
    agent any
    
    environment {
        NODE_VERSION = '20'
        DOCKER_REGISTRY = 'registry.example.com'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Install') {
            steps {
                sh 'npm ci'
            }
        }
        
        stage('Lint') {
            steps {
                sh 'npm run lint'
            }
        }
        
        stage('Test') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh 'npm run test:unit'
                    }
                }
                stage('Integration Tests') {
                    steps {
                        sh 'npm run test:integration'
                    }
                }
            }
        }
        
        stage('Build') {
            steps {
                sh 'npm run build'
            }
        }
        
        stage('Docker Build') {
            steps {
                script {
                    docker.build("${DOCKER_REGISTRY}/myapp:${env.BUILD_NUMBER}")
                }
            }
        }
        
        stage('Deploy to Staging') {
            when {
                branch 'develop'
            }
            steps {
                sh './deploy-staging.sh'
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            input {
                message "Deploy to production?"
                ok "Deploy"
            }
            steps {
                sh './deploy-production.sh'
            }
        }
    }
    
    post {
        success {
            slackSend color: 'good', message: "Build succeeded: ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        }
        failure {
            slackSend color: 'danger', message: "Build failed: ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        }
        always {
            junit '**/test-results/*.xml'
            publishHTML([
                reportDir: 'coverage',
                reportFiles: 'index.html',
                reportName: 'Coverage Report'
            ])
        }
    }
}
```

## Deployment Strategies

### 1. Blue-Green Deployment

```yaml
# blue-green-deploy.yml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Green
        run: |
          # Deploy new version to green environment
          kubectl apply -f k8s/deployment-green.yml
          
          # Wait for rollout
          kubectl rollout status deployment/app-green
      
      - name: Run smoke tests
        run: |
          curl https://green.example.com/health
          npm run test:smoke -- --env=green
      
      - name: Switch traffic to Green
        run: |
          kubectl patch service app-service -p '{"spec":{"selector":{"version":"green"}}}'
      
      - name: Verify production
        run: |
          sleep 30
          curl https://example.com/health
      
      - name: Cleanup Blue
        if: success()
        run: |
          kubectl delete deployment app-blue
```

### 2. Canary Deployment

```yaml
# canary-deploy.yml
jobs:
  canary:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy canary (10%)
        run: |
          kubectl apply -f k8s/deployment-canary.yml
          kubectl scale deployment app-canary --replicas=1
          kubectl scale deployment app-stable --replicas=9
      
      - name: Monitor canary
        run: |
          sleep 300  # 5 minutes
          ERROR_RATE=$(curl -s https://metrics.example.com/error-rate)
          if [ $ERROR_RATE -gt 1 ]; then
            echo "High error rate, rolling back"
            exit 1
          fi
      
      - name: Increase canary (50%)
        run: |
          kubectl scale deployment app-canary --replicas=5
          kubectl scale deployment app-stable --replicas=5
      
      - name: Monitor again
        run: |
          sleep 300
          # Check metrics again
      
      - name: Full rollout
        run: |
          kubectl scale deployment app-canary --replicas=10
          kubectl scale deployment app-stable --replicas=0
```

### 3. Rolling Update

```yaml
# rolling-update.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 10
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 2        # 2 pods extra durante update
      maxUnavailable: 1  # Máximo 1 pod down
  template:
    spec:
      containers:
      - name: app
        image: myapp:v2
```

## Quality Gates

### SonarQube Integration

```yaml
# sonarqube.yml
jobs:
  sonarqube:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for analysis
      
      - name: SonarQube Scan
        uses: sonarsource/sonarqube-scan-action@master
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
      
      - name: SonarQube Quality Gate
        uses: sonarsource/sonarqube-quality-gate-action@master
        timeout-minutes: 5
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

### Custom Quality Checks

```yaml
jobs:
  quality-check:
    runs-on: ubuntu-latest
    steps:
      - name: Check coverage
        run: |
          COVERAGE=$(cat coverage/coverage-summary.json | jq '.total.lines.pct')
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "Coverage too low: $COVERAGE%"
            exit 1
          fi
      
      - name: Check bundle size
        run: |
          SIZE=$(stat -f%z dist/bundle.js)
          MAX_SIZE=500000  # 500KB
          if [ $SIZE -gt $MAX_SIZE ]; then
            echo "Bundle too large: $SIZE bytes"
            exit 1
          fi
      
      - name: Security scan
        run: |
          npm audit --audit-level=high
          # Will fail if high/critical vulnerabilities found
```

## Artifacts & Caching

### Artifacts

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: npm run build
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: dist-files
          path: dist/
          retention-days: 5
  
  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Download artifacts
        uses: actions/download-artifact@v4
        with:
          name: dist-files
          path: dist/
      
      - name: Deploy
        run: ./deploy.sh
```

### Caching

```yaml
steps:
  # Node modules cache
  - name: Cache node modules
    uses: actions/cache@v3
    with:
      path: node_modules
      key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
      restore-keys: |
        ${{ runner.os }}-node-
  
  # Docker layer cache
  - name: Cache Docker layers
    uses: actions/cache@v3
    with:
      path: /tmp/.buildx-cache
      key: ${{ runner.os }}-buildx-${{ github.sha }}
      restore-keys: |
        ${{ runner.os }}-buildx-
```

## Notifications

### Slack

```yaml
jobs:
  notify:
    runs-on: ubuntu-latest
    if: always()
    steps:
      - name: Slack Notification
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: |
            Deployment ${{ job.status }}
            Branch: ${{ github.ref }}
            Commit: ${{ github.sha }}
            Author: ${{ github.actor }}
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
          channel: '#deployments'
```

### Email

```yaml
- name: Send email on failure
  if: failure()
  uses: dawidd6/action-send-mail@v3
  with:
    server_address: smtp.gmail.com
    server_port: 465
    username: ${{ secrets.MAIL_USERNAME }}
    password: ${{ secrets.MAIL_PASSWORD }}
    subject: Build failed - ${{ github.repository }}
    body: |
      Build #${{ github.run_number }} failed
      Branch: ${{ github.ref }}
      Commit: ${{ github.sha }}
    to: team@example.com
```

## Best Practices

### 1. Fast Feedback

```yaml
# Run fast tests first
jobs:
  quick-checks:
    runs-on: ubuntu-latest
    steps:
      - run: npm run lint      # <10s
      - run: npm run type-check # <30s
      - run: npm run test:unit  # <2min
  
  slow-tests:
    needs: quick-checks
    runs-on: ubuntu-latest
    steps:
      - run: npm run test:integration  # 5-10min
      - run: npm run test:e2e          # 10-20min
```

### 2. Fail Fast

```yaml
strategy:
  fail-fast: true  # Stop all jobs if one fails
  matrix:
    node-version: [18, 20, 21]
```

### 3. Security

```yaml
# Never log secrets
- name: Deploy
  env:
    API_KEY: ${{ secrets.API_KEY }}
  run: |
    # ❌ DON'T: echo "API Key: $API_KEY"
    # ✅ DO: Use secrets securely
    ./deploy.sh
```

### 4. Idempotency

```bash
# Scripts should be idempotent (can run multiple times)
#!/bin/bash
set -e

# Check if already exists
if kubectl get deployment myapp; then
  kubectl apply -f deployment.yml
else
  kubectl create -f deployment.yml
fi
```

## CI/CD Checklist

- [ ] Tests run on every PR
- [ ] Linting enforced
- [ ] Coverage tracked
- [ ] Security scans (npm audit, Snyk)
- [ ] Build artifacts cached
- [ ] Staging environment exists
- [ ] Manual approval for production
- [ ] Rollback plan
- [ ] Notifications configured
- [ ] Deployment monitoring

## Best Practices

1. **Automate Everything** - Build, test, deploy
2. **Fast Pipelines** - <10min for full pipeline
3. **Fail Fast** - Quick feedback on errors
4. **Small Commits** - Easier to debug failures
5. **Version Everything** - Docker tags, artifacts
6. **Monitor Deployments** - Metrics & logs
7. **Rollback Plan** - Always have an escape hatch
8. **Security First** - Scan dependencies, secrets management
9. **Documentation** - Document pipeline setup
10. **Continuous Improvement** - Measure & optimize

---

**Última actualización:** Fase 6 - DevOps & Workflow  
**Mantenedor:** Sistema de Skills  
**Siguiente:** Deployment para llevar apps a producción
