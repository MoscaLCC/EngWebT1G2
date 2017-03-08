#!/usr/bin/env ruby -w
require 'socket'

class Client
	def initialize(server)
		@server = server
		@request = nil
		@response = nil
		listen
		send
		envia
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
		@request = Thread.new do
			loop{
				msg = $stdin.gets.chomp
				@server.puts(msg)
			}
		end
		envia_dados
	end

	def envia
		xdk = XDKsensor.new()
		a = xdk.getdados()
		puts a
	end

end

server = TCPSocket.open("localhost", 3000)
Client.new(server)

