#!/usr/bin/env ruby -w
require 'socket'

class Client

	attr_reader :temperatura, :ruido, :lat, :long, :alt, :esc, :inic

	def initialize(server)
		@server = server
		@requesttemp = nil
		@requestruid = nil
		@temperatura=0
		@ruido=0
		@lat=0
		@long=0
		@alt=0
		@esc=""
		send
		
		@requesttemp.join
		@requestruid.join
	end

	def send	
		puts "Digite o seu ID:"
		@server.puts($stdin.gets.chomp)
		@inic = @server.gets.chomp
		puts @inic

		if @inic != "exit"	

			sendTemp
			sendRuid

			while @esc != "exit" do
				
				@esc = $stdin.gets.chomp

				if esc == "exit"
     				@server.puts(@esc)
     			end
			end
			@requestruid.kill
			@requesttemp.kill
		end
	end

	def sendTemp
		@requesttemp = Thread.new do
			loop{
				getdadost
				sleep(30)
			}
		end
	end

	def sendRuid
		@requestruid = Thread.new do
			loop{
				getdadosr
				sleep(1)
			}
		end
	end

	def geradorall
		@temperatura = rand(100)
		@long = rand(100)
		@ruido = rand(100)
		@lat = rand(100)
		@alt = rand(100)
	end

	def getdadost
		geradorall
		@server.puts("Temperatura_" + @temperatura.to_s + "_GPS_(" + @lat.to_s + "," + @long.to_s + "," + @alt.to_s + ")_Data_" + Time.now.to_s + "\n")
	end

	def getdadosr
		geradorall
		@server.puts("Ruido_" + @ruido.to_s + "_GPS_(" + @lat.to_s + "," + @long.to_s + "," + @alt.to_s + ")_Data_" + Time.now.to_s + "\n")
	end
end

server = TCPSocket.open("localhost", 3000)
Client.new(server)

