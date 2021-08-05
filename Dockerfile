FROM alpine:3.14 AS build

# install kubectl
RUN apk add curl
ENV KUBECTL_VERSION=v1.19.1
ENV KUBECTL_URL=https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
ENV KUBECTL_SHA256SUM=da4de99d4e713ba0c0a5ef6efe1806fb09c41937968ad9da5c5f74b79b3b38f5
RUN curl -fsSLO "${KUBECTL_URL}" \
	&& echo "${KUBECTL_SHA256SUM}  kubectl" | sha256sum -c - \
	&& chmod +x kubectl \
	&& mv kubectl "/usr/local/bin/kubectl-${KUBECTL_VERSION}" \
	&& ln -s "/usr/local/bin/kubectl-${KUBECTL_VERSION}" /usr/local/bin/kubectl

FROM alpine:3.14

RUN apk add --update \
    bash \
  && rm -rf /var/cache/apk/*

WORKDIR /home/replicated

COPY --from=build /usr/local/bin/kubectl /usr/local/bin/
COPY check-mount.sh entrypoint.sh ./

ENTRYPOINT [ "./entrypoint.sh" ]
