require 'csv'
require 'securerandom'
class TeachingRouteUploadingController < ApplicationController
  # Action Method
  def update_routes
  end

  # Action Method
  def update_error
    @file_name = params[:file_name]
  end

  # Action Method
  def upload_file
    if params[:upload] == nil
      flash[:notice] = 'Please browse to a valid csv file'
      redirect_to :action => 'update_routes'
    else
      file_name = save_file(params[:upload])
      begin
        create_routes(file_name)
      rescue Exception => e
        logger.info("Error parsing Teaching Routes for: #{file_name}")
        logger.info(e)
        redirect_to :action => 'update_error', :file_name => backup_file_name
      end
    end
  end

  # Action Method
  def update_with_path
    create_routes(params[:file_name])
  end


  # Action Method
  def update_names
    @file_name = params[:name] || [""]
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
    create_routes(@file_name)
  end


  def upload_root
    Rails.root.join('tmp', 'uploads')
  end

  def uploaded_file_path(name)
    # Use File.basename to ensure we don't append anything with slashes in it, to avoid ../..
    upload_root.join(File.basename(name))
  end

  def save_file(upload)
    name = SecureRandom.hex(16)
    File.open(uploaded_file_path(name), "wb") { |f| f.write(upload['datafile'].read) }
    name
  end

end
