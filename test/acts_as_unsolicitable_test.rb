require 'test_helper'

class ActsAsUnsolicitableTest < ActiveSupport::TestCase

  test "comment_name_field_should_be_name" do
    assert_equal "name", Comment.unsolicitable_name_field
  end

  test "comment_email_field_should_be_email" do
    assert_equal "email", Comment.unsolicitable_email_field
  end

  test "comment_content_field_should_be_content" do
    assert_equal "content", Comment.unsolicitable_content_field
  end

  test "customized_comment_name_field_should_be_name" do
    assert_equal "first_name", CustomizedComment.unsolicitable_name_field
  end

  test "customized_comment_email_field_should_be_email" do
    assert_equal "email_address", CustomizedComment.unsolicitable_email_field
  end

  test "customized_comment_content_field_should_be_content" do
    assert_equal "body", CustomizedComment.unsolicitable_content_field
  end

  test "comment_should_have_score_of_1" do
    comment = Comment.new
    comment.content = "viagra"
    comment.email = "foobar@example.ca"
    assert_equal 1, comment.calculate_score
  end

end
