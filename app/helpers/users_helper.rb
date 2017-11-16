module UsersHelper
  
  # see also: /config/initializers/gravatar_image_tag.rb
  
  def gravatar(user)
    gravatar_image_tag user.email, gravatar: {size: 40}, class: user.active? ? "" : "disabled"
  end
end
