pipeline {
    agent { dockerfile true }
    stages {
        stage('Test') {
            steps {
                git branch: 'sankeeth-test',
                url: 'git@bitbucket.org:vetstoria/platform.git',
                credentialsId: '9c80be6c-d19b-4424-93d1-c1a5ffd7e558'
                sh 'cp -r ./version/* ./oabp/source/appdata/version'
                sh 'mkdir /docker'
                sh 'touch /docker/envvars'
                sh '''awk 'NF { print "export "$1"="$2 }' ./setups/docker/oabp/app.env > /docker/envvars'''            
                sh '''echo "export RDS_DB_USER='root'" >> /docker/envvars'''
                sh '''echo "export RDS_DB_HOST='localhost'" >> /docker/envvars'''
                sh '''echo "export RDS_DB_PASSWORD='root'" >> /docker/envvars'''
                sh '/bin/bash -c "source /docker/envvars"'
                sh '/etc/init.d/mysql start'
                sh 'ln -s "$( pwd )/" /projects'
                dir('core'){
                    sh 'composer install'
                }
                dir('oabp'){
                    sh 'composer install'
                    sh '/bin/bash -c "source /docker/envvars && ./vendor/phing/phing/bin/phing db-init-jenkins"'
                    sh '/bin/bash -c "source /docker/envvars && ./vendor/codeception/codeception/codecept run unit tests/unit/billing/NonChargeableCest.php"'
                }
            }
        }
    }
}
