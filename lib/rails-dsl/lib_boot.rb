# in most of my project i use a boor.rb file in the libs folder for 3. party libs
Thread.new do
  sleep(0.5) while Rails.root.nil?
  require Rails.root.join('lib','boot.rb') if File.exist?(Rails.root.join('lib','boot.rb'))
end
