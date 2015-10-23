# == Class: certs
#
# The certs class can be called directly and it will instantiate any vhosts defined.
# It could also be called to just provide a default_source_path.
#
# === Parameters
#
# [default_source_path]
#   String - The default location of the certificate  and key files. Typically
#   references a module's files. e.g. 'puppet:///site_certs' will search
#   $modulepath/site_certs/files on the master for the specified files.
#
# [default_target_path]
#   String - Location where the certificate files will be stored on the managed
#   node.
#   Optional value, defaults to '/etc/ssl/certs'
#
# [default_service]
#   String - Default Name of the web server service to notify when certificates
#   are updated.
#   Optional value, defaults to 'httpd'
#
# === Examples
#
# [vhosts]
#   List or Hash of certs::vhost resources to create
#   NOTE: List only makes sense if you also specify default_source_path
#
# === Examples
#
# ==== Example 1: Install List of certs from source path
#  Without Hiera:
#    (Why would you do this to yourself?)
#
#    $vhosts = [
#      'www.example.com',
#      'www.sample.com',
#      'www.whatever.net',
#    ]
#
#    class {'certs':
#      default_source_path => 'puppet:///site_certificates',
#      vhosts              => $vhosts
#    }
#
#  With Hiera:
#
#    server.yaml
#    ---
#    certs::default_source_path: puppet:///site_certificates
#    certs::vhosts:
#      - www.example.com
#      - www.sample.com
#      - www.whatever.net
#
#    manifest.pp
#    ---
#    include ::certs
#    Certs::Vhost<| |> -> Apache::Vhost<| |>
#
# ==== Example 2: Install Hash of certs
#  Without Hiera:
#    (Why would you do this to yourself?)
#
#    $vhosts = {
#      'www.example.com' => {}, # default path
#      'www.sample.com'  => {
#         source_path    =>  'puppet:///another_site_module',
#      },
#      'www.whatever.net => {
#        cert            => 'PEM ENCODED CERTIFICATE',
#        key             => 'PEM ENCODED KEY',
#      },
#    }
#
#    class {'certs':
#      default_source_path => 'puppet:///site_certificates',
#      vhosts              => $vhosts
#    }
#
#  With Hiera:
#
#    server.yaml
#    ---
#    certs::default_source_path: puppet:///site_certificates
#    certs::vhosts:
#      www.example.com: {}
#      www.sample.com:
#        source_path: puppet:///another_site_module
#      www.whatever.net:
#        cert: |
#          -----BEGIN CERTIFICATE-----
#          MIIF.....
#          ........
#          ........
#          -----END CERTIFICATE-----
#
#        # We suggest using eyaml or something similar to protect the private key below
#        key: |
#          -----BEGIN RSA PRIVATE KEY-----
#          MIIJ....
#          .......
#          .......
#          .......
#          -----END RSA PRIVATE KEY-----
#
#    manifest.pp
#    ---
#    include ::certs
#    Certs::Vhost<| |> -> Apache::Vhost<| |>
#
#
# === Authors
#
# Rob Nelson <rnelson0@gmail.com>
#  and
# Tommy McNeely <tommy@lark-it.com>
#
# === Copyright
#
# Copyright 2014 Rob Nelson
#
class certs (
  $default_source_path = undef,
  $default_target_path = '/etc/pki/ssl',
  $default_service = 'httpd',
  $vhosts = [],
) {
  # Input Validation? or let is pass through? probably should be done here.

  # Setup vhost_defaults
  $vhost_defaults = {
    'source_path'     => $default_source_path,
    'target_path'     => $default_target_path,
    'default_service' => $default_service,
  }

  # Setup certs::vhosts that were defined to init.pp
  if is_hash($vhosts) {
    create_resources( 'certs::vhosts', $vhosts, $vhost_defaults)
  } else {
    ensure_resource( 'certs::vhosts', $vhosts, $vhost_defaults)
  }
}
