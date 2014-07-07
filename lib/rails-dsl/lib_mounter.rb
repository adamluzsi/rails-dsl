# in most of my project i use a boot.rb file in the libs folder for 3. party libs
Thread.new do

  sleep(0.5) while Rails.root.nil?
  if File.exist?(Rails.root.join('lib','boot.rb'))
    require Rails.root.join('lib','boot.rb')
  else
    Dir.glob( Rails.root.join('lib','*.{ru,rb}') ).each { |p| require(p) }
  end

end
