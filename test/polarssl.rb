# PolarSSL Test
assert("PolarSSL") do
  assert_equal Module, PolarSSL.class
end

assert("PollarSSL.debug") do
  msgs = []
  begin
    PolarSSL.debug { |*a| msgs << a }
    PolarSSL.debug_threshold = 5
    socket = TCPSocket.new('tls.mbed.org', 443)
    entropy = PolarSSL::Entropy.new
    ctr_drbg = PolarSSL::CtrDrbg.new(entropy)
    ssl = PolarSSL::SSL.new
    ssl.set_endpoint(PolarSSL::SSL::SSL_IS_CLIENT)
    ssl.set_authmode(PolarSSL::SSL::SSL_VERIFY_NONE)
    ssl.set_rng(ctr_drbg)
    ssl.set_socket(socket)
    ssl.handshake
    assert_not_equal [], msgs
  ensure
    PolarSSL.debug_threshold = 0
  end
end

assert('PolarSSL::Entropy') do
  assert_equal Class, PolarSSL::Entropy.class
end

assert('PolarSSL::Entropy#new') do
  entropy = PolarSSL::Entropy.new
end

assert('PolarSSL::Entropy#gather') do
  entropy = PolarSSL::Entropy.new
  assert_true entropy.gather()
end

assert('PolarSSL::CtrDrbg') do
  assert_equal Class, PolarSSL::CtrDrbg.class
end

assert('PolarSSL::CtrDrbg#new err') do
  assert_raise(ArgumentError) do
    ctrdrbg = PolarSSL::CtrDrbg.new
  end
end

assert('PolarSSL::CtrDrbg#new err 2') do
  assert_raise(TypeError) do
    ctrdrbg = PolarSSL::CtrDrbg.new "foo"
  end
end

assert('PolarSSL::CtrDrbg#new') do
  entropy = PolarSSL::Entropy.new
  ctrdrbg = PolarSSL::CtrDrbg.new entropy
end

assert('PolarSSL::CtrDrbg#self_test') do
  PolarSSL::CtrDrbg.self_test
end

assert('PolarSSL::SSL') do
  assert_equal Class, PolarSSL::SSL.class
end

assert('PolarSSL::SSL#new') do
  ssl = PolarSSL::SSL.new
end

assert('PolarSSL::SSL::SSL_IS_CLIENT') do
  PolarSSL::SSL.const_defined? :SSL_IS_CLIENT
  assert_equal(PolarSSL::SSL::SSL_IS_CLIENT, 0)
end

assert('PolarSSL::SSL::SSL_VERIFY_NONE') do
  PolarSSL::SSL.const_defined? :SSL_VERIFY_NONE
  assert_equal(PolarSSL::SSL::SSL_VERIFY_NONE, 0)
end

assert('PolarSSL::SSL::SSL_VERIFY_OPTIONAL') do
  PolarSSL::SSL.const_defined? :SSL_VERIFY_OPTIONAL
  assert_equal(PolarSSL::SSL::SSL_VERIFY_OPTIONAL, 1)
end

assert('PolarSSL::SSL::SSL_VERIFY_REQUIRED') do
  PolarSSL::SSL.const_defined? :SSL_VERIFY_REQUIRED
  assert_equal(PolarSSL::SSL::SSL_VERIFY_REQUIRED, 2)
end

assert('PolarSSL::SSL#set_endpoint') do
  ssl = PolarSSL::SSL.new
  ssl.set_endpoint(PolarSSL::SSL::SSL_IS_CLIENT)
end

assert('PolarSSL::SSL#set_authmode') do
  ssl = PolarSSL::SSL.new
  ssl.set_authmode(PolarSSL::SSL::SSL_VERIFY_NONE)
end

assert('PolarSSL::SSL#new with read timeout') do
  PolarSSL::SSL.new(read_timeout: 20000)
end

assert('PolarSSL::SSL#set_rng') do
  entropy = PolarSSL::Entropy.new
  ctr_drbg = PolarSSL::CtrDrbg.new(entropy)
  ssl = PolarSSL::SSL.new

  ssl.set_endpoint(PolarSSL::SSL::SSL_IS_CLIENT)
  ssl.set_authmode(PolarSSL::SSL::SSL_VERIFY_NONE)
  ssl.set_rng(ctr_drbg)
end

assert('PolarSSL::SSL#set_rng err') do
  assert_raise(TypeError) do
    ssl = PolarSSL::SSL.new
    ssl.set_rng "foo"
  end
end

assert('PolarSSL::SSL#set_socket') do
  socket = TCPSocket.new('tls.mbed.org', 443)
  entropy = PolarSSL::Entropy.new
  ctr_drbg = PolarSSL::CtrDrbg.new(entropy)
  ssl = PolarSSL::SSL.new
  ssl.set_endpoint(PolarSSL::SSL::SSL_IS_CLIENT)
  ssl.set_authmode(PolarSSL::SSL::SSL_VERIFY_NONE)
  ssl.set_rng(ctr_drbg)
  ssl.set_socket(socket)
end

assert('PolarSSL::SSL#handshake') do
  socket = TCPSocket.new('tls.mbed.org', 443)
  entropy = PolarSSL::Entropy.new
  ctr_drbg = PolarSSL::CtrDrbg.new(entropy)
  ssl = PolarSSL::SSL.new
  ssl.set_endpoint(PolarSSL::SSL::SSL_IS_CLIENT)
  ssl.set_authmode(PolarSSL::SSL::SSL_VERIFY_NONE)
  ssl.set_rng(ctr_drbg)
  ssl.set_socket(socket)
  ssl.handshake
