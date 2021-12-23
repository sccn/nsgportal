function status = nsg_checknet()
  status = 0;
  try
    % If no connection, this will throw an error
    iaddress = java.net.InetAddress.getByName('www.nsgportal.org');
    res = webread('https://nsgr.sdsc.edu:8443/cipresrest/v1');
    status = 1;
  end
end