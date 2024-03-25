ARG TAG="v3.6.2"
ARG BCI_IMAGE=registry.suse.com/bci/bci-base:latest
ARG GO_IMAGE=rancher/hardened-build-base:v1.21.8b1

# Build the project
FROM ${GO_IMAGE} as builder
RUN set -x && \
    apk --no-cache add \
    git \
    make
ARG TAG
RUN git clone https://github.com/k8snetworkplumbingwg/sriov-network-device-plugin
WORKDIR sriov-network-device-plugin
RUN git fetch --all --tags --prune
RUN git checkout tags/${TAG} -b ${TAG}
RUN make clean && make build

# Create the sriov-network-device-plugin image
FROM ${BCI_IMAGE}
WORKDIR /
RUN zypper refresh && \
    zypper update -y && \
    zypper install -y hwdata gawk which && \
    zypper clean -a
COPY --from=builder /go/sriov-network-device-plugin/build/sriovdp /usr/bin/
COPY --from=builder /go/sriov-network-device-plugin/images/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
