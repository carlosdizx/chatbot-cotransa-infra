output "output_ec2_ip_public" {
  description = "Dirección IP pública de las instancia EC2 del chatbot"
  value       = "Dirección de la instancia es http://${aws_instance.chatbot.public_ip}:8501"
}

output "output_ec2_connect_ssh" {
  description = "Instrucciones para conectarse por SSH"
  value = <<-EOT
    Ejecuta (Unix/Linux):
      chmod 400 ${local_file.private_key_file.filename}
    Luego, conéctate con:
      ssh -i ${local_file.private_key_file.filename} ec2-user@${aws_instance.chatbot.public_ip}
  EOT
}