provider "kubernetes" {
  # Configuration options
    alias = "foo"
    config_path = "~/.kube/config"

}
provider "gitlab" {
  token = " "
  base_url = "https://gitlab.com/"
}

provider "helm" {
  alias = "pakage"
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "mariadb-galera" {
   name       = "mariadb-galera"
   repository = "https://charts.bitnami.com/bitnami"
   chart      = "mariadb-galera"
   namespace =  "mariadb"
  
   set {
     name  = "primary.service.ports.mysql"
     value = "3306"
   }

   set {
     name  = "rootUser.user"
     value = "root"
   }

   set {
     name  = "rootUser.password"
     value = "admin"
   }
  
   set {
     name  = "rootUser.forcePassword"
     value = "false"
   }

   set {
     name  = "db.user"
     value = "keycloak"
   }

   set {
     name  = "db.password"
     value = "keycloak"
   }
  
   set {
     name = "db.name"
     value = "keycloak"
   }
 }
