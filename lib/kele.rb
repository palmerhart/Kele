require 'httparty'
require 'json'
require './kele/roadmap'

class Kele
    include HTTParty
    include Roadmap
    
    def initialize(email, password)
        response = self.class.post(api_url("sessions"), body:{"email": email, "password": password})
        raise "Invalid email or password" if response.code != 200
        @auth_token = response["auth_token"]
    end
    
    def get_me
        url = "https://www.bloc.io/api/v1/users/me"
        response = self.class.get(url, headers: {"authorization" => @auth_token})
        body = JSON.parse(response.body)
    end
    
    def get_mentor_availability(mentor_id = 2355824)
        url = 'https://www.bloc.io/api/v1/mentors/'+(mentor_id.to_s)+'/student_availability'
        response = self.class.get(url, headers: {"authorization" => @auth_token})
        body = JSON.parse(response.body)
    end
    
    def get_messages(arg = nil)
        url = 'https://www.bloc.io/api/v1/message_threads'
        response = self.class.get(url, headers: {"authorization" => @auth_token})
        body = JSON.parse(response.body)
        if arg == nil
            pages = (1..response["count"]).map do |n|
                self.class.get(url, body: { page: n}, headers: {"authorization" => @auth_token})
            end
        else
           self.class.get(url, body: { page: arg }, headers: {"authorization" => @auth_token}) 
        end
    end
    
    def create_message(user_id, recipient_id, subject, stripped)
        url = 'https://www.bloc.io/api/v1/messages'
        self.class.post(url, body: {user_id: user_id, recipient_id: recipient_id, token: nil, subject: subject, stripped: stripped}, headers: {"authorization" => @auth_token})
    end
    
    def create_submission(checkpoint_id, assignment_branch, assignment_commit_link, comment)
        url = 'https://www.bloc.io/api/v1/checkpoint_submissions'
        self.class.post(url, body: {checkpoint_id: checkpoint_id, assignment_branch: assignment_branch, assignment_commit_link: assignment_commit_link, comment: comment}, headers: {"authorization" => @auth_token})
        
    end
    
    private
    def api_url(endpoint)
        "https://www.bloc.io/api/v1/#{endpoint}"
    end
    
end