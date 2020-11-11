function nsg_delete(url)

nsg_info;

command = sprintf('curl -u %s:%s -k -H cipres-appkey:%s -X DELETE %s', nsgusername, nsgpassword, nsgkey, url);
system(command);
