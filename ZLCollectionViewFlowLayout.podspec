Pod::Spec.new do |s|

  s.name         = "ZLCollectionViewFlowLayout"
  s.version      = "0.0.1"
  s.summary      = "A short description of ZLCollectionViewFlowLayout."

  s.description  = <<-DESC
                      各种样式的uicollectionviewflowlayout
                   DESC

  s.homepage     = "https://github.com/czl0325/ZLCollectionView/"

  s.license      = "MIT"

  s.author       = { "czl0325" => "295183917@qq.com" }

  s.source       = { :git => "https://github.com/czl0325/ZLCollectionView.git", :tag => s.version }
  s.requires_arc = true
  s.ios.deployment_target = '8.0'
  s.source_files  = "ZLCollectionViewFlowLayout/*.{h,m}"
 #s.exclude_files = "Classes/Exclude"

end
