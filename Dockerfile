FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    curl \
    sudo \
    gnupg2 \
    lsb-release \
    software-properties-common \
    git \
    iproute2 \
    iputils-ping \
    bash \
    && rm -rf /var/lib/apt/lists/* \
    && curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash \
    && curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh \
    && curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash \
    && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

COPY wiki-service/ /app/wiki-service/
COPY wiki-chart/ /app/wiki-chart/
COPY cluster.sh /cluster.sh

RUN chmod +x /cluster.sh

WORKDIR /app

CMD ["/cluster.sh"]
