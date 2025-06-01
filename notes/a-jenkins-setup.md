ran these two commands 
brew install terraform
brew install awscli

python3 -m pip install --user ansible  
don't use brew to install ansible as it tries to download large files 

ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa


created aws console account 
created terraform-user with programmatic access 
created user santosh with console and programmatic access 

created main.tf variable.tf and output.tf file to create ec2 instances using terraform 

pushed the change to github (optional)


use 
source ~/ansible-env/bin/activate

to activate ansible env then ansible aws and terraform are available 


The output looks like 
gopal:~ gopalkhanal$ source ~/ansible-env/bin/activate
(ansible-env) gopal:~ gopalkhanal$ terraform --version
Terraform v1.12.1
on darwin_amd64
(ansible-env) gopal:~ gopalkhanal$ aws --version
aws-cli/2.27.26 Python/3.13.3 Darwin/21.6.0 exe/x86_64
(ansible-env) gopal:~ gopalkhanal$ ansible --version
ansible [core 2.18.6]
  config file = None
  configured module search path = ['/Users/gopalkhanal/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /Users/gopalkhanal/ansible-env/lib/python3.13/site-packages/ansible
  ansible collection location = /Users/gopalkhanal/.ansible/collections:/usr/share/ansible/collections
  executable location = /Users/gopalkhanal/ansible-env/bin/ansible
  python version = 3.13.3 (v3.13.3:6280bb54784, Apr  8 2025, 10:47:54) [Clang 15.0.0 (clang-1500.3.9.4)] (/Users/gopalkhanal/ansible-env/bin/python3.13)
  jinja version = 3.1.6
  libyaml = True
(ansible-env) gopal:~ gopalkhanal$ 


Then do aws configure 

and run this to verify cli is set properly 
aws sts get-caller-identity


create keypair and download called terraform-jenkins.pem from console 

then run this 
Perfect! Based on your setup, here is the complete **Terraform infrastructure setup** to launch:

* ✅ 1 Jenkins master (EC2)
* ✅ 2 Jenkins agents (EC2)
* ✅ Shared security group
* ✅ Uses your existing key pair: `terraform-jenkins`

---

## 📁 Project Folder Structure

```bash
mkdir jenkins-ec2-terraform && cd jenkins-ec2-terraform
touch main.tf variables.tf outputs.tf
```

---

## 🛠️ Step-by-Step Setup

---

### ✍️ `variables.tf`

```hcl
variable "region" {
  default = "us-east-1"
}

variable "key_name" {
  default     = "terraform-jenkins"
  description = "Name of your existing EC2 key pair"
}

variable "public_key_path" {
  default     = "/Users/gopalkhanal/.ssh/id_rsa.pub"
  description = "Path to your public SSH key"
}
```

---

### ✍️ `main.tf`

```hcl
provider "aws" {
  region = var.region
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH and Jenkins port"

  ingress = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "jenkins_master" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]

  tags = {
    Name = "jenkins-master"
  }
}

resource "aws_instance" "jenkins_agents" {
  count                       = 2
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.small"
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]

  tags = {
    Name = "jenkins-agent-${count.index + 1}"
  }
}
```

---

### ✍️ `outputs.tf`

```hcl
output "jenkins_master_ip" {
  value = aws_instance.jenkins_master.public_ip
}

output "jenkins_agent_ips" {
  value = [for agent in aws_instance.jenkins_agents : agent.public_ip]
}
```

---

## 🚀 Deploy Instructions

### ✅ Step 1: Initialize Terraform

```bash
cd jenkins-ec2-terraform
terraform init
```

### ✅ Step 2: Apply

```bash
terraform apply
```

> Confirm with `yes` when prompted.

---

## ✅ After Apply

Terraform will output:

* `jenkins_master_ip`
* `jenkins_agent_ips`

Copy those IPs to use in your `inventory.ini` for Ansible.

---

## 🔑 SSH Access

To SSH into the instances:

```bash
chmod 400 ~/.ssh/terraform-jenkins.pem

ssh -i ~/.ssh/terraform-jenkins.pem ubuntu@<jenkins_master_ip>
```

---

Would you like me to generate the Ansible `inventory.ini` and the full playbook next to install Jenkins and connect agents?


--------------------Now we will setup jenkins 

create jenkins-ansible folder and update files and run the cocmmand from same level as inventory.ini file 


ansible-playbook -i inventory.ini playbook.yml

Absolutely! Here's a **complete, clean setup** to configure your Jenkins Master + 2 Agents using **Ansible**, now fully aligned with:

✅ Your valid key pair name: `terraform-jenkins`
✅ Private key location: `/Users/gopalkhanal/.ssh/terraform-jenkins.pem`
✅ Public key location: `/Users/gopalkhanal/.ssh/id_rsa.pub`
✅ EC2 IPs provisioned via Terraform

---

## 📁 Ansible Project Structure

```
jenkins-ansible/
├── inventory.ini
├── playbook.yml
└── roles/
    ├── common/
    │   └── tasks/
    │       └── main.yml
    ├── jenkins-master/
    │   └── tasks/
    │       └── main.yml
    └── jenkins-agent/
        └── tasks/
            └── main.yml
```

---

## 📄 inventory.ini

```ini
[jenkins_master]
master ansible_host=54.224.143.121 ansible_user=ubuntu ansible_ssh_private_key_file=/Users/gopalkhanal/.ssh/terraform-jenkins.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[jenkins_agents]
agent1 ansible_host=3.81.47.190 ansible_user=ubuntu ansible_ssh_private_key_file=/Users/gopalkhanal/.ssh/terraform-jenkins.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'
agent2 ansible_host=13.217.38.6 ansible_user=ubuntu ansible_ssh_private_key_file=/Users/gopalkhanal/.ssh/terraform-jenkins.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

---

## 📄 playbook.yml

```yaml
- name: Install Java on all nodes
  hosts: all
  become: yes
  roles:
    - common

- name: Install and configure Jenkins on master
  hosts: jenkins_master
  become: yes
  roles:
    - jenkins-master

- name: Authorize Jenkins master on agent nodes
  hosts: jenkins_agents
  become: yes
  roles:
    - jenkins-agent
```

---

## 📄 roles/common/tasks/main.yml

```yaml
- name: Update APT cache
  apt:
    update_cache: yes

- name: Install Java
  apt:
    name: openjdk-17-jdk
    state: present
```

---

## 📄 roles/jenkins-master/tasks/main.yml

```yaml
- name: Add Jenkins GPG key
  apt_key:
    url: https://pkg.jenkins.io/debian-stable/jenkins.io.key
    state: present

- name: Add Jenkins repository
  apt_repository:
    repo: deb https://pkg.jenkins.io/debian-stable binary/
    state: present

- name: Install Jenkins
  apt:
    name: jenkins
    state: present

- name: Enable and start Jenkins
  service:
    name: jenkins
    state: started
    enabled: yes

- name: Create .ssh directory for Jenkins user
  file:
    path: /var/lib/jenkins/.ssh
    state: directory
    mode: 0700
    owner: jenkins
    group: jenkins

- name: Generate SSH keypair for Jenkins
  command: ssh-keygen -t rsa -b 4096 -f /var/lib/jenkins/.ssh/id_rsa -N ""
  args:
    creates: /var/lib/jenkins/.ssh/id_rsa

- name: Ensure ownership of Jenkins .ssh directory
  file:
    path: /var/lib/jenkins/.ssh
    state: directory
    recurse: yes
    owner: jenkins
    group: jenkins

- name: Read Jenkins public key
  slurp:
    src: /var/lib/jenkins/.ssh/id_rsa.pub
  register: jenkins_pubkey

- name: Set public key fact
  set_fact:
    jenkins_public_key: "{{ jenkins_pubkey.content | b64decode }}"
```

---

## 📄 roles/jenkins-agent/tasks/main.yml

```yaml
- name: Create .ssh directory for ubuntu
  file:
    path: /home/ubuntu/.ssh
    state: directory
    mode: 0700
    owner: ubuntu
    group: ubuntu

- name: Add Jenkins master public key to authorized_keys
  copy:
    content: "{{ hostvars['master'].jenkins_public_key }}"
    dest: /home/ubuntu/.ssh/authorized_keys
    owner: ubuntu
    group: ubuntu
    mode: 0600
```

---

## 🚀 Run the Setup

From the root of your Ansible project (`jenkins-ansible/`), run:

```bash
ansible-playbook -i inventory.ini playbook.yml
```

---

## ✅ After Setup

1. **Access Jenkins**:
   `http://54.224.143.121:8080`

2. **Unlock Jenkins**:

```bash
ssh -i ~/.ssh/terraform-jenkins.pem ubuntu@54.224.143.121
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

3. **Manually add agents in Jenkins UI** (or automate later):

   * **Manage Jenkins > Nodes > New Node**
   * Launch via SSH
   * IP: `agent1`, `agent2`
   * User: `ubuntu`
   * Use the private key from `/var/lib/jenkins/.ssh/id_rsa`

---

Would you like:

* A `.zip` download of this project?
* Help automating agent registration via Groovy/CLI?
* Add Git, Maven, or Docker to your agents?


----------------------------
after this we need to register nodes 
Perfect! Here's your **step-by-step guide** to **manually add Jenkins agents** using the Jenkins UI, now that SSH keys are set up and working between your master and agents.

---

## 🎯 GOAL:

Add 2 Jenkins agents via the web UI (using SSH), without needing to install any extra software on the agents.

---

## ✅ Prerequisites (already covered):

* Jenkins is running on: `http://54.224.143.121:8080`
* You have the **private key** at `/var/lib/jenkins/.ssh/id_rsa` (generated via Ansible)
* Jenkins master can SSH into both agents (`agent1`, `agent2`)
* Ports are open (22, 8080)
* User on agents is: `ubuntu`

---

## 🧭 Steps to Manually Add an Agent in Jenkins UI

---

### 🔐 Step 1: Log into Jenkins UI

* Open browser: `http://54.224.143.121:8080`
* If prompted for unlock:

  ```bash
  ssh -i ~/.ssh/terraform-jenkins.pem ubuntu@54.224.143.121
  sudo cat /var/lib/jenkins/secrets/initialAdminPassword
  ```
* Complete plugin installation (if not already done)
* Create an admin user or continue as admin

---

### ⚙️ Step 2: Go to “Manage Jenkins”

* Click **Manage Jenkins** from the sidebar
* Click **Nodes and Clouds**
* Click **New Node**

---

### 🛠️ Step 3: Create Agent 1

* **Name**: `agent1`
* Select: **Permanent Agent**
* Click **OK**

Then fill in:

| Field                 | Value                             |
| --------------------- | --------------------------------- |
| # of Executors        | `1`                               |
| Remote root directory | `/home/ubuntu/agent`              |
| Labels (optional)     | `linux`                           |
| Usage                 | Use this node as much as possible |
| Launch method         | Launch agents via SSH             |
| Host                  | `3.81.47.190`                     |
| Credentials           | Click "Add → Jenkins"             |

Now in the Credentials popup:

1. **Kind**: SSH Username with private key
2. **Username**: `ubuntu`
3. **Private key**:

   * Select `Enter directly`
   * Run this command on the master node and copy the output:

     ```bash
     sudo cat /var/lib/jenkins/.ssh/id_rsa
     ```
   * Paste it into the private key box
4. Click **Add**

Back in the agent config:

* Select the newly added credential
* Leave the rest as default

Click **Save**

Jenkins will now attempt to connect via SSH.

---

### 🔁 Step 4: Repeat for Agent 2

* Name: `agent2`
* Host: `13.217.38.6`
* All other settings remain the same as `agent1`
* Use the **same credential**

---

### ✅ Step 5: Verify Connection

* Go to **Manage Jenkins > Nodes**
* You should see `master`, `agent1`, and `agent2`
* Agent icons should be 🟢 (connected)
* If any show red ❌, click on the agent and check logs

---

## 🧪 Optional Verification

From Jenkins master:

```bash
ssh -i /var/lib/jenkins/.ssh/id_rsa ubuntu@3.81.47.190
```

This confirms Jenkins master can reach the agent.

---

Let me know if:

* You want to add labels to target specific jobs to these agents
* Or restrict certain jobs to only run on agents


-------------------ssh connection from jenkins master will fail to agents use below 
to fix 
Option 1: Switch to “Non-verifying” SSH Key Verification (Recommended for Dev/Test)
Go to Manage Jenkins > Nodes > agent1 > Configure

Scroll to Launch method > Advanced

Find: Host Key Verification Strategy

Change from:

KnownHostsFileKeyVerificationStrategy

✅ to: Non verifying Verification Strategy

Click Save

➡️ Jenkins will now skip checking the known_hosts file and allow the SSH connection.