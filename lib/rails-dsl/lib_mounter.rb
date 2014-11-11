# in most of my project i use a boot.rb file in the libs folder for 3. party libs
Thread.new do

  #> wait for 60 sec try else give up, no inf loop chance!
  120.times do
    if Rails.root.nil?
      sleep(0.5)
    else

      if File.exist?(File.join(Rails.root,'lib','boot.rb'))
        require File.join(Rails.root,'lib','boot.rb')
      else
        Dir.glob( File.join(Rails.root,'lib','*.{ru,rb}') ).each { |p| require(p) }
      end
      break

    end
  end

end
