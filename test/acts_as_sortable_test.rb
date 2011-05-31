require File.dirname(__FILE__) + '/test_helper'

class ActsAsSortableTest < ActiveSupport::TestCase
  setup do
    DatabaseCleaner.start
    @asimov = Factory(:asimov)
    @gibson = Factory(:gibson)
    @foundation = Factory(:foundation)
    @robots = Factory(:robots)
    @neuromancer = Factory(:neuromancer)
  end

  test 'should_include_acts_as_sortable' do
    assert ActiveRecord::Base.include?(ActsAsSortable)
  end

  test 'should_have_acts_as_sortable_method' do
    assert ActiveRecord::Base.respond_to?(:acts_as_sortable)
  end

  test 'working base case' do
    assert Book.sort().all
  end

  test "return all records" do
    assert_equal 3, Book.sort().count
  end
    
  test "sort by attribute ascending" do
    assert_equal [@foundation, @neuromancer, @robots], Book.sort('name', 'ASC').all
  end
 
  test "sort by attribute descending" do
    assert_equal [@foundation, @neuromancer, @robots].reverse, Book.sort('name', 'DESC').all
  end

  test "sort by association ascending" do
    assert_equal [@foundation, @robots, @neuromancer], Book.sort('author.name', 'ASC').all
  end

  test "multiple sorts" do
    assert_equal [@robots, @foundation, @neuromancer], Book.sort(['author.name', 'ASC'], ['name', 'DESC']).all
  end

  test "ignore invalid sort" do
    assert_equal [@foundation, @neuromancer, @robots], Book.sort(['bla', 'ASC'], ['name', 'ASC']).all
  end
  
  teardown do
    DatabaseCleaner.clean
  end
end