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

        stage('Show Commit Hash for File') {
            steps {
                sh '''
                        echo "Listing commit hashes for all YAML files:"
                        find . -type f -name "*.yaml" | while read f; do
                          commit=$(git log -n 1 --pretty=format:%H -- "$f")
                          echo "$f was last modified in commit $commit"
                        done
                   '''
            }
        }
    }
}
