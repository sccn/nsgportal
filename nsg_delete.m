function nsg_delete(url)

nsg_info;

command = sprintf('curl -u arnodelorme:%s -H cipres-appkey:%s -X DELETE %s', nsgpassword, nsgkey, url);
system(command);
