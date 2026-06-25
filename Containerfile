ARG FEDORA_VERSION=${FEDORA_VERSION}

FROM scratch AS ctx
COPY build-scripts /
COPY system-files/assets /assets
COPY system-files/ /system-files

FROM quay.io/fedora/fedora-bootc:${FEDORA_VERSION}
COPY system-files/common /
COPY system-files/wm /

ARG IMAGE=${IMAGE}

RUN mkdir -p /usr/lib/bootupd/updates \
    && cp -r /usr/lib/efi/*/*/* /usr/lib/bootupd/updates

# NVIDIA flavor only: overlay nvidia system-files (COPY can't be conditional)
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    if [ "$IMAGE" = "zena-nvidia" ]; then cp -avf /ctx/system-files/nvidia/. / ; fi

# --- base ---
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var --mount=type=tmpfs,dst=/tmp \
    /ctx/modules/base/dnf.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var --mount=type=tmpfs,dst=/tmp \
    /ctx/modules/base/kernel.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var --mount=type=tmpfs,dst=/tmp \
    /ctx/modules/base/packages.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var --mount=type=tmpfs,dst=/tmp \
    /ctx/modules/base/system.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var --mount=type=tmpfs,dst=/tmp \
    /ctx/modules/base/services.sh

# --- desktop / window manager ---
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var --mount=type=tmpfs,dst=/tmp \
    /ctx/modules/wm/packages.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var --mount=type=tmpfs,dst=/tmp \
    /ctx/modules/wm/services.sh

# --- integrations ---
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var --mount=type=tmpfs,dst=/tmp \
    /ctx/modules/integrations/homed.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var --mount=type=tmpfs,dst=/tmp \
    /ctx/modules/integrations/nix.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var --mount=type=tmpfs,dst=/tmp \
    /ctx/modules/integrations/virtualization.sh

# NVIDIA flavor only: driver + container toolkit
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var --mount=type=tmpfs,dst=/tmp \
    if [ "$IMAGE" = "zena-nvidia" ]; then /ctx/modules/integrations/nvidia.sh ; fi

# --- signing + initramfs ---
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var --mount=type=tmpfs,dst=/tmp \
    /ctx/modules/sign.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var --mount=type=tmpfs,dst=/tmp \
    /ctx/modules/initramfs.sh

# --- final cleanup ---
RUN --mount=type=tmpfs,dst=/var --mount=type=tmpfs,dst=/tmp \
    find /etc/yum.repos.d/ -maxdepth 1 -type f -name '*.repo' \
        ! -name 'fedora.repo' ! -name 'fedora-updates.repo' ! -name 'fedora-updates-testing.repo' \
        -exec rm -f {} + \
    && dnf5 clean all

RUN bootc container lint
