provider "kubernetes" {
  # Configuration options
    config_path = "~/.kube/config"

}
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# If you need to install dashbboard then resource helm_release is applicable

# resource "helm_release" "my-kubernetes-dashboard" {

#   name = "my-kubernetes-dashboard"
#   repository = "https://kubernetes.github.io/dashboard/"
#   chart      = "kubernetes-dashboard"
#   namespace  = "local_ns"
# }

data "kubernetes_all_namespaces" "allns" {}

output "all-ns" {
  value = data.kubernetes_all_namespaces.allns.namespaces
}

resource "kubernetes_namespace" "example" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "local_ns"
  }
}


resource "kubernetes_service_account_v1" "example" {
   metadata {
     name = "localadmin"
     namespace = "local_ns"
    }
   depends_on = [kubernetes_namespace.example ]
}

resource "kubernetes_secret" "example" {
   metadata {
     name = "dashboard-token"
     namespace = "local_ns"
     annotations = {
       "kubernetes.io/service-account.name" = "local"
     }
    }

   type                           = "kubernetes.io/service-account-token"

    depends_on = [
     kubernetes_service_account_v1.example ,
     kubernetes_namespace.example
   ]
}


resource "kubernetes_cluster_role_binding_v1" "example" {
   metadata {
     name = "terraform-cluster"
   }
   role_ref {
     api_group = "rbac.authorization.k8s.io"
     kind      = "ClusterRole"
     name      = "cluster-admin"
   }
   subject {
     kind      = "ServiceAccount"
     name      = "local"
     namespace = "local_ns"
   }
   depends_on = [
     kubernetes_namespace.example,
     kubernetes_service_account_v1.example
   ]
}


output "tokenValue" {
   value = nonsensitive(kubernetes_secret.example.data.token)
 }
