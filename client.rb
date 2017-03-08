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
		@request = Thread.new do
			loop{
				msg = $stdin.gets.chomp
				@server.puts(msg)
			}
		end
	end

	def geradorall
		@temperatura = Random.rand(0..100)
		@long = Random.rand(0..100)
		@ruido = Random.rand(0..100)
		@lat = Random.rand(0..100)
		@alt = Random.rand(0..100)
	end

	def getdados
		geradorall
		$stdin.puts("->"+temperatura+ruido+lat+long+alt+Time.now)
	end

	def envia
		
	getdados
		
	end

end

server = TCPSocket.open("localhost", 3000)
Client.new(server)

