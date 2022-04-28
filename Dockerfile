ARG TAG="v3.4.0"
ARG BCI_IMAGE=registry.suse.com/bci/bci-base:latest
ARG GO_IMAGE=rancher/hardened-build-base:v1.18.1b7

# Build the project
FROM ${GO_IMAGE} as builder
RUN set -x && \
    apk --no-cache add \
    git \
    make
ARG TAG
RUN git clone https://github.com/k8snetworkplumbingwg/sriov-network-device-plugin && \
    cd sriov-network-device-plugin && \
    git fetch --all --tags --prune  && \
    git checkout tags/${TAG} -b ${TAG}  && \
    make clean && \
    make build

# Create the sriov-network-device-plugin image
FROM ${BCI_IMAGE}
WORKDIR /
RUN zypper update -y && \
    zypper install -y hwdata && \
    zypper clean --all
COPY --from=builder /go/sriov-network-device-plugin/build/sriovdp /usr/bin/
COPY --from=builder /go/sriov-network-device-plugin/images/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
