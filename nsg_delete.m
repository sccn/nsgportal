function nsg_delete(url)

nsg_info;

command = sprintf('curl -u %s:%s -H cipres-appkey:%s -X DELETE %s', nsgusername, nsgpassword, nsgkey, url);
system(command);
