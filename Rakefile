require "yast/rake"

Yast::Tasks.configuration do |conf|
  conf.obs_api = "https://api.opensuse.org"
  conf.obs_target = "openSUSE_Leap_15.6"
  conf.obs_sr_project = "openSUSE:Leap:15.6:Update"
  conf.obs_project = "YaST:openSUSE:15.6"

  conf.obs_api = "https://api.opensuse.org"
  conf.obs_target = "openSUSE_Leap_15.5"
  conf.obs_sr_project = "openSUSE:Leap:15.5:Update"
  conf.obs_project = "YaST:openSUSE:15.5"

  # lets ignore license check for now
  conf.skip_license_check << /.*/
end
