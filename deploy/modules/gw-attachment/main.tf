#################################
# Federation script
#################################

locals {
  lock_shell_cmds = file("${path.module}/grab_lock.sh")
  federate_hub_cmds = templatefile("${path.module}/federate_hub.tpl", {
    ssh_key_path = var.hub_ssh_key_path
    dsf_gw_ip    = var.gw
    dsf_hub_ip   = var.hub
  })
  federate_gw_cmds = templatefile("${path.module}/federate_gw.tpl", {
    ssh_key_path = var.hub_ssh_key_path
    gw_ssh_key_path = var.gw_ssh_key_path != null ? var.gw_ssh_key_path : var.hub_ssh_key_path
    dsf_gw_ip    = var.gw
    dsf_hub_ip   = var.hub
  })
  sleep_value = "40s"
}

resource "time_sleep" "sleep" {
  create_duration = local.sleep_value
}

resource "null_resource" "federate_cmds" {
  provisioner "local-exec" {
    command     = "${local.lock_shell_cmds} ${local.federate_hub_cmds} ${local.federate_gw_cmds}"
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [
    time_sleep.sleep,
  ]
  triggers = {
    installation_source = "${var.installation_source}",
  }
}