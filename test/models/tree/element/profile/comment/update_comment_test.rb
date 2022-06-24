require "test_helper"

# Single author model test.
class UpdateCommentTest < ActiveSupport::TestCase

  def setup
    @te = tree_elements(:red_gum_in_taxonomy)
  end

  test "update comment" do
    te = update_null_comment_to_non_null_value(@te)
    te = update_non_null_comment_to_null_value(te)
    te = update_null_comment_to_null_value(te)
    te = update_null_comment_to_non_null_value(te)
    te = update_non_null_comment_to_non_null_value(te)
    te = update_non_null_comment_to_unchanged_value(te)
  end

  def update_null_comment_to_non_null_value(te)
    new_comment = 'comment for where none exists'
    assert_not_nil(te.profile, 'Expect profile to exist to start this test')
    assert_nil(te.comment, 'Expect no profile comment to start this test')
    comment, refresh = te.update_comment(new_comment, 'nncuser')
    te_changed = Tree::Element.find(te.id)
    assert_equal(te_changed.comment_value, new_comment)
    te_changed
  end

  def update_non_null_comment_to_null_value(te)
    new_comment = nil
    assert_not_nil(te.profile, 'Expect profile to exist to start this test')
    assert_not_nil(te.comment, 'Expect profile comment to exist to start this test')
    comment, refresh = te.update_comment(new_comment, 'nncuser')
    te_changed = Tree::Element.find(te.id)
    assert_nil(te_changed.comment_value)
    te_changed
  end

  def update_null_comment_to_null_value(te)
    new_comment = nil
    assert_not_nil(te.profile, 'Expect profile to exist to start this test')
    assert_nil(te.comment, 'Expect profile comment to be null to start this test')
    comment, refresh = te.update_comment(new_comment, 'nncuser')
    te_changed = Tree::Element.find(te.id)
    assert_nil(te_changed.comment_value)
    te_changed
  end

  def update_non_null_comment_to_non_null_value(te)
    new_comment = 'non-null value'
    assert_not_nil(te.profile, 'Expect profile to exist to start this test')
    assert_not_nil(te.comment, 'Expect profile comment to exist to start this test')
    comment, refresh = te.update_comment(new_comment, 'nncuser')
    te_changed = Tree::Element.find(te.id)
    assert_equal(new_comment, te_changed.comment_value)
    te_changed
  end

  def update_non_null_comment_to_unchanged_value(te)
    assert_not_nil(te.profile, 'Expect profile to exist to start this test')
    assert_not_nil(te.comment, 'Expect profile comment to exist to start this test')
    new_comment = te.comment_value
    comment, refresh = te.update_comment(new_comment, 'nncuser')
    te_changed = Tree::Element.find(te.id)
    assert_equal(new_comment, te_changed.comment_value)
    te_changed
  end
end
