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
      ID TEXT PRIMARY KEY,
      GPSATUAL TEXT);"
    @db.execute "CREATE TABLE IF NOT EXISTS XDKDADOS(
      XDKID INTEGER PRIMARY KEY,
      TIPO TEXT,
      VALOR INTEGER,
      GPS TEXT,
      DATA TEXT,
      XDKSENSOR_XDKSENSORID TEXT,
      FOREIGN KEY (XDKSENSOR_XDKSENSORID) REFERENCES XDKSENSOR(ID));"
  end

  def run
    loop {
      Thread.start(@server.accept) do | client |
        nick_name = client.gets.chomp.to_sym
        @connections[:clients].each do |other_name, other_client|
          if @connections[:clients][nick_name] != nil
            # com a BD vai ser preciso ver se ele ja esta registado na BD, se não estiver regista-lo
            client.puts "Esse aparelho ja e tem sessão iniciada"
            Thread.kill self
          end
        end
        puts "<ENTRADA> #{nick_name} >> #{client} <ENTRADA>"
        @db.execute "INSERT OR IGNORE INTO XDKSENSOR(ID) VALUES('#{nick_name}')"
        puts "Cheguei aqui"
        # coloca o valor de quantidades leituras enquanto online a 0 
        @connections[:clients][nick_name] = client
        client.puts "Conexão establecida, Obrigado por se Juntar a nós!"
        central_messages( nick_name, client )
        menu

      end
    }.join
    @response.join
    
 

  end

  def central_messages( username, client )
    @response = Thread.new do
    loop {
      msg = client.gets.chomp
      #puts "#{msg}"

      if msg == "exit"
            puts "<SAIDA> #{username} >> #{client} <SAIDA>"
            #falar ir a base de dados e por a imprimir o valor de leituras 
            @connections[:clients][username] = nil

    
      else 
      values = msg.split('_')

      #puts "#{values[0]}"
      @db.execute "INSERT INTO XDKDADOS(TIPO, VALOR, GPS, DATA, XDKSENSOR_XDKSENSORID) VALUES('#{values[0]}', '#{values[1]}', '#{values[3]}', '#{values[5]}', '#{username}');"

      #estes puts são de teste, estes dados são guradaddos na BD 
      
      #puts username 
      #puts values[0] tipo = {"Temperatura", "Ruido"}
      #puts values[1] valor 
      #puts values[2] "GPS"
      #puts values[3] valor de GPS
      #puts values[4] "Data"
      #puts values[5] valor da Data
      # aciona +1 ao numero de leitura na BD
      
      end
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
    #esta a imprimir todos ofline e online, probbavelmente com a BD resolve-se facil
    #por cada cliente ir a BD buscar as ultimas coords e imprimilas  
    menu
  end  

  def listDados

    puts "Insira o ID do cliente:"
    id = $stdin.gets.chomp

    puts "O sensor que quer analisar:"
    sens = $stdin.gets.chomp

    #acabar de listar os dados que iram estar na BD
    menu
  end  

end

Server.new( 3000, "localhost" )




