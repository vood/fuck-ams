#!/usr/bin/env ruby

require 'logger'
require 'mechanize'

class App
  @@log = Logger.new(STDOUT)

  AUTH_URL = 'https://redirector.hotspotsvankpn.com/'
  AUTH_USER_AGENT_ALIAS = 'Mac Safari'
  AUTH_ATTEMPTS_LIMIT = 3

  def self.execute en, ssid, interval = 30
    last_run = nil
    app = self.new
    @@log.info("Network interface is #{en}")
    @@log.info("SSID is #{ssid}")
    @@log.info("Reset interval is #{interval} minute(s)")
    while true
      now = Time.now
      if last_run.nil? || last_run < now - interval * 60
        begin
          @@log.info('Updating mac address...')
          raise 'Unable to update mac address' unless app.change_mac_address(en)
          @@log.info('Mac address has been successfully updated')
          @@log.info("Reconnecting to '#{ssid}' Wi-Fi network on '#{en}' interface...")
          raise 'Unable to reconnect to Wi-Fi network' unless app.reconnect_to_wifi(en, ssid)
          @@log.info('Wi-Fi network has been reconnected successfully')
          @@log.info('Authenticating to Wi-Fi network...')
          raise 'Unable to authenticate to Wi-Fi network' unless app.auth
          @@log.info('Wi-Fi network has been successfully authenticated')
          last_run = now
        rescue Exception => e
          @@log.error(e)
          exit(false)
        end
      end
    end
  end

  def change_mac_address en
    system("ifconfig #{en} ether #{generate_mac_address}")
  end

  def reconnect_to_wifi en, ssid
    system("networksetup -setairportnetwork #{en} #{ssid}")
  end

  def auth
    (1..AUTH_ATTEMPTS_LIMIT).each do |index|
      @@log.info('Trying to authenticate...')
      begin
        a = Mechanize.new { |agent|
          agent.user_agent_alias = AUTH_USER_AGENT_ALIAS
        }

        a.get(AUTH_URL) do |page|
          page2 = a.click(page.link_with(:text => 'here'))
          form = page2.form_with(:dom_id => 'hybridelogin')
          form.checkbox_with(:name => 'voorwaarden').check
          form.submit
        end
      rescue Exception => e
        raise e if index === AUTH_ATTEMPTS_LIMIT
        @@log.error('Error during authentication. Will retry in 3 seconds...')
        sleep(3)
      end
    end
  end

  def generate_mac_address
    (1..6).map { "%0.2X"%rand(256) }.join(":")
  end
end

unless Process.uid === 0
  print "Root permissions are required to run this script. Please run as root user or use sudo\n";
  exit(false)
end

if ARGV.length < 2
  print "Usage: sudo ruby app.rb <enterface> <wifi_network_name> <reset_interval_in_seconds:optional>\n"
  exit(false)
end

App.execute ARGV[0], ARGV[1]
