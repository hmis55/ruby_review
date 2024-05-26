class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :books, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_one_attached :profile_image
  has_many :book_comments, dependent: :destroy

  validates :name, length: { minimum: 2, maximum: 20 }, uniqueness: true
  #通知機能関連付け
 has_many :active_notifications, class_name: "Notification", foreign_key: "visitor_id", dependent: :destroy
 has_many :passive_notifications, class_name: "Notification", foreign_key: "visited_id", dependent: :destroy




  def get_profile_image
    (profile_image.attached?) ? profile_image : 'no_image.jpg'
  end

  validates :name, presence: true, uniqueness: true, length: { in: 2..20 }
  validates :introduction, length: { maximum: 50 }

  # フォローしている関連付け
  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy

  # フォローされている関連付け
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy

  # フォローしているユーザーを取得
  has_many :followings, through: :active_relationships, source: :followed

  # フォロワーを取得
  has_many :followers, through: :passive_relationships, source: :follower

  # 指定したユーザーをフォローする
  def follow(user)
    active_relationships.create(followed_id: user.id)
  end

  # 指定したユーザーのフォローを解除する
  def unfollow(user)
    active_relationships.find_by(followed_id: user.id).destroy
  end

  # 指定したユーザーをフォローしているかどうかを判定
  def following?(user)
    followings.include?(user)
  end

  def self.search_for(content, method)
    if method == 'perfect'
      User.where(name: content)
    elsif method == 'forward'
      User.where('name LIKE ?', content + '%')
    elsif method == 'backward'
      User.where('name LIKE ?', '%' + content)
    else
      User.where('name LIKE ?', '%' + content + '%')
    end
  end
  
  # フォロー通知を作成するメソッド
  def create_notification_follow!(current_user)
    # すでにフォロー通知が存在するか検索

    existing_notification = Notification.find_by(visitor_id: current_user.id, visited_id: self.id, action: 'follow')

    # フォロー通知が存在しない場合のみ、通知レコードを作成
    if existing_notification.blank?
      notification = current_user.active_notifications.build(
        visited_id: self.id,
        action: 'follow'
      )
      notification.save if notification.valid?
    end
  end

end
