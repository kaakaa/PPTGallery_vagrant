#########
# setup #
#########

remote_file "/tmp/rpmforge.rpm" do
	source "http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.i686.rpm"
	owner "vagrant"
	group "vagrant"
end

package "rpmforge" do
	action :install
	provider Chef::Provider::Package::Rpm
	source "/tmp/rpmforge.rpm"
end

bash "yum_update" do
	code <<-EOH
	  sudo yum -y update rpmforge-release
	  sudo yum update -y
	EOH
end

#########################
# Install Ruby on rbenv #
#########################

%w(libyaml libyaml-devel zlib zlib-devel readline readline-devel openssl openssl-devel libxml2 libxml2-devel libxslt libxslt-devel git).each do |pkgname|
	package pkgname do
		action :install
	end
end

# Install rbenv
git "/home/vagrant/.rbenv" do
	user "vagrant"
	group "vagrant"
	repository "https://github.com/sstephenson/rbenv.git"


	reference "master"
	action :sync
end

directory "/home/vagrant/.rbenv/plugins" do
	owner "vagrant"
	group "vagrant"
	mode "0755"
	action :create
end

template "/etc/profile.d/rbenv.sh" do
	source "rbenv.sh.erb"
	owner "vagrant"
	group "vagrant"
	mode "0644"
end

git "/home/vagrant/.rbenv/plugins/ruby-build" do
	user "vagrant"
	group "vagrant"
	repository "https://github.com/sstephenson/ruby-build.git"
	reference "master"
	action :checkout
end

# Install Ruby 1.9.3-p484
execute "ruby install" do
	not_if "source /etc/profile.d/rbenv.sh; rbenv versions | grep 1.9.3-p484"
	command "source /etc/profile.d/rbenv.sh; rbenv install 1.9.3-p484; rbenv rehash;rbenv shell 1.9.3-p484"
	action :run
end

#######################
# Install LivreOffice #
#######################

%w(libfreetype.so.6 libgnomevfs-2.so.0 libgconf-2.so.4 libXinerama.so.1 libcups.so.2 java-1.7.0-openjdk desktop-file-utils).each do |pkgname|
	package pkgname do
		action :install
	end
end

remote_file "/tmp/LibreOffice.tar.gz" do
	source "#{node.libreoffice.download}"
	owner "vagrant"
	group "vagrant"
	mode "0644"
end

# Install LibreOffice
bash "install_libre_office" do
	cwd "/tmp"
	code <<-EOH
	  tar xvf LibreOffice.tar.gz
	  rpm -ivh LibreOffice_4.1.4.2_Linux_x86-64_rpm/RPMS/*.rpm
	EOH
end

# Set up LibreOffice daemon
#
# In first time setting up, soffice don't return control.
# So ending up first setting up by timeout, and retry soffice setting.
bash "setup_libreoffice" do
	timeout 300
	code <<-EOH
	  unset DISPLAY
	  /opt/libreoffice4.1/program/soffice --headless --invisible --nologo --accept="socket,host=127.0.0.1,port=8100;urp;"
	EOH
	retries 3
end

#######################
# Install ImageMagick #
#######################
%w(libjpeg-devel libpng-devel ImageMagick ImageMagick-devel).each do |pkgname|
	package pkgname do
		action :install
	end
end

#####################
# Set up PPTGallery #
#####################
git "/home/vagrant/PPTGallery" do
	user "vagrant"
	group "vagrant"
	repository "https://github.com/kaakaa/PPTGallery.git"
	reference "master"
	action :sync
end

bash "execute_application" do
	cwd "/home/vagrant/PPTGallery"
	code <<-EOH
	  source /etc/profile.d/rbenv.sh
          rbenv shell 1.9.3-p484
	  rbenv exec gem install bundler
	  rbenv exec bundle install --path vendor/bundle
	  rbenv exec bundle exec foreman start
	EOH
end