end

assert('PolarSSL::SSL#handshake yields during blocking on a non-blocking socket') do
  # we connect to a server that will never complete the handshake. It must
  # time out, therefore we expect our block to be called while we wait.
  # Raising within that block aborts the whole handshake, so we don't actually
  # wait for a timeout.
  begin
    server_pid = fork do
      begin
        server = TCPServer.new('127.0.0.1', 14443)
        sock = server.accept
        sock.read
        exit 0
      rescue Exception => e
        puts e.class, e.to_s, *e.backtrace
      end
    end
    sleep 0.25 # allow enough time for server to bind
    socket = TCPSocket.new('127.0.0.1', 14443)
    entropy = PolarSSL::Entropy.new
    ctr_drbg = PolarSSL::CtrDrbg.new(entropy)
    ssl = PolarSSL::SSL.new
    ssl.set_endpoint(PolarSSL::SSL::SSL_IS_CLIENT)
    ssl.set_authmode(PolarSSL::SSL::SSL_VERIFY_NONE)
    ssl.set_rng(ctr_drbg)
    ssl.set_socket(socket)
    ssl.blocking = false
    class BlockCalled < RuntimeError; end
    assert_raise(BlockCalled) { ssl.handshake { raise BlockCalled } }
  ensure
    Process.kill :SIGTERM, server_pid
  end
end

assert('PolarSSL::SSL#handshake err') do
  socket = TCPSocket.new('tls.mbed.org', 80)
  entropy = PolarSSL::Entropy.new
  ctr_drbg = PolarSSL::CtrDrbg.new(entropy)
  ssl = PolarSSL::SSL.new
  ssl.set_endpoint(PolarSSL::SSL::SSL_IS_CLIENT)
  ssl.set_authmode(PolarSSL::SSL::SSL_VERIFY_NONE)
  ssl.set_rng(ctr_drbg)
  ssl.set_socket(socket)
  assert_raise(PolarSSL::SSL::Error) do
    ssl.handshake
  end
end

assert('PolarSSL::SSL#write') do
  socket = TCPSocket.new('tls.mbed.org', 443)
  entropy = PolarSSL::Entropy.new
  ctr_drbg = PolarSSL::CtrDrbg.new(entropy)
  ssl = PolarSSL::SSL.new
  ssl.set_endpoint(PolarSSL::SSL::SSL_IS_CLIENT)
  ssl.set_authmode(PolarSSL::SSL::SSL_VERIFY_NONE)
  ssl.set_rng(ctr_drbg)
  ssl.set_socket(socket)
  ssl.handshake
  ssl.write "foo"
end

assert('PolarSSL::SSL#read') do
  socket = TCPSocket.new('tls.mbed.org', 443)
  entropy = PolarSSL::Entropy.new
  ctr_drbg = PolarSSL::CtrDrbg.new(entropy)
  ssl = PolarSSL::SSL.new
  ssl.set_endpoint(PolarSSL::SSL::SSL_IS_CLIENT)
  ssl.set_authmode(PolarSSL::SSL::SSL_VERIFY_NONE)
  ssl.set_rng(ctr_drbg)
  ssl.set_socket(socket)
  ssl.handshake
  ssl.write("GET / HTTP/1.0\r\nHost: tls.mbed.org\r\n\r\n")
  response = ""
  assert_raise(ArgumentError) { ssl.read(-1) }
  while chunk = ssl.read(1024)
    response << chunk
  end
  assert_true response.size > 0
  assert_true ssl.eof?
  assert_raise(EOFError) { ssl.read(1) }
  #debug
  #p "https response size: #{response.size}"
end

assert('PolarSSL::SSL#close_notify') do
  socket = TCPSocket.new('tls.mbed.org', 443)
  entropy = PolarSSL::Entropy.new
  ctr_drbg = PolarSSL::CtrDrbg.new(entropy)
  ssl = PolarSSL::SSL.new
  ssl.set_endpoint(PolarSSL::SSL::SSL_IS_CLIENT)
  ssl.set_authmode(PolarSSL::SSL::SSL_VERIFY_NONE)
  ssl.set_rng(ctr_drbg)
  ssl.set_socket(socket)
  ssl.handshake
  ssl.write("GET / HTTP/1.0\r\nHost: tls.mbed.org\r\n\r\n")
  buf = ssl.read(4)
  #debug
  #p buf
  ssl.close_notify
end

assert('PolarSSL::SSL#close') do
  socket = TCPSocket.new('tls.mbed.org', 443)
  entropy = PolarSSL::Entropy.new
  ctr_drbg = PolarSSL::CtrDrbg.new(entropy)
  ssl = PolarSSL::SSL.new
  ssl.set_endpoint(PolarSSL::SSL::SSL_IS_CLIENT)
  ssl.set_authmode(PolarSSL::SSL::SSL_VERIFY_NONE)
  ssl.set_rng(ctr_drbg)
  ssl.set_socket(socket)
  ssl.handshake
  ssl.write("GET / HTTP/1.0\r\nHost: tls.mbed.org\r\n\r\n")
  buf = ssl.read(4)
  #debug
  #p buf
  ssl.close_notify
  socket.close
  ssl.close
end
