# == Define: certs::vhost
#
# SSL Certificate File Management
#
# Intended to be used in conjunction with puppetlabs/apache's apache::vhost
# definitions, to provide the ssl_cert and ssl_key files.
#
# === Parameters
#
# [name]
# The title of the resource matches the certificate's name
# e.g. 'www.example.com' matches the certificate for the hostname
# 'www.example.com'
#
# [cert]
# The raw content of the certificate overriedes looking for the certificate
# file in source_path (below). Can be used to get the certificate from heira.
#
# [key]
# The raw content of the private key overriedes looking for the private key
# file in source_path (below). Can be used to get the private key from heira.
#
# [source_path]
# The location of the certificate files. Typically references a module's files.
# e.g. 'puppet:///site_certs' wills earch $modulepath/site_certs/files on the
# master for the specified files.
#
# [target_path]
# Location where the certificate files will be stored on the managed node.
# Optional value, defaults to $certs::default_target_path
#
# [service]
# Name of the web server service to notify when certificates are updated.
# Optional value, defaults to $certs::default_service
#
# === Examples
#
#  Without Hiera:
#
#    $cname = www.example.com
#    certs::vhost{ $cname:
#      source_path => 'puppet:///site_certificates',
#    }
#
#  With Hiera:
#
#    server.yaml
#    ---
#    certsvhost:
#      'www.example.com':
#        source_path: 'puppet:///modules/site_certificates/'
#
#    manifest.pp
#    ---
#    certsvhost = hiera_hash('certsvhost')
#    create_resources(certs::vhost, certsvhost)
#    Certs::Vhost<| |> -> Apache::Vhost<| |>
#
# === Authors
#
# Rob Nelson <rnelson0@gmail.com>
#
# === Copyright
#
# Copyright 2014 Rob Nelson
#
define certs::vhost (
  $source_path = $certs::default_source_path,
  $cert = undef,
  $key = undef,
  $target_path = $certs::default_target_path,
  $service     = $certs::default_service
) {
  if ($name == undef) {
    fail('You must provide a name value for the vhost to certs::vhost.')
  }

  if ($target_path == undef) {
    fail('You must provide a target_ path for the certs to certs::vhost.')
  }

  $crt_filename = "${name}.crt"
  $key_filename = "${name}.key"

  if ($cert != undef) {
    # Use the cert provided instead of looking in source_path
    $cert_source = undef
  } else {
    if ($source_path != undef) {
      $cert_source = "${source_path}/${crt_filename}"
    } else {
      fail('You must provide a source_path for the SSL files or cert to certs::vhost.')
    }
  }

  if ($key != undef) {
    # Use the cert provided instead of looking in source_path
    $key_source = undef
  } else {
    if ($source_path != undef) {
      $key_source = "${source_path}/${key_filename}"
    } else {
      fail('You must provide a source_path for the SSL files or key to certs::vhost.')
    }
  }

  file { $crt_filename:
    ensure  => file,
    path    => "${target_path}/${crt_filename}",
    content => $cert,
    source  => $cert_source,
    notify  => Service[$service],
  } ->

  file { $key_filename:
    ensure  => file,
    path    => "${target_path}/${key_filename}",
    content => $key,
    source  => $key_source,
    notify  => Service[$service],
  }
}
