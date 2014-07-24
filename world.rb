require 'socket'

s = TCPSocket.new '72.14.188.107', 7158
s.print '(voice 0 100 "1234")'
s.close

