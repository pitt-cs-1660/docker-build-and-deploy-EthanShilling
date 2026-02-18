[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/pNNPdvpL)
# Docker Assignment

This project is a Go web application that generates random band names. The application code is located at the root of the repository.

## Pre-requisites

Before you begin, ensure the following are set up:

- **Docker**: Download from [here](https://www.docker.com/products/docker-desktop).
- **Go** (optional, for local development): Download from [here](https://go.dev/dl/).
- **AWS Account**: You should have an active AWS account with access to ECR.
- **AWS ECR Repository**: Create a repository in AWS ECR to store your Docker image.

---

## Assignment

Your task is to create a multi-stage `Dockerfile` that builds and runs the Go application. A GitHub Actions workflow is provided that will automatically build and push your Docker image to AWS ECR when you push to the `main` branch. You will need to complete the workflow and configure it with your AWS details.

### Dockerfile Requirements:

#### Build Stage
1. Use `golang:1.23` as the base image.
2. Copy `go.mod`, `main.go`, and the `templates` directory into the build stage.
3. Compile the application into a static binary using `CGO_ENABLED=0`:
   ```dockerfile
   RUN CGO_ENABLED=0 go build -o <binary-name> .
   ```
   `CGO_ENABLED=0` disables CGo and produces a fully static binary with no external library dependencies. This is required because the final stage (`scratch`) is an empty image with no C libraries.

#### Final Stage
4. Use `scratch` as the base image. This is a completely empty image - no shell, no OS, no libraries - resulting in the smallest possible container.
5. Copy the compiled binary and `templates` directory from the build stage.
6. Set a **CMD** or **ENTRYPOINT** that runs the compiled binary.

### GitHub Actions Workflow:

A workflow file is provided at `.github/workflows/deploy.yml`. You need to:

1. **Set the environment variables** in the workflow file:
   - `ACCOUNT_ID` - your AWS account ID
   - `REGION` - your AWS region (e.g., `us-east-1`)
   - `REPO_NAME` - your ECR repository name

2. **Complete the final step** of the workflow with the correct `docker build`, `docker tag`, and `docker push` commands. Refer to [docs/docker-commands.md](docs/docker-commands.md) for guidance.

3. **Set your AWS credentials as GitHub secrets** in your repository settings:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

   You should already be familiar with configuring GitHub secrets from the previous assignment using `${{ secrets }}`.

4. **Create an ECR repository** in your AWS account to store your Docker image.

When you push to the `main` branch, the workflow will build your image and push it to your ECR repository.

### Automated Grading:

A grading workflow runs automatically on every push to `main` and on pull requests. It checks your Dockerfile for the required multi-stage build structure and verifies that your container builds and runs correctly. You can check your score by going to the **Actions** tab in your GitHub repository and viewing the output of the **Grading** workflow.

### Grading Rubric:

#### Dockerfile (10 points)

| Objectives                                                              | Points |
|-------------------------------------------------------------------------|--------|
| Multi-stage build                                                       | 1      |
| Build stage uses `golang:1.23`                                          | 1      |
| Final stage based on `scratch`                                           | 1      |
| Image builds successfully                                               | 3      |
| Container runs and serves HTTP 200                                      | 4      |

#### AWS ECR (5 points)

| Objectives                                                       | Points |
|------------------------------------------------------------------|--------|
| Image successfully pushed to ECR on push to main                 | 5      |

---

## Running Locally (without Docker)

If you have Go installed, you can run the application directly:

```bash
go run main.go
```

Visit `http://localhost:8080` in your browser.

---

## Building an Image for Your Local Machine

To build the Docker image for your local machine, run the following command:

```bash
# build the image locally
docker build -t cs1660-assignment2:v1 .
```

---

## Testing the Image

To test that your image works, run the container with the following command and visit `http://localhost:8080` in your browser to verify the application is running.

```bash
docker run -p 8080:8080 -it --rm --name app cs1660-assignment2:v1
```

---

## Running the Grading Script

You can run the grading script locally to check your score before submitting. From the root of the project:

```bash
./grade.sh .
```

The script will check your Dockerfile structure, build the image, run the container, and output your score.

**Windows users:** PowerShell cannot run bash scripts. You will need to use [WSL (Windows Subsystem for Linux)](https://learn.microsoft.com/en-us/windows/wsl/install) to run the grading script.

---

## Submission Instructions

1. **Set the environment variables** in `.github/workflows/deploy.yml` with your AWS account ID, region, and ECR repository name.
2. **Complete the final workflow step** with your `docker build`, `docker tag`, and `docker push` commands.
3. **Ensure your AWS credentials** are configured as GitHub secrets in your repository.
4. **Merge your code** into the **main** branch of the GitHub project.
5. **Verify** that the GitHub Actions workflow has successfully pushed the image to your ECR repository.
6. **Submit GitHub Repo URL** on Canvas.

---

## Resources

- [Dockerfile reference](https://docs.docker.com/reference/dockerfile/)
- [Docker Commands Reference](docs/docker-commands.md)
- [Docker Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Amazon ECR User Guide](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [aws-actions/amazon-ecr-login](https://github.com/aws-actions/amazon-ecr-login)
