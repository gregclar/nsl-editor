require "test_helper"

# Single author model test.
class LowLevelOperationsTest < ActiveSupport::TestCase

  def setup
    @te = tree_elements(:red_gum_in_taxonomy)
  end

  test "comment key for insert" do
    assert_equal(@te.comment_key_for_insert, "APC Comment")
  end

  test "profile comment crud" do
    te = add_comment_where_none_exists
    te = update_comment(te)
    te = remove_comment(te)
    add_comment_to_null_profile(te)
  end

  def add_comment_where_none_exists
    new_comment = 'comment for where none exists'
    assert_not_nil(@te.profile, 'Expect profile to exist to start this test')
    assert_nil(@te.comment, 'Expect no profile comment to start this test')
    @te.add_comment_to_profile(new_comment, 'fred')
    assert_not_nil(@te.comment)
    assert_equal(@te.comment_value, new_comment)
    te = Tree::Element.find(@te.id)
    assert_not_nil(te.comment)
    assert_equal(te.comment_value, new_comment)
    te
  end

  def update_comment(te)
    new_comment = 'updated comment'
    te.update_comment_directly(new_comment, 'joe')
    te_updated = Tree::Element.find(te.id)
    assert_equal(new_comment, te_updated.comment_value)
    te_updated
  end

  def remove_comment(te)
    te.remove_comment_directly
    te_no_comment = Tree::Element.find(te.id)
    assert_nil(te_no_comment.comment)
    assert_nil(te_no_comment.comment_value)
    te_no_comment
  end

  def add_comment_to_null_profile(te)
    te.profile = nil
    te.save!
    new_comment = 'comment for null profile'
    assert_nil(te.profile, 'Expect empty profile to start this test')
    te.add_profile_and_comment(new_comment, 'jill')
    assert_not_nil(te.comment)
    assert_equal(te.comment_value,new_comment)
    te_commented = Tree::Element.find(te.id)
    assert_equal(te_commented.comment_value,new_comment)
  end
end

