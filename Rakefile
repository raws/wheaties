namespace :rip do
  task :env do
    sh "rip env use wheaties"
  end
  
  desc "Install wheaties using rip"
  task :install => [:env] do
    sh "rip install #{File.dirname(__FILE__)}"
  end
  
  desc "Remove rip installation of wheaties"
  task :uninstall => [:env] do
    sh "rip uninstall wheaties" if `rip list` =~ /wheaties/i
  end
  
  desc "Refresh rip installation of wheaties with the current source"
  task :refresh => [:uninstall, :install]
end
