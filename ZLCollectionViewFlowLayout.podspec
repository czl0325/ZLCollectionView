Pod::Spec.new do |s|

  s.name         = "ZLCollectionViewFlowLayout"
  s.version      = "1.4.9"
  s.summary      = "ZLCollectionViewFlowLayout"

  s.description  = <<-DESC
                      各种样式的uicollectionview，功能持续更新中...
                   DESC

  s.homepage     = "https://github.com/czl0325/ZLCollectionView"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = { "czl0325" => "295183917@qq.com" }
  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/czl0325/ZLCollectionView.git", :tag => s.version }
  
  #s.ios.deployment_target = '8.0'
  s.source_files  = "ZLCollectionViewFlowLayout/*.{h,m}"
  #s.resources = 'SXWaveAnimate/images/*.{png,xib}'
 #s.exclude_files = "Classes/Exclude"
  s.requires_arc = true

end
