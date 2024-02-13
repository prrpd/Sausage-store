pipeline {
    agent any // Выбираем Jenkins агента, на котором будет происходить сборка: нам нужен любой

    triggers {
        pollSCM('H/5 * * * *') // Запускать будем автоматически по крону примерно раз в 5 минут
    }
    stages {  
            stage ("first") {
                steps {
                    sh 'java -version'
                }
            }
            stage("second"){
                tools {
                   jdk "jdk-1.8.152"
                }
                steps{
                    sh 'java -version'
                }
            }
       }
}
