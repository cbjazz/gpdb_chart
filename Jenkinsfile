pipeline {
    agent any

    environment {
      PATH="/Users/choic3/anaconda3/bin:/Users/choic3/anaconda/anaconda/bin:$PATH"
    }

    stages {
        stage('Unit tests') {
            steps {
                sh ''' source activate gpchart
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


        stage('Static code metrics') {
            steps {
                echo "Raw metrics"
                sh  ''' source activate gpchart
                        radon raw --json gpchart > raw_report.json
                        radon cc --json gpchart > cc_report.json
                        radon mi --json gpchart > mi_report.json
                    '''
                echo "Test coverage"
                sh  ''' source activate gpchart
                        coverage run gpchart/iris.py
                        python -m coverage xml -o reports/coverage.xml
                    '''
                echo "Style check"
                sh  ''' source activate gpchart
                        pylint gpchart || true
                    '''
            }
            post{
                always{
                    step([$class: 'CoberturaPublisher',
                                   autoUpdateHealth: false,
                                   autoUpdateStability: false,
                                   coberturaReportFile: 'reports/coverage.xml',
                                   failNoReports: false,
                                   failUnhealthy: false,
                                   failUnstable: false,
                                   maxNumberOfBuilds: 10,
                                   onlyStable: false,
                                   sourceEncoding: 'ASCII',
                                   zoomCoverageChart: false])
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
                sh ''' source activate gpchart
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
