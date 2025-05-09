#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint slowmo_video_recorder.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'slowmo_video_recorder'
  s.version          = '0.0.1'
  s.summary          = 'Slow-motion video recording for Flutter (iOS).'
  s.description      = <<-DESC
High-frame-rate (120 / 240 fps) video capture with simple Dart API. Supports
720p and 1080p, built on AVFoundation. iOS-only.
                       DESC
  s.homepage         = 'https://github.com/your-org/slowmo_video_recorder'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Open Source' => 'opensource@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'slowmo_video_recorder_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
