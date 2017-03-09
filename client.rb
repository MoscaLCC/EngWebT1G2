#!/usr/bin/env ruby -w
require 'socket'

class Client

	attr_reader :temperatura, :ruido, :lat, :long, :alt

	def initialize(server)
		@server = server
		@request = nil
		@response = nil
		@temperatura=0
		@ruido=0
		@lat=0
		@long=0
		@alt=0
		listen
		send
		@request.join
		@response.join
		
	end

	def listen
		@response = Thread.new do
			loop{
				msg = @server.gets.chomp
				puts "#{msg}"
			}
		end
	end

	def send
		puts "Enter the username:"
		@server.puts($stdin.gets.chomp)
		@request = Thread.new do
			loop{
				getdados
				sleep(3)
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

	def getdados
		geradorall
		@server.puts("INFO->\n\ttemperatura:" + @temperatura.to_s + "\n\truido:" + @ruido.to_s + "\nGPS->\n\tlatitude:" + @lat.to_s + "\n\tlongitude:" + @long.to_s + "\n\taltitude:" + @alt.to_s + "\nTIME->\n\t" + Time.now.to_s + "\n\n\n\n\n")
	end
end

server = TCPSocket.open("localhost", 3000)
Client.new(server)

