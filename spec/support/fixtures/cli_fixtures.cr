module CLIFixtures
  def expected_animal_controller
    <<-CONT
    class AnimalController < ApplicationController
      def index
        animals = Animal.all.to_a
        respond_with 200 do
          json animals.to_json
        end
      end
    
      def show
        if animal = Animal.find params["id"]
          respond_with 200 do
            json animal.to_json
          end
        else
          results = {status: "not found"}
          respond_with 404 do
            json results.to_json
          end
        end
      end
    
      def create
        animal = Animal.new(animal_params.validate!)
    
        if animal.valid? && animal.save
          respond_with 201 do
            json animal.to_json
          end
        else
          results = {status: "invalid"}
          respond_with 422 do
            json results.to_json
          end
        end
      end
    
      def update
        if animal = Animal.find(params["id"])
          animal.set_attributes(animal_params.validate!)
          if animal.valid? && animal.save
            respond_with 200 do
              json animal.to_json
            end
          else
            results = {status: "invalid"}
            respond_with 422 do
              json results.to_json
            end
          end
        else
          results = {status: "not found"}
          respond_with 404 do
            json results.to_json
          end
        end
      end
    
      def destroy
        if animal = Animal.find params["id"]
          animal.destroy
          respond_with 204 do
            json ""
          end
        else
          results = {status: "not found"}
          respond_with 404 do
            json results.to_json
          end
        end
      end
    
      def animal_params
        params.validation do
        end
      end
    end

    CONT
  end

  def expected_post_model_migration
    <<-SQL
    -- +micrate Up
    CREATE TABLE posts (
      id INTEGER NOT NULL PRIMARY KEY,
      title VARCHAR,
      body TEXT,
      published BOOL,
      likes INT,
      user_id BIGINT,
      created_at TIMESTAMP,
      updated_at TIMESTAMP
    );
    CREATE INDEX post_user_id_idx ON posts (user_id);

    -- +micrate Down
    DROP TABLE IF EXISTS posts;

    SQL
  end

  def expected_post_model_spec
    <<-SQL
    require "./spec_helper"
    require "../../src/models/post.cr"

    describe Post do
      Spec.before_each do
        Post.clear
      end
    end

    SQL
  end

  def expected_post_model
    <<-MODEL
    class Post < ApplicationModel
      with_timestamps
      mapping(
        id: Primary32,
        title: { type: String? },
        body: { type: String? },
        published: { type: Bool? },
        likes: { type: Int32? },
        created_at: { type: Time? },
        updated_at: { type: Time? }
      )

      belongs_to :user
    end

    MODEL
  end
end
