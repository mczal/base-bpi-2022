<br />
<div align="center">
  <a href="https://wellcode.io">
    <img src="https://d2sb5cns5ryu46.cloudfront.net/wp-content/uploads/2021/01/HEADER-WELLCODE-COLOR-500x94.png" alt="Logo" width="300" height="60">
  </a>

  <h3 align="center">-README Taxsam SIA WELLCODE-</h3>

  <p align="center">
    This is Template to jumpstart your projects!    
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#checklist-improvement">Checklist Improvement</a>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#environment">Environment</a></li>
    <li><a href="#deploy-server">Deploy Server</a></li>
    <li><a href="#setup-local-project-for-deploy-server">Setup Local Project for Deploy Server</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>

## Checklist Improvement

- [x] Template Rails 6 
- [x] Template Rails 7
- [x] User Activity Monitoring (Google Analytics)
- [x] Monitoring Website (New Relic)
- [x] Monitoring Website (Datadog)
- [x] App Notification (Airbrake)
- [x] Server Notification (AWS Cloudwatch Alarm)
- [x] Monitoring & Centralized Log (Datadog logs)
- [x] Auto Deploy (Capistrano)
- [x] Default Template Framework (Metronic 7)
- [x] Background Processing (Sidekiq & Redis)
- [x] Assets Sync (AWS S3)
- [x] Active Storage (AWS S3)
- [x] 2FA Whatsapp (Twillio)
- [x] Email Service (WG-Mail)
- [x] Basic Component API, Service, Facede, Presenter
- [x] Javascript Framework (Stimulus)
- [x] CSS Framework (Boostrap Metronic 7)
- [ ] Code Standardization rails (?)
- [ ] Code Standardization JS (?)
- [ ] Code Standardization Template/Framework (?)
- [ ] ...

<!-- GETTING STARTED -->
## Getting Started

Download dan clone this project to your local and change :
- `database.yml`
- `asset_sync.yml`
- Replace all `TAXSAM SIA` from `app/views/*` to your project name.

  <p align="right">(<a href="#top">back to top</a>)</p>

### Prerequisites

You need to install :
- ruby
- Yarn 
- postgresql
- git
- nginx
- nodejs
- npm

  <p align="right">(<a href="#top">back to top</a>)</p>

### Installation

1. Go to yout project directory
2. Clone the repo
   ```sh
   git clone https://github.com/wellcodeglobal/taxsam_sia.git
   ```
3. install rails and bundle Instal
   ```sh
   bundle install
   ```
4. install yarn modules
   ```sh
   yarn install
   ```
5. migrate database
   ```sh
   rails db:migrate
   ```
5. create file `.env` and Setup with Environment below

<p align="right">(<a href="#top">back to top</a>)</p>

### Environment
  ```
  HOST="localhost"
  PORT="3000"

  ASSET_HOST_NAME=""

  S3_ACCESS_KEY=""
  S3_SECRET_KEY=""
  S3_REGION=""
  S3_MEDIA_BUCKET=""
  
  TWILIO_ACCOUNT_SID=""
  TWILIO_AUTH_TOKEN=""
  TWILIO_PHONE_NUMBER=""

  NEW_RELIC_NAME_APP=""
  NEW_RELIC_LICENSE="d626813596683fbfde6ff0c817aad2832f8053e5" <<-CHANGE THIS WITH New Relic project>>

  GOOGLE_ANALYTICS_KEY="UA-206526044-1" <<-CHANGE THIS WITH GA project>>

  AIRBRAKE_PROJECT_ID=""
  AIRBRAKE_PROJECT_KEY=""
  ```

  <p align="right">(<a href="#top">back to top</a>)</p>

