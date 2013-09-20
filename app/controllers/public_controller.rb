class PublicController < ApplicationController

  layout 'public'
  layout false, only: [:quoteapp, :author_topic_list]
  before_filter :setup_navigation
  before_filter :langchange
  before_filter :meta_defaults
  def aboutus
  end
  def privacy
  end
  def disclaimer
  end
  def sitemap
  end
  def feedback
	@feedbacks = Feedback.visible.all
  end

  def index
  @quotes = Quote.find_by_sql("SELECT * FROM quotes WHERE (LENGTH(quote) - LENGTH(REPLACE(quote,' ',''))+1) < 25 ORDER BY rand(CURDATE( ) )LIMIT 1 ")
  @keyword = SearchEngOpt.where(:meta_id => '0', :meta_type => 'MainHomePage')

  end
 
  def latest_update
  end


def show
@subnav = Subject.find(params[:id])
@page_title = @subnav.name
@subsubjectnav = SubSubject.where(:subject_id => @subnav.id)
@relpages = Page.where(:subject_id => @subnav.id).order("created_at desc").limit(3)
@titles = Page.where(:subject_id => @subnav.id).visible.order(:name)
@titles1 = Page.where(:subject_id => @subnav.id).visible.order(:popular_name)
@authors = Author.all
@posts = Page.find_by_sql(["SELECT p.* FROM pages p, comments c WHERE p.subject_id =? AND c.page_id = p.id AND c.visible ='1' GROUP BY p.id ORDER BY count( c.comment ) DESC LIMIT 3",@subnav.id])
@keyword = SearchEngOpt.where(:meta_id => @subnav.id, :meta_type => 'Subject')
@advertise = Advertisement.where(:location_id => @subnav.id, :location_type => 'Subject')
end

def showsubsubject
@subsubjectid = SubSubject.find(params[:id])
@subjectname = Subject.find(@subsubjectid.subject_id)
@subsubjectname = SubSubject.where(:subject_id => @subjectname.id)
@subpages = Page.where(:sub_subject_id => @subsubjectid.id).visible.order("created_at desc").paginate :page => params[:page], :per_page => 3
@pagename = Page.where(:sub_subject_id => @subsubjectid.id).visible.order(:name)
@keyword = SearchEngOpt.where(:meta_id => @subsubjectid.id, :meta_type => 'SubSubject')
end

def showpages
@pageid = Page.find(params[:id])
@otherpage = Page.where(:sub_subject_id => @pageid.sub_subject_id).order("RAND()").limit(1)
@page_title = @pageid.subject.name
@page_script = @pageid.popular_name
@pagesec = Section.where(:page_id => @pageid.id)
@pagecom = Comment.visible.where(:page_id => @pageid.id)
@authorid = Author.find_by_author_name(@pageid.name)
@q = @pageid.sub_subject.name.split(' ')
@topicid = Topic.where('topic_name LIKE ?', "%#{@q[0]}%")
@keyword = SearchEngOpt.where(:meta_id => @pageid.id, :meta_type => 'Page')
end

def quotations
@subnav = Subject.find_by_permalink('quotations')
@page_title = 'Quotations'
@topics = Topic.order(:topic_name)
@authors = Author.order(:author_name)
@type = params[:type] 
if @type == 'author'
	@selauthor = Author.find(params[:id])
	@selquotes = Quote.where(:author_id => @selauthor.id).paginate(:per_page => 10, :page => params[:page], :order => "RAND()")
elsif @type == 'topic'
	@seltopic = Topic.find(params[:id])
	@selquotes = Quote.where(:topic_id => @seltopic.id).paginate(:per_page => 10, :page => params[:page], :order => "RAND()")
else @type == 'topviews'
      @selquotes = Quote.all.sort_by{rand}.slice(0,10)
end
@advertise = Advertisement.where(:location_id => @subnav.id, :location_type => 'Subject')
@keyword = SearchEngOpt.where(:meta_id => @subnav.id, :meta_type => 'Subject')
end



def videotags
@videotag = VideoTag.where(:name => params[:title])
end

def videolist
@maincat=params[:cat]
@title= params[:title]
@videocatid = Videosub1cat.find_by_name(@title)
@videolist = VideoList.where(:videocats_id => @videocatid.id)
@videopopular = VideoTag.all.sort_by{rand}.slice(0,4)  
end

def video
if params[:cat]
@maincat=params[:cat]
@videomaincat=VideoMainCat.find_by_name(params[:cat])
@videocat = Videocat.where(:cat_id => @videomaincat.id)
@videocat1 = Videocat.find_by_cat_id(@videomaincat.id ,:limit => 1)
@videosubcat1 = Videosub1cat.find_by_category_id(@videocat1.id ,:limit => 1)
@videopopular = VideoTag.where(:id => @videosubcat1.id)
@videomaincat=VideoMainCat.all
@videolist = VideoList.where(:videocats_id => @videosubcat1.id)
else
@maincat='WHO'
@maincat1=VideoMainCat.first
@videocat = Videocat.where(:cat_id => @maincat1.id)
@videocat1 = Videocat.find_by_cat_id(@maincat1.id ,:limit => 1)
@videosubcat1 = Videosub1cat.find_by_category_id(@videocat1.id ,:limit => 1)
@videopopular = VideoTag.where(:id => @videosubcat1.id)
@videomaincat=VideoMainCat.all
@videolist = VideoList.where(:videocats_id => @videosubcat1.id)
end
end

