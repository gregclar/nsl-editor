require "test_helper"

# Single author model test.
class UpdateDistributionTest < ActiveSupport::TestCase

  def setup
  end

  test "update distribution" do
    te = tree_elements(:red_gum_in_taxonomy)
    te = update_null_dist_to_null_value(te)
    te = update_null_profile_to_non_null_disordered_dist(te)
    te = update_profile_to_invalid_dist(te, 'Wa')
    te = update_profile_to_invalid_dist(te, 'NSW (native naturalised)')
    te = update_profile_to_invalid_dist(te, 'wa, nsw, gh')
    te = update_profile_to_invalid_dist(te, 'VIC')
    te = update_profile_to_invalid_dist(te, 'Vic,, NSW', /Error: empty distribution value, likely due to an unnecessary comma/i)
    te = update_profile_to_invalid_dist(te, ',Vic', /Error: empty distribution value, likely due to an unnecessary comma/i)
    te = remove_dist_leaving_comment(te)
    te = update_null_dist_to_valid_dist(te, 'WA, NSW (naturalised)')
    te = update_dist_to_valid_dist(te, 'NSW,,')
  end

  def update_null_dist_to_null_value(te)
    new_dist = nil
    assert_nil(te.profile, 'Expect no profile to start this test')
    assert_nil(te.distribution, 'Expect no profile distribution to start this test')
    distribution, refresh = te.update_distribution(new_dist, 'dist user')
    te_changed = Tree::Element.find(te.id)
    assert_nil(te_changed.distribution_value, 'Update distribution, update null to null - value is not nil error')
    te_changed
  end

  # Note: the new distribution is deliberately in the wrong order
  def update_null_profile_to_non_null_disordered_dist(te)
    tag = 'update_null_profile_to_non_null_dist'
    new_dist = 'NSW, WA'
    assert_nil(te.profile, "Expect no profile to start #{tag} test")
    assert_nil(te.distribution, "Expect no profile distribution to start #{tag} test")
    message, refresh = te.update_distribution(new_dist, 'dist user')
    assert_match(/Distribution added to .* profile/, message, "Wrong message '#{message}' for #{tag}") 
    assert(refresh, "Expect refresh for #{tag}") 
    te_changed = Tree::Element.find(te.id)
    assert_equal(new_dist.split(',').collect {|x| x.strip}.sort.join(', '),
                 te_changed.distribution_value.split(',').collect {|x| x.strip}.sort.join(', '),
                 "Expected sorted distributions to be equal for #{tag}")
    assert_not_equal(new_dist, te_changed.distribution_value,
                 "Expected unsorted distributions to be unequal for #{tag}")
    te_changed
  end

  def update_profile_to_invalid_dist(te, new_dist, expected_message_re = /Error: Invalid distribution value: /i)
    tag = 'update_profile_to_invalid_dist'
    message, refresh = te.update_distribution(new_dist, 'dist user')
    te_changed = Tree::Element.find(te.id)
    assert_match(expected_message_re,
                 message, "Unexpected message for #{tag} with dist: #{new_dist}") 
    assert_not(refresh, "Expected no refresh for #{tag}") 
    assert_equal(te.distribution_value, te_changed.distribution_value,
                 "Expected distribution to be unchanged for #{tag}")
    te_changed
  end

  # Note: the new distribution is deliberately in the wrong order
  def remove_dist_leaving_comment(te)
    tag = 'remove_dist_leaving_comment'
    new_dist = ''
    assert_not_nil(te.profile, "Expect profile to start #{tag} test")
    assert_not_nil(te.distribution, "Expect profile distribution to start #{tag} test")
    message, refresh = te.update_distribution(new_dist, 'dist user')
    te_changed = Tree::Element.find(te.id)
    assert_match(/Distribution removed/, message, "Wrong message '#{message}' for #{tag}") 
    assert(refresh, "Expected refresh for #{tag}") 
    assert_nil(te_changed.distribution_value,
                 "Expected no distribution for #{tag}")
    te_changed
  end

  def update_null_dist_to_valid_dist(te, new_dist)
    tag = 'update_null_dist_to_valid_dist'
    message, refresh = te.update_distribution(new_dist, 'dist user')
    te_changed = Tree::Element.find(te.id)
    assert_match(/Distribution added to a fresh profile/i,
                 message, "Unexpected message '#{message}' for #{tag}") 
    assert(refresh, "Expected refresh for #{tag}") 
    assert_equal(new_dist, te_changed.distribution_value,
                 "Expected distribution to be changed for #{tag}")
    te_changed
  end

  def update_dist_to_valid_dist(te, new_dist)
    tag = 'update_dist_to_valid_dist'
    message, refresh = te.update_distribution(new_dist, 'dist user')
    te_changed = Tree::Element.find(te.id)
    assert_match(/Distribution changed/i,
                 message, "Unexpected message '#{message}' for #{tag}") 
    assert(refresh, "Expected refresh for #{tag}") 
    assert_equal(new_dist.sub(/,,*$/,''), te_changed.distribution_value,
                 "Expected distribution to be add for #{tag}")
    te_changed
  end

  def show_tede(te)
    puts "TEDE: #{te.distribution_value}"
    Tree::Element::DistributionEntry.where(tree_element_id: te.id)
      .joins(:dist_entry).order('sort_order').each {|tede| puts(tede.show)}
  end
end
