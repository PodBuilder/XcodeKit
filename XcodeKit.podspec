Pod::Spec.new do |s|
  s.name = "XcodeKit"
  s.version = "3.0.3"
  s.summary = "A library to read and write Xcode project files"
  s.homepage = "https://github.com/PodBuilder/XcodeKit"
  s.license = 'MIT'
  s.authors = { "William Kent" => "gmail.com:wjk011" }
  s.source = { :git => "https://github.com/PodBuilder/XcodeKit.git", :tag => s.version.to_s }
  s.platform = :osx, '10.10'
  s.source_files = 'XcodeKit/*.{h,m}'
  s.requires_arc = true

  s.subspec 'Swift' do |swift|
    swift.platform = :osx, '10.10'
    swift.source_files = 'SwiftXcodeKit/**/*.swift'
  end
end
