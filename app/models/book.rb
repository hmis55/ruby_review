class Book < ApplicationRecord
  belongs_to :user
  has_many :favorites, dependent: :destroy
  has_many :book_comments, dependent: :destroy
  has_many :notifications, dependent: :destroy

  validates :title,presence:true
  validates :body,presence:true,length:{maximum:200}

  def self.search_for(content, method)
    if method == 'perfect'
      Book.where(title: content)
    elsif method == 'forward'
      Book.where('name LIKE ?', content + '%')
    elsif method == 'backward'
      Book.where('name LIKE ?', '%' + content)
    else
      Book.where('name LIKE ?', '%' + content + '%')
    end
  end


  def favorited_by?(user)
     favorites.exists?(user_id: user.id)
  end

  # いいね通知機能
 def create_notification_favorite_book!(current_user)
   # 同じユーザーが同じ投稿に既にいいねしていないかを確認
   existing_notification = Notification.find_by(book_id: self.id, visitor_id: current_user.id, action: "favorite_book")

   # すでにいいねされていない場合のみ通知レコードを作成
   if existing_notification.nil? && current_user != self.user
     notification = Notification.new(
       book_id: self.id,
       visitor_id: current_user.id,
       visited_id: self.user.id,
       action: "favorite_post"
     )

     if notification.valid?
       notification.save
     end
   end
 end
end
