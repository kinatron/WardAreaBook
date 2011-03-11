class MailerController < ApplicationController
  def create_todo_email
    id = params[:id]
    person = Person.find(id)
    email = TaskMailer.create_todo(person)
    render(:text => "<pre>" + email.encoded + "</pre>")
  end
end
