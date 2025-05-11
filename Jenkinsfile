pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Get YAML Commit Hashes') {
            steps {
                script {
                    // Step 1: Get recently changed and added files
                    def changedFiles = sh(script: 'git diff --name-only HEAD~1 HEAD', returnStdout: true).trim().split('\n')
                    def newFiles = sh(script: 'git diff --name-only --diff-filter=A HEAD~1 HEAD', returnStdout: true).trim().split('\n')

                    // Step 2: Filter YAML files from each list
                    def changedYamls = changedFiles.findAll { it.endsWith(".yaml") }
                    def newYamls = newFiles.findAll { it.endsWith(".yaml") }

                    echo "Changed YAML files: ${changedYamls}"
                    echo "New YAML files: ${newYamls}"

                    // Step 3: Combine and deduplicate
                    def allYamls = (changedYamls + newYamls).unique()

                    // Step 4: Get commit hash for each file
                    allYamls.each { file ->
                        def commitHash = sh(
                            script: "git log -n 1 --pretty=format:%H -- ${file}",
                            returnStdout: true
                        ).trim()
                        echo "${file} was last modified in commit ${commitHash}"
                    }
                }
            }
        }
    }
}
