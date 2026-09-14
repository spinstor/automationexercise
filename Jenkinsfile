pipeline {
    /*
     * AutomationExercise — Robot Framework test pipeline (Windows agent).
     *
     * Default: full suite in headless Chrome with the MongoDB-driven suite
     * excluded. Override behaviour at build time via the parameters below.
     */
    agent { label 'windows' }

    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')
        disableConcurrentBuilds()
        skipDefaultCheckout()
    }

    parameters {
        string(
            name: 'TEST_TAG',
            defaultValue: '',
            description: 'Robot tag to filter by (e.g. smoke, regression). Leave EMPTY to run the full suite.'
        )
        choice(
            name: 'BROWSER',
            choices: ['headlesschrome', 'chrome', 'headlessfirefox', 'firefox'],
            description: 'Browser + flavour used for UI tests.'
        )
        booleanParam(
            name: 'INCLUDE_MONGO_SUITE',
            defaultValue: false,
            description: 'Also run tests/auth/mongo_credentials.robot. Requires MongoDB reachable on the agent.'
        )
        booleanParam(
            name: 'PUBLISH_ROBOT_REPORT',
            defaultValue: false,
            description: 'Publish the Robot Framework trend/report view. Requires the "Robot Framework" Jenkins plugin.'
        )
        booleanParam(
            name: 'CLEAN_WORKSPACE',
            defaultValue: true,
            description: 'Delete the previous output/ directory before running.'
        )
    }

    environment {
        // Override via a Jenkins secret/file or global config when needed.
        // Empty => falls back to the framework defaults (mongodb://localhost:27017/).
        MONGO_URI = ''
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Clean output') {
            when { expression { return params.CLEAN_WORKSPACE } }
            steps {
                bat 'if exist output rmdir /s /q output'
            }
        }

        stage('Setup environment') {
            steps {
                bat 'python --version'
                bat 'if not exist .venv python -m venv .venv'
                bat '.venv\\Scripts\\python.exe -m pip install --upgrade pip'
                bat '.venv\\Scripts\\python.exe -m pip install -r requirements.txt'
                if (env.MONGO_URI) {
                    bat "set MONGO_URI=${env.MONGO_URI} && echo MONGO_URI overridden for this build"
                }
            }
        }

        stage('Seed data') {
            steps {
                // Fresh unique emails every build so the Excel-driven
                // registration suite always has pending rows.
                bat '.venv\\Scripts\\python.exe scripts\\seed_test_users.py --rows 3'
            }
        }

        stage('Run Robot tests') {
            steps {
                script {
                    def tagArg = params.TEST_TAG ? "-i ${params.TEST_TAG}" : ''
                    def mongoArg = params.INCLUDE_MONGO_SUITE ? '' : '--exclude mongo'
                    def mongoVar = env.MONGO_URI ? "set MONGO_URI=${env.MONGO_URI} &&" : ''

                    bat """
                        ${mongoVar} .venv\\Scripts\\python.exe -m robot ^
                            --listener resources\\common\\console_listener.py ^
                            --outputdir output ^
                            --loglevel INFO ^
                            --xunit robot_xunit.xml ^
                            --variable BROWSER:${params.BROWSER} ^
                            ${tagArg} ${mongoArg} tests
                    """
                }
            }
        }
    }

    post {
        always {
            // JUnit-style results -> test trend on the build page.
            script {
                try {
                    junit testResults: 'output/robot_xunit.xml', allowEmptyResults: true
                } catch (e) {
                    echo "No JUnit report to publish: ${e}"
                }
            }

            archiveArtifacts(
                artifacts: 'output/**',
                fingerprint: true,
                allowEmptyArchive: true
            )

            script {
                if (params.PUBLISH_ROBOT_REPORT) {
                    try {
                        publishRobotFrameworkReports outputPath: 'output'
                    } catch (e) {
                        echo "Robot Framework plugin not available (${e}). "
                            + "Install it to get the robot report view, or keep PUBLISH_ROBOT_REPORT off."
                    }
                }
            }
        }
    }
}