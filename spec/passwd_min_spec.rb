require 'spec_helper'

describe Ohai::System, "plugin etc" do
  before(:each) do
    @ohai = Ohai::System.new
    @ohai.stub!(:require_plugin).and_return(true)
    data_passwd = "#ACOMMENT\nsshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin\nvagrant:x:1005:1005::/home/vagrant:/bin/bash\n"
    data_group = "stapdev:x:158:\nwheel:x:10:vagrant\n"
    File.stub(:open).with("/etc/passwd", "r") { |&block| block.yield StringIO.new(data_passwd)}
    File.stub(:open).with("/etc/group", "r") { |&block| block.yield StringIO.new(data_group)}
  end


  it "lists all of the users" do
    @ohai._require_plugin("passwd_min")
    @ohai[:etc][:passwd].keys.sort.should == ["sshd", "vagrant"]
  end

  it "provides the uid of the user" do
    @ohai._require_plugin("passwd_min")
    @ohai[:etc][:passwd]["sshd"]["uid"].should == 74
  end

  it "provides the gid of the user" do
    @ohai._require_plugin("passwd_min")
    @ohai[:etc][:passwd]["sshd"]["gid"].should == 74
  end

  it "provides the gecos of the user" do
    @ohai._require_plugin("passwd_min")
    @ohai[:etc][:passwd]["sshd"]["gecos"].should == "Privilege-separated SSH"
  end

  it "provides the homedir of the user" do
    @ohai._require_plugin("passwd_min")
    @ohai[:etc][:passwd]["sshd"]["dir"].should == "/var/empty/sshd"
  end

  it "provides the shell of the user" do
    @ohai._require_plugin("passwd_min")
    @ohai[:etc][:passwd]["sshd"]["shell"].should == "/sbin/nologin"
  end

  it "lists all of the groups" do
    @ohai._require_plugin("passwd_min")
    @ohai[:etc][:group].keys.sort.should == ["stapdev", "wheel"]
  end

  it "provides the gid of the group" do
    @ohai._require_plugin("passwd_min")
    @ohai[:etc][:group]["wheel"]["gid"].should == 10
  end

  it "lists the group members" do
    @ohai._require_plugin("passwd_min")
    @ohai[:etc][:group]["wheel"]["members"].should == ["vagrant"]
  end

  it "ignores comments in the passwd file" do
    @ohai._require_plugin("passwd_min")
    @ohai[:etc][:passwd].keys.length.should == 2
  end

  it "ignores comments in the group file" do
    @ohai._require_plugin("passwd_min")
    @ohai[:etc][:group].keys.length.should == 2
  end

  it "sets the current user" do
    Etc.should_receive(:getlogin).and_return('wombat')
    @ohai._require_plugin("passwd_min")
    @ohai[:current_user].should == 'wombat'
  end

end
