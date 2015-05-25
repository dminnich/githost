require 'sinatra'


#////Functions
#http://snipplr.com/view.php?codeview&id=62410
def do_upload(theFile,user)
    maxFileSize = 1048576 #bytes
    fileDir = "tmpupload"

    fileName = Time.now.to_i.to_s + '-' + user + '-' + theFile[:filename]
    filePath = File.join(fileDir, fileName)

    tempFile = theFile[:tempfile]

    upload = {
        :fileSize => tempFile.size,
        :originalFileName => theFile[:filename],
        :fileType => theFile[:type],
        :fileName => fileName,
        :filePath => filePath
    }

    # dd file size tests with no extensions
    # if upload[:fileType] != 'application/octet-stream' && upload[:fileType] != 'application/octet-stream'
    if upload[:fileSize] > maxFileSize
        return {'fileError' => 'Your ssh key must be less than 1MB in size.'}
    end

    if !File.directory?(fileDir)
        return {'fileError' => 'Cannot upload your ssh key. Destination ' + fileDir + ' does not exist. Please contact the site admin.'}
    end
        
    if !File.writable?(fileDir)
        return {'fileError' => 'Cannot upload your ssh key. Unable to write to ' + fileDir + '. Please contact the site admin.'}
    end

    File.open(filePath, "wb") { |f| f.write(tempFile.read) }
    
    real_mt = `file --brief --mime-type #{filePath}`.strip
    if real_mt != "text/plain"    
       return {'fileError' => 'Your ssh key must be a text/plain file.'}
    else
       return upload
    end

end


@@myfqdn = `hostname | tr -d '[[:space:]]'`
@@fqdn = @@myfqdn


#////
get '/' do
erb :index
end


#////
post '/form' do
@user = params[:username]
@key = params[:sshkey]
@showcmd = "no"

userlist = Array.new
 File.foreach( '/etc/passwd' ) do |line|
   line = line.split(':')[0]
   userlist.insert(-1, line)
end

#check username
if (( @user =~ /[^[:alnum:]]/ ) or @user.length < 2) 
     @message = "Your username must be at least two characters long and can only be alphanumeric in nature."

  elsif userlist.include? @user
     @message = "The username you chose is already in use. Please try a different one."

  #check key
  elsif @key.nil?
     @message = "You must specify an ssh-key."

  #check upload
  else 
     @upload = do_upload(@key,@user)
     if @upload["fileError"]
        @message = @upload["fileError"]
     else
     #upload array returned
     #check command 
     @thesshkey = @upload[:filePath]
     @showcmd = "yes"
     #@cmd = `echo "#{@user} created" && cat #{@thesshkey} 2>&1`; result=$?.success?
     @cmd = `cd /opt/githost && sudo ansible-playbook -i inventory  add-user.yaml --extra-vars "username=#{@user} pubkey=/var/www/githost/#{@thesshkey}" 2>&1`; result=$?.success?
     @cmdoutput = @cmd
        if not result
           @message = "Account creation failed. Please contact your site admin and give them the debug output below."
        else
           @message = "Your account has been created. <br />Please do a 'git clone ssh://#{@user}@#{@@fqdn}/home/#{@user}/geekhost_home_folder' to get started."
        end
     end	

#big if
end

erb :createaccount 
#form page
end


#///
not_found do
  status 404
  '404'
end
