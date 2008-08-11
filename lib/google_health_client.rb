require 'httpclient'
require 'hpricot'
class GoogleHealthClient

  
  AUTH_URL = "https://www.google.com/accounts/ClientLogin"
  PROFILE_LIST = "https://www.google.com/health/feeds/profile/list"
  PROFILE = "https://www.google.com/health/feeds/profile/ui/"
  PROFILE_REGISTER = "https://www.google.com/health/feeds/register/ui/"
  def authenticate(username, password)
    body = "Email=#{username}&Passwd=#{password}&service=health&source=HaloMontioring-haloror-1" 
    client = HTTPClient.new
    resp = client.post(AUTH_URL, body)
    puts resp.content
    auth = resp.content.split('Auth=')[1].strip
    return auth
  end
  
  def profile_list(auth)
    client = HTTPClient.new
    headers = {"Authorization" => "GoogleLogin auth=#{auth}"}
    resp = client.get(PROFILE_LIST, nil, headers)
    puts resp.content
    doc = Hpricot(resp.content)
    url = doc.search("//entry/id").innerHTML
    id = url.split("/").last
    return id
  end
  
  def get_profile(auth, id)
      client = HTTPClient.new
      headers = {"Authorization" => "GoogleLogin auth=#{auth}"}
      url = "#{PROFILE}#{id}"
      resp = client.get(url, nil, headers)
      puts resp.content
  end
  
  def post_notice(auth, id, title, notice)
    client = HTTPClient.new
    headers = {"Authorization" => "GoogleLogin auth=#{auth}", "Content-type" => 'application/atom+xml'}
    url = "#{PROFILE_REGISTER}#{id}"
    body = <<-EOF
      <entry xmlns="http://www.w3.org/2005/Atom">
        <title type="text">#{title}</title>
        <content type="text">#{notice}</content>
      </entry>
    EOF
    resp = client.post(url, body, headers)
    puts resp.content
  end
    
end