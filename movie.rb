#!/usr/bin/env ruby

require 'json'
require 'uri'
require 'net/http'
require 'colorize'
require 'yourub'


class Movie

#  Define Youtube Acc Info

  def initialize
    options   = { developer_key:      'mySecretKey',
                  application_name:   'yourub',
                  application_version: 2.0,
                  log_level: 3 }
    @yt       = Yourub::Client.new(options)
    @repo     = ""
    @username = ""
  end


# Word wrapping for consise output

  def wrap(s, width = 78)
    s.gsub(/(.{1,#{width}})(\s+|\Z)/, "\\1\n ")
  end


#  Ask for upload movie.yml

  def upload(option)
    run_git if option == "-y"
  end


#  Add and Push to GitHub

  def run_git
    system("git add movie.yml")
    system("git commit -m 'Movie Updated'")
    system("git remote add origin git@github.com:#{@username}/#{@repo}")
    system("git push origin master")
  end


#  Search movie data

  def movie(name)

    api_key = ENV['OMDBAPI_API_KEY'] || '946f500a'
    movie_name = "#{name}"

    uri = URI("http://www.omdbapi.com/?t=#{movie_name}&apikey=#{api_key}")
    response = Net::HTTP.get(uri)
    info = JSON.parse(response)

    if info['Response'] == 'False'
      puts 'No Movie Found!'

    else

     begin
      @title = info['Title'].upcase
      @year = info['Year']
      @score = info['Ratings'][1]['Value']
     rescue
      @score = 'Unknown'
     end

    @rated = info['Rated']
    @genre = info['Genre']
    @actors = wrap(info['Actors'], 48)
    @plot_unformatted = info['Plot']
    @plot = wrap(@plot_unformatted, 48)

    puts '=================================================='.yellow
    puts ""
    puts " Name: #{@title} ".white
    puts " Year: #{@year} ".white
    puts " Genre: #{@genre}".white
    puts ""
    puts " Score: #{@score}".red
    puts " Rated: #{@rated}".light_red
    puts ""
    puts " Actors: #{@actors}".white
    puts " Plot: #{@plot}".yellow
    puts '=================================================='.yellow

    end     # end of if info[response]
  end       # end of movie_name


#  Search youtube for trailer

  def yt_trailer
    @yt.search(query: "#{@name}") do |search|
      @link = search.id
    end
  end


#  Save output

  def save_txt
    File.open("movie.yml", "wb") do |row|
      row <<       "name: #{@title}\n"
      row <<       "year: #{@year}\n"
      row <<      "genre: #{@genre}\n"
      row <<      "score: #{@score}\n"
      row <<     "actors: #{@actors}\n"
      row <<       "plot: #{@plot}\n"
      row << "yt-trailer: #{@link}\n"
    end
  end


#  Movie script execution

  def search(movie)
    movie(movie)
    save_txt
    yt_trailer
  end


end     # END OF CLASS


  movie = Movie.new


  if ARGV[0] == "-y"
    movie.upload("-y")
  elsif ARGV[1] == "-y"
    movie.search(ARGV[0])
    movie.upload("-y")
  else
    movie.search(ARGV[0])
  end


