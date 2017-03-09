#!/usr/bin/env ruby -w

require "socket"
require "sqlite3"

class Server

  attr_reader :bd

  def initialize( port, ip )
    @server = TCPServer.open( ip, port )
    @connections = Hash.new
    @rooms = Hash.new
    @clients = Hash.new
    @connections[:server] = @server
    @connections[:rooms] = @rooms
    @connections[:clients] = @clients
    @db = SQLite3::Database.open "wsbd.db"
    criabasedados
    run
  end

  def criabasedados
    @db.execute "CREATE TABLE IF NOT EXISTS XDKSENSOR(
      ID INTEGER PRIMARY KEY);"
    @db.execute "CREATE TABLE IF NOT EXISTS XDKDADOS(
      ID INTEGER PRIMARY KEY,
      XDKSENSOR_ID VARCHAR(10) NOT NULL,
      TEMPERATURA FLOAT,
      LATITUDE FLOAT NOT NULL,
      LONGITUDE FLOAT NOT NULL,
      FOREIGN KEY (XDKSENSOR_ID) REFERENCES XDKSENSOR(ID));"
  end

  def run
    loop {
      Thread.start(@server.accept) do | client |
        nick_name = client.gets.chomp.to_sym
        @connections[:clients].each do |other_name, other_client|
          if nick_name == other_name || client == other_client
            client.puts "This username already exist"
            Thread.kill self
          end
        end
        puts "#{nick_name} #{client}"
        @connections[:clients][nick_name] = client
        client.puts "Connection established, Thank you for joining!"
        listen_user_messages( nick_name, client )
      end
    }.join
  end

  def listen_user_messages( username, client )
    loop {
      msg = client.gets.chomp
      puts "#{msg}"
     # @connections[:clients].each do |other_name, other_client|
      #unless other_name == username
       #  other_client.puts "#{username.to_s}: #{msg}"
       # end
      #end
    }
  end

end

Server.new( 3000, "localhost" )
