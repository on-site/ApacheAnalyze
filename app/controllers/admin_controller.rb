class AdminController < ApplicationController
  def pull
    system "cd #{Rails.root} && git pull"
    flash[:message] = "Pull complete"
    redirect_to :action => :index
  end

  def restart
    system "touch #{Rails.root}/tmp/restart.txt"
    flash[:message] = "Restart complete"
    redirect_to :action => :index
  end
end
