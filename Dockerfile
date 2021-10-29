# last commit on 2021-10-06
ARG TAG="441e06f11bfafcf5f818975298943537a103b5a8"
ARG UBI_IMAGE=registry.access.redhat.com/ubi7/ubi-minimal:latest
ARG GO_IMAGE=rancher/hardened-build-base:v1.16.9b7

# Build the project
FROM ${GO_IMAGE} as builder
RUN set -x \
 && apk --no-cache add \
    git \
    make
ARG TAG
RUN git clone https://github.com/k8snetworkplumbingwg/sriov-network-device-plugin
WORKDIR sriov-network-device-plugin
RUN git fetch --all --tags --prune
RUN git checkout ${TAG}
RUN make clean && make build

# Create the sriov-network-device-plugin image
FROM ${UBI_IMAGE}
WORKDIR /
RUN microdnf update -y && \
    microdnf install hwdata
COPY --from=builder /go/sriov-network-device-plugin/build/sriovdp /usr/bin/
COPY --from=builder /go/sriov-network-device-plugin/images/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
