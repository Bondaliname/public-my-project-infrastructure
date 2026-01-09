resource "null_resource" "wait_for_traefik_ip" {
  provisioner "local-exec" {
    command = <<EOT
      until kubectl get svc traefik -n traefik -o jsonpath='{.status.loadBalancer.ingress[0].ip}' | grep -E '[0-9]'; do
        echo "Waiting for Traefik LoadBalancer IP..."
        sleep 10
      done
    EOT
  }

  depends_on = [helm_release.traefik]
}
