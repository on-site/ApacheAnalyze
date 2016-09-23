class AdminController < ApplicationController
  def pull
    system "cd #{Rails.root} && git pull"
    flash[:notice] = "Pull complete"
    redirect_to action: :index
  end

  def restart
    system "touch #{Rails.root}/tmp/restart.txt"
    flash[:notice] = "Restart complete"
    redirect_to action: :index
  end
end
