require 'jenkins_api_client'
require 'config_service'
require 'socket'

jenkins_config = ConfigService.load_config('jenkins.yml')[ConfigService.environment]

@client = JenkinsApi::Client.new({ server_ip: jenkins_config.server_ip, 
                                   username: jenkins_config.username, 
                                   password: ENV['MY_PASSWORD'], ssl: false } )

puts @client.job.list("^sinatra")

opts = {'build_start_timeout' => 30}

my_local_ip = ARGV[0] || IPSocket.getaddress(Socket.gethostname)

job_params = { 'TARGETS' => {"app"=>["ec2-user@#{my_local_ip}"], "db"=>["ec2-user@#{my_local_ip}"]}.to_json,
               'DEPLOY_TO_DEV' => 'true'
             }
puts @client.job.build('sinatra_play', job_params , opts)