# == Class: debian_vagrant::vboxguest
#
# Download and install VBox Guest Additions
#
class debian_vagrant::vboxguest {

  include wget

  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  if file('/home/vagrant/.vbox_version', '/dev/null') != '' {
    $virtualbox_version = generate('/bin/cat', '/home/vagrant/.vbox_version')
  }
  else {
    $virtualbox_version = '5.2.20'
  }
  exec { 'Ensure correct kernel headers are installed':
    command => "apt -y install linux-headers-$(uname -r)",
  }
  exec { 'Create /media/VBoxGuestAdditions':
    command => 'mkdir -p /media/VBoxGuestAdditions',
    creates => '/media/VBoxGuestAdditions',
  }
  -> wget::fetch { 'Get VBoxGuestAdditions':
    source             => "http://download.virtualbox.org/virtualbox/${virtualbox_version}/VBoxGuestAdditions_${virtualbox_version}.iso",
    destination        => "/home/vagrant/VBoxGuestAdditions_${virtualbox_version}.iso",
    timeout            => 0,
    verbose            => true,
    nocheckcertificate => true,
  }
  -> exec { 'Mount VBoxGuestAdditions':
    command => "mount -o loop,ro \
                /home/vagrant/VBoxGuestAdditions_${virtualbox_version}.iso \
                /media/VBoxGuestAdditions",
  }
  -> exec { 'Install VBoxGuestAdditions':
    command => 'sh /media/VBoxGuestAdditions/VBoxLinuxAdditions.run || true',
  }
  -> exec { 'Check VBoxGuestAdditions':
    command => '/bin/true',
    onlyif  => '/usr/bin/test -e /lib/modules/$(uname -r)/misc/vboxsf.ko',
  }
  -> file { "/home/vagrant/VBoxGuestAdditions_${virtualbox_version}.iso":
    ensure => 'absent',
  }
  -> exec { 'Unmount VBoxGuestAdditions':
    command => 'umount /media/VBoxGuestAdditions',
  }
  -> exec { 'Remove /media/VBoxGuestAddition':
    command => 'rm -r /media/VBoxGuestAdditions',
  }

}
