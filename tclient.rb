class Tclient import Runnable

	attr_reader :client, :nome

	def initialize(cliente)
		@client = cliente
	end

	def run()
		@client.puts "Cliente estou no run"
	end




end
