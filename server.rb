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
    @response = nil
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
            client.puts "Esse aparelho ja e tem sessão iniciada"
            Thread.kill self
          end
        end
        puts "#{nick_name} #{client}"
        @connections[:clients][nick_name] = client
        client.puts "Conexão establecida, Obrigado por se Juntar a nós!"
        listen_user_messages( nick_name, client )
        menu

      end
    }.join
    @response.join
  end

  def listen_user_messages( username, client )
    @response = Thread.new do
    loop {
      msg = client.gets.chomp
      values = msg.split('_')

      #estes puts são de teste, estes dados são guradaddos na BD 
      
      #puts username 
      #puts values[0] tipo = {"Temperatura", "Ruido"}
      #puts values[1] valor 
      #puts values[2] "GPS"
      #puts values[3] valor de GPS
      #puts values[4] "Data"
      #puts values[5] valor da Data
      }
    end
  end

  def menu 
    puts "0-Listar os utilizador que estão ligados"
    puts "1-Listar os valores de dados de um sensor de um cliente"

    esc = $stdin.gets.chomp

    if esc == "0"
      listaUtl
    else 
      listDados
    end
  end

  def listaUtl
    puts @connections[:clients]

    #por cada cliente ir a BD buscar as ultimas coords e imprimilas  
    menu
  end  

  def listDados

    puts "Insira o ID do cliente:"
    id = $stdin.gets.chomp
    puts id

    #acabar de listar os dados que iram estar na BD
    menu
  end  

end

Server.new( 3000, "localhost" )


##falta fazer o ponto 6/ 7/ 8 ... é ease

