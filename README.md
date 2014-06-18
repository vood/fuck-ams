#Description#
The other day I got stuck in Amsterdam Airport Schiphol for more that 10 hours due to a flight delay. I was very disappointed.
"Will work from here" - I decided. Once I connected to public Wi-Fi spot a message welcomed me
stated that access would be limited to 30 minutes per device :(
I didn't give up and wrote this small script that would reset mac address and would
reconnect to the desired Wi-Fi network automatically every 30 minutes.
I hope it can be useful for someone else.
#Usage#
It is required to run this script as a root user/sudo
```
bundle install
sudo ruby app.rb <interface> <SSID> <reset_interval_in_seconds:optional>
```
#Example#
```
sudo ruby app.rb en0 MyPublicWiFiSSID
```
