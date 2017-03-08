require 'socket'

server = TCPSocket.open('localhost', 3001)
server.puts "Ola servidor, eu cliente, estou a enviar esta mensagem"

resp = server.recvfrom(10000)
puts resp

server.close