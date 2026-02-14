# Docker Commands Reference

This document covers the three Docker commands you need to complete the GitHub Actions workflow.

---

## docker build

Builds a Docker image from a Dockerfile in the current directory.

```bash
docker build -t <image-name>:<tag> .
```

- `-t` tags the image with a name and optional tag
- `.` tells Docker to use the current directory as the build context

**example:**
```bash
docker build -t my-app:latest .
```

---

## docker tag

Creates a new tag for an existing image. This is used to associate your local image with a remote registry.

```bash
docker tag <source-image>:<tag> <target-image>:<tag>
```

- the source is your locally built image
- the target is the full registry URI where you want to push

**example with ecr:**
```bash
docker tag my-app:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest
```

The ECR image URI follows this format:
```
<account-id>.dkr.ecr.<region>.amazonaws.com/<repo-name>:<tag>
```

---

## docker push

Pushes a tagged image to a remote registry. You must be authenticated to the registry before pushing.

```bash
docker push <image-uri>:<tag>
```

**example with ecr:**
```bash
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest
```

---

## Putting It All Together

In your workflow, you have access to the environment variables `ACCOUNT_ID`, `REGION`, and `REPO_NAME`. In GitHub Actions, you can reference environment variables using `${{ env.VAR_NAME }}` syntax.

Your completed step should build the image, tag it with your full ECR URI, and push it.
