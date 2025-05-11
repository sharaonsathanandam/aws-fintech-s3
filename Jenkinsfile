pipeline {
    agent any

    environment {
        FILE_PATH = "path/to/your/file.yaml"   // adjust as needed
        REPO_URL  = "https://github.com/your-org/your-repo.git"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

    stage('Detect New/Updated YAMLs')
    {
      steps {
        script {
          changedYamlFiles = sh(
            script: 'git diff --name-only HEAD~1 HEAD | grep configs/ | grep .yaml || true',
            returnStdout: true
          ).trim().split('\n').findAll { it.endsWith(".yaml") }

          if (changedYamlFiles.isEmpty()) {
            echo "No new or updated YAMLs found. Skipping pipeline."
            currentBuild.result = 'SUCCESS'
            exit 0
          }
        }
      }
    }

        stage('Process New YAMLs') {
      steps {
        script {
          for (yamlFile in changedYamlFiles) {
            def commitHash = sh(script: "git log -n 1 --pretty=format:%H -- ${yamlFile}", returnStdout: true).trim()
            echo "Processing ${yamlFile} from commit ${commitHash}"
          }
        }
      }
    }
  }
}