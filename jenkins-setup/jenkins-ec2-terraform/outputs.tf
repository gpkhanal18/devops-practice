output "jenkins_master_ip" {
  value = aws_instance.jenkins_master.public_ip
}

output "jenkins_agent_ips" {
  value = [for agent in aws_instance.jenkins_agents : agent.public_ip]
}
