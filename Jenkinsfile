PROJETOS_DISPONIVEIS = [
	'EXATA_CX_RAPIDO',
	'EXATA_COM_COMPLETO',
	'EXATA_COM_NFE',
	'EXATA_COM_PAFECF',
	'EXATA_COM_SAT',
	'EXATA_DEV',
	'EXATA_LOCACAO',
	'EXATA_OS',
	'EXATA_TRANSPORTES',
	'EXATA_TRANSP_COMPLETO',
	'EXATA_PEDIDO_DE_COMPRA']

pipeline {
	agent any

	options {
		buildDiscarder(logRotator(numToKeepStr: '10'))
	}

	stages {
		stage('check') {
			steps {
				echo "Verificando numero da versao informada."

				script {
					_VERSAO_ = (env.EXATA_VERSAO_TAG != null && env.EXATA_VERSAO_TAG.length() > 0) ? env.EXATA_VERSAO_TAG : "0.0.0.0"
					echo("Versao ..: ${_VERSAO_}")

					if (_VERSAO_ ==~ /([0-9]+\.){3}([0-9]+){1}/) {
						echo("Versao ${_VERSAO_} informada corretamente...")
					} else {
						error("Versao ${_VERSAO_} informada incorretamente...")
					}

					env._VERSAO_ = _VERSAO_
					env._VERSAO_ID_ = _VERSAO_.replace('.', ',')

					echo("Versao   : ${_VERSAO_}")
					echo("Versao ID: ${_VERSAO_ID_}")
				}

				echo "Ajuste na informacao de qual projeto sera compilado..."

				script {
					if (env.EXATA_PROJETO == null) {
						env.EXATA_PROJETO = "TODOS"
					}
				}

				echo "Tipo de build"

				script {
					if (env.TIPO_BUILD == null) {
						env.TIPO_BUILD = "DEV"
					}
				}

				echo "Build instalador: SIM|NAO"

				script {
					if (env.BUILD_INSTALADOR == null) {
						env.BUILD_INSTALADOR = "NAO"
					}
				}

				echo("Projeto: ${env.EXATA_PROJETO}")
				echo("Versao : ${env._VERSAO_}")
				echo("Tipo   : ${env.TIPO_BUILD}")
				echo("Instalador: ${env.BUILD_INSTALADOR}")
			}
		}

		stage('testes') {
			steps {
				bat 'ant testes'
			}

			post {
				always {
					nunit testResultsPattern: 'fontes/testes/**/dunitx-results.xml'
					nunit testResultsPattern: 'fontes/comum/**/dunitx-results.xml'
				}
			}
		}

		stage('limpar') {
			steps {
				bat 'ant limpar'
			}
		}

		stage('build') {
			steps {
				bat 'ant recursos'
				bat 'ant config'

				script {
					if (env.EXATA_PROJETO in PROJETOS_DISPONIVEIS || env.EXATA_PROJETO == 'TODOS') {
						echo 'Build: Integracao PAF-ECF'
						bat "ant \"-Dexata.id=EXATA_DEV\" \"-Dexata.projeto=INTEGRACAO-PAFECF\" \"-Dexata.versao=${env._VERSAO_}\" \"-Dexata.versao.id=${env._VERSAO_ID_}\" build"
				
						echo 'Build: Integrador Exata'
						bat "ant \"-Dexata.id=EXATA_DEV\" \"-Dexata.projeto=INTEGRADOR-EXATA\" \"-Dexata.versao=${env._VERSAO_}\" \"-Dexata.versao.id=${env._VERSAO_ID_}\" build"
					}

					PROJETOS_DISPONIVEIS.each {
						if (it == env.EXATA_PROJETO || env.EXATA_PROJETO == 'TODOS') {
							echo "Build: ${it}"
							bat "ant \"-Dexata.id=${it}\" \"-Dexata.projeto=EXATA\" \"-Dexata.versao=${env._VERSAO_}\" \"-Dexata.versao.id=${env._VERSAO_ID_}\" build"
						} else {
							echo "Projeto ${it} não selecionado para build."
						}
					}
				}
			}
		}

		stage('instalador') {
			when {
				anyOf {
					environment name: 'BUILD_INSTALADOR', value: 'SIM'
					environment name: 'TIPO_BUILD', value: 'PRODUCAO'
				}
			}

			steps {
				bat 'ant install.recursos'

				script {
					PROJETOS_DISPONIVEIS.each {
						if (it == env.EXATA_PROJETO || env.EXATA_PROJETO == 'TODOS') {
							echo "Build: ${it}"
							bat "ant \"-Dexata.id=${it}\" \"-Dexata.projeto=EXATA\" \"-Dexata.versao=${env._VERSAO_}\" \"-Dexata.versao.id=${env._VERSAO_ID_}\" install.build"
						} else {
							echo "Projeto ${it} não selecionado para build."
						}
					}
				}
			}
		}

		stage('artefatos') {
			steps {
				archiveArtifacts artifacts: "deploy/${env._VERSAO_}/exe/INTEGRACAO-PAFECF*.zip", fingerprint: true
				archiveArtifacts artifacts: "deploy/${env._VERSAO_}/exe/INTEGRADOR-EXATA*.zip", fingerprint: true
				archiveArtifacts artifacts: "deploy/${env._VERSAO_}/exe/EXATA*.zip", fingerprint: true
				archiveArtifacts artifacts: "deploy/${env._VERSAO_}/install/Instalador*.zip", fingerprint: true, allowEmptyArchive: true
			}
		}

		stage('upload') {
			when {
				anyOf {
					environment name: 'TIPO_BUILD', value: 'PRODUCAO'
				}
			}

			steps {
				withAWS(profile: 'default') {
					s3Upload(bucket: "exata-versoes-54e53eb9-550d-482f-821f-eca79f744c06", path: "${env._VERSAO_}/", workingDir: "deploy/${env._VERSAO_}/exe/", includePathPattern: "INTEGRACAO-PAFECF*.zip")
					s3Upload(bucket: "exata-versoes-54e53eb9-550d-482f-821f-eca79f744c06", path: "${env._VERSAO_}/", workingDir: "deploy/${env._VERSAO_}/exe/", includePathPattern: "INTEGRADOR-EXATA*.zip")
					s3Upload(bucket: "exata-versoes-54e53eb9-550d-482f-821f-eca79f744c06", path: "${env._VERSAO_}/", workingDir: "deploy/${env._VERSAO_}/exe/", includePathPattern: "EXATA*.zip")
					s3Upload(bucket: "exata-versoes-54e53eb9-550d-482f-821f-eca79f744c06", path: "${env._VERSAO_}/", workingDir: "deploy/${env._VERSAO_}/install/", includePathPattern: "Instalador*.zip")
				}
			}
		}
	}
}