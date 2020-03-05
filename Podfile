platform :ios, '9.0'

inhibit_all_warnings!

def testing_pods
    pod 'Quick', '~> 2.2.0'
    pod 'Nimble', '~> 8.0.5'
end

target 'AppstudMapLauncher' do
  	use_frameworks!

  	target 'AppstudMapLauncherTests' do
    	inherit! :search_paths
    	testing_pods
  	end

end
