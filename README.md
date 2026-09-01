# GitOps Demo Application

A simple Python Flask application demonstrating an end-to-end GitOps deployment workflow using GitHub Actions, Docker, Kubernetes, Argo CD, and Trivy.

## Project Overview

This project demonstrates how a code change can automatically move through a CI/CD and GitOps workflow:

**Developer → GitHub → GitHub Actions → Docker → Trivy → Docker Hub → Kubernetes manifests → Argo CD → Kubernetes**

The application is a small Flask service that returns its current version.

## Technologies Used

- **Python / Flask** - Application
- **Git / GitHub** - Source code and Kubernetes manifest repository
- **GitHub Actions** - CI/CD automation
- **Docker** - Application containerization
- **Docker Hub** - Container image registry
- **Trivy** - Container vulnerability scanning
- **Kubernetes** - Application orchestration
- **Argo CD** - GitOps continuous delivery
- **Minikube** - Local Kubernetes environment

## Project Structure

```text
gitops-kubernetes-project/
├── .github/
│   └── workflows/
│       └── ci.yml
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
├── app.py
├── Dockerfile
├── requirements.txt
├── .gitignore
├── GitOps_Kubernetes_Project_Report
└── README.md
```

## Application

The Flask application runs on port `5000`.

The current application version is:

```text
GitOps Demo Application - Version v1
```

The application version can be changed in `app.py`.

## Kubernetes Configuration

The application is deployed in the `gitops-demo` namespace.

### Deployment

- Deployment name: `gitops-demo`
- Replicas: `2`
- Container port: `5000`
- Image: `shohithdocker/gitops-demo:<commit-sha>`

### Service

- Service name: `gitops-demo`
- Type: `NodePort`
- Service port: `5000`
- Target port: `5000`

## CI/CD and GitOps Workflow

### 1. Code Change

A developer modifies the application and pushes the change to the `main` branch.

### 2. GitHub Actions

The workflow in `.github/workflows/ci.yml` runs automatically.

The test job:

- Checks out the repository
- Sets up Python 3.14
- Installs dependencies
- Runs the Flask application test

The Docker job runs after the test job succeeds.

### 3. Docker Image Build

GitHub Actions builds the application image using the Git commit SHA as the image tag.

Example:

```text
shohithdocker/gitops-demo:<commit-sha>
```

### 4. Security Scan

Trivy scans the Docker image for `CRITICAL` and `HIGH` OS vulnerabilities.

The workflow is configured with:

```text
exit-code: 1
ignore-unfixed: true
severity: CRITICAL,HIGH
vuln-type: os
```

The project also verified the installed Python package versions inside the image during the security troubleshooting process.

### 5. Push to Docker Hub

After the security scan passes, GitHub Actions logs in to Docker Hub and pushes the image.

### 6. Kubernetes Manifest Update

GitHub Actions updates `k8s/deployment.yaml` with the newly built image tag and commits the manifest change back to GitHub.

The Kubernetes manifest therefore acts as the desired state for the deployment.

### 7. Argo CD Synchronization

Argo CD watches the GitHub repository.

The configured Argo CD application is:

```text
Application: gitops-demo
Repository: https://github.com/shohith-git/gitops-kubernetes-project.git
Path: k8s
Branch: main
Namespace: gitops-demo
```

Automated synchronization is enabled with:

```text
prune: true
selfHeal: true
```

When the Kubernetes manifest changes, Argo CD synchronizes the cluster with the Git repository.

## GitOps Principle Demonstrated

The Git repository is the source of truth for the Kubernetes deployment configuration.

Instead of manually changing the deployment as the normal release process, the desired state is committed to Git and Argo CD reconciles Kubernetes to that state.

This project also demonstrated Argo CD self-healing by making a temporary manual image change in Kubernetes and observing Argo CD restore the Git-defined image.

## Failure Testing

The project tested a failed deployment by changing the Kubernetes manifest to use an invalid Docker image tag:

```text
shohithdocker/gitops-demo:invalid-failure-test
```

Argo CD detected the Git change and attempted to apply it.

The deployment behavior was observed through Kubernetes pod and deployment status.

The deployment was then restored to a valid image through Git, and Argo CD synchronized the desired state back to Kubernetes.

## Rollback Testing

The project tested application rollback from version `v2` to version `v1`.

The rollback was performed by restoring the application and deployment configuration to the earlier version and committing the change to Git.

Argo CD synchronized the rollback to Kubernetes.

Final verification showed:

```text
GitOps Demo Application - Version v1
```

This demonstrates that Git history can be used to restore a previously working application state.

## Pod and Service Failure Testing

A running application pod was manually deleted:

```bash
kubectl delete pod <pod-name> -n gitops-demo
```

Kubernetes automatically created a replacement pod because the Deployment desired two replicas.

The final state was verified with:

```bash
kubectl get pods -n gitops-demo
kubectl get deployment gitops-demo -n gitops-demo
kubectl get svc gitops-demo -n gitops-demo
kubectl get endpoints gitops-demo -n gitops-demo
```

The application remained available and both replicas returned to the `Running` and `Ready` state.

## Useful Verification Commands

Check Argo CD application:

```bash
kubectl get application gitops-demo -n argocd
```

Check deployment:

```bash
kubectl get deployment gitops-demo -n gitops-demo
```

Check pods:

```bash
kubectl get pods -n gitops-demo
```

Check service:

```bash
kubectl get svc gitops-demo -n gitops-demo
```

Check the deployed image:

```bash
kubectl get deployment gitops-demo -n gitops-demo -o jsonpath="{.spec.template.spec.containers[0].image}"
```

Test the application from inside the deployment:

```bash
kubectl exec -n gitops-demo deploy/gitops-demo -- python -c "import urllib.request; print(urllib.request.urlopen('http://localhost:5000').read().decode())"
```

## Final Verified State

The project was verified with:

- Git working tree clean
- GitHub repository synchronized
- Kubernetes Deployment running `2/2` replicas
- Both application pods in `Running` and `Ready` state
- Kubernetes Service available on port `5000`
- Argo CD application `Synced`
- Argo CD application `Healthy`
- Application returning version `v1`
- Rollback successfully demonstrated
- Pod replacement successfully demonstrated
- Trivy security scanning integrated into CI

## How to Run Locally

### Run Flask directly

```bash
python app.py
```

### Build the Docker image

```bash
docker build -t gitops-demo .
```

### Run the Docker container

```bash
docker run -p 5000:5000 gitops-demo
```

### Deploy Kubernetes manifests

```bash
kubectl apply -f k8s/
```

The project itself uses Argo CD for the GitOps deployment flow.

## Core Project Boundary

This project focuses on demonstrating:

- Application containerization
- Automated CI testing
- Docker image creation
- Container security scanning
- Image publishing
- Git-based Kubernetes desired state
- Argo CD continuous delivery
- Kubernetes deployment and service management
- GitOps synchronization
- Self-healing
- Failure testing
- Rollback

It is a demonstration/internship project and does not attempt to implement production-scale infrastructure such as multi-cluster management, external cloud infrastructure, advanced observability, or enterprise secrets management.

---