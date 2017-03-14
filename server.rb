#!/usr/bin/env ruby -w

require "socket"
require "sqlite3"

class Server

  #attr_reader :bd

  def initialize( port, ip )
    @hash = Hash.new
    @leitura = 0
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
            #puts @leitura
            client.puts(@leitura)
            #falar ir a base de dados e por a imprimir o valor de leituras 
            @connections[:clients][username] = nil

    
      else 
      values = msg.split('_')

      @db.execute "INSERT INTO XDKDADOS(TIPO, VALOR, GPS, DATA, XDKSENSOR_XDKSENSORID) VALUES('#{values[0]}', '#{values[1]}', '#{values[3]}', '#{values[5]}', '#{username}');"
      @db.execute "UPDATE XDKSENSOR SET GPSATUAL='#{values[3]}' WHERE ID='#{username}'"
      @leitura += 1

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
      #listaUtl
    else 
      listDados
    end
  end

  def listaUtl
    #puts @connections[:clients]

    @connections.each do |key|
      row = @db.get_first_row "SELECT * FROM XDKSENSOR WHERE ID='#{key}'"
      puts row.join "\s"
    end

    #esta a imprimir todos ofline e online, probbavelmente com a BD resolve-se facil
    #por cada cliente ir a BD buscar as ultimas coords e imprimilas  
    menu

  end  

  def listDados
    puts "Insira o ID do cliente:"
    id = $stdin.gets.chomp

    puts "O sensor que quer analisar:"
    sens = $stdin.gets.chomp

    imprimedabd(id, sens)

    #acabar de listar os dados que iram estar na BD
    menu
  end  

  def imprimedabd(id, sens)
    val = @db.execute "SELECT * FROM XDKDADOS WHERE XDKSENSOR_XDKSENSORID='#{id}' AND TIPO='#{sens}'"
    puts "\n"
    for row in val do
      puts row.join "\s"
    end
    puts "\n"
  end

end

Server.new( 3000, "localhost" )




