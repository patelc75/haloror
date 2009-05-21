require 'socket'                # Get sockets from stdlib

server = TCPServer.open(2000)   # Socket to listen on port 2000
loop {                          # Servers run forever
  Thread.start(server.accept) do |client|
    time = Time.now
    rep = client.gets
    puts("at %s (%s): %s\n" % [time.ctime, time.usec, rep.chomp])
    if (rep.chomp != "@")
	# testing timeout:
	#sleep(10)
        client.write("ACK\r\n\r\n")
    end 
    client.close                # Disconnect from the client
  end
}

