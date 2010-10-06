class FamilySweeper < ActionController::Caching::Sweeper
  observe Family
  observe Event

  def after_save(family)
    expire_cache(family)
  end

  def after_destroy(family)
    expire_cache(family)
  end

  def after_update(family)
    expire_cache(family)
  end

  def expire_cache(family)
    expire_action(:controller => :families, :action => :index)
    expire_action(:controller => :families, :action => :show, :id => family.family)
    expire_action(:controller => :reports, :action => [:hope, :month])
    expire_action(:controller => :teaching_routes, :action => :index)
  end
end
