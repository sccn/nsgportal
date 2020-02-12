function status = nsg_checknet()
  status = 0;
  try
    % If no connection, this will throw an error
    iaddress = java.net.InetAddress.getByName('www.nsgportal.org');
    status = 1;
  end
end