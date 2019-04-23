function status = nsg_checknet()
  status = 0;
  try
    iaddress = java.net.InetAddress.getByName('www.nsgportal.org');
    status = 1;
  end
end