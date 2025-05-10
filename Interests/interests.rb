require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'yaml'

LIST_OF_NAMES = 'public/users.yaml'

before do
  @info = YAML.load_file LIST_OF_NAMES
end

get '/' do
  redirect '/names'
end

get '/names' do
  @title = 'All Names'

  erb :names
end

get '/user' do
  @name = params['name']
  @title = "#{@name}'s Email and Interests"
  this_user = @info.find { |item| @name == item.first.to_s }
  @email = this_user.last[:email]
  @interests = this_user.last[:interests].sort

  erb :user
end

helpers do
  def count_interests
    @total_interests = @info.reduce(0) do |accum, info|
      accum + info.last[:interests].size
    end
  end

  def count_users
    @info.size
  end

  def other_users
    @info.reject { |item| item.to_s == @name }.map(&:first).sort
  end

  def user_as_link(name)
    <<-END
      <a href="/user?name=#{name}" class="navigate-to-user"
         id="navigate-to-user-#{name}">
        #{name}
      </a>
    END
  end
end
