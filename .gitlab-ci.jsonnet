local utils = import "jpy-utils.libsonnet";
local baseJobs = import ".gitlab-ci/jobs.libsonnet";
local vars = import ".gitlab-ci/vars.libsonnet";
local images = vars.images;

local stages = {
  "code-style": "tests",
  tests: "tests",
  build_image: "build_image",
  docker_release: "docker_release",
};

local jobs = {
  // All the CI jobs


  'container-release': baseJobs.dockerBuild(images.release.failfast) {
    stage: stages.docker_release,
    script: utils.docker.rename(images.ci.failfast.name, images.release.failfast.name),
  } + utils.gitlabCi.onlyMaster,

  'build-image': baseJobs.dockerBuild(images.ci.failfast) +
                 {
                   stage: stages.build_image,
                 },

  pylint: baseJobs.job {
    before_script+: [
      "pip install pylint",
    ],
    stage: stages["code-style"],
    script: [
      "make pylint",
    ],
  },
  flake8: baseJobs.job {
    before_script+: [
      "pip install flake8",
    ],
    stage: stages["code-style"],
    script: [
      "make flake8",
    ],
  },
  yapf: baseJobs.job {
    before_script+: [
      "pip install yapf",
    ],
    stage: stages["code-style"],
    script: [
      "make yapf-diff",
    ],
  },

  'unit-tests': baseJobs.job {
    before_script+: [
      "pip install -r requirements_test.txt",
    ],
    stage: stages.tests,
    script: [
      "make test",
    ],
  },
};


{

  variables: {
    FAILFASTCI_NAMESPACE: "failfast-ci",
  },

  stages: std.objectFields(stages),
  cache: { paths: ["cache"] },
} + jobs
