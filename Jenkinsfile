/* import shared library a preciser dans mon interface jenkins */
@Library('junie-webapp-slack-share-library')_

pipeline {
    environment {
        IMAGE_NAME = "projet-file-rouge"
        APP_EXPOSED_PORT = "80"
        IMAGE_TAG = "latest"
        STAGING = "chocoapp-staging"
        PRODUCTION = "chocoapp-prod"
        DOCKERHUB_ID = "671609644"
        DOCKERHUB_PASSWORD = credentials('dockerhub_password')
        APP_NAME = "junie"
        STG_API_ENDPOINT = "10.0.19.6:1993"
        STG_APP_ENDPOINT = "10.0.19.6:${PORT_EXPOSED}90"
        PROD_API_ENDPOINT = "10.0.19.6:1993"
        PROD_APP_ENDPOINT = "10.0.42.5:${PORT_EXPOSED}"
        // STG_API_ENDPOINT = "ip10-0-16-5-cqefhrr9jotg009h5e3g-1993.direct.docker.labs.eazytraining.fr"
        // STG_APP_ENDPOINT = "ip10-0-16-5-cqefhrr9jotg009h5e3g-8080.direct.docker.labs.eazytraining.fr"
        // PROD_API_ENDPOINT = "ip10-0-16-5-cqefhrr9jotg009h5e3g-1993.direct.docker.labs.eazytraining.fr"
        // PROD_APP_ENDPOINT = "ip10-0-16-5-cqefhrr9jotg009h5e3g-80.direct.docker.labs.eazytraining.fr"
        INTERNAL_PORT = "80"
        EXTERNAL_PORT = "${PORT_EXPOSED}"
        CONTAINER_IMAGE = "${DOCKERHUB_ID}/${IMAGE_NAME}:${IMAGE_TAG}"
    }

    // je declare un agent none pour dire que c'est chaque stage qui definira son agent
    agent none
    stages {
       stage('Build image') {
           agent any
           steps {
              script {
                sh 'docker build -t ${DOCKERHUB_ID}/$IMAGE_NAME:$IMAGE_TAG .'
                // je passe  la commande pour buider mon dockerfile en specifiant le dossier dans lewuel il se trouve 
              }
           }
       }
       stage('Run container based on builded image') {
          agent any
          steps {
            script {
              sh '''
                  echo "Cleaning existing container if exist"
                  docker ps -a | grep -i $IMAGE_NAME && docker rm -f $IMAGE_NAME
                  docker run --name $IMAGE_NAME -d -p $APP_EXPOSED_PORT:$INTERNAL_PORT  ${DOCKERHUB_ID}/$IMAGE_NAME:$IMAGE_TAG
                  sleep 5
              '''
             }
          }
       }
       // stage('Test image') {
       //     agent any
       //     steps {
       //        script {
       //          sh '''
       //             curl -v 172.17.0.1:$APP_EXPOSED_PORT | grep -i "Search"
       //          '''
       //        }
       //     }
       // }
       stage('Clean container') {
          agent any
          steps {
             script {
               sh '''
                   docker stop $IMAGE_NAME
                   docker rm $IMAGE_NAME
               '''
             }
          }
      }

      stage ('Login and Push Image on docker hub') {
          agent any
          steps {
             script {
               sh '''
                   echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_ID --password-stdin
                   docker push ${DOCKERHUB_ID}/$IMAGE_NAME:$IMAGE_TAG
               '''
             }
          }
      }

      //
    // }
      stage('STAGING - Deploy app') {
      agent any
      steps {
          script {
            sh """
              echo  {\\"your_name\\":\\"${APP_NAME}\\",\\"container_image\\":\\"${CONTAINER_IMAGE}\\", \\"external_port\\":\\"${EXTERNAL_PORT}90\\", \\"internal_port\\":\\"${INTERNAL_PORT}\\"}  > data.json 
              curl -k -v -X POST http://${STG_API_ENDPOINT}/staging -H 'Content-Type: application/json'  --data-binary @data.json  2>&1 | grep 200
            """
          }
        }
     
     }
     stage('PROD - Deploy app') {
       when {
           expression { GIT_BRANCH == 'origin/main' }
       }
     agent any

       steps {
          script {
            sh """
              echo  {\\"your_name\\":\\"${APP_NAME}\\",\\"container_image\\":\\"${CONTAINER_IMAGE}\\", \\"external_port\\":\\"${EXTERNAL_PORT}\\", \\"internal_port\\":\\"${INTERNAL_PORT}\\"}  > data.json 
              curl -k -v -X POST http://${PROD_API_ENDPOINT}/prod -H 'Content-Type: application/json'  --data-binary @data.json  2>&1 | grep 200
            """
          }
       }
     }
  }
  post {
       success {
         slackSend (color: '#00FF00', message: "JUNIE - SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL}) - PROD URL => http://${PROD_APP_ENDPOINT} , STAGING URL => http://${STG_APP_ENDPOINT}")
         }
      failure {
            slackSend (color: '#FF0000', message: "JUNIE - FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
          }   
    }  
}
