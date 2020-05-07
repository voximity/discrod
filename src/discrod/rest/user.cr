module Discrod::REST::UserEndpoints
    # Gets a user from Discord's API, skipping the cache. Use the cache to get channels if you do not wish to request the API.
    def get_user(id : Snowflake | UInt64)
        body = @route_client.get Route.new("/users/#{id.to_s}")
        User.from_json body
    end
end