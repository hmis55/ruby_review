class RelationshipsController < ApplicationController
before_action :authenticate_user!

  #ユーザーをフォローするときのアクション
  def create
    user = User.find(params[:user_id])
    current_user.follow(user)
    redirect_to request.referer
  end

  #ユーザーのフォローを解除するためのアクション
  def destroy
    user = User.find(params[:user_id])
    current_user.unfollow(user)
    redirect_to  request.referer
  end

  #特定のユーザーがフォロしてるユーザーの一覧を表示するためのアクション
  def followings
    user = User.find(params[:user_id])
    @users = user.followings
  end

   #特定のユーザーをフォロしてるユーザーの一覧を表示するためのアクション
  def followers
    user = User.find(params[:user_id])
    @users = user.followers
  end
end
