module PeopleHelper
  def link_to_add_calling(name, f, association)
    new_calling = f.object.send(association).klass.new
    id = new_calling.object_id
    fields = f.fields_for(association, new_calling, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', class: "add_calling", data: {id: id, fields: fields.gsub("\n", "")})
  end
end
