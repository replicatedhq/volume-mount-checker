# replicatedhq/volume-mount-checker

The replicated/volume-mount-checker image can be run as an init container in a Kubernetes pod to validate CephFilesystem mounts.

## Installation

The following environment variables must be defined:

- **MOUNT_PATH:** Filesystem mount path
- **NAMESPACE:** Kuberenetes pod namespace
- **POD_NAME:** Kuberenetes pod name

An example Deployment spec:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: example-deployment
  labels:
    app: myapp
spec:
  selector:
    matchLabels:
      app: myapp
  template:
    spec:
      initContainers:
        - name: check-mount
          image: replicated/volume-mount-checker:latest
          env:
            - name: MOUNT_PATH
              value: /sharedfs
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
          volumeMounts:
            - name: rook-shared-fs
              mountPath: /sharedfs
              readOnly: true
```

## Releasing

Releases are created when a tag is pushed to the upstream repository.

```
git tag -a v1.0.0 -m "Release 1.0.0" && git push origin v1.0.0
```
