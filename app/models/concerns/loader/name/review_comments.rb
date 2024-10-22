module Loader::Name::ReviewComments
  extend ActiveSupport::Concern

  def has_name_review_comments?
    name_review_comments.size > 0
  end

  def direct_reviewer_comments?(context = "any")
    narrow_direct_reviewer_comments.size > 0
  end

  def direct_reviewer_comments(context = "any")
    name_review_comments
      .includes(batch_reviewer: [:batch_review_role])
      .select { |comment| comment.reviewer.role.name == Loader::Batch::Review::Role::NAME_REVIEWER }
      .select { |comment| comment.context == context || context == "any" }
  end

  def children_reviewer_comments(context = "any")
    children.map do |child| 
      child.name_review_comments
      .includes(batch_reviewer: [:batch_review_role])
      .select { |comment| comment.reviewer.role.name == Loader::Batch::Review::Role::NAME_REVIEWER }
      .select { |comment| comment.context == context || context == "any" }
    end.flatten
  end

  def narrow_direct_reviewer_comments?
    narrow_direct_reviewer_comments.size > 0
  end

  # just comments for this record - excluding concept-note or distribution comments for accepted/excluded records
  def narrow_direct_reviewer_comments
    name_review_comments
      .includes(batch_reviewer: [:batch_review_role])
      .select { |comment| comment.reviewer.role.name == Loader::Batch::Review::Role::NAME_REVIEWER }
      .select { |comment| comment.context == record_type }
  end

  def direct_compiler_comments(context = "any")
    name_review_comments
      .includes(batch_reviewer: [:batch_review_role])
      .select { |comment| comment.reviewer.role.name == Loader::Batch::Review::Role::COMPILER }
      .select { |comment| comment.context == context || context == "any" }
  end

  def children_compiler_comments(context = "any")
    children.map do |child| 
      child.name_review_comments
      .includes(batch_reviewer: [:batch_review_role])
      .select { |comment| comment.reviewer.role.name == Loader::Batch::Review::Role::COMPILER }
      .select { |comment| comment.context == context || context == "any" }
    end.flatten
  end

  def reviewer_comments(context = "any")
    [direct_reviewer_comments(context), 
     children_reviewer_comments(context)].flatten
  end

  def reviewer_comments?(context = "any")
    reviewer_comments(context).size > 0
  end


  def compiler_comments(context = "any")
    [direct_compiler_comments(context), 
     children_compiler_comments(context)].flatten
  end

  def compiler_comments?(context = "any")
    compiler_comments(context).size > 0
  end

  def compiler_and_reviewer_comments(context = "any")
    [reviewer_comments(context),
     compiler_comments(context)].flatten
  end

  def compiler_and_reviewer_comments?(context = "any")
    compiler_and_reviewer_comments(context).size > 0
  end
end

