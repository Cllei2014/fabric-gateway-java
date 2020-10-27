def githubUrl = "https://github.com/tw-bc-group/fabric-gateway-java"

void setBuildStatus(String message, String state) {
  step([
      $class: "GitHubCommitStatusSetter",
      reposSource: [$class: "ManuallyEnteredRepositorySource", url: githubUrl],
      contextSource: [$class: "ManuallyEnteredCommitContextSource", context: "ci/jenkins/build-status"],
      errorHandlers: [[$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]],
      statusResultSource: [ $class: "ConditionalStatusResultSource", results: [[$class: "AnyBuildResult", message: message, state: state]] ]
  ]);
}

pipeline {
    agent any

    environment {
        DOCKER_NS = "${DOCKER_REGISTRY}/twbc"
    }

    stages {
        stage('Unit&Int Tests') {
            steps {
                setBuildStatus("Build Started", "PENDING");

                sh 'aws ecr get-login-password | docker login --username AWS --password-stdin ${DOCKER_REGISTRY}'

                sh '''
                make tests
                '''
            }

            post {
                always {
                    sh 'make fabric-down'
                }
            }
        }

        stage('Package') {
            steps {
                sh 'make package'
            }

            post {
                success {
                    archiveArtifacts 'target/*.jar'
                }
            }
        }
    }

    post {
        success {
            setBuildStatus("Build succeeded", "SUCCESS");
        }
        unsuccessful {
            setBuildStatus("Build failed", "FAILURE");
        }
    }
}
