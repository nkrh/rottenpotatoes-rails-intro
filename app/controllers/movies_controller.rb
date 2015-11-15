class MoviesController < ApplicationController
  before_action :set_filter, only: :index

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def set_filter
    session[:sort] = {} unless session[:sort]  
    session[:filter] = {} unless session[:filter]  
  end
  
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    
    if params[:sort]
      params[:sort].split('|').each do |column_name|
        session[:sort][column_name.to_sym] = :asc if Movie.column_names.include? column_name
      end
    elsif not session[:sort].length.zero?
      redirect_to movies_path params.merge sort: session[:sort].keys.join('|')
      return
    end
    
    if params[:ratings] and not params[:ratings].length.zero?
      session[:filter] = {'rating' => params[:ratings].keys}
    elsif not session[:sort]['rating'].nil?
      redirect_to movies_path params.merge ratings: session[:filter]['rating']
      return
    end

    @sort = session[:sort]
    @filter = session[:filter]
    @all_ratings = ['G', 'PG', 'PG-13', 'R'];
    @movies = Movie.where(@filter).order(@sort)

  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
