# Cody Herriges <c.a.herriges@gmail.com>
#
# Testing the feasibility of generating a fact on the fly for every package
# present on the system.

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
    setcode do
      value
    end 
  end 

end
