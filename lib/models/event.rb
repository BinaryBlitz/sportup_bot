require 'active_record'

class Event < ActiveRecord::Base
  has_many :users, through: :memberships
  has_many :memberships, dependent: :destroy
  has_many :guests, dependent: :destroy

  validates :chat_id, uniqueness: true

  def members_count
    users.count + guests.count
  end

  def members
    users + guests
  end

  def members_list
    members.map.with_index(1) do |member, i|
      if member.class == User
        "#{i}.@#{member.name}"
      else
        "#{i}.Гость @#{member.user.name}"
      end
    end.join("\n")
  end
end
