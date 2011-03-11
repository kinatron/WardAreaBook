require 'test_helper'

class TaskMailerTest < ActionMailer::TestCase
  test "todo" do
    @expected.subject = 'TaskMailer#todo'
    @expected.body    = read_fixture('todo')
    @expected.date    = Time.now

    assert_equal @expected.encoded, TaskMailer.create_todo(@expected.date).encoded
  end

end
