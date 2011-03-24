# Cody Herriges <cody@puppetlabs.com>
#
# Collects and creates a fact for every package installed on the system and
# returns that package's version as the fact value.  Useful for doing package
# inventory and making decisions based on installed package versions.

case Facter.value(:operatingsystem)
  when 'Debian', 'Ubuntu'
    command = 'dpkg-query -W'
    packages = []
    Facter::Util::Resolution.exec(command).each_line do |pkg|
      packages << pkg.chomp.split("\t")
    end
  when 'CentOS', 'RedHat', 'Fedora'
    command = 'rpm -qa --qf %{NAME}"\t"%{VERSION}-%{RELEASE}"\n"'
    packages = []
    Facter::Util::Resolution.exec(command).each_line do |pkg|
      packages << pkg.chomp.split("\t")
    end
  when 'Solaris'
    command = 'pkginfo -x'
    combined = ''
    packages = []
    Facter::Util::Resolution.exec(command).each_line do |line|
      if line =~ /^\w/
        then
          combined << line.chomp
        else
          combined << line
      end
    end
    combined.each_line do |pkg|
      packages << pkg.chomp.scan(/^(\S+).*\s(\d.*)/)[0]
    end
end

packages.each do |key, value|
  Facter.add(:"pkg_#{key}") do
    confine :operatingsystem => %w{CentOS Fedora Redhat Debian Ubuntu Solaris}
    setcode do
      value
    end
  end

end
