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
    
    # Check if we miss some query params while they are exist in session
    redirect_params = {}
    
    if !session[:sort].length.zero? and !params[:sort]
      redirect_params[:sort] = session[:sort].keys.join('|') 
    end

    if !session[:filter]['rating'].nil? and !params[:ratings]
      rating_hash = {}
      session[:filter]['rating'].each do |rating|
        rating_hash[rating] = 1
      end
      redirect_params[:ratings] = rating_hash
    end
    
    # Redirect to current path with new params
    if !redirect_params.empty?
      redirect_to movies_path params.permit(:sort, :ratings).merge(redirect_params)
      return
    end
    
    if params[:sort]
      sort_hash = {}
      params[:sort].split('|').each do |column_name|
        sort_hash[column_name.to_sym] = :asc if Movie.column_names.include? column_name
      end
      session[:sort] = sort_hash
    end
    
    if params[:ratings] and not params[:ratings].length.zero?
      session[:filter] = {'rating' => params[:ratings].keys}
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
