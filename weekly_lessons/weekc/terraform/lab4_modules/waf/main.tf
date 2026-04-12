#Security Policy

resource "google_compute_security_policy" "waf" {
  name = "${var.name}-policy"

  # Allow your IP (example)
  rule {
    priority = 1000
    action   = "allow"

    match {
      versioned_expr = "SRC_IPS_V1"

      config {
        src_ip_ranges = ["YOUR_IP/32"]
      }
    }

    description = "Allow trusted IP"
  }

  # Basic SQL injection protection
  rule {
    priority = 2000
    action   = "deny(403)"

    match {
      expr {
        expression = "evaluatePreconfiguredExpr('sqli-v33-stable')"
      }
    }

    description = "Block SQL injection"
  }

  # Default allow (required)
  rule {
    priority = 2147483647
    action   = "allow"

    match {
      versioned_expr = "SRC_IPS_V1"

      config {
        src_ip_ranges = ["*"]
      }
    }

    description = "Default allow"
  }
}

#Attach to Backend Service

resource "google_compute_backend_service" "secured_backend" {
  name          = "${var.name}-secured-backend"
  protocol      = "HTTP"
  timeout_sec   = 10
  health_checks = []

  security_policy = google_compute_security_policy.waf.id
}



variable "name" {
  type = string
}

variable "enable_geo_blocking" {
  type    = bool
  default = true
}

variable "blocked_region_codes" {
  type    = list(string)
  default = []
}

variable "enable_rate_limit" {
  type    = bool
  default = true
}

variable "rate_limit_count" {
  type    = number
  default = 100
}

variable "rate_limit_interval_sec" {
  type    = number
  default = 60
}

variable "enable_waf_rules" {
  type    = bool
  default = true
}

variable "enable_bot_management" {
  type    = bool
  default = false
}

variable "recaptcha_redirect_site_key" {
  type    = string
  default = ""
}


