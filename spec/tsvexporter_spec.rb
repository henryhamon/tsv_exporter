require 'rubygems'
require 'spec'
require 'active_support'
require 'iconv'

require File.dirname(__FILE__) + '/../lib/tsv_exporter'
Array.send :include, TsvExporter

BOM = "\377\376"

class User
  attr_accessor :id
  attr_accessor :username
  attr_accessor :email
  attr_accessor :password
  attr_accessor :parent
  
  def initialize(options = {})
    @id       = options[:id]
    @username = options[:username]
    @email    = options[:email]
    @password = options[:password]
  end
  
  def a_virtual_attribute
    username.reverse
  end
  
  def attributes # This method is available by default on all ActiveRecord objects
    { 'id' => id, 'username' => username, 'email' => email, 'password' => password }
  end
end

describe "to_tsv" do
  
  before(:each) do 
    @data = []
    3.times do |i|
      @data << User.new(:id => i+1, :username => "user_#{i+1}", :email => "user_#{i+1}@test.br", :password => "a_password")
    end
  end
  
  it "should generate a valid TSV representation of the data" do
    tsv = @data.to_tsv [:id, :username, :email, :password]
    tsv.should == BOM + Iconv.conv("utf-16le", "utf-8", "id\tusername\temail\tpassword\n1\tuser_1\tuser_1@test.br\ta_password\n2\tuser_2\tuser_2@test.br\ta_password\n3\tuser_3\tuser_3@test.br\ta_password\n")
  end
  
  it "should include only specified attributes" do
    tsv = @data.to_tsv [:id, :username]
    tsv.should == BOM + Iconv.conv("utf-16le", "utf-8", "id\tusername\n1\tuser_1\n2\tuser_2\n3\tuser_3\n")
  end
  
  it "should include virtual attributes if they are specified" do
    tsv = @data.to_tsv [:id, :username, :a_virtual_attribute]
    tsv.should == BOM + Iconv.conv("utf-16le", "utf-8", "id\tusername\ta_virtual_attribute\n1\tuser_1\t1_resu\n2\tuser_2\t2_resu\n3\tuser_3\t3_resu\n")
  end
  
  it "should not generate rows if there is no data" do
    @data = []
    tsv = @data.to_tsv [:id, :username]
    tsv.should == BOM + Iconv.conv("utf-16le", "utf-8", "id\tusername\n")
  end
  
end
