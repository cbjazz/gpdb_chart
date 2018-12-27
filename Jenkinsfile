pipeline {
    agent any

    environment {
      PATH="/Users/choic3/anaconda3/bin:/Users/choic3/anaconda/anaconda/bin:$PATH"
    }

    stages {

        stage('Build environment') {
            steps {
                echo "Building virtualenv"
                sh  ''' conda create --yes -n ${BUILD_TAG} python
                        source activate ${BUILD_TAG}
                    '''
            }
        }

        stage('Unit tests') {
            steps {
                sh ''' source activate ${BUILD_TAG}
                       python -m pytest --verbose --junit-xml reports/unit_tests.xml
                   '''
            }
            post {
                always {
                    //Archive unit tests for the future
                    junit (allowEmptyResults: true,
                          testResults: './reports/unit_tests.xml')
                }
            }
        }
        stage('Build package') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                sh ''' source acitvate ${BUILD_TAG}
                       python setup.py bdist_wheel
                   '''
            }
            post {
                always {
                    //Archive unit tests for the future
                    archiveArtifacts allowEmptyArchive: true, artifacts: 'dist/*whl'
                }
            }
        }
    }
    post {
        always {
            sh 'conda remove --yes -n ${BUILD_TAG} --all'            
        }
        failure {
            echo 'This will run only if failed'
        }
        unstable {
            echo 'This will run only if the run was marked as unstable'
        }
        changed {
            echo 'This will run only if the state of the Pipeline has changed'
            echo 'For example, if the Pipeline was previously failing but is now successful'
        }
    }
}
