require 'csv'
class TeachingRoutesController < ApplicationController
  caches_action :index, :layout => false

  BAKUP_FILE = Rails.root.join('public', 'data', 'LastGoodTeachingReport.csv')

  # TODO This doesn't appear to ever be called...
  def checkAccess
    if (action_name == "teacherList" and params[:id] == session[:user_id].to_s ) or hasAccess(2)
      true
    else 
      deny_access
    end
  end

  def updateRoutes
  end

  def uploadFile
    if params[:upload] == nil
      flash[:notice] = 'Please browse to a valid csv file'
      redirect_to :action => 'updateRoutes'
    else
      path = HomeTeachingFile.save(params[:upload])
      expire_action :action => "index"
      begin
        createHomeTeachingRoutes(path)
      rescue Exception => e
        # Most likely a parsing error in the HomeTeacher file.
        logger.info("Error parsing Home Teaching Routes")
        logger.info(e)
        path = BAKUP_FILE
        redirect_to :action => 'updateError', :path => path
      end
    end
  end

  def createHomeTeachingRoutes(homeTeachingFile=nil)
    # TODO This is pretty dangerous, just letting people pass a path into the webserver that
    # we will then read from disk...
    if params[:path] != nil
      homeTeachingFile = params[:path]
    end
    @cantFindTeacher = Set.new
    @cantFindFamily = Set.new
    TeachingRoute.delete_all()
    CSV.foreach(homeTeachingFile, {:headers => true}) do |row|
      #skip past the first row
      if row[0] == ""
        next
      end
      #Get the family name
      famName, headOfHouseHold = getName(row[12].gsub("&","and"))
      fam = Family.find_by_name_and_head_of_house_hold(famName,headOfHouseHold)
      if fam.nil?
        # Check to see if this name is in the NameMapping table
        nameMap = NameMapping.find_by_name_and_category(row[12],'family')
        if nameMap.nil?
          # If there is only one "Smith" in the ward then assume this is the family we want
          families = Family.find_all_by_name(famName)
          if families.size == 1
            fam = families[0]
          else 
            @cantFindFamily.add(row[12])
            next
          end
        else
          fam = Family.find(nameMap.family_id)
        end
      end
      #Get the first home teacher
      hometeacher1 = getPerson(row[6])
      if hometeacher1.nil?
        @cantFindTeacher.add(row[6])
      else
        #puts hometeacher1.name + " " + hometeacher1.family.name 
        TeachingRoute.create(:category => row[0], 
                             :person_id => hometeacher1.id, 
                             :family_id => fam.id)
      end

      hometeacher2 = getPerson(row[9])
      unless hometeacher2 == nil
        #puts hometeacher2.name + " " + hometeacher2.family.name 
        TeachingRoute.create(:category => row[0], 
                             :person_id => hometeacher2.id, 
                             :family_id => fam.id)
      else
        unless row[9] == ""
          @cantFindTeacher.add(row[9])
        end
      end

    end # iterate through the ward list

    if @cantFindTeacher.empty? and @cantFindFamily.empty?
      # All is well - clear the cache and save this 
      # copy of the home teaching report
      expire_action :action => "index"
      if homeTeachingFile != BAKUP_FILE
        FileUtils.cp(homeTeachingFile,BAKUP_FILE)
      end
      redirect_to(teaching_routes_path) 
    else 
      @path = homeTeachingFile 
      render 'updateNames'
    end

  end # action uploadFile

  def updateError
    @path = params[:path]
  end

  def updateNames
    @path = params[:path] || [""]
    names = params[:correct_person] || [""]
    names.each do |name, person_id|
      if NameMapping.find_by_name_and_category(name,'person') == nil
        NameMapping.create(:name => name, :person_id => person_id, 
                           :category =>'person')
      end
    end
    names = params[:correct_family] || [""]
    names.each do |name, family_id|
      if NameMapping.find_by_name_and_category(name,'family') == nil
        NameMapping.create(:name => name, :family_id => family_id,
                           :category =>'family')
      end
    end
    createHomeTeachingRoutes(@path)
  end


  # GET /teaching_routes
  # GET /teaching_routes.xml
  def index
    @teaching_routes = TeachingRoute.all
    @last_updated = TeachingRoute.first ? "last updated #{TeachingRoute.first.last_update}" : 'never updated'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @teaching_routes }
    end
  end

  # GET /teaching_routes/teacherList/1
  def teacherList
    @families = Set.new
    @homeTeacher = Person.find(params[:id])
    teachingRoutes = TeachingRoute.includes(:family).find_all_by_person_id(@homeTeacher.id)
    teachingRoutes.each do | route|
      @families.add(route.family)
    end

    visitingRoutes = VisitingTeachingRoute.includes(:person => [:family]).find_all_by_visiting_teacher_id(@homeTeacher.id)
    visitingRoutes.each do |route|
      @families.add(route.person.family)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => teaching_routes }
    end
  end

  # GET /teaching_routes/1
  # GET /teaching_routes/1.xml
  def show
    @teaching_route = TeachingRoute.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @teaching_route }
    end
  end

  # GET /teaching_routes/new
  # GET /teaching_routes/new.xml
  def new
    @teaching_route = TeachingRoute.new
    @names = Person.selectionList

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @teaching_route }
    end
  end

  # GET /teaching_routes/1/edit
  def edit
    @teaching_route = TeachingRoute.find(params[:id])
    @names = Person.selectionList 
  end

  # POST /teaching_routes
  # POST /teaching_routes.xml
  def create
    @teaching_route = TeachingRoute.new(params[:teaching_route])
    @teaching_route2 = TeachingRoute.new(params[:teaching_route])
    @teaching_route2.person_id = params[:otherHomeTeacher]

    respond_to do |format|
      if @teaching_route.save && @teaching_route2.save
        flash[:notice] = 'TeachingRoute was successfully created.'
        format.html { redirect_to(teaching_routes_path) }
        format.xml  { render :xml => @teaching_route, :status => :created, :location => @teaching_route }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @teaching_route.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /teaching_routes/1
  # PUT /teaching_routes/1.xml
  def update
    @teaching_route = TeachingRoute.find(params[:id])

    respond_to do |format|
      if @teaching_route.update_attributes(params[:teaching_route])
        flash[:notice] = 'TeachingRoute was successfully updated.'
        format.html { redirect_to(@teaching_route) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @teaching_route.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /teaching_routes/1
  # DELETE /teaching_routes/1.xml
  def destroy
    @teaching_route = TeachingRoute.find(params[:id])
    @teaching_route.destroy

    respond_to do |format|
      format.html { redirect_to(teaching_routes_url) }
      format.xml  { head :ok }
    end
  end

private

  def getName(fullName)
    fullName.split(",").collect! {|x| x.strip}
  end

  def getPerson(fullName)
    begin
      lastName, firstName = getName(fullName)

      family = Family.find_all_by_name(lastName)
      if family.size == 0
        return nil
      end

      family.each do |fam|
        #puts firstName + "--" + fam.id.to_s
        person = Person.find_by_current_and_name_and_family_id(true,firstName,fam.id)
        if person.nil?
          next 
        end
        return person
      end
      # At this point we couldn't find the person
      # See if their name is in the mapping table
      # otherwise return nil
      nameMap = NameMapping.find_by_name_and_category(fullName,'person')
      if nameMap
        person = Person.find(nameMap.person_id)
      else
        nil
      end

    rescue Exception => e
      puts e
      nil
    end
  end
end
