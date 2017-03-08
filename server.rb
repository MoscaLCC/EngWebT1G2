require 'socket'
require 'tclient'

server = TCPServer.open(3001)

loop{
	client = server.accept
	msg_cliente = client.recvfrom(10000)

	puts "Mensagem do Cliente: #{msg_cliente}"
	client.puts "Ola cliente, eu, o servidor, recebi a sua mensagem"
	
	cli = Tclient.new(client)
	t = Thread.new{cli}
	
	t.start()
}