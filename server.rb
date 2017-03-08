#!/usr/bin/env ruby -w
require 'socket'

class Server
	def initialize(port,ip)
		@server = TCPServer.open(ip,port)
		%%@clients = Hash.new%
		%%@connections[:clients] = @clients%
		run
	end

	def run
		loop{
			Thread.start(@server.accept) do |client|
				nick_name=client.gets.chomp.to_sym
				
				%%@connections[:clients].each do |other_name, other_client|
					if nick_name == other_name || client == other_client
						client.puts "O Cliente já existe"
						Thread.kill self
					end
				end%

				puts "#{nick_name} #{client}"

				%%@connections[:clients][nick_name] = client%

				client.puts "Ligação establecida"
			end
		}.join
	end

end

Server.new(3000,"localhost")