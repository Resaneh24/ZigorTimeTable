

Pod::Spec.new do |s|
  s.name             = 'ZigorTimeTable'
  s.version          = '1.0.0'
  s.summary          = 'Zigor time table is a model for Offline calculation of recurring time tables with minimal data structure and incredible performance.'

  s.description      = 'Zigor time table is a model for Offline calculation of recurring time tables with minimal data structure and incredible performance. Time tables in Zigor are completely flexible.'

  s.homepage         = 'https://github.com/Resaneh24/ZigorTimeTable'
  s.license          = { :type => 'Apache License', :file => 'LICENSE' }
  s.author           = { 'far2an' => 'far.abd8050@gmail.com' }
  s.source           = { :git => 'https://github.com/Resaneh24/ZigorTimeTable.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.source_files = 'Swift/TimeTable.swift'

end