### Deploy Server
  1. Access SSH
    access ssh to server production and prepare all requirement for server

  2. Folder & File requirement in server production
  ```
  mkdir -p /home/ubuntu/template-project
  mkdir -p /home/ubuntu/template-project/shared/tmp/sockets

  touch /home/ubuntu/.env
  touch /home/ubuntu/.env_export
  ```

  3. Setup Postgre sql and database  
  ```
  setup the database postgresql and provide the url :
  
  1. sudo -u postgres psql
  2. create database taxsam_sia;
  3. \password postgres
  ```

  4. result url for user postgres and password postgres in localhost env to be like this :
  ```
  postgresql://postgres@localhost:5432/taxsam_sia
  ```
  
  5. setup puma service and nginx : 
  - try to `cap production deploy`  first
  - if there is messages like `Failed to restart puma_mysite_production.service: Unit puma_mysite_production.service not found.`
  - then follow this tutorial for setup puma service :

  `create service for puma`
  ```
  vi /etc/systemd/system/puma_template-project_production.service
  ```
  
  `code script for service puma`
  ```
  [Unit]
  Description=Puma HTTP Server for taxsam_sia (production)
  After=network.target

  [Service]
  Type=simple
  User=ubuntu
  WorkingDirectory=/home/ubuntu/template-project/current
  ExecStart=/home/ubuntu/.rbenv/bin/rbenv do bundle exec puma -C /home/ubuntu/template-project/shared/puma.rb
  ExecReload=/bin/kill -TSTP $MAINPID
  StandardOutput=append:/home/ubuntu/template-project/current/log/puma.access.log
  StandardError=append:/home/ubuntu/template-project/current/log/puma.error.log
  EnvironmentFile=/home/ubuntu/.env
  Restart=always
  SyslogIdentifier=puma

  [Install]
  WantedBy=multi-user.target
  ```

  Follow this article for more detail to setup server deployment with capistrano :
  <a href="https://webdevchallenges.com/how-to-deploy-a-rails-6-application-with-capistrano">
  How to Deploy a Rails 6 Application with Capistrano, Nginx, Puma, Postgresql, LetsEncrypt on Ubuntu 20.04`
  </a>
  ```
  https://webdevchallenges.com/how-to-deploy-a-rails-6-application-with-capistrano
  ```  

  <p align="right">(<a href="#top">back to top</a>)</p>

### Setup Nginx
  1. make file for site nginx
  ```
  vi /etc/nginx/sites-available/template-project.wellcode.io  
  ```

  2. setup nginx with this code :
  ```
  upstream template-project.wellcode.io {
    server unix:///home/ubuntu/template-project/shared/tmp/sockets/template-project-puma.sock;
  }

  server {
    server_name template-project.wellcode.io;
    client_max_body_size 50M;

    root /home/ubuntu/template-project/current/public;
    access_log /home/ubuntu/template-project/current/log/nginx.access.log;
    error_log /home/ubuntu/template-project/current/log/nginx.error.log info;

    location / {
      proxy_set_header Host $host;
      proxy_set_header X-Forwarded-Host $host;
      proxy_set_header X-Forwarded-Ssl on;

      proxy_buffer_size          128k;
      proxy_buffers              4 256k;
      proxy_busy_buffers_size    256k;
    }
  }
  ```

  3. and link file to site-enabled
  ```
  sudo ln -s /etc/nginx/sites-available/template-project.wellcode.io /etc/nginx/sites-enabled/template-project.wellcode.io
  ```
  
  4. setup new ssl certificate for domain name
  
  Ensure cerbot already installed in server
  ```
  sudo certbot --nginx -d alert-template-project.wellcode.io <-- change to domain name
  ```
  <p align="right">(<a href="#top">back to top</a>)</p>

### Change hostname server :

 1. Type the hostnamectl command :
 
    ```sudo hostnamectl set-hostname newNameHere```
    
    Delete the old name and setup new name.
    
 2. Next Edit the /etc/hosts file:
 
    ```sudo nano /etc/hosts```
    
    Replace any occurrence of the existing computer name with your new hostname.
    
 3. Reboot the system to changes take effect:
 
    ```sudo reboot```
    
  <p align="right">(<a href="#top">back to top</a>)</p>
  
### Create Alarms CloudWatch
  Follow this article for more detail to setup alarms cloudwatch :
  
  <a href="https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/UsingAlarmActions.html">
  
  Create alarms that stop, terminate, reboot, or recover an instance
  </a>
  
  After follow setup above then
  Go to menu Amazon SNS to setup Notification then go to menu Subscription to Create New Subscription
  - Choose Topic
  - Choose Protocol -> ```Email```
  - Fill Endpoint
  - Save
  
  <p align="right">(<a href="#top">back to top</a>)</p>

### Setup DataDog For New Server
  Follow this Tutorial for more detail to setup Monitoring Rails applications with Datadog <a href="https://abstracted-feast-51a.notion.site/Tutorial-7fbed8bf1e5b4c37b67ee70510389166" target="_blank">Monitoring Rails applications with Datadog</a>
  
  If the installation already exist you can directly can check ```status dog```
  
  Installation : 
  ```
  DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=API_KEY DD_SITE="datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"
  ```
  - show status datadog `sudo datadog-agent status`

  - Configure the Agent to collect request traces and logs
  You can configure both APM and log management by editing the datadog.yaml file located in your host’s ```/etc/datadog-agent/``` directory
  ```
  # Trace Agent Specific Settings
  apm_config:
    enabled: true
    env: production
  ```
  The Agent doesn’t collect logs by default, so you will need to enable log collection in the same ```datadog.yaml```
  ```
  # Logs agent
    logs_enabled: true
  ```
  Save the file and restart the Agent to apply your recent changes:
  ```
  sudo service datadog-agent restart
  ```
  - Capture Rails Logs
  
  First, create a new directory and YAML file named after your log source in the Agent’s conf.d directory
  ```
  cd /etc/datadog-agent/conf.d/
  mkdir ruby.d
  touch ruby.d/conf.yaml
  
  # Log Information
   logs:
    - type: file
      path: /path/to/app/log/development.log
      service: production-rails-app
      source: ruby
  ```
  Restart the Agent to load the new configuration files:
  ```
  sudo service datadog-agent restart
  ```
  - Follow this article for more detail to setup Monitoring Rails applications with Datadog :
  <a href="https://www.datadoghq.com/blog/monitoring-rails-with-datadog/">Monitoring Rails applications with Datadog</a>
  
  <p align="right">(<a href="#top">back to top</a>)</p>
  
### Setup Local Project for Deploy Server
  You can follow this step Deploy project :

  1. run `bundle install`
  2. run `cap install`
  3. replace code Taxsam SIA for deployment with your project in `config/deploy.rb`
  ```  
  server 'TAXSAM SIA.com', port: 22, roles: [:web, :app, :db], primary: true
  set :application, "TAXSAM SIA"
  set :repo_url, "git@github.com:wellcodeglobal/taxsam_sia.git"
  ```

  4. setup pub ssh with your project ssh key public server, and change the path in `config/deploy.rb`
  ```
  set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/taxsam_sia.pub) }
  ```

  4. Copy your master.key to the shared dir.
  ```
  # SSH to server and create folder config in your project folder
  ssh rails@template-project.com
  mkdir -p /home/ubuntu/template-project/shared/config

  # Back on your machine
  cd template-project
  scp config/master.key rails@template-project.com:~/template-project/shared/config
  ```

  5. Adjust your production database `config/database.yml` file and set env for deployment in `config/deploy.rb`.
  ```
  set :default_env, {
    PATH: '$HOME/.nvm/versions/node/v14.16.0/bin/:$PATH',  
    NODE_ENVIRONMENT: 'production',
    DATABASE_URL: "postgresql://postgres:postgres@localhost:5432/taxsam_sia"
  }
  ```  

  6. try to deploy to production with actual server.
  ```
  cap production deploy
  ```

  7. access log for capistrano run :
  ```
  cap production rails:logs
  ```

  8. Note 
  - to turn on assets sync please see the document in `lib/tasks/asset_sync.rake`
  - to setup WA please fill teh ENV for twillio.

  <p align="right">(<a href="#top">back to top</a>)</p>

<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the template to be such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/taxsam_sia`)
3. Commit your Changes (`git commit -m 'Add some taxsam_sia'`)
4. Push to the Branch (`git push origin feature/taxsam_sia`)
5. Open a Pull Request

<p align="right">(<a href="#top">back to top</a>)</p>


<!-- LICENSE -->
## License

Distributed under the <a href="https://wellcode.io"> WELLCODE.IO </a> License.

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Wellcode.io - (https://wellcode.io/) - admin@wellcode.io

Project Link: [https://github.com/wellcodeglobal/taxsam_sia.git](https://github.com/wellcodeglobal/taxsam_sia.git)

<p align="right">(<a href="#top">back to top</a>)</p>
