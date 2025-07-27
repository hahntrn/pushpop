require 'xcodeproj'

project = Xcodeproj::Project.new('pushpop.xcodeproj')
app_target = project.new_target(:application, 'pushpop', :osx, '14.0')
main_group = project.main_group.new_group('pushpop', 'pushpop')

source_files = %w[pushpopApp.swift StackStore.swift ContentView.swift PeekView.swift HistoryView.swift]
source_refs = source_files.map { |f| main_group.new_file("Sources/#{f}") }
plist_ref = main_group.new_file('Sources/Info.plist')
asset_ref = main_group.new_file('Sources/Assets.xcassets')
sound_ref = main_group.new_file('Sources/Resources/pop.wav')

source_refs.each do |ref|
  app_target.add_file_references([ref])
end
app_target.resources_build_phase.add_file_reference(asset_ref)
app_target.resources_build_phase.add_file_reference(sound_ref)

app_target.build_configurations.each do |config|
  config.build_settings['INFOPLIST_FILE'] = 'Sources/Info.plist'
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.example.pushpop'
  config.build_settings['SWIFT_VERSION'] = '5.9'
  config.build_settings['CODE_SIGN_IDENTITY'] = ''
  config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
end

project.save
