# Connect to an NFSv4 server over stunnel
#
# No stunnel connections will be made to the local system if possible due to
# the likelihood of a port conflict. If you're connecting to the local system,
# please use a direct connection.
#
# @param name [Simplib::Host::Port]
#   An ``<ip>:<port>`` combination to the remote NFSv4 server
#
#   * The ``port`` must be the port upon which the **local** stunnel should
#     listen for connections from the local system's NFS services.
#
# @param nfs_connect_port
#   The ``stunnel`` remote connection port
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
#
define nfs::client::stunnel::v4 (
  Simplib::Port $nfs_connect_port = 20490
) {
  include '::nfs::client'

  if $name !~ Simplib::Host::Port {
    fail('$name must be a Simplib::Host::Port => `<host>:<port>`')
  }

  $_target_parts = split($name, ':')

  $_nfs_server = join($_target_parts[0,-2],':')
  $_nfs_port = $_target_parts[-1]

  # Don't do this if you're running on yourself because, well, it's bad!
  if host_is_me($_nfs_server) {
    warning("You are trying to use stunnel for a local connection to '${name}'. Please use a direct connection.")
  }
  else {
    include '::stunnel'

    stunnel::connection { "nfs4_${name}_client":
      connect => ["${_nfs_server}:${nfs_connect_port}"],
      accept  => "127.0.0.1:${$_nfs_port}",
      verify  => $::nfs::client::stunnel_verify
    }
  }
}
