local body = ngx.req.read_body()
local methodType = ngx.req.get_method()
local args = ngx.req.get_post_args()
local sourceIP = ngx.var.remote_addr
local ipuserdict = ngx.shared.ipuser
local header = ngx.header
local currentHPuserIPaddr1 = ipuserdict:get("honeypot1")
local currentHPuserIPaddr2 = ipuserdict:get("honeypot2")

ngx.log(ngx.STDERR, sourceIP)
ngx.log(ngx.STDERR, currentHPuserIPaddrX)
ngx.log(ngx.STDERR, currentHPuserIPaddrY)

-- POST requests
if(methodType == "POST") then
  -- Login request
  if(args["wp-submit"] == "Log In") then
    ngx.log(ngx.STDERR, "wp-submit post zahtjev.")
    
    -- Honeypot1 login
    if(args['pwd'] == "honeypot1pass" and args["log"] == "honeypot1user") then
      -- if honeypot1 not yet started (first time log in) -> start a new honeypot
      if(currentHPuserIPaddr1 == nil or currentHPuserIPaddr1 == "") then
        ngx.log(ngx.STDERR, "Starting up hacker images...")
        os.execute("docker start honeypot1-mysql")
        os.execute("docker start honeypot1-wordpress")
        os.execute("until ping -c1 10.0.0.2; do sleep 1; done")
        os.execute("until nc -z 10.0.2.1 3666; do sleep 1; done")
        ngx.log(ngx.STDERR, "Copying databases")
        os.execute("mysqldump -h\"10.0.0.1\" -P\"3306\" -uroot -p\"mysecpas\" wordpress wp_posts | mysql -h\"10.0.0.2\" -uroot -p\"mysecpas\" wordpress")
        ngx.log(ngx.STDERR, "Finished copying databases")
        
        ngx.log(ngx.STDERR, "Setting the source IP adress...")
        ipuserdict:set("honeypot1", sourceIP)
        ngx.log(ngx.STDERR, sourceIP)
        ngx.var.upstream = "10.0.2.1:3666"
        ngx.exit(ngx.OK)
      
      -- the same attacker came back and we have the honeypot running
      elseif(currentHPuserIPaddr1 == sourceIP) then
        ngx.log(ngx.STDERR, "Same sourceIP accessing again.")
        ngx.var.upstream = "10.0.2.1:3666"
        ngx.exit(ngx.OK)
        
      -- user with new IP address trying to access the honeypot (decline)
      else
        ngx.log(ngx.STDERR, "New user trying to log into honeypot, decline.")
        ngx.var.upstream = "10.0.2.1:3333"
        ngx.exit(ngx.OK)
      end
    
    -- Honeypot2 login
    elseif(args['pwd'] == "honeypot2pass" and args["log"] == "honeypot2user") then
      -- if honeypot2 not yet started (first time log in) -> start a new honeypot
      if(currentHPuserIPaddr2 == nil or currentHPuserIPaddr2 == "") then
        ngx.log(ngx.STDERR, "Starting up hacker images...")
        os.execute("docker start honeypot2-mysql")
        os.execute("docker start honeypot2-wordpress")
        os.execute("until ping -c1 10.0.0.3; do sleep 1; done")
        os.execute("until nc -z 10.0.2.1 3999; do sleep 1; done")
        ngx.log(ngx.STDERR, "Copying databases")
        os.execute("mysqldump -h\"10.0.0.1\" -P\"3306\" -uroot -p\"mysecpas\" wordpress wp_posts | mysql -h\"10.0.0.3\" -uroot -p\"mysecpas\" wordpress")
        ngx.log(ngx.STDERR, "Finished copying databases")
        
        ngx.log(ngx.STDERR, "Setting the source IP adress...")
        ipuserdict:set("honeypot2", sourceIP)
        ngx.log(ngx.STDERR, sourceIP)
        ngx.var.upstream = "10.0.2.1:3999"
        ngx.exit(ngx.OK)
      
      -- the same attacker came back and we have the honeypot running
      elseif(currentHPuserIPaddr2 == sourceIP) then
        ngx.log(ngx.STDERR, "Same sourceIP accessing again.")
        ngx.var.upstream = "10.0.2.1:3999"
        ngx.exit(ngx.OK)
        
      -- user with new IP address trying to access the honeypot (decline)
      else
        ngx.log(ngx.STDERR, "New user trying to log into honeypot, decline.")
        ngx.var.upstream = "10.0.2.1:3333"
        ngx.exit(ngx.OK)
      end
      
    -- Regular login
    else
      ngx.var.upstream = "10.0.2.1:3333"
      ngx.exit(ngx.OK)
    end
  
  -- Ordinary HTTP POST (not login)
  else
    if(currentHPuserIPaddr1 == sourceIP) then
      ngx.var.upstream = "10.0.2.1:3666"
      ngx.exit(ngx.OK)
    elseif(currentHPuserIPaddr2 == sourceIP) then
      ngx.var.upstream = "10.0.2.1:3999"
      ngx.exit(ngx.OK)
    else
      ngx.var.upstream = "10.0.2.1:3333"
      ngx.exit(ngx.OK)
    end
  end

-- Other requests (GET, PUT etc.)
else
  if(currentHPuserIPaddr1 == sourceIP) then
    ngx.var.upstream = "10.0.2.1:3666"
    ngx.exit(ngx.OK)
  elseif(currentHPuserIPaddr2 == sourceIP) then
    ngx.var.upstream = "10.0.2.1:3999"
    ngx.exit(ngx.OK)
  else
    ngx.var.upstream = "10.0.2.1:3333"
    ngx.exit(ngx.OK)
  end
end
