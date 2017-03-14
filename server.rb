#!/usr/bin/env ruby -w

require "socket"
require "sqlite3"

class Server

  def initialize( port, ip )
    @hash = Hash.new
    @leitura = 0
    @server = TCPServer.open( ip, port )
    @connections = Hash.new
    @clients = Hash.new
    @response = nil
    @connections[:clients] = @clients
    @db = SQLite3::Database.open "wsbd.db"
    criabasedados
    run
  end

  def criabasedados
    @db.execute "CREATE TABLE IF NOT EXISTS XDKSENSOR(
      ID TEXT PRIMARY KEY,
      GPSATUAL TEXT,
      NLEITURA TEXT);"
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
          if @connections[:clients].has_key?(nick_name)
            client.puts "exit"
            Thread.kill self
          end
 
        puts "<ENTRADA> #{nick_name} >> #{client} <ENTRADA>"
        @db.execute "INSERT OR IGNORE INTO XDKSENSOR(ID) VALUES('#{nick_name}')"
        @db.execute "UPDATE XDKSENSOR SET NLEITURA=0 WHERE ID='#{nick_name}'"
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

      if msg == "exit"
            val = @db.execute "SELECT NLEITURA FROM XDKSENSOR WHERE ID='#{username}'"
            xval=val[0].to_s
            yval = xval.scan(/\d+/).join().to_i
            puts "<SAIDA> #{username} >> Nº de leituras: #{yval} <SAIDA>"
            
            @connections[:clients].delete(username)

    
      else 
      values = msg.split('_')

      @db.execute "INSERT INTO XDKDADOS(TIPO, VALOR, GPS, DATA, XDKSENSOR_XDKSENSORID) VALUES('#{values[0]}', '#{values[1]}', '#{values[3]}', '#{values[5]}', '#{username}');"
      @db.execute "UPDATE XDKSENSOR SET GPSATUAL='#{values[3]}' WHERE ID='#{username}'"
      val = @db.execute "SELECT NLEITURA FROM XDKSENSOR WHERE ID='#{username}'"
      xval = val[0].to_s
      yval = xval.scan(/\d+/).join().to_i
      yval += 1
      yval.to_s
      @db.execute "UPDATE XDKSENSOR SET NLEITURA='#{yval}' WHERE ID='#{username}'"
      
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
    @connections[:clients].each { |key, value|
      imprimesensor(key)
    }
    menu
  end  

  def listDados
    puts "Insira o ID do cliente:"
    id = $stdin.gets.chomp

    puts "O sensor que quer analisar:"
    sens = $stdin.gets.chomp

    imprimedabd(id, sens)

    menu
  end  

  def imprimesensor(key)
    val = @db.execute "SELECT GPSATUAL FROM XDKSENSOR WHERE ID='#{key}'"
    for row in val do
      puts "#{key} -> " + row.join 
    end
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




