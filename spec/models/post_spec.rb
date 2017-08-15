require 'spec_helper'

RSpec.describe Post do
  context 'attributes' do
    it 'defines id, title, and body' do
      post = Post.new

      expect(post).to respond_to(:title)
      expect(post).to respond_to(:title=)
      post.title = "The Title of the Post"
      expect(post.title).to eq("The Title of the Post")
      
      expect(post).to respond_to(:body)
      expect(post).to respond_to(:body=)      
      post.body = "The Body of the Post"
      expect(post.body).to eq("The Body of the Post")
    end
  end

  context 'persistance' do
    context '.all' do
      it 'returns an array' do
        expect(Post.all).to be_a(Array)
      end
    end

    context '#save' do
      it 'persists the post' do
        post = Post.new
        post.save

        expect(Post.all).to include(post)
      end
    end
  end

  context 'finders' do
    context '.find_by_id' do
      it 'returns the post by id' do
        post = Post.new
        post.insert

        expect(Post.find_by_id(post.id)).to eq(post)
      end
    end
  end

  context '.create_table' do
    it 'creates a posts table' do

      Post.create_table
      sql = "SELECT name FROM sqlite_master WHERE type='table';"
      results = DB[:conn].execute(sql)

      expect(results.first).to include("posts")
    end
  end

  context '#insert' do
    it 'insert the post row with attributes to the DB' do

      # setup
      post = Post.new
      post.title = "Hello World"
      post.insert

      # expectation
      sql = "SELECT * FROM posts WHERE title = 'Hello World'"
      results = DB[:conn].execute(sql)

      expect(results.first[1]).to eq("Hello World")
    end

    it 'assigns a primary key to the post instance' do
      post = Post.new
      post.title = "Hello World"
      post.insert

      expect(post.id).to be_a(Integer)      
    end
  end  

  context '#update' do
    it 'updates the post' do

      # setup
      post = Post.new
      post.title = "Hello World"
      post.insert

      post.title = "New Title"
      post.update

      # expectation
      sql = "SELECT * FROM posts WHERE title = 'New Title'"
      results = DB[:conn].execute(sql)

      expect(results.first[1]).to eq("New Title")
    end
  end
end 

# .create_table
# .drop_table
# #insert

# .new_from_db

# #persisted?
# #update


# .find_or_create_by
# .find_by_name

# #destroy