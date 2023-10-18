FROM openeuler/openeuler:22.03-lts-sp2

ENV GITHUB_USER=notconfigured GITHUB_EMAIL=notconfigured GITHUB_ACCESS_TOKEN=notconfigured GITHUB_BRANCH=master 
COPY ./build.sh /build
COPY ./openEuler.repo /etc/yum.repos.d/openEuler.repo
RUN dnf update -y && dnf install -y dnf-plugins-core rpmdevtools && rpmdev-setuptree && dnf clean all && chmod +x /build
CMD ["/build"]
