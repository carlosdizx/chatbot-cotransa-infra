output "private_key_path" {
  value = local_file.private_key_file.filename
}

output "public_key_path" {
  value = local_file.public_key_file.filename
}