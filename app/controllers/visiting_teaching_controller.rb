require 'csv'
class VisitingTeachingController < ApplicationController
  BAKUP_FILE = Rails.root.join('public', 'data', 'LastGoodVisitingTeachingReport.csv')

  # GET /teaching_routes
  # GET /teaching_routes.xml
  def index
    @teaching_routes = VisitingTeachingRoute.all
    @last_updated = VisitingTeachingRoute.first ? "last updated #{VisitingTeachingRoute.first.updated_at}" : 'never updated'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @teaching_routes }
    end
  end

  def update_routes
  end

  def upload_file
    if params[:upload] == nil
      flash[:notice] = 'Please browse to a valid csv file'
      redirect_to :action => 'update_routes'
    else
      path = HomeTeachingFile.save(params[:upload])
      expire_action :action => "index"
      begin
        create_visiting_teaching_routes(path)
      rescue Exception => e
        # Most likely a parsing error in the HomeTeacher file.
        logger.info("Error parsing Visiting Teaching Routes")
        logger.info(e)
        path = BAKUP_FILE
        redirect_to :action => 'update_error', :path => path
      end
    end
  end

  def update_with_path
    create_visiting_teaching_routes
  end

  def create_visiting_teaching_routes(visitingTeachingFile=nil)
    if params[:path] != nil
      visitingTeachingFile = params[:path]
    end
    @cantFindPerson = Set.new
    VisitingTeachingRoute.delete_all()
    CSV.foreach(visitingTeachingFile, {:headers => true}) do |row|
      #skip past the first row
      if row[0] == ""
        next
      end

      # Get the person taught
      sister_taught = getPerson(row[11])
      if sister_taught.nil?
        @cantFindPerson.add(row[11])
        next
      end

      #Get the first visiting teacher
      visiting_teacher = getPerson(row[5])
      if visiting_teacher.nil?
        @cantFindPerson.add(row[5])
      else
        VisitingTeachingRoute.create(:person_id => sister_taught.id, :visiting_teacher_id => visiting_teacher.id)
      end

      #Get the second visiting teacher
      visiting_teacher = getPerson(row[8])
      if visiting_teacher.nil?
        unless row[9].empty?
          @cantFindPerson.add(row[8])
        end
      else
        VisitingTeachingRoute.create(:person_id => sister_taught.id, :visiting_teacher_id => visiting_teacher.id)
      end

    end # iterate through the ward list

    if @cantFindPerson.empty?
      if visitingTeachingFile != BAKUP_FILE
        FileUtils.cp(visitingTeachingFile,BAKUP_FILE)
      end
      redirect_to(visiting_teaching_path) 
    else 
      @path = visitingTeachingFile 
      render 'update_names'
    end

  end # action uploadFile

  def update_error
    @path = params[:path]
  end

  def update_names
    @path = params[:path] || [""]
    names = params[:correct_person] || [""]
    names.each do |name, person_id|
      if NameMapping.find_by_name_and_category(name,'person') == nil
        NameMapping.create(:name => name, :person_id => person_id, 
                           :category =>'person')
      end
    end

    create_visiting_teaching_routes(@path)
  end


  # GET /teaching_routes/teacherList.html
  def teacher_list
    @families = Set.new
    @homeTeacher = Person.find(params[:id])
    @teachingRoutes = TeachingRoute.find_all_by_person_id(@homeTeacher.id)
    @teachingRoutes.each do | route|
      @families.add(route.family)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @teaching_routes }
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

  def checkAccess
    if (action_name == "teacherList" and params[:id] == session[:user_id].to_s ) or hasAccess(2)
      true
    else 
      deny_access
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
        if person == nil
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
