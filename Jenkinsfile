pipeline {
    agent any

    environment {
        FILE_PATH = "path/to/your/file.yaml"   // optional if looping through all .yaml files
        REPO_URL  = "https://github.com/your-org/your-repo.git"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

stage('Show Commit Hash for YAML Files') {
    steps {
        sh '''
            echo "Listing commit hashes for all YAML files..."
            find . -type f -name "*.yaml" > files.tmp
            while IFS= read -r f; do
              commit=$(git log -n 1 --pretty=format:%H -- "$f")
              echo "$f was last modified in commit $commit"
            done < files.tmp
            rm -f files.tmp
        '''
    }
}
    }
}