def events
@page_title = 'Events'
@pageid = Page.find(params[:id])
@otherpage = Page.where(:subject_id => @pageid.subject_id).order("RAND()").limit(1)
@page_script = @pageid.name
@pagecom = Comment.visible.where(:page_id => @pageid.id)
end

def gkpages
@page_title = 'G Knowledge'
@view='View Questions'
@pageid = Page.find(params[:id])
@pagesec = Section.where(:page_id => @pageid.id)
@page_script = @pageid.name
@pagecom = Comment.visible.where(:page_id => @pageid.id)
@otherpage = Page.where(:subject_id => @pageid.subject_id).order("RAND()").limit(1)
end

def gspeeches
@page_title = 'Great Speeches'
@pageid = Page.find(params[:id])
end

def search
      @pagetype = params[:pagetype]
      @pageactiontype = params[:pageactiontype]
      @pageid = Page.all
      @strisrt = Sanitize.clean(params[:search_string])
      @seperateword = @strisrt.split(' ')


      @videosearch = VideoTag.search @strisrt,@strisrt.capitalize,@strisrt.upcase,@strisrt.downcase,@strisrt.split(' ').map {|w| w.capitalize }.join(' ')

      @subjectsearchrsult = Subject.search @strisrt,@strisrt.capitalize,@strisrt.upcase,@strisrt.downcase,@strisrt.split(' ').map {|w| w.capitalize }.join(' ')
        
      @sectioncompletesamestring = Section.search @strisrt,@strisrt.capitalize,@strisrt.upcase,@strisrt.downcase,@strisrt.split(' ').map {|w| w.capitalize }.join(' ')
    
      @pagecompletesamestring = Page.subjectpagesearch @strisrt,@strisrt.capitalize,@strisrt.upcase,@strisrt.downcase,@strisrt.split(' ').map {|w| w.capitalize }.join(' ')
      
      @quotesearch = Quote.search @strisrt,@strisrt.capitalize,@strisrt.upcase,@strisrt.downcase

      @quoteauthorsearch = Author.authorsearch @strisrt,@strisrt.capitalize,@strisrt.upcase,@strisrt.downcase,@strisrt.split(' ').map {|w| w.capitalize }.join(' ')

      @quotetopicsearch = Topic.topicsearch @strisrt,@strisrt.capitalize,@strisrt.upcase,@strisrt.downcase,@strisrt.split(' ').map {|w| w.capitalize }.join(' ')

      @searchbasedon = Subject.where(:id => @pagetype)
       if @pageactiontype == 'quotations'
	@pageactiontypecontent = @quotesearch
	@pageactiontypecontent2 =  @quoteauthorsearch
	@pageactiontypecontent3 =  @quotetopicsearch
       else
	@pagesearchspecific = Page.where(:subject_id => @pagetype)
	@a=@pagesearchspecific.subjectpagesearch @strisrt,@strisrt.capitalize,@strisrt.upcase,@strisrt.downcase,@strisrt.split(' ').map {|w| w.capitalize }.join(' ')
	@pageactiontypecontent3 =  @quotetopicsearch
       end

end


  private
  
  def setup_navigation
  	@subjects = Subject.visible.sorted
	@subsubjects = SubSubject.where(:subject_id => 1)
  	@pages = Page.visible.last
	@pagetypesearchid = params[:id]
	@pagetypesearchaction = params[:action]
	
	#@subjects1 = Subject.all.collect {|p| p.name}
	#@subjects1 += Page.all.collect {|p| p.name} # Page autosuggest
	#@subjects1 += SubSubject.all.collect {|p| p.name} # Subsubject autosuggest
	#@authors1 = Author.all.collect {|p| p.author_name}	# Author autosuggest
	#@autosuggest_json = @subjects1.to_json
	#@authors1_json = @authors1.to_json

	
  end
    


        		
  def langchange
 	#@urlc ='http://localhost:3001/'+params[:controller]+'/'+params[:action]+'/'
        if params[:permalink] && (params[:action] == 'showsubsubject')
       		@langsubsubjectid = SubSubject.find_by_permalink(params[:permalink])
       		if @langsubsubjectid
        		params[:id] = @langsubsubjectid
      		else
			redirect_to :back
       		end
     	elsif (params[:permalink] && (params[:action] == 'show'))
      		@langsubjectid = Subject.find_by_permalink(params[:permalink])
      		if @langsubjectid
        		params[:id] = @langsubjectid
      		else
			redirect_to :back
       		end
    	elsif (params[:permalink] && (params[:action] == 'showpages'))
       		@langpageid = Page.find_by_permalink(params[:permalink])
       		 if @langpageid
         		params[:id] = @langpageid
        	else
        		redirect_to :back
		end
        elsif (params[:permalink] && (params[:action] == 'events'))
       		@langpageid = Page.find_by_permalink(params[:permalink])
       		 if @langpageid
         		params[:id] = @langpageid
        	else
        		redirect_to :back
		end
 elsif (params[:permalink] && (params[:action] == 'inventions'))
       		@langpageid = Page.find_by_permalink(params[:permalink])
       		 if @langpageid
         		params[:id] = @langpageid
        	else
        		redirect_to :back
		end
		elsif (params[:permalink] && (params[:action] == 'gkpages'))
       		@langpageid = Page.find_by_permalink(params[:permalink])
       		 if @langpageid
         		params[:id] = @langpageid
        	else
        		redirect_to :back
		end
      end
		
  end



  private

 def meta_defaults
   # @page_title = "Welcome to"
    @meta_keywords = ""
    @meta_description = ""
  end

end
