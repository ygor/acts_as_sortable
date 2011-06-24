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
    assert Book.sorted.all
  end

  test 'working empty case' do
    assert Book.sorted({}).all
    assert Book.sorted().all
    assert Book.sorted([]).all
  end

  test "return all records" do
    assert_equal 3, Book.sorted.count
  end
    
  test "sort by attribute ascending" do
    assert_equal [@foundation, @neuromancer, @robots], Book.sorted(:key => 'name', :dir => 'asc').all
  end
 
  test "sort by attribute descending" do
    assert_equal [@foundation, @neuromancer, @robots].reverse, Book.sorted(:key => 'name', :dir => 'desc').all
  end

  test "sort by association ascending" do
    assert_equal [@foundation, @robots, @neuromancer], Book.sorted(:key => 'author.name', :dir => 'asc').all
  end

  test "multiple sorts" do
    assert_equal [@robots, @foundation, @neuromancer], Book.sorted({:key => 'author.name', :dir => 'asc'}, {:key => 'name', :dir => 'DESC'}).all
  end

  test "ignore invalid sort" do
    assert_equal [@foundation, @neuromancer, @robots], Book.sorted({:key =>'bla', :dir => 'asc'}, {:key => 'name', :dir => 'asc'}).all
  end

  test "sort scoped model" do
    assert_equal [@robots, @foundation], @asimov.books.where('name != ""').sorted(:key => :name, :dir => :desc).all
  end  
  
  teardown do
    DatabaseCleaner.clean
  end
end