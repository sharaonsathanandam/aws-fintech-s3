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
                        for f in *.yaml; do
                          commit=$(git log -n 1 --pretty=format:%H -- "$f")
                          echo "$f was last modified in commit $commit"
                        done
                   '''
            }
        }
    }
}
