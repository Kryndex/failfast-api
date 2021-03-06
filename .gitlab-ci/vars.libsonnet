local utils = (import "jpy-utils.libsonnet");
{
  images: {
    release: {
      failfast: {
        creds: {
          host: "quay.io",
          password: "$QUAY_TOKEN",
          username: "failfast-ci+gitlabci",
        },
        repo: "quay.io/failfast-ci/failfast",
        tag: "${CI_COMMIT_REF_SLUG}-${SHA8}",
        name: utils.docker.containerName(self.repo, self.tag),
        get_name(tag):: utils.docker.containerName(self.repo, tag),
      },
    },
    ci: {
      failfast: {
        creds: {
          host: "quay.io",
          password: "$QUAY_TOKEN",
          username: "failfast-ci+gitlabci",
        },
        repo: "quay.io/failfast-ci/failfast-cibuild",
        tag: "${CI_COMMIT_REF_SLUG}-${SHA8}",
        name: utils.docker.containerName(self.repo, self.tag),
        get_name(tag):: utils.docker.containerName(self.repo, tag),
      },
    },
  },
}
